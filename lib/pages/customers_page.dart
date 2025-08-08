import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';
/// Customer management page implementing all CST2335 assignment requirements.
/// This page provides complete CRUD functionality for customer management with:
/// - ListView displaying user-inserted records (Requirement 1)
/// - TextField and Button for data entry (Requirement 2)
/// - Floor database persistence (Requirement 3)
/// - Responsive phone/tablet layouts (Requirement 4)
/// - AlertDialog and Snackbar notifications (Requirement 5)
/// - EncryptedSharedPreferences for form data (Requirement 6)
/// - ActionBar with ActionItems for help (Requirement 7)
/// - Multi-language support (Requirement 8)
/// - Professional UI design (Requirement 10)
/// - Comprehensive documentation (Requirement 11)
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});
  @override
  State<CustomersPage> createState() => _CustomersPageState();
}
class _CustomersPageState extends State<CustomersPage> {
  final CustomerRepository _repository = CustomerRepository();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = true;
  /// Track if we're adding a new customer.
  bool _isAddingNew = false;
  // Form controllers
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
  /// Closes the details view and returns to the list view.
  /// This is used primarily for phone layout navigation.
  void _closeDetails() {
    _clearForm();
  }
  /// Loads all customers from database following assignment slide patterns.
  /// Implements the ListView initialization pattern from course slides:
  /// 1. Sets loading state for user feedback
  /// 2. Fetches data using repository pattern
  /// 3. Updates UI state with setState()
  /// 4. Handles errors with user-friendly messages
  /// Called in initState() and after CRUD operations to maintain
  /// ListView synchronization with database as demonstrated in slides.
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
  /// Loads previous customer data from EncryptedSharedPreferences.
  /// This allows users to quickly populate form fields with data from
  /// the previously added customer, reducing repetitive data entry.
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
  /// Saves customer data to EncryptedSharedPreferences.
  /// This data can be retrieved later when adding a new customer to
  /// pre-populate form fields with similar information.
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
  /// Validates customer form fields per assignment requirements.
  /// Checks all required fields for customer topic:
  /// - First name: Must not be empty
  /// - Last name: Must not be empty
  /// - Address: Must not be empty
  /// - Date of birth: Must not be empty (YYYY-MM-DD format)
  /// Shows AlertDialog on validation failure (Requirement 5).
  /// Returns true if all fields valid, false otherwise.
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
  /// Validates the form fields, creates a new [Customer] object,
  /// saves it to the database, and saves the data for future use.
  /// Shows a success message on completion.
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
  /// Updates an existing customer in the database.
  /// Validates the form fields and updates the currently selected customer
  /// with the new data. Shows a success message on completion.
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
  /// Deletes the currently selected customer from the database.
  /// Removes the customer from the database and refreshes the customer list.
  /// Shows a success message on completion.
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
  /// Clears all form fields and resets the selected customer state.
  /// This method is used to reset the form when navigating away from
  /// the details view or after completing CRUD operations.
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
  /// Shows a dialog asking whether to copy previous customer data or start blank.
  /// This provides users with the option to either start with a clean form
  /// or pre-populate it with data from the previously added customer.
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
  /// Shows help dialog implementing Requirement 7.
  /// Creates AlertDialog with instructions as specified:
  /// "ActionBar with ActionItems that displays an AlertDialog
  /// with instructions for how to use the interface"
  /// Includes guidance on adding, editing, deleting customers
  /// and using the copy previous data feature.
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
  /// Displays language selection dialog for internationalization.
  /// Implements Requirement 8 (multi-language support) by allowing users
  /// to switch between supported languages:
  /// - English (🇺🇸)
  /// - French (🇫🇷)
  /// - Spanish (🇪🇸)
  /// Uses MyApp.setLocale() to change the application language dynamically
  /// following the internationalization pattern from the course slides.
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
  /// Shows a snack bar with the provided message.
  /// Used to display feedback messages for user actions such as
  /// successful operations or error notifications.
  /// [message] The message to display in the snack bar.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  /// Shows an alert dialog with the specified title and content.
  /// Used for displaying validation errors, help information,
  /// and other important messages to the user.
  /// [title] The title of the alert dialog.
  /// [content] The content/message of the alert dialog.
  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  /// Creates the responsive layout based on screen size and orientation.
  /// Implements Requirement 4 by providing different layouts:
  /// - Tablet/Desktop (>600px landscape): Master-detail side-by-side
  /// - Phone: Full-screen switching between list and details
  /// This follows the responsive design patterns demonstrated in Week 9 lab
  /// using MediaQuery to detect screen characteristics.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    // Determine if we should use tablet layout
    // based on screen width and orientation
    final isTabletLayout = screenWidth > 600 && orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations?.translate('customer_management') ?? 'Customer Management'),
        centerTitle: true,
        actions: [
          // Back button for phone layout when viewing details
          if ((_selectedCustomer != null || _isAddingNew) && !isTabletLayout)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _closeDetails,
              tooltip: 'Back to List',
            ),
          // FIXED: ActionBar ActionItems (Requirement 7)
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _showHelpDialog,
            tooltip: localizations?.translate('help') ?? 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: localizations?.translate('language') ?? 'Language',
          ),
        ],
      ),
      body: isTabletLayout
          ? _buildTabletLayout()
          : _buildPhoneLayout(),
      // FloatingActionButton shows only when not editing or adding new customer
      floatingActionButton: (_selectedCustomer == null && !_isAddingNew)
          ? FloatingActionButton(
        onPressed: _showCopyDataDialog,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
  /// Builds the tablet and desktop layout with side-by-side master-detail view.
  /// Shows the customer list on the left and the form on the right,
  /// providing an efficient workflow for larger screens.
  Widget _buildTabletLayout() {
    final localizations = AppLocalizations.of(context);
    return Row(
      children: [
        // Master panel (Customer List)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${localizations?.translate('customers_count') ?? 'Customers'} (${_customers.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(child: _buildCustomerList()),
            ],
          ),
        ),
        // Detail panel (Customer Form)
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: _buildCustomerForm(),
          ),
        ),
      ],
    );
  }
  /// Builds the phone layout with full-screen switching between list and details.
  /// On phones, this shows either the customer list or the form in full screen,
  /// switching between them based on the current state.
  Widget _buildPhoneLayout() {
    if (_selectedCustomer != null || _isAddingNew) {
      // Show form page in full screen
      return _buildCustomerForm();
    } else {
      // Show list page
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${AppLocalizations.of(context)?.translate('customers_count') ?? 'Customers'} (${_customers.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(child: _buildCustomerList()),
        ],
      );
    }
  }
  /// Builds the customer form widget.
  /// Creates a scrollable form with input fields for customer data
  /// and appropriate action buttons based on the current mode
  /// (add new customer vs. edit existing customer).
  Widget _buildCustomerForm() {
    final localizations = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                (_selectedCustomer == null || _isAddingNew)
                    ? (localizations?.translate('add_new_customer') ?? 'Add New Customer')
                    : (localizations?.translate('edit_customer') ?? 'Edit Customer'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('first_name') ?? 'First Name',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('last_name') ?? 'Last Name',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('address') ?? 'Address',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('date_of_birth') ?? 'Date of Birth (YYYY-MM-DD)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedCustomer == null || _isAddingNew) ...[
                    // Buttons for adding new customer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addCustomer,
                        child: Text(localizations?.translate('submit') ?? 'Submit'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showCopyDataDialog,
                      child: Text(localizations?.translate('copy_previous') ?? 'Copy Previous'),
                    ),
                  ] else ...[
                    // Buttons for editing existing customer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateCustomer,
                        child: Text(localizations?.translate('update') ?? 'Update'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _deleteCustomer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(localizations?.translate('delete') ?? 'Delete'),
                    ),
                    ElevatedButton(
                      onPressed: _clearForm,
                      child: Text(localizations?.translate('clear') ?? 'Clear'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// Builds the customer list widget implementing Requirement 1.
  /// Displays a scrollable ListView of customers using ListView.builder()
  /// as demonstrated in the course slides. Shows loading indicator when
  /// data is being fetched, and an empty state message when no customers exist.
  /// Each list item is a Card with customer information that can be tapped
  /// to select and edit the customer details.
  Widget _buildCustomerList() {
    final localizations = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_customers.isEmpty) {
      return Center(
        child: Text(
          localizations?.translate('no_customers_found') ?? 'No customers found. Add a customer to get started.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        final customer = _customers[index];
        final isSelected = _selectedCustomer?.id == customer.id;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            title: Text('${customer.firstName} ${customer.lastName}'),
            subtitle: Text(customer.address),
            trailing: Text('${localizations?.translate('born') ?? 'Born'}: ${customer.dateOfBirth}'),
            onTap: () {
              setState(() {
                _selectedCustomer = customer;
                _isAddingNew = false;
              });
              _firstNameController.text = customer.firstName;
              _lastNameController.text = customer.lastName;
              _addressController.text = customer.address;
              _dateOfBirthController.text = customer.dateOfBirth;
            },
          ),
        );
      },
    );
  }
}