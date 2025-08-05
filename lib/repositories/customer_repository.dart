import '../models/customer.dart';
import '../database/database.dart';
import '../database/daos/customer_dao.dart';

/// Repository class for managing Customer data operations
class CustomerRepository {
  late CustomerDao _customerDao;
  bool _initialized = false;

  /// Initializes the database connection
  Future<void> _initializeDatabase() async {
    if (!_initialized) {
      final database = await AppDatabase.getInstance();
      _customerDao = database.customerDao;
      _initialized = true;
    }
  }

  /// Inserts a new customer into the database
  /// [customer] - Customer object to be inserted
  /// Returns the ID of the inserted customer
  /// Throws exception if insertion fails
  Future<int> insertCustomer(Customer customer) async {
    try {
      await _initializeDatabase();

      await _customerDao.insertCustomer(customer);

      // Get the auto-generated ID by finding the last inserted customer
      final customers = await _customerDao.findAllCustomers();
      return customers.isNotEmpty ? customers.last.id! : 0;
    } catch (e) {
      throw Exception('Failed to insert customer: $e');
    }
  }

  /// Retrieves all customers from the database
  /// Returns a list of all Customer objects
  /// Returns empty list if no customers found
  /// Throws exception if retrieval fails
  Future<List<Customer>> getAllCustomers() async {
    try {
      await _initializeDatabase();
      final customers = await _customerDao.findAllCustomers();
      return customers;
    } catch (e) {
      throw Exception('Failed to retrieve customers: $e');
    }
  }

  /// Retrieves a specific customer by ID
  /// [id] - ID of the customer to retrieve
  /// Returns Customer object if found, null otherwise
  /// Throws exception if retrieval fails
  Future<Customer?> getCustomerById(int id) async {
    try {
      await _initializeDatabase();
      return await _customerDao.findCustomerById(id);
    } catch (e) {
      throw Exception('Failed to retrieve customer by ID: $e');
    }
  }

  /// Updates an existing customer in the database
  /// [customer] - Customer object with updated information
  /// Returns 1 if update successful, 0 if customer not found
  /// Throws exception if update fails
  Future<int> updateCustomer(Customer customer) async {
    try {
      await _initializeDatabase();
      if (customer.id == null) {
        throw Exception('Cannot update customer: ID is null');
      }
      await _customerDao.updateCustomer(customer);
      return 1;
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  /// Deletes a customer from the database
  /// [id] - ID of the customer to delete
  /// Returns 1 if deletion successful, 0 if customer not found
  /// Throws exception if deletion fails
  Future<int> deleteCustomer(int id) async {
    try {
      await _initializeDatabase();
      await _customerDao.delete(id);
      return 1;
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  /// Searches customers by name
  /// [searchTerm] - Term to search in first name and last name
  /// Returns list of customers matching the search term
  /// Case-insensitive search
  Future<List<Customer>> searchCustomers(String searchTerm) async {
    try {
      await _initializeDatabase();
      final allCustomers = await getAllCustomers();
      final term = searchTerm.toLowerCase();
      return allCustomers.where((customer) =>
      customer.firstName.toLowerCase().contains(term) ||
          customer.lastName.toLowerCase().contains(term) ||
          customer.fullName.toLowerCase().contains(term)).toList();
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  /// Gets the count of total customers
  /// Returns the number of customers in the database
  Future<int> getCustomerCount() async {
    try {
      await _initializeDatabase();
      return await _customerDao.getCustomerCount() ?? 0;
    } catch (e) {
      throw Exception('Failed to get customer count: $e');
    }
  }

  /// Validates customer data before database operations
  /// [customer] - Customer object to validate
  /// Returns true if valid, throws exception with details if invalid
  bool validateCustomer(Customer customer) {
    if (customer.firstName.trim().isEmpty) {
      throw Exception('First name cannot be empty');
    }
    if (customer.lastName.trim().isEmpty) {
      throw Exception('Last name cannot be empty');
    }
    if (customer.address.trim().isEmpty) {
      throw Exception('Address cannot be empty');
    }
    if (customer.dateOfBirth.trim().isEmpty) {
      throw Exception('Date of birth cannot be empty');
    }

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(customer.dateOfBirth)) {
      throw Exception('Date of birth must be in YYYY-MM-DD format');
    }

    return true;
  }
}