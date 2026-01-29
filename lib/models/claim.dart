import 'package:uuid/uuid.dart';
import 'bill.dart';
import 'claim_status.dart';

/// Represents an insurance claim with all associated data.
/// 
/// A claim contains patient information, policy details, bills,
/// payment information, and status tracking.
class Claim {
  /// Unique identifier for the claim
  final String id;
  
  /// Name of the patient
  final String patientName;
  
  /// Insurance policy number
  final String policyNumber;
  
  /// Date when the claim was filed
  final DateTime claimDate;
  
  /// List of bills associated with this claim
  final List<Bill> bills;
  
  /// Amount paid in advance by the patient
  final double advancePaid;
  
  /// Amount that has been settled/paid out
  final double settlementAmount;
  
  /// Current status of the claim
  final ClaimStatus status;
  
  /// Timestamp when the claim was created
  final DateTime createdAt;
  
  /// Timestamp when the claim was last updated
  final DateTime updatedAt;

  Claim({
    String? id,
    required this.patientName,
    required this.policyNumber,
    required this.claimDate,
    List<Bill>? bills,
    this.advancePaid = 0.0,
    this.settlementAmount = 0.0,
    this.status = ClaimStatus.draft,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        bills = bills ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ============ CALCULATED PROPERTIES ============

  /// Calculates the total amount of all bills
  double get totalBillAmount {
    if (bills.isEmpty) return 0.0;
    return bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  /// Calculates the pending amount to be paid
  /// Formula: Total Bill Amount - Advance Paid - Settlement Amount
  double get pendingAmount {
    final pending = totalBillAmount - advancePaid - settlementAmount;
    // Ensure pending amount is never negative
    return pending < 0 ? 0.0 : pending;
  }

  /// Returns the number of bills in this claim
  int get billCount => bills.length;

  /// Returns true if the claim has any bills
  bool get hasBills => bills.isNotEmpty;

  /// Returns true if the claim is fully settled (pending amount is 0)
  bool get isFullySettled => pendingAmount == 0 && totalBillAmount > 0;

  // ============ STATUS MANAGEMENT ============

  /// Checks if the claim can transition to the given status
  bool canTransitionTo(ClaimStatus newStatus) {
    return status.canTransitionTo(newStatus);
  }

  /// Returns the list of valid next statuses
  List<ClaimStatus> get validNextStatuses => status.validTransitions;

  /// Returns true if the claim can be edited
  bool get isEditable => status.isEditable;

  // ============ BILL MANAGEMENT ============

  /// Returns a new Claim with the bill added
  Claim addBill(Bill bill) {
    return copyWith(
      bills: [...bills, bill],
      updatedAt: DateTime.now(),
    );
  }

  /// Returns a new Claim with the bill updated
  Claim updateBill(Bill updatedBill) {
    final index = bills.indexWhere((b) => b.id == updatedBill.id);
    if (index == -1) return this;
    
    final newBills = List<Bill>.from(bills);
    newBills[index] = updatedBill;
    
    return copyWith(
      bills: newBills,
      updatedAt: DateTime.now(),
    );
  }

  /// Returns a new Claim with the bill removed
  Claim removeBill(String billId) {
    return copyWith(
      bills: bills.where((b) => b.id != billId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Returns the bill with the given ID, or null if not found
  Bill? getBillById(String billId) {
    try {
      return bills.firstWhere((b) => b.id == billId);
    } catch (_) {
      return null;
    }
  }

  // ============ COPY AND SERIALIZATION ============

  /// Creates a copy of this claim with optional modified fields
  Claim copyWith({
    String? id,
    String? patientName,
    String? policyNumber,
    DateTime? claimDate,
    List<Bill>? bills,
    double? advancePaid,
    double? settlementAmount,
    ClaimStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Claim(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      policyNumber: policyNumber ?? this.policyNumber,
      claimDate: claimDate ?? this.claimDate,
      bills: bills ?? List<Bill>.from(this.bills),
      advancePaid: advancePaid ?? this.advancePaid,
      settlementAmount: settlementAmount ?? this.settlementAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converts the claim to a Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'policyNumber': policyNumber,
      'claimDate': claimDate.toIso8601String(),
      'bills': bills.map((b) => b.toJson()).toList(),
      'advancePaid': advancePaid,
      'settlementAmount': settlementAmount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a Claim from a Map (deserialization)
  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      policyNumber: json['policyNumber'] as String,
      claimDate: DateTime.parse(json['claimDate'] as String),
      bills: (json['bills'] as List<dynamic>)
          .map((b) => Bill.fromJson(b as Map<String, dynamic>))
          .toList(),
      advancePaid: (json['advancePaid'] as num).toDouble(),
      settlementAmount: (json['settlementAmount'] as num).toDouble(),
      status: ClaimStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ClaimStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Claim && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Claim(id: $id, patient: $patientName, status: ${status.displayName}, '
        'total: $totalBillAmount, pending: $pendingAmount)';
  }
}
