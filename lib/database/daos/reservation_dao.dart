import 'package:floor/floor.dart';
import '../../models/reservation.dart';

/// Data Access Object for Reservation entities
@dao
abstract class ReservationDao {
  /// Retrieves all reservations from the database
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> findAllReservations();

  /// Retrieves a reservation by ID
  @Query('SELECT * FROM Reservation WHERE id = :id')
  Future<Reservation?> findReservationById(int id);

  /// Inserts a new reservation into the database
  @insert
  Future<void> insertReservation(Reservation reservation);

  /// Updates an existing reservation in the database
  @update
  Future<void> updateReservation(Reservation reservation);

  /// Deletes a reservation by ID
  @Query('DELETE FROM Reservation WHERE id = :id')
  Future<void> delete(int id);

  /// Gets count of all reservations
  @Query('SELECT COUNT(*) FROM Reservation')
  Future<int?> getReservationCount();
}