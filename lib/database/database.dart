import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/customer.dart';
import 'daos/customer_dao.dart';

part 'database.g.dart';

///Main database class for the Flutter project
///Uses Floor SQLite for data persistence
@Database(version: 1, entities: [Customer])
abstract class AppDatabase extends FloorDatabase{
  /// Provides access to customer database operations
  CustomerDao get customerDao;

  /// Singleton instance for database access
static AppDatabase? _instance;


}