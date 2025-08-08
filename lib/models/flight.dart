import 'package:floor/floor.dart';

/// Flight data model representing a flight route in the airline system
/// This model handles flight information including departure/arrival details
/// and provides serialization methods for database storage
@entity
class Flight {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String departureCity;
  final String destinationCity;
  final String departureTime;
  final String arrivalTime;

  /// Creates a new Flight instance
  ///
  /// [id] - Unique identifier (null for new flights, Floor will auto-assign)
  /// [departureCity] - City of departure
  /// [destinationCity] - City of arrival
  /// [departureTime] - Departure time in 24-hour format
  /// [arrivalTime] - Arrival time in 24-hour format
  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });

  /// Converts Flight object to Map for database storage
  /// Returns a Map<String, dynamic> suitable for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departure_city': departureCity,
      'destination_city': destinationCity,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
    };
  }

  /// Creates Flight object from database Map
  ///
  /// [map] - Map containing flight data from database
  /// Returns a Flight instance with populated fields
  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'],
      departureCity: map['departure_city'],
      destinationCity: map['destination_city'],
      departureTime: map['departure_time'],
      arrivalTime: map['arrival_time'],
    );
  }

  /// Returns flight route as a string
  String get route => '$departureCity → $destinationCity';

  /// Returns flight duration
  String get schedule => 'Depart: $departureTime • Arrive: $arrivalTime';

  /// Creates a copy of this flight
  Flight copyWith({
    int? id,
    String? departureCity,
    String? destinationCity,
    String? departureTime,
    String? arrivalTime,
  }) {
    return Flight(
      id: id ?? this.id,
      departureCity: departureCity ?? this.departureCity,
      destinationCity: destinationCity ?? this.destinationCity,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  /// String representation of flight
  @override
  String toString() {
    return 'Flight{id: $id, departureCity: $departureCity, destinationCity: $destinationCity, departureTime: $departureTime, arrivalTime: $arrivalTime}';
  }

  /// Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Flight &&
        other.id == id &&
        other.departureCity == departureCity &&
        other.destinationCity == destinationCity &&
        other.departureTime == departureTime &&
        other.arrivalTime == arrivalTime;
  }

  /// Hash code for flight
  @override
  int get hashCode {
    return id.hashCode ^
    departureCity.hashCode ^
    destinationCity.hashCode ^
    departureTime.hashCode ^
    arrivalTime.hashCode;
  }
}