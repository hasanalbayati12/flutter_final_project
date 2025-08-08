import 'package:floor/floor.dart';
import '../../models/flight.dart';

/// Data Access Object for Flight entities
@dao
abstract class FlightDao {
  /// Retrieves all flights from the database
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> findAllFlights();

  /// Retrieves a flight by ID
  @Query('SELECT * FROM Flight WHERE id = :id')
  Future<Flight?> findFlightById(int id);

  /// Inserts a new flight into the database
  @insert
  Future<void> insertFlight(Flight flight);

  /// Updates an existing flight in the database
  @update
  Future<void> updateFlight(Flight flight);

  /// Deletes a flight by ID
  @Query('DELETE FROM Flight WHERE id = :id')
  Future<void> delete(int id);

  /// Gets count of all flights
  @Query('SELECT COUNT(*) FROM Flight')
  Future<int?> getFlightCount();
}