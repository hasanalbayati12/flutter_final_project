import 'package:floor/floor.dart';
import '../../models/airplane.dart';

/// Data Access Object (DAO) for Airplane entity
/// Provides methods to interact with the Airplane table in the database
/// This interface defines the methods for querying and manipulating Airplane data
/// It includes methods for finding all airplanes, finding an airplane by ID,
/// inserting a new airplane, updating an existing airplane, deleting an airplane,
/// and getting the count of airplanes in the database.
@dao
abstract class AirplaneDao {
  
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> findAllAirplanes();
  
  @Query('SELECT * FROM Airplane WHERE id = :id')
  Future<Airplane?> findAirplaneById(int id);
  
  @insert
  Future<void> insertAirplane(Airplane airplane);
  
  @update
  Future<void> updateAirplane(Airplane airplane);
  
  @Query('DELETE FROM Airplane WHERE id = :id')
  Future<void> delete(int id);
  
  @Query('SELECT COUNT(*) FROM Airplane')
  Future<int?> getAirplaneCount();
}
