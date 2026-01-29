import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Provider class for managing insurance claims state with Firebase Firestore.
/// 
/// This class handles all CRUD operations for claims with real-time sync support.
/// Uses a shared collection for all users (no authentication required).
class ClaimsProvider extends ChangeNotifier {
  /// Internal list of all claims
  List<Claim> _claims = [];

  /// Error message if any operation fails
  String? _errorMessage;

  /// Flag to track if initial data has been loaded
  bool _isInitialized = false;

  /// Flag to track loading state
  bool _isLoading = false;

  /// Subscription to Firestore stream
  StreamSubscription<QuerySnapshot>? _claimsSubscription;

  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection name for claims
  static const String _collectionName = 'claims';

  /// Constructor
  ClaimsProvider() {
    _initializeFirestore();
  }

  /// Initialize Firestore and start listening to changes
  void _initializeFirestore() {
    _isLoading = true;
    notifyListeners();

    // Listen to claims collection for real-time updates
    _claimsSubscription = _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _claims = snapshot.docs.map((doc) {
          final data = doc.data();
          return Claim.fromJson(data);
        }).toList();
        _isInitialized = true;
        _isLoading = false;
        
        // Auto-add sample data if collection is empty
        if (_claims.isEmpty) {
          _addSampleDataToFirestore();
        }
        
        notifyListeners();
      },
      onError: (error) {
        print('Firestore error: $error');
        _setError('Failed to load claims from cloud');
        _isLoading = false;
        // Fallback to localStorage
        _loadFromLocalStorage();
      },
    );
  }

  /// Add sample data to Firestore automatically
  Future<void> _addSampleDataToFirestore() async {
    final sampleClaims = _generateSampleClaims();
    final batch = _firestore.batch();
    
    for (final claim in sampleClaims) {
      batch.set(
        _firestore.collection(_collectionName).doc(claim.id),
        claim.toJson(),
      );
    }
    
    try {
      await batch.commit();
      print('Sample data added to Firestore');
    } catch (e) {
      print('Failed to add sample data: $e');
    }
  }

  /// Fallback to localStorage if Firestore fails
  void _loadFromLocalStorage() {
    final stored = StorageService.loadClaims();
    if (stored.isNotEmpty) {
      _claims = stored;
    } else {
      _claims = _generateSampleClaims();
      _saveToLocalStorage();
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Persist claims to localStorage as backup
  void _saveToLocalStorage() {
    StorageService.saveClaims(_claims);
  }

  /// Dispose resources
  @override
  void dispose() {
    _claimsSubscription?.cancel();
    super.dispose();
  }

  // ============ GETTERS ============

  /// Returns an unmodifiable list of all claims
  List<Claim> get claims => List.unmodifiable(_claims);

  /// Returns the current error message, if any
  String? get errorMessage => _errorMessage;

  /// Returns true if there are no claims
  bool get isEmpty => _claims.isEmpty;

  /// Returns the total number of claims
  int get claimCount => _claims.length;

  /// Returns true if provider has been initialized
  bool get isInitialized => _isInitialized;

  /// Returns true if data is being loaded
  bool get isLoading => _isLoading;

  /// Returns true if using Firestore (always true now)
  bool get isUsingFirestore => true;

  // ============ COMPUTED STATISTICS ============

  /// Returns claims filtered by status
  List<Claim> getClaimsByStatus(ClaimStatus status) {
    return _claims.where((c) => c.status == status).toList();
  }

  /// Returns the count of claims by status
  Map<ClaimStatus, int> get claimCountByStatus {
    final map = <ClaimStatus, int>{};
    for (final status in ClaimStatus.values) {
      map[status] = _claims.where((c) => c.status == status).length;
    }
    return map;
  }

  /// Returns the total value of all claims
  double get totalClaimsValue {
    return _claims.fold(0.0, (sum, claim) => sum + claim.totalBillAmount);
  }

  /// Returns the total pending amount across all claims
  double get totalPendingAmount {
    return _claims.fold(0.0, (sum, claim) => sum + claim.pendingAmount);
  }

  /// Returns the total settled amount across all claims
  double get totalSettledAmount {
    return _claims.fold(0.0, (sum, claim) => sum + claim.settlementAmount);
  }

  // ============ CLAIM CRUD OPERATIONS ============

  /// Retrieves a claim by its ID
  Claim? getClaimById(String id) {
    try {
      return _claims.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Creates a new claim and adds it to Firestore
  Future<Claim> createClaim({
    required String patientName,
    required String policyNumber,
    required DateTime claimDate,
    List<Bill>? bills,
    double advancePaid = 0.0,
    double settlementAmount = 0.0,
  }) async {
    _clearError();
    
    final claim = Claim(
      patientName: patientName,
      policyNumber: policyNumber,
      claimDate: claimDate,
      bills: bills ?? [],
      advancePaid: advancePaid,
      settlementAmount: settlementAmount,
      status: ClaimStatus.draft,
    );

    try {
      await _firestore.collection(_collectionName).doc(claim.id).set(claim.toJson());
    } catch (e) {
      _setError('Failed to create claim: $e');
      // Fallback: add locally
      _claims.insert(0, claim);
      _saveToLocalStorage();
      notifyListeners();
    }
    
    return claim;
  }

  /// Updates an existing claim
  Future<bool> updateClaim(Claim updatedClaim) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == updatedClaim.id);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    // Only allow editing if claim is in draft status
    if (!_claims[index].isEditable) {
      _setError('Cannot edit claim that is not in draft status');
      return false;
    }

    final updated = updatedClaim.copyWith(updatedAt: DateTime.now());

    try {
      await _firestore.collection(_collectionName).doc(updated.id).update(updated.toJson());
    } catch (e) {
      _setError('Failed to update claim: $e');
      return false;
    }
    
    return true;
  }

  /// Deletes a claim by ID
  Future<bool> deleteClaim(String claimId) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    // Only allow deleting if claim is in draft status
    if (!_claims[index].isEditable) {
      _setError('Cannot delete claim that is not in draft status');
      return false;
    }

    try {
      await _firestore.collection(_collectionName).doc(claimId).delete();
    } catch (e) {
      _setError('Failed to delete claim: $e');
      return false;
    }
    
    return true;
  }

  // ============ STATUS TRANSITIONS ============

  /// Transitions a claim to a new status
  Future<bool> transitionClaimStatus(String claimId, ClaimStatus newStatus) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    final claim = _claims[index];
    
    // Validate the transition
    if (!claim.canTransitionTo(newStatus)) {
      _setError(
        'Invalid status transition from ${claim.status.displayName} to ${newStatus.displayName}'
      );
      return false;
    }

    // Perform the transition
    final updated = claim.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    try {
      await _firestore.collection(_collectionName).doc(claimId).update(updated.toJson());
    } catch (e) {
      _setError('Failed to update status: $e');
      return false;
    }
    
    return true;
  }

  // ============ BILL MANAGEMENT ============

  /// Adds a bill to a claim
  Future<bool> addBillToClaim(String claimId, Bill bill) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    if (!_claims[index].isEditable) {
      _setError('Cannot add bills to a claim that is not in draft status');
      return false;
    }

    final updated = _claims[index].addBill(bill);

    try {
      await _firestore.collection(_collectionName).doc(claimId).update(updated.toJson());
    } catch (e) {
      _setError('Failed to add bill: $e');
      return false;
    }
    
    return true;
  }

  /// Updates a bill in a claim
  Future<bool> updateBillInClaim(String claimId, Bill updatedBill) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    if (!_claims[index].isEditable) {
      _setError('Cannot update bills in a claim that is not in draft status');
      return false;
    }

    final updated = _claims[index].updateBill(updatedBill);

    try {
      await _firestore.collection(_collectionName).doc(claimId).update(updated.toJson());
    } catch (e) {
      _setError('Failed to update bill: $e');
      return false;
    }
    
    return true;
  }

  /// Removes a bill from a claim
  Future<bool> removeBillFromClaim(String claimId, String billId) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    if (!_claims[index].isEditable) {
      _setError('Cannot remove bills from a claim that is not in draft status');
      return false;
    }

    final updated = _claims[index].removeBill(billId);

    try {
      await _firestore.collection(_collectionName).doc(claimId).update(updated.toJson());
    } catch (e) {
      _setError('Failed to remove bill: $e');
      return false;
    }
    
    return true;
  }

  // ============ PAYMENT MANAGEMENT ============

  /// Updates the advance paid amount for a claim
  Future<bool> updateAdvancePaid(String claimId, double amount) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    if (!_claims[index].isEditable) {
      _setError('Cannot update advance in a claim that is not in draft status');
      return false;
    }

    if (amount < 0) {
      _setError('Advance amount cannot be negative');
      return false;
    }

    if (amount > _claims[index].totalBillAmount) {
      _setError('Advance amount cannot exceed total bill amount');
      return false;
    }

    final updated = _claims[index].copyWith(
      advancePaid: amount,
      updatedAt: DateTime.now(),
    );

    try {
      await _firestore.collection(_collectionName).doc(claimId).update(updated.toJson());
    } catch (e) {
      _setError('Failed to update advance: $e');
      return false;
    }
    
    return true;
  }

  /// Updates the settlement amount for a claim
  Future<bool> updateSettlementAmount(String claimId, double amount) async {
    _clearError();
    
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) {
      _setError('Claim not found');
      return false;
    }

    final claim = _claims[index];

    if (claim.status != ClaimStatus.draft &&
        claim.status != ClaimStatus.approved &&
        claim.status != ClaimStatus.partiallysettled) {
      _setError('Cannot update settlement in current claim status');
      return false;
    }

    if (amount < 0) {
      _setError('Settlement amount cannot be negative');
      return false;
    }

    final maxSettlement = claim.totalBillAmount - claim.advancePaid;
    if (amount > maxSettlement) {
      _setError('Settlement amount cannot exceed pending amount');
      return false;
    }

    final updated = claim.copyWith(
      settlementAmount: amount,
      updatedAt: DateTime.now(),
    );

    try {
      await _firestore.collection(_collectionName).doc(claimId).update(updated.toJson());
    } catch (e) {
      _setError('Failed to update settlement: $e');
      return false;
    }
    
    return true;
  }

  // ============ SEARCH AND FILTER ============

  /// Searches claims by patient name or policy number
  List<Claim> searchClaims(String query) {
    if (query.isEmpty) return claims;
    
    final lowerQuery = query.toLowerCase();
    return _claims.where((c) =>
      c.patientName.toLowerCase().contains(lowerQuery) ||
      c.policyNumber.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Filters claims by multiple criteria
  List<Claim> filterClaims({
    ClaimStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    double? minAmount,
    double? maxAmount,
  }) {
    return _claims.where((claim) {
      if (status != null && claim.status != status) return false;
      if (fromDate != null && claim.claimDate.isBefore(fromDate)) return false;
      if (toDate != null && claim.claimDate.isAfter(toDate)) return false;
      if (minAmount != null && claim.totalBillAmount < minAmount) return false;
      if (maxAmount != null && claim.totalBillAmount > maxAmount) return false;
      return true;
    }).toList();
  }

  /// Returns claims sorted by a specified field
  List<Claim> getSortedClaims({
    required ClaimSortField sortBy,
    bool ascending = true,
  }) {
    final sorted = List<Claim>.from(_claims);
    sorted.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case ClaimSortField.patientName:
          comparison = a.patientName.compareTo(b.patientName);
          break;
        case ClaimSortField.claimDate:
          comparison = a.claimDate.compareTo(b.claimDate);
          break;
        case ClaimSortField.totalAmount:
          comparison = a.totalBillAmount.compareTo(b.totalBillAmount);
          break;
        case ClaimSortField.pendingAmount:
          comparison = a.pendingAmount.compareTo(b.pendingAmount);
          break;
        case ClaimSortField.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case ClaimSortField.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case ClaimSortField.updatedAt:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  // ============ HELPER METHODS ============

  /// Sets an error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears the error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Clears all claims
  Future<void> clearAllClaims() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection(_collectionName).get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Adds sample data for testing/demo purposes
  Future<void> addSampleData() async {
    if (_claims.isEmpty) {
      final sampleClaims = _generateSampleClaims();
      final batch = _firestore.batch();
      
      for (final claim in sampleClaims) {
        batch.set(
          _firestore.collection(_collectionName).doc(claim.id),
          claim.toJson(),
        );
      }
      
      await batch.commit();
    }
  }

  /// Generates sample claims for demonstration
  List<Claim> _generateSampleClaims() {
    return [
      Claim(
        patientName: 'Rajesh Kumar',
        policyNumber: 'POL123456',
        claimDate: DateTime.now().subtract(const Duration(days: 5)),
        bills: [
          Bill(description: 'Consultation Fee', amount: 500.0),
          Bill(description: 'Blood Tests', amount: 1200.0),
          Bill(description: 'X-Ray', amount: 800.0),
        ],
        advancePaid: 500.0,
        status: ClaimStatus.draft,
      ),
      Claim(
        patientName: 'Priya Sharma',
        policyNumber: 'POL789012',
        claimDate: DateTime.now().subtract(const Duration(days: 10)),
        bills: [
          Bill(description: 'Surgery', amount: 50000.0),
          Bill(description: 'Hospital Stay (3 days)', amount: 15000.0),
          Bill(description: 'Medications', amount: 5000.0),
        ],
        advancePaid: 20000.0,
        status: ClaimStatus.submitted,
      ),
      Claim(
        patientName: 'Amit Patel',
        policyNumber: 'POL345678',
        claimDate: DateTime.now().subtract(const Duration(days: 15)),
        bills: [
          Bill(description: 'Emergency Treatment', amount: 25000.0),
          Bill(description: 'ICU Charges', amount: 30000.0),
        ],
        advancePaid: 10000.0,
        settlementAmount: 0.0,
        status: ClaimStatus.approved,
      ),
      Claim(
        patientName: 'Sunita Verma',
        policyNumber: 'POL901234',
        claimDate: DateTime.now().subtract(const Duration(days: 20)),
        bills: [
          Bill(description: 'Chemotherapy Session 1', amount: 40000.0),
          Bill(description: 'Chemotherapy Session 2', amount: 40000.0),
          Bill(description: 'Supportive Care', amount: 10000.0),
        ],
        advancePaid: 30000.0,
        settlementAmount: 30000.0,
        status: ClaimStatus.partiallysettled,
      ),
      Claim(
        patientName: 'Vikram Singh',
        policyNumber: 'POL567890',
        claimDate: DateTime.now().subtract(const Duration(days: 30)),
        bills: [
          Bill(description: 'Appendix Surgery', amount: 35000.0),
          Bill(description: 'Hospital Stay', amount: 10000.0),
          Bill(description: 'Post-op Medications', amount: 3000.0),
        ],
        advancePaid: 15000.0,
        settlementAmount: 33000.0,
        status: ClaimStatus.settled,
      ),
      Claim(
        patientName: 'Meera Nair',
        policyNumber: 'POL234567',
        claimDate: DateTime.now().subtract(const Duration(days: 25)),
        bills: [
          Bill(description: 'Cosmetic Procedure', amount: 75000.0),
        ],
        advancePaid: 0.0,
        status: ClaimStatus.rejected,
      ),
      // Additional diverse claims for better visualization
      Claim(
        patientName: 'Arjun Reddy',
        policyNumber: 'POL112233',
        claimDate: DateTime.now().subtract(const Duration(days: 2)),
        bills: [
          Bill(description: 'MRI Scan', amount: 8500.0),
          Bill(description: 'Neurologist Consultation', amount: 1500.0),
          Bill(description: 'Prescription Medicines', amount: 2200.0),
        ],
        advancePaid: 3000.0,
        status: ClaimStatus.draft,
      ),
      Claim(
        patientName: 'Kavita Gupta',
        policyNumber: 'POL445566',
        claimDate: DateTime.now().subtract(const Duration(days: 8)),
        bills: [
          Bill(description: 'Cardiac Surgery', amount: 150000.0),
          Bill(description: 'ICU Stay (5 days)', amount: 75000.0),
          Bill(description: 'Post-Surgery Care', amount: 25000.0),
          Bill(description: 'Medications', amount: 15000.0),
        ],
        advancePaid: 100000.0,
        status: ClaimStatus.submitted,
      ),
      Claim(
        patientName: 'Rahul Mehta',
        policyNumber: 'POL778899',
        claimDate: DateTime.now().subtract(const Duration(days: 12)),
        bills: [
          Bill(description: 'Knee Replacement Surgery', amount: 200000.0),
          Bill(description: 'Hospital Stay (7 days)', amount: 35000.0),
          Bill(description: 'Physiotherapy (10 sessions)', amount: 15000.0),
        ],
        advancePaid: 80000.0,
        settlementAmount: 120000.0,
        status: ClaimStatus.partiallysettled,
      ),
      Claim(
        patientName: 'Ananya Krishnan',
        policyNumber: 'POL334455',
        claimDate: DateTime.now().subtract(const Duration(days: 18)),
        bills: [
          Bill(description: 'Maternity - Delivery', amount: 45000.0),
          Bill(description: 'Hospital Stay (3 days)', amount: 18000.0),
          Bill(description: 'Newborn Care', amount: 8000.0),
        ],
        advancePaid: 20000.0,
        settlementAmount: 51000.0,
        status: ClaimStatus.settled,
      ),
      Claim(
        patientName: 'Deepak Joshi',
        policyNumber: 'POL667788',
        claimDate: DateTime.now().subtract(const Duration(days: 3)),
        bills: [
          Bill(description: 'Diabetes Checkup', amount: 3500.0),
          Bill(description: 'Blood Sugar Tests', amount: 800.0),
          Bill(description: 'Eye Examination', amount: 1200.0),
          Bill(description: 'Monthly Insulin Supply', amount: 2500.0),
        ],
        advancePaid: 0.0,
        status: ClaimStatus.approved,
      ),
      Claim(
        patientName: 'Sneha Agarwal',
        policyNumber: 'POL990011',
        claimDate: DateTime.now().subtract(const Duration(days: 35)),
        bills: [
          Bill(description: 'Dental Implants (4 units)', amount: 120000.0),
          Bill(description: 'Bone Grafting', amount: 25000.0),
        ],
        advancePaid: 50000.0,
        status: ClaimStatus.rejected,
      ),
      Claim(
        patientName: 'Mohammed Farooq',
        policyNumber: 'POL223344',
        claimDate: DateTime.now().subtract(const Duration(days: 7)),
        bills: [
          Bill(description: 'Dialysis Session 1', amount: 5000.0),
          Bill(description: 'Dialysis Session 2', amount: 5000.0),
          Bill(description: 'Dialysis Session 3', amount: 5000.0),
          Bill(description: 'Nephrologist Consultation', amount: 2000.0),
          Bill(description: 'Lab Tests', amount: 3500.0),
        ],
        advancePaid: 8000.0,
        status: ClaimStatus.submitted,
      ),
    ];
  }
}

/// Enum for sorting claims
enum ClaimSortField {
  patientName,
  claimDate,
  totalAmount,
  pendingAmount,
  status,
  createdAt,
  updatedAt,
}
