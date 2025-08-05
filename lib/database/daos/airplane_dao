import 'package:floor/floor.dart';
import '../../models/airplane.dart';

/// Database operations for airplanes
@dao
abstract class AirplaneDao {
  /// Get all airplanes
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> getAll();

  /// Get airplane by id
  @Query('SELECT * FROM Airplane WHERE id = :id')
  Future<Airplane?> getById(int id);

  /// Add new airplane
  @insert
  Future<void> add(Airplane plane);

  /// Update airplane
  @update
  Future<void> update(Airplane plane);

  /// Delete airplane by id
  @Query('DELETE FROM Airplane WHERE id = :id')
  Future<void> remove(int id);

  /// Count all airplanes
  @Query('SELECT COUNT(*) FROM Airplane')
  Future<int?> count();
}
