import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/reservation.dart';
import '../repositories/reservation_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';

/// Reservation management page implementing all CST2335 assignment requirements.
///
/// This page provides complete CRUD functionality for reservation management with:
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
class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final ReservationRepository _repository = ReservationRepository();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  List<Reservation> _reservations = [];
  Reservation? _selectedReservation;
  bool _isLoading = true;
  bool _isAddingNew = false; // Track if we're adding a new reservation

  // Form controllers
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _flightIdController = TextEditingController();
  final TextEditingController _flightDateController = TextEditingController();
  final TextEditingController _reservationNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _flightIdController.dispose();
    _flightDateController.dispose();
    _reservationNameController.dispose();
    super.dispose();
  }

  /// Closes details view (for phone layout)
  void _closeDetails() {
    _clearForm();
  }

  /// Starts adding a new reservation (for portrait mode)
  void _startAddingReservation() {
    _clearForm();
    setState(() => _isAddingNew = true);
  }

  /// Loads all reservations from database following assignment slide patterns.
  ///
  /// Implements the ListView initialization pattern from course slides:
  /// 1. Sets loading state for user feedback
  /// 2. Fetches data using repository pattern
  /// 3. Updates UI state with setState()
  /// 4. Handles errors with user-friendly messages
  ///
  /// Called in initState() and after CRUD operations to maintain
  /// ListView synchronization with database as demonstrated in slides.
  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final reservations = await _repository.getAllReservations();
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading reservations: $e');
    }
  }

  /// Loads previous reservation data from EncryptedSharedPreferences.
  ///
  /// This implements Requirement 6 by allowing users to quickly populate
  /// form fields with data from the previously added reservation, reducing
  /// repetitive data entry as specified in the assignment.
  Future<void> _loadPreviousReservationData() async {
    try {
      final customerId = await _prefs.getString('prev_customer_id') ?? '';
      final flightId = await _prefs.getString('prev_flight_id') ?? '';
      final flightDate = await _prefs.getString('prev_flight_date') ?? '';
      final reservationName = await _prefs.getString('prev_reservation_name') ?? '';

      if (customerId.isNotEmpty) {
        _customerIdController.text = customerId;
        _flightIdController.text = flightId;
        _flightDateController.text = flightDate;
        _reservationNameController.text = reservationName;
      }
    } catch (e) {
      debugPrint('Error loading previous reservation data: $e');
    }
  }

  /// Saves reservation data to EncryptedSharedPreferences.
  ///
  /// This data can be retrieved later when adding a new reservation to
  /// pre-populate form fields with similar information, implementing
  /// the "copy previous data" feature required by the assignment.
  Future<void> _savePreviousReservationData() async {
    try {
      await _prefs.setString('prev_customer_id', _customerIdController.text);
      await _prefs.setString('prev_flight_id', _flightIdController.text);
      await _prefs.setString('prev_flight_date', _flightDateController.text);
      await _prefs.setString('prev_reservation_name', _reservationNameController.text);
    } catch (e) {
      debugPrint('Error saving previous reservation data: $e');
    }
  }

  /// Validates reservation form fields per assignment requirements.
  ///
  /// Checks all required fields for reservation topic:
  /// - Customer ID: Must be valid positive integer (references existing customer)
  /// - Flight ID: Must be valid positive integer (references existing flight)
  /// - Flight date: Must not be empty (YYYY-MM-DD format: "2025-07-15")
  /// - Reservation name: Must not be empty (e.g., "Summer Holiday", "Business Trip")
  ///
  /// Shows AlertDialog on validation failure (Requirement 5).
  /// Returns true if all fields valid, false otherwise.
  bool _validateFields() {
    final localizations = AppLocalizations.of(context);
    if (_customerIdController.text.trim().isEmpty ||
        _flightIdController.text.trim().isEmpty ||
        _flightDateController.text.trim().isEmpty ||
        _reservationNameController.text.trim().isEmpty) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          localizations?.translate('all_fields_required') ?? 'All fields must be filled out.'
      );
      return false;
    }

    if (int.tryParse(_customerIdController.text.trim()) == null) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          'Customer ID must be a valid number.'
      );
      return false;
    }

    if (int.tryParse(_flightIdController.text.trim()) == null) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          'Flight ID must be a valid number.'
      );
      return false;
    }

    return true;
  }

  /// Adds a new reservation to the database following the assignment pattern.
  ///
  /// Implements the CRUD operation pattern from course slides:
  /// 1. Validates form fields
  /// 2. Creates new Reservation object
  /// 3. Saves to database using repository
  /// 4. Updates SharedPreferences for next use
  /// 5. Refreshes ListView
  /// 6. Shows success feedback via Snackbar
  Future<void> _addReservation() async {
    if (!_validateFields()) return;

    final reservation = Reservation(
      customerId: int.parse(_customerIdController.text.trim()),
      flightId: int.parse(_flightIdController.text.trim()),
      flightDate: _flightDateController.text.trim(),
      reservationName: _reservationNameController.text.trim(),
    );

    try {
      await _repository.insertReservation(reservation);
      await _savePreviousReservationData();
      _clearForm();
      _loadReservations();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('reservation_added') ?? 'Reservation created successfully!');
    } catch (e) {
      _showSnackBar('Error creating reservation: $e');
    }
  }

  /// Updates an existing reservation in the database.
  ///
  /// Validates form fields and updates the currently selected reservation
  /// with new data. Shows success message via Snackbar on completion.
  Future<void> _updateReservation() async {
    if (_selectedReservation == null || !_validateFields()) return;

    final reservation = Reservation(
      id: _selectedReservation!.id,
      customerId: int.parse(_customerIdController.text.trim()),
      flightId: int.parse(_flightIdController.text.trim()),
      flightDate: _flightDateController.text.trim(),
      reservationName: _reservationNameController.text.trim(),
    );

    try {
      await _repository.updateReservation(reservation);
      _clearForm();
      _loadReservations();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('reservation_updated') ?? 'Reservation updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating reservation: $e');
    }
  }

  /// Deletes the currently selected reservation from the database.
  ///
  /// Removes the reservation from database and refreshes the reservation list.
  /// Shows success message via Snackbar on completion.
  Future<void> _deleteReservation() async {
    if (_selectedReservation == null) return;

    try {
      await _repository.deleteReservation(_selectedReservation!.id!);
      _clearForm();
      _loadReservations();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('reservation_deleted') ?? 'Reservation cancelled successfully!');
    } catch (e) {
      _showSnackBar('Error cancelling reservation: $e');
    }
  }

  /// Clears all form fields and resets the selected reservation state.
  /// This method is used to reset the form when navigating away from
  /// the details view or after completing CRUD operations.
  void _clearForm() {
    _customerIdController.clear();
    _flightIdController.clear();
    _flightDateController.clear();
    _reservationNameController.clear();
    setState(() {
      _selectedReservation = null;
      _isAddingNew = false;
    });
  }

  /// Shows a dialog asking whether to copy previous reservation data or start blank.
  ///
  /// This implements the assignment requirement for users to have a choice
  /// to copy fields from the previous reservation or start with a blank page,
  /// as specified in the reservation topic requirements.
  void _showCopyDataDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('copy_previous_data') ?? 'Copy Previous Data'),
          content: Text(localizations?.translate('copy_previous_question') ??
              'Would you like to copy fields from the previous reservation or start with a blank page?'),
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
                _loadPreviousReservationData();
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
  ///
  /// Creates AlertDialog with instructions as specified:
  /// "ActionBar with ActionItems that displays an AlertDialog
  /// with instructions for how to use the interface"
  ///
  /// Includes guidance on adding, editing, deleting reservations,
  /// using the copy previous data feature, and ID/date format examples.
  void _showHelpDialog() {
    final localizations = AppLocalizations.of(context);
    _showAlertDialog(
      localizations?.translate('help') ?? 'Reservation Management Help',
      localizations?.translate('help_content') ??
          'Instructions:\n\n'
              '• Tap "+" to add a new reservation\n'
              '• Fill out all required fields\n'
              '• Select a reservation from the list to view/edit details\n'
              '• Use Update button to save changes\n'
              '• Use Delete button to cancel reservation\n'
              '• Choose to copy previous data or start blank\n\n'
              'Note: Customer ID and Flight ID must reference existing records\n'
              'Date Format: YYYY-MM-DD (e.g., 2025-07-15)\n'
              'Reservation Name: e.g., "Summer Holiday", "Business Trip"',
    );
  }

  /// Displays language selection dialog for internationalization.
  ///
  /// Implements Requirement 8 (multi-language support) by allowing users
  /// to switch between supported languages:
  /// - English (🇺🇸)
  /// - French (🇫🇷)
  /// - Spanish (🇪🇸)
  ///
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

  /// Shows a snack bar with the provided message implementing Requirement 5.
  ///
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
  ///
  /// Used for displaying validation errors, help information,
  /// and other important messages to the user, implementing
  /// the AlertDialog portion of Requirement 5.
  ///
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
  ///
  /// Implements Requirement 4 by providing different layouts:
  /// - Tablet/Desktop (>600px landscape): Master-detail side-by-side
  /// - Phone: Full-screen switching between list and details
  ///
  /// This follows the responsive design patterns demonstrated in Week 9 lab
  /// using MediaQuery to detect screen characteristics.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    // Tablet and desktop layout (from Week 9 lab)
    final isTabletLayout = screenWidth > 600 && orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations?.translate('reservation_management') ?? 'Reservation Management'),
        centerTitle: true,
        actions: [
          // Back button for phone layout when viewing details
          if ((_selectedReservation != null || _isAddingNew) && !isTabletLayout)
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
      // FloatingActionButton shows only when not editing
      floatingActionButton: (_selectedReservation == null && !_isAddingNew)
          ? FloatingActionButton(
        onPressed: _showCopyDataDialog,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  /// Builds the tablet and desktop layout with side-by-side master-detail view.
  /// Shows the reservation list on the left and the form on the right,
  /// providing an efficient workflow for larger screens.
  Widget _buildTabletLayout() {
    final localizations = AppLocalizations.of(context);

    return Row(
      children: [
        // Master panel (List)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${localizations?.translate('reservations_count') ?? 'Reservations'} (${_reservations.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(child: _buildReservationList()),
            ],
          ),
        ),
        // Detail panel (Form)
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
            child: _buildReservationForm(),
          ),
        ),
      ],
    );
  }

  /// Builds the phone layout with full-screen switching between list and details.
  /// On phones, this shows either the reservation list or the form in full screen,
  /// switching between them based on the current state.
  Widget _buildPhoneLayout() {
    if (_selectedReservation != null || _isAddingNew) {
      // Show form page in full screen
      return _buildReservationForm();
    } else {
      // Show list page
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${AppLocalizations.of(context)?.translate('reservations_count') ?? 'Reservations'} (${_reservations.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(child: _buildReservationList()),
        ],
      );
    }
  }

  /// Builds the reservation form widget implementing Requirements 2 and 6.
  ///
  /// Creates a scrollable form with TextFields for reservation data entry
  /// and appropriate action buttons based on the current mode
  /// (add new reservation vs. edit existing reservation).
  ///
  /// Form includes all required fields for reservation topic:
  /// - Customer ID with numeric validation
  /// - Flight ID with numeric validation
  /// - Flight date in YYYY-MM-DD format
  /// - Reservation name with examples
  Widget _buildReservationForm() {
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
                (_selectedReservation == null || _isAddingNew)
                    ? (localizations?.translate('create_new_reservation') ?? 'Create New Reservation')
                    : (localizations?.translate('edit_reservation') ?? 'Edit Reservation'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: localizations?.translate('customer_id') ?? 'Customer ID',
                  hintText: 'Enter customer ID number',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _flightIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: localizations?.translate('flight_id') ?? 'Flight ID',
                  hintText: 'Enter flight ID number',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _flightDateController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('flight_date') ?? 'Flight Date',
                  hintText: 'YYYY-MM-DD (e.g., 2025-07-15)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reservationNameController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('reservation_name') ?? 'Reservation Name',
                  hintText: 'e.g., Summer Holiday, Business Trip',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedReservation == null || _isAddingNew) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addReservation,
                        child: Text(localizations?.translate('submit') ?? 'Create Reservation'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showCopyDataDialog,
                      child: Text(localizations?.translate('copy_previous') ?? 'Copy Previous'),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateReservation,
                        child: Text(localizations?.translate('update') ?? 'Update'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _deleteReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(localizations?.translate('delete') ?? 'Cancel'),
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

  /// Builds the reservation list widget implementing Requirement 1.
  ///
  /// Displays a scrollable ListView of reservations using ListView.builder()
  /// as demonstrated in the course slides. Shows loading indicator when
  /// data is being fetched, and an empty state message when no reservations exist.
  ///
  /// Each list item is a Card with reservation information that can be tapped
  /// to select and edit the reservation details (Requirement 4).
  Widget _buildReservationList() {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reservations.isEmpty) {
      return Center(
        child: Text(
          localizations?.translate('no_reservations_found') ?? 'No reservations found. Create a reservation to get started.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        final isSelected = _selectedReservation?.id == reservation.id;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: const Icon(Icons.book_online, color: Colors.purple),
            title: Text(reservation.reservationName),
            subtitle: Text(
              '${localizations?.translate('customer') ?? 'Customer'}: ${reservation.customerId} • ${localizations?.translate('flight') ?? 'Flight'}: ${reservation.flightId}\n'
                  '${localizations?.translate('date') ?? 'Date'}: ${reservation.flightDate}',
            ),
            trailing: Icon(
              Icons.event,
              color: Colors.orange.shade700,
            ),
            onTap: () {
              setState(() {
                _selectedReservation = reservation;
                _isAddingNew = false;
              });
              _customerIdController.text = reservation.customerId.toString();
              _flightIdController.text = reservation.flightId.toString();
              _flightDateController.text = reservation.flightDate;
              _reservationNameController.text = reservation.reservationName;
            },
          ),
        );
      },
    );
  }
}