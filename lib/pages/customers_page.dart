import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';

/// Customer management page for the airline system.
/// Handles adding, viewing, editing, and deleting customers.
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}
/// State class for CustomersPage.
/// Manages customer data, form controllers, and UI state.
class _CustomersPageState extends State<CustomersPage> {
  final CustomerRepository _repository = CustomerRepository();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = true;
  bool _isAddingNew = false;

  // Form controllers for customer input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }
  /// Closes the details view and returns to the customer list.
  void _closeDetails() {
    _clearForm();
  }