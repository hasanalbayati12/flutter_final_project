import '../models/flight.dart';
import '../database/database.dart';
import '../database/daos/flight_dao.dart';

/// Handles all data operations for flights.
class FlightRepository {
  late FlightDao _flightDao;
  bool _initialized = false;

  /// Initializes the database and DAO if not already done.
  Future<void> _initializeDatabase() async {
    if (!_initialized) {
      final database = await AppDatabase.getInstance();
      _flightDao = database.flightDao;
      _initialized = true;
    }
  }

  /// Adds a new flight to the database.
  /// Returns the ID of the inserted flight.
  Future<int> insertFlight(Flight flight) async {
    try {
      await _initializeDatabase();
      await _flightDao.insertFlight(flight);

      // Retrieve the last flight to get the auto-generated ID
      final flights = await _flightDao.findAllFlights();
      return flights.isNotEmpty ? flights.last.id! : 0;
    } catch (e) {
      throw Exception('Failed to insert flight: $e');
    }
  }

  /// Retrieves all flights from the database.
  Future<List<Flight>> getAllFlights() async {
    try {
      await _initializeDatabase();
      return await _flightDao.findAllFlights();
    } catch (e) {
      throw Exception('Failed to retrieve flights: $e');
    }
  }

  /// Gets a flight by its ID.
  Future<Flight?> getFlightById(int id) async {
    try {
      await _initializeDatabase();
      return await _flightDao.findFlightById(id);
    } catch (e) {
      throw Exception('Failed to retrieve flight by ID: $e');
    }
  }

  /// Updates an existing flight.
  /// Returns 1 if successful.
  Future<int> updateFlight(Flight flight) async {
    try {
      await _initializeDatabase();
      if (flight.id == null) {
        throw Exception('Cannot update flight: ID is null');
      }
      await _flightDao.updateFlight(flight);
      return 1;
    } catch (e) {
      throw Exception('Failed to update flight: $e');
    }
  }

  /// Deletes a flight by ID.
  /// Returns 1 if successful.
  Future<int> deleteFlight(int id) async {
    try {
      await _initializeDatabase();
      await _flightDao.delete(id);
      return 1;
    } catch (e) {
      throw Exception('Failed to delete flight: $e');
    }
  }

  /// Returns the total number of flights.
  Future<int> getFlightCount() async {
    try {
      await _initializeDatabase();
      return await _flightDao.getFlightCount() ?? 0;
    } catch (e) {
      throw Exception('Failed to get flight count: $e');
    }
  }

  /// Validates a flight before saving or updating.
  /// Throws an exception if any required field is empty.
  bool validateFlight(Flight flight) {
    if (flight.departureCity.trim().isEmpty) {
      throw Exception('Departure city cannot be empty');
    }
    if (flight.destinationCity.trim().isEmpty) {
      throw Exception('Destination city cannot be empty');
    }
    if (flight.departureTime.trim().isEmpty) {
      throw Exception('Departure time cannot be empty');
    }
    if (flight.arrivalTime.trim().isEmpty) {
      throw Exception('Arrival time cannot be empty');
    }

    return true;
  }
}
