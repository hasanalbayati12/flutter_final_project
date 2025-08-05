import '../models/airplane.dart';
import '../database/database.dart';
import '../database/daos/airplane_dao.dart';

/// Repository for airplane data operations
class AirplaneRepository {
  late AirplaneDao _dao;
  bool _init = false;

  /// Initialize database connection
  Future<void> _initDb() async {
    if (!_init) {
      final db = await AppDatabase.getInstance();
      _dao = db.airplaneDao;
      _init = true;
    }
  }

  /// Insert new airplane
  Future<int> insertAirplane(Airplane plane) async {
    try {
      await _initDb();
      await _dao.add(plane);
      final planes = await _dao.getAll();
      return planes.isNotEmpty ? planes.last.id! : 0;
    } catch (e) {
      throw Exception('Failed to insert plane: $e');
    }
  }

  /// Get all airplanes
  Future<List<Airplane>> getAllAirplanes() async {
    try {
      await _initDb();
      return await _dao.getAll();
    } catch (e) {
      throw Exception('Failed to get planes: $e');
    }
  }

  /// Get airplane by ID
  Future<Airplane?> getAirplaneById(int id) async {
    try {
      await _initDb();
      return await _dao.getById(id);
    } catch (e) {
      throw Exception('Failed to get plane by ID: $e');
    }
  }

  /// Update airplane
  Future<int> updateAirplane(Airplane plane) async {
    try {
      await _initDb();
      if (plane.id == null) {
        throw Exception('Cannot update plane: ID is null');
      }
      await _dao.update(plane);
      return 1;
    } catch (e) {
      throw Exception('Failed to update plane: $e');
    }
  }

  /// Delete airplane
  Future<int> deleteAirplane(int id) async {
    try {
      await _initDb();
      await _dao.remove(id);
      return 1;
    } catch (e) {
      throw Exception('Failed to delete plane: $e');
    }
  }

  /// Get airplane count
  Future<int> getAirplaneCount() async {
    try {
      await _initDb();
      return await _dao.count() ?? 0;
    } catch (e) {
      throw Exception('Failed to get plane count: $e');
    }
  }

  /// Validate airplane data
  bool validateAirplane(Airplane plane) {
    if (plane.type.trim().isEmpty) {
      throw Exception('Plane type cannot be empty');
    }
    if (plane.seats <= 0) {
      throw Exception('Seat count must be greater than 0');
    }
    if (plane.speed.trim().isEmpty) {
      throw Exception('Speed cannot be empty');
    }
    if (plane.range.trim().isEmpty) {
      throw Exception('Range cannot be empty');
    }
    return true;
  }
}
