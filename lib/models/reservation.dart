import 'package:floor/floor.dart';

/// Reservation data model representing a booking in the airline system
/// This model handles reservation information linking customers to flights
/// and provides serialization methods for database storage
@entity
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int customerId;
  final int flightId;
  final String flightDate;
  final String reservationName;

  /// Creates a new Reservation instance
  ///
  /// [id] - Unique identifier (null for new reservations, Floor will auto-assign)
  /// [customerId] - ID of the customer making the reservation
  /// [flightId] - ID of the flight being reserved
  /// [flightDate] - Date of the flight in YYYY-MM-DD format
  /// [reservationName] - Name/description of the reservation
  Reservation({
    this.id,
    required this.customerId,
    required this.flightId,
    required this.flightDate,
    required this.reservationName,
  });

  /// Converts Reservation object to Map for database storage
  /// Returns a Map<String, dynamic> suitable for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'flight_id': flightId,
      'flight_date': flightDate,
      'reservation_name': reservationName,
    };
  }

  /// Creates Reservation object from database Map
  ///
  /// [map] - Map containing reservation data from database
  /// Returns a Reservation instance with populated fields
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      customerId: map['customer_id'],
      flightId: map['flight_id'],
      flightDate: map['flight_date'],
      reservationName: map['reservation_name'],
    );
  }

  /// Returns reservation summary
  String get summary => '$reservationName (Customer: $customerId, Flight: $flightId)';

  /// Creates a copy of this reservation
  Reservation copyWith({
    int? id,
    int? customerId,
    int? flightId,
    String? flightDate,
    String? reservationName,
  }) {
    return Reservation(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      flightId: flightId ?? this.flightId,
      flightDate: flightDate ?? this.flightDate,
      reservationName: reservationName ?? this.reservationName,
    );
  }

  /// String representation of reservation
  @override
  String toString() {
    return 'Reservation{id: $id, customerId: $customerId, flightId: $flightId, flightDate: $flightDate, reservationName: $reservationName}';
  }

  /// Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation &&
        other.id == id &&
        other.customerId == customerId &&
        other.flightId == flightId &&
        other.flightDate == flightDate &&
        other.reservationName == reservationName;
  }

  /// Hash code for reservation
  @override
  int get hashCode {
    return id.hashCode ^
    customerId.hashCode ^
    flightId.hashCode ^
    flightDate.hashCode ^
    reservationName.hashCode;
  }
}