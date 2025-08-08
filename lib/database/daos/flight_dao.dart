import 'package:floor/floor.dart';
import '../../models/flight.dart';

/// DAO for accessing flight records in the database.

@dao
abstract class FlightDao {
  /// Returns all flights.
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> findAllFlights();

  /// Returns a flight by its ID.
  @Query('SELECT * FROM Flight WHERE id = :id')
  Future<Flight?> findFlightById(int id);

  /// Inserts a new flight.
  @insert
  Future<void> insertFlight(Flight flight);

  /// Updates an existing flight.
  @update
  Future<void> updateFlight(Flight flight);

  /// Deletes a flight by ID.
  @Query('DELETE FROM Flight WHERE id = :id')
  Future<void> delete(int id);

  /// Returns the total number of flights.
  @Query('SELECT COUNT(*) FROM Flight')
  Future<int?> getFlightCount();
}
