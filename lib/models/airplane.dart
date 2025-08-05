import 'package:floor/floor.dart';

/// Airplane data model
@entity
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String type;
  final int seats;
  final String speed;
  final String range;

  /// Create airplane
  Airplane({
    this.id,
    required this.type,
    required this.seats,
    required this.speed,
    required this.range,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'airplane_type': type,
      'passengers': seats,
      'max_speed': speed,
      'range_distance': range,
    };
  }

  /// Create from map
  factory Airplane.fromMap(Map<String, dynamic> map) {
    return Airplane(
      id: map['id'],
      type: map['airplane_type'],
      seats: map['passengers'],
      speed: map['max_speed'],
      range: map['range_distance'],
    );
  }

  /// Copy with changes
  Airplane copyWith({
    int? id,
    String? type,
    int? seats,
    String? speed,
    String? range,
  }) {
    return Airplane(
      id: id ?? this.id,
      type: type ?? this.type,
      seats: seats ?? this.seats,
      speed: speed ?? this.speed,
      range: range ?? this.range,
    );
  }

  /// String representation
  @override
  String toString() {
    return 'Airplane{id: $id, type: $type, seats: $seats, speed: $speed, range: $range}';
  }

  /// Check equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Airplane &&
        other.id == id &&
        other.type == type &&
        other.seats == seats &&
        other.speed == speed &&
        other.range == range;
  }

  /// Get hash code
  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        seats.hashCode ^
        speed.hashCode ^
        range.hashCode;
  }
}
