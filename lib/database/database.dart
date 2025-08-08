import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/customer.dart';
import '../models/airplane.dart';
import '../models/flight.dart';
import '../models/reservation.dart';
import 'daos/customer_dao.dart';
import 'daos/airplane_dao.dart';
import 'daos/flight_dao.dart';
import 'daos/reservation_dao.dart';

part 'database.g.dart';

/// Main database class
@Database(version: 1, entities: [Customer, Airplane, Flight, Reservation])
abstract class AppDatabase extends FloorDatabase {
  CustomerDao get customerDao;
  AirplaneDao get airplaneDao;
  FlightDao get flightDao;
  ReservationDao get reservationDao;

  /// Singleton instance for database access
  static AppDatabase? _instance;

  /// Gets database instance using the pattern from slides
  static Future<AppDatabase> getInstance() async {
    if (_instance == null) {
      try {
        _instance = await $FloorAppDatabase
            .databaseBuilder('database.db')
            .build();
      } catch (e) {
        print('Database initialization error: $e');
        rethrow;
      }
    }
    return _instance!;
  }
}