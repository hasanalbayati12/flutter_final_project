import 'package:floor/floor.dart';
import '../../models/airplane.dart';

/// Data Access Object for Airplane entities
@dao
abstract class AirplaneDao {
  /// Retrieves all airplanes from the database
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> findAllAirplanes();
  /// Retrieves an airplane by ID
  @Query('SELECT * FROM Airplane WHERE id = :id')
  Future<Airplane?> findAirplaneById(int id);
  /// Inserts a new airplane into the database
  @insert
  Future<void> insertAirplane(Airplane airplane);
  /// Updates an existing airplane in the database
  @update
  Future<void> updateAirplane(Airplane airplane);
  /// Deletes an airplane by ID
  @Query('DELETE FROM Airplane WHERE id = :id')
  Future<void> delete(int id);
  /// Gets count of all airplanes
  @Query('SELECT COUNT(*) FROM Airplane')
  Future<int?> getAirplaneCount();
}