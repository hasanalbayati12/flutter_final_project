import 'package:floor/floor.dart';

/// Customer data model representing a customer in the airline system
/// This model handles customer information including personal details
/// and provides serialization methods for database storage
@entity
class Customer {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String firstName;
  final String lastName;
  final String address;
  final String dateOfBirth;


  /// Creates a new Customer instance
  /// [id] - Unique identifier (null for new customers, Floor will auto-assign)
  /// [firstName] - Customer's first name (required)
  /// [lastName] - Customer's last name (required)
  /// [address] - Customer's address (required)
  /// [dateOfBirth] - Customer's date of birth in YYYY-MM-DD format (required)
  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dateOfBirth,
  });

  /// Returns customer's full name
  String get fullName => '$firstName $lastName';

  /// Creates a copy of this customer
  Customer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? address,
    String? dateOfBirth,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  /// String representation of customer
  @override
  String toString() {
    return 'Customer{id: $id, firstName: $firstName, lastName: $lastName, address: $address, dateOfBirth: $dateOfBirth}';
  }

  /// Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.address == address &&
        other.dateOfBirth == dateOfBirth;
  }

  /// Hash code for customer
  @override
  int get hashCode {
    return id.hashCode ^
    firstName.hashCode ^
    lastName.hashCode ^
    address.hashCode ^
    dateOfBirth.hashCode;
  }
}