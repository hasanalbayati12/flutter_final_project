import 'package:floor/floor.dart';

/// Represents an Airplane entity in the database
/// Contains fields for airplane type, passenger capacity, max speed, and range distance
@entity
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String airplaneType;
  final int passengers;
  final String maxSpeed;
  final String rangeDistance;


  /// Constructor for Airplane
  /// [id] - Optional ID for the airplane, auto-generated if null
  /// [airplaneType] - Type of the airplane (e.g., "Boeing 747")
  /// [passengers] - Number of passengers the airplane can carry
  /// [maxSpeed] - Maximum speed of the airplane (e.g., "900 km/h")
  /// [rangeDistance] - Maximum range of the airplane (e.g., "10000 km")
  Airplane({
    this.id,
    required this.airplaneType,
    required this.passengers,
    required this.maxSpeed,
    required this.rangeDistance,
  });

  /// Converts Airplane object to a Map for database storage
  /// Returns a Map with keys matching the database column names
  /// [id] - ID of the airplane
  /// [airplaneType] - Type of the airplane
  /// [passengers] - Number of passengers
  /// [maxSpeed] - Maximum speed of the airplane
  /// [rangeDistance] - Maximum range of the airplane
  /// This method is used to convert the Airplane object into a format suitable for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'airplane_type': airplaneType,
      'passengers': passengers,
      'max_speed': maxSpeed,
      'range_distance': rangeDistance,
    };
  }

  /// Creates an Airplane object from a Map
  factory Airplane.fromMap(Map<String, dynamic> map) {
    return Airplane(
      id: map['id'],
      airplaneType: map['airplane_type'],
      passengers: map['passengers'],
      maxSpeed: map['max_speed'],
      rangeDistance: map['range_distance'],
    );
  }

  /// Creates a copy of the Airplane object with optional new values
  Airplane copyWith({
    int? id,
    String? airplaneType,
    int? passengers,
    String? maxSpeed,
    String? rangeDistance,
  }) {
    return Airplane(
      id: id ?? this.id,
      airplaneType: airplaneType ?? this.airplaneType,
      passengers: passengers ?? this.passengers,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      rangeDistance: rangeDistance ?? this.rangeDistance,
    );
  }

  /// Converts the Airplane object to a string representation
  /// Useful for debugging and logging
  @override
  String toString() {
    return 'Airplane{id: $id, airplaneType: $airplaneType, passengers: $passengers, maxSpeed: $maxSpeed, rangeDistance: $rangeDistance}';
  }

  /// Checks if two Airplane objects are equal
  /// Compares all fields except ID for equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Airplane &&
        other.id == id &&
        other.airplaneType == airplaneType &&
        other.passengers == passengers &&
        other.maxSpeed == maxSpeed &&
        other.rangeDistance == rangeDistance;
  }

  /// Generates a hash code for the Airplane object
  /// Used for collections and comparisons
  @override
  int get hashCode {
    return id.hashCode ^
    airplaneType.hashCode ^
    passengers.hashCode ^
    maxSpeed.hashCode ^
    rangeDistance.hashCode;
  }
}
