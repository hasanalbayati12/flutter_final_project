import '../models/airplane.dart';
import '../database/database.dart';
import '../database/daos/airplane_dao.dart';

/// Repository class for managing the Airplanes data operations
class AirplaneRepository {
  late AirplaneDao _airplaneDao;
  bool _initialized = false;

  /// Initialize db connection
  Future<void> _initializeDatabase() async {
    if (!_initialized) {
      final database = await AppDatabase.getInstance();
      _airplaneDao = database.airplaneDao;
      _initialized = true;
    }
  }

 /// Inserts a new airplane into the database
  /// [airplane] - Airplane object to insert
  /// Returns the auto-generated ID of the inserted airplane
  /// Throws exception if insertion fails
  Future<int> insertAirplane(Airplane airplane) async {
    try {
      await _initializeDatabase();

      await _airplaneDao.insertAirplane(airplane);

      // Validate airplane data before insertion
      final airplanes = await _airplaneDao.findAllAirplanes();
      return airplanes.isNotEmpty ? airplanes.last.id! : 0;
    } catch (e) {
      throw Exception('Failed to insert airplane: $e');
    }
  }

/// Retrieves all airplanes from the database
  /// Returns a list of Airplane objects
  /// Throws exception if retrieval fails
  Future<List<Airplane>> getAllAirplanes() async {
    try {
      await _initializeDatabase();
      final airplanes = await _airplaneDao.findAllAirplanes();
      return airplanes;
    } catch (e) {
      throw Exception('Failed to retrieve airplanes: $e');
    }
  }

  /// Retrieves an airplane by ID
  /// [id] - ID of the airplane to retrieve
  /// Returns an Airplane object if found, null if not found
  /// Throws exception if retrieval fails
  Future<Airplane?> getAirplaneById(int id) async {
    try {
      await _initializeDatabase();
      return await _airplaneDao.findAirplaneById(id);
    } catch (e) {
      throw Exception('Failed to retrieve airplane by ID: $e');
    }
  }

  /// Updates an existing airplane in the database
  /// [airplane] - Airplane object with updated data
  /// Returns 1 if update successful, throws exception if update fails
  Future<int> updateAirplane(Airplane airplane) async {
    try {
      await _initializeDatabase();
      if (airplane.id == null) {
        throw Exception('Cannot update airplane: ID is null');
      }
      await _airplaneDao.updateAirplane(airplane);
      return 1;
    } catch (e) {
      throw Exception('Failed to update airplane: $e');
    }
  }

  /// Deletes an airplane by ID
  /// [id] - ID of the airplane to delete
  /// Returns 1 if deletion successful, throws exception if deletion fails
  Future<int> deleteAirplane(int id) async {
    try {
      await _initializeDatabase();
      await _airplaneDao.delete(id);
      return 1;
    } catch (e) {
      throw Exception('Failed to delete airplane: $e');
    }
  }

  /// Gets the count of all airplanes in the database
  /// Returns the count as an integer, or 0 if no airplanes exist
  Future<int> getAirplaneCount() async {
    try {
      await _initializeDatabase();
      return await _airplaneDao.getAirplaneCount() ?? 0;
    } catch (e) {
      throw Exception('Failed to get airplane count: $e');
    }
  }

  /// Validates the Airplane object before insertion or update
  /// Throws an exception if validation fails
  bool validateAirplane(Airplane airplane) {
    if (airplane.airplaneType.trim().isEmpty) {
      throw Exception('Airplane type cannot be empty');
    }
    if (airplane.passengers <= 0) {
      throw Exception('Passenger count must be greater than 0');
    }
    if (airplane.maxSpeed.trim().isEmpty) {
      throw Exception('Maximum speed cannot be empty');
    }
    if (airplane.rangeDistance.trim().isEmpty) {
      throw Exception('Range distance cannot be empty');
    }

    return true;
  }
}
