import 'package:uuid/uuid.dart';

/// Represents a single bill item within an insurance claim.
/// 
/// Each bill has a unique ID, description, and amount.
/// Bills are immutable - create a new instance to modify.
class Bill {
  /// Unique identifier for the bill
  final String id;
  
  /// Description of the bill (e.g., "X-Ray", "Consultation Fee", "Medication")
  final String description;
  
  /// Amount of the bill in currency units
  final double amount;
  
  /// Timestamp when the bill was created
  final DateTime createdAt;

  Bill({
    String? id,
    required this.description,
    required this.amount,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Creates a copy of this bill with optional modified fields
  Bill copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts the bill to a Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a Bill from a Map (deserialization)
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill &&
        other.id == id &&
        other.description == description &&
        other.amount == amount;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'Bill(id: $id, description: $description, amount: $amount)';
  }
}
