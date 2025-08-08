import 'package:floor/floor.dart';

/// Airplane data model representing an aircraft in the airline fleet
/// This model handles airplane information including specifications
/// and provides serialization methods for database storage
@entity
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String airplaneType;
  final int passengers;
  final String maxSpeed;
  final String rangeDistance;


  /// Creates a new Airplane instance
  ///
  /// [id] - Unique identifier (null for new airplanes, Floor will auto-assign)
  /// [airplaneType] - Type of aircraft (e.g., Boeing 777, Airbus A350)
  /// [passengers] - Maximum passenger capacity
  /// [maxSpeed] - Maximum speed of the aircraft
  /// [rangeDistance] - Maximum flight range
  Airplane({
    this.id,
    required this.airplaneType,
    required this.passengers,
    required this.maxSpeed,
    required this.rangeDistance,
  });

  /// Converts Airplane object to Map for database storage
  /// Returns a Map<String, dynamic> suitable for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'airplane_type': airplaneType,
      'passengers': passengers,
      'max_speed': maxSpeed,
      'range_distance': rangeDistance,
    };
  }

  /// Creates Airplane object from database Map
  ///
  /// [map] - Map containing airplane data from database
  /// Returns an Airplane instance with populated fields
  factory Airplane.fromMap(Map<String, dynamic> map) {
    return Airplane(
      id: map['id'],
      airplaneType: map['airplane_type'],
      passengers: map['passengers'],
      maxSpeed: map['max_speed'],
      rangeDistance: map['range_distance'],
    );
  }

  /// Creates a copy of this airplane
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

  /// String representation of airplane
  @override
  String toString() {
    return 'Airplane{id: $id, airplaneType: $airplaneType, passengers: $passengers, maxSpeed: $maxSpeed, rangeDistance: $rangeDistance}';
  }

  /// Equality comparison
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

  /// Hash code for airplane
  @override
  int get hashCode {
    return id.hashCode ^
    airplaneType.hashCode ^
    passengers.hashCode ^
    maxSpeed.hashCode ^
    rangeDistance.hashCode;
  }
}