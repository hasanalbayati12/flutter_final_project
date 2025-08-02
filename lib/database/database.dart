import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/customer.dart';
import 'daos/customer_dao.dart';

part 'database.g.dart';

/// Main database class for the Customer Management module.
/// Uses Floor SQLite for data persistence following assignment requirements.
@Database(version: 1, entities: [Customer])
abstract class AppDatabase extends FloorDatabase {
  /// Provides access to customer database operations.
  CustomerDao get customerDao;

  /// Singleton instance for database access.
  static AppDatabase? _instance;

  /// Gets the database instance using singleton pattern.
  /// Creates a new database connection if none exists.
  /// Returns the shared database instance for the application.
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