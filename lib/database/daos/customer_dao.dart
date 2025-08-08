import 'package:floor/floor.dart';
import '../../models/customer.dart';

/// Data Access Object for Customer entities
@dao
abstract class CustomerDao {
  /// Retrieves all customers from the database
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> findAllCustomers();

  /// Retrieves a customer by ID
  @Query('SELECT * FROM Customer WHERE id = :id')
  Future<Customer?> findCustomerById(int id);

  /// Inserts a new customer into the database
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Updates an existing customer in the database
  @update
  Future<void> updateCustomer(Customer customer);

  /// Deletes a customer by ID
  @Query('DELETE FROM Customer WHERE id = :id')
  Future<void> delete(int id);

  /// Gets count of all customers
  @Query('SELECT COUNT(*) FROM Customer')
  Future<int?> getCustomerCount();
}