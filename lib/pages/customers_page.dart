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
  /// Loads all customers from the database.
  /// Updates the UI with loading state and error handling.
  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final customers = await _repository.getAllCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading customers: $e');
    }
  }
  /// Loads previously saved customer data from encrypted storage.
  /// Used for the "copy previous" feature.
  Future<void> _loadPreviousCustomerData() async {
    try {
      final firstName = await _prefs.getString('prev_first_name') ?? '';
      final lastName = await _prefs.getString('prev_last_name') ?? '';
      final address = await _prefs.getString('prev_address') ?? '';
      final dateOfBirth = await _prefs.getString('prev_date_of_birth') ?? '';

      if (firstName.isNotEmpty) {
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
        _addressController.text = address;
        _dateOfBirthController.text = dateOfBirth;
      }
    } catch (e) {
      debugPrint('Error loading previous customer data: $e');
    }
  }
  /// Saves current customer data to encrypted storage.
  /// Stores data for future "copy previous" use.
  Future<void> _savePreviousCustomerData() async {
    try {
      await _prefs.setString('prev_first_name', _firstNameController.text);
      await _prefs.setString('prev_last_name', _lastNameController.text);
      await _prefs.setString('prev_address', _addressController.text);
      await _prefs.setString('prev_date_of_birth', _dateOfBirthController.text);
    } catch (e) {
      debugPrint('Error saving previous customer data: $e');
    }
  }

  /// Validates all form fields are filled out.
  /// Shows error dialog if validation fails.
  /// Returns true if all fields are valid.
  bool _validateFields() {
    final localizations = AppLocalizations.of(context);
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _dateOfBirthController.text.trim().isEmpty) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          localizations?.translate('all_fields_required') ?? 'All fields must be filled out.'
      );
      return false;
    }
    return true;
  }
  /// Adds a new customer to the database.
  /// Validates form, saves customer, and refreshes the list.
  Future<void> _addCustomer() async {
    if (!_validateFields()) return;
    final customer = Customer(
      id: null,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      address: _addressController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
    );
    try {
      await _repository.insertCustomer(customer);
      await _savePreviousCustomerData();
      _clearForm();
      _loadCustomers();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('customer_added') ?? 'Customer added successfully!');
    } catch (e) {
      _showSnackBar('Error adding customer: $e');
    }
  }
  /// Updates the currently selected customer.
  /// Validates form, updates database, and refreshes the list.
  Future<void> _updateCustomer() async {
    if (_selectedCustomer == null || !_validateFields()) return;

    final customer = Customer(
      id: _selectedCustomer!.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      address: _addressController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
    );

    try {
      await _repository.updateCustomer(customer);
      _clearForm();
      _loadCustomers();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('customer_updated') ?? 'Customer updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating customer: $e');
    }
  }
  /// Deletes the currently selected customer.
  /// Removes from database and refreshes the list.
  Future<void> _deleteCustomer() async {
    if (_selectedCustomer == null) return;

    try {
      await _repository.deleteCustomer(_selectedCustomer!.id!);
      _clearForm();
      _loadCustomers();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('customer_deleted') ?? 'Customer deleted successfully!');
    } catch (e) {
      _showSnackBar('Error deleting customer: $e');
    }
  }

  /// Clears all form fields and resets selection state.
  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _dateOfBirthController.clear();
    setState(() {
      _selectedCustomer = null;
      _isAddingNew = false;
    });
  }

  /// Shows dialog asking to copy previous data or start blank.
  void _showCopyDataDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('copy_previous_data') ?? 'Copy Previous Data'),
          content: Text(localizations?.translate('copy_previous_question') ??
              'Would you like to copy fields from the previous customer or start with a blank page?'),
          actions: [
            TextButton(
              onPressed: () {
                _clearForm();
                setState(() => _isAddingNew = true);
                Navigator.of(context).pop();
              },
              child: Text(localizations?.translate('blank_page') ?? 'Blank Page'),
            ),
            TextButton(
              onPressed: () {
                _loadPreviousCustomerData();
                setState(() => _isAddingNew = true);
                Navigator.of(context).pop();
              },
              child: Text(localizations?.translate('copy_previous_short') ?? 'Copy Previous'),
            ),
          ],
        );
      },
    );
  }

  /// Shows help dialog with usage instructions.
  void _showHelpDialog() {
    final localizations = AppLocalizations.of(context);
    _showAlertDialog(
      localizations?.translate('help') ?? 'Customer Management Help',
      localizations?.translate('help_content') ??
          'Instructions:\n\n'
              '• Tap "+" to add a new customer\n'
              '• Fill out all required fields\n'
              '• Select a customer from the list to view/edit details\n'
              '• Use Update button to save changes\n'
              '• Use Delete button to remove customer\n'
              '• Choose to copy previous data or start blank',
    );
  }

  /// Shows language selection dialog.
  void _showLanguageDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('language') ?? 'Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(localizations?.translate('english') ?? 'English'),
                leading: const Text('🇺🇸'),
                onTap: () {
                  MyApp.setLocale(context, const Locale('en', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(localizations?.translate('french') ?? 'French'),
                leading: const Text('🇫🇷'),
                onTap: () {
                  MyApp.setLocale(context, const Locale('fr', ''));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(localizations?.translate('spanish') ?? 'Spanish'),
                leading: const Text('🇪🇸'),
                onTap: () {
                  MyApp.setLocale(context, const Locale('es', ''));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }