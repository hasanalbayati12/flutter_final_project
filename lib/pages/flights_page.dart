import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/flight.dart';
import '../repositories/flight_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';

/// Page for managing flights with full CRUD support and assignment compliance.
///
/// Features include:
/// - Displays saved flights using ListView
/// - Form input with TextFields and button controls
/// - Persistent storage with Floor
/// - Responsive design for different screen sizes
/// - UI feedback via dialogs and snackbars
/// - Field reuse with EncryptedSharedPreferences
/// - Action bar help menu
/// - Language translation support
/// - Professional styling and comments
class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});

  @override
  State<FlightsPage> createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  final FlightRepository _repository = FlightRepository();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  List<Flight> _flights = [];
  Flight? _selectedFlight;
  bool _isLoading = true;
  bool _isAddingNew = false; // Track if we're adding a new flight

  // Form controllers
  final TextEditingController _departureCityController = TextEditingController();
  final TextEditingController _destinationCityController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  @override
  void dispose() {
    _departureCityController.dispose();
    _destinationCityController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }

  /// Hides the form and clears selected flight (for mobile layout)
  void _closeDetails() {
    _clearForm();
  }

  /// Retrieves flights from the database and updates the view.
  ///
  /// Sets loading indicator while fetching, updates the state with results,
  /// and handles any error by showing a snackbar message.
  Future<void> _loadFlights() async {
    setState(() => _isLoading = true);
    try {
      final flights = await _repository.getAllFlights();
      setState(() {
        _flights = flights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading flights: $e');
    }
  }

  /// Loads previous form values stored in encrypted preferences.
  ///
  /// If values exist, they are inserted back into the form inputs.
  Future<void> _loadPreviousFlightData() async {
    try {
      final departureCity = await _prefs.getString('prev_departure_city') ?? '';
      final destinationCity = await _prefs.getString('prev_destination_city') ?? '';
      final departureTime = await _prefs.getString('prev_departure_time') ?? '';
      final arrivalTime = await _prefs.getString('prev_arrival_time') ?? '';

      if (departureCity.isNotEmpty) {
        _departureCityController.text = departureCity;
        _destinationCityController.text = destinationCity;
        _departureTimeController.text = departureTime;
        _arrivalTimeController.text = arrivalTime;
      }
    } catch (e) {
      debugPrint('Error loading previous flight data: $e');
    }
  }

  /// Saves current form inputs into encrypted shared preferences.
  ///
  /// This helps pre-fill the form later when user wants to copy previous input.
  Future<void> _savePreviousFlightData() async {
    try {
      await _prefs.setString('prev_departure_city', _departureCityController.text);
      await _prefs.setString('prev_destination_city', _destinationCityController.text);
      await _prefs.setString('prev_departure_time', _departureTimeController.text);
      await _prefs.setString('prev_arrival_time', _arrivalTimeController.text);
    } catch (e) {
      debugPrint('Error saving previous flight data: $e');
    }
  }


  /// Validates if the form inputs are filled properly.
  ///
  /// If any field is empty, shows an alert dialog to the user.
  /// Returns true if all inputs are valid.
  bool _validateFields() {
    final localizations = AppLocalizations.of(context);
    if (_departureCityController.text.trim().isEmpty ||
        _destinationCityController.text.trim().isEmpty ||
        _departureTimeController.text.trim().isEmpty ||
        _arrivalTimeController.text.trim().isEmpty) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          localizations?.translate('all_fields_required') ?? 'All fields must be filled out.'
      );
      return false;
    }
    return true;
  }

  /// Adds a new flight to the database following the assignment pattern.
  ///
  /// Implements the CRUD operation pattern from course slides:
  /// 1. Validates form fields
  /// 2. Creates new Flight object
  /// 3. Saves to database using repository
  /// 4. Updates SharedPreferences for next use
  /// 5. Refreshes ListView
  /// 6. Shows success feedback via Snackbar
  Future<void> _addFlight() async {
    if (!_validateFields()) return;

    final flight = Flight(
      departureCity: _departureCityController.text.trim(),
      destinationCity: _destinationCityController.text.trim(),
      departureTime: _departureTimeController.text.trim(),
      arrivalTime: _arrivalTimeController.text.trim(),
    );

    try {
      await _repository.insertFlight(flight);
      await _savePreviousFlightData();
      _clearForm();
      _loadFlights();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('flight_added') ?? 'Flight added successfully!');
    } catch (e) {
      _showSnackBar('Error adding flight: $e');
    }
  }

  /// Updates an existing flight in the database.
  ///
  /// Validates form fields and updates the currently selected flight
  /// with new data. Shows success message via Snackbar on completion.
  Future<void> _updateFlight() async {
    if (_selectedFlight == null || !_validateFields()) return;

    final flight = Flight(
      id: _selectedFlight!.id,
      departureCity: _departureCityController.text.trim(),
      destinationCity: _destinationCityController.text.trim(),
      departureTime: _departureTimeController.text.trim(),
      arrivalTime: _arrivalTimeController.text.trim(),
    );

    try {
      await _repository.updateFlight(flight);
      _clearForm();
      _loadFlights();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('flight_updated') ?? 'Flight updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating flight: $e');
    }
  }

  /// Deletes the currently selected flight from the database.
  ///
  /// Removes the flight from database and refreshes the flight list.
  /// Shows success message via Snackbar on completion.
  Future<void> _deleteFlight() async {
    if (_selectedFlight == null) return;

    try {
      await _repository.deleteFlight(_selectedFlight!.id!);
      _clearForm();
      _loadFlights();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('flight_deleted') ?? 'Flight deleted successfully!');
    } catch (e) {
      _showSnackBar('Error deleting flight: $e');
    }
  }

  /// Clears all form fields and resets the selected flight state.
  /// This method is used to reset the form when navigating away from
  /// the details view or after completing CRUD operations.
  void _clearForm() {
    _departureCityController.clear();
    _destinationCityController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
    setState(() {
      _selectedFlight = null;
      _isAddingNew = false;
    });
  }

  /// Shows a dialog asking whether to copy previous flight data or start blank.
  ///
  /// This implements the assignment requirement for users to have a choice
  /// to copy fields from the previous flight or start with a blank page,
  /// as specified in the flight topic requirements.
  void _showCopyDataDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('copy_previous_data') ?? 'Copy Previous Data'),
          content: Text(localizations?.translate('copy_previous_question') ??
              'Would you like to copy fields from the previous flight or start with a blank page?'),
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
                _loadPreviousFlightData();
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

  /// Displays a help dialog to guide the user (Requirement 7).
  ///
  /// This dialog provides instructions on how to use the app, including:
  /// - Adding, editing, and deleting flights
  /// - Using the "Copy Previous" feature
  /// - Time formatting expectations
  void _showHelpDialog() {
    final localizations = AppLocalizations.of(context);
    _showAlertDialog(
      localizations?.translate('help') ?? 'Flight Management Help',
      localizations?.translate('help_content') ??
          'Instructions:\n\n'
              '• Tap "+" to add a new flight route\n'
              '• Fill out all required fields\n'
              '• Select a flight from the list to view/edit details\n'
              '• Use Update button to save changes\n'
              '• Use Delete button to remove flight\n'
              '• Choose to copy previous data or start blank\n\n'
              'Time Format: Use 24-hour format (e.g., 14:30)\n'
              'Cities: Enter full city names (e.g., London, New York)',
    );
  }

  /// Opens a language selection dialog (Requirement 8).
  ///
  /// Allows users to switch the app's language between:
  /// - English US
  /// - French FR
  /// - Spanish ES
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

  /// Displays a snackbar with a short feedback message (Requirement 5).
  ///
  /// [message] - The message to show.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Opens a simple alert dialog with a title and message (Requirement 5).
  ///
  /// Used for displaying validation errors, help, and notifications.
  ///
  /// [title] - Dialog title.
  /// [content] - Message to display.
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

  /// Builds a responsive layout (Requirement 4).
  ///
  /// Automatically switches between tablet and phone layout based on screen width
  /// and orientation using MediaQuery, based on Week 9 lab pattern.
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
        title: Text(localizations?.translate('flight_management') ?? 'Flight Management'),
        centerTitle: true,
        actions: [
          // Back button for phone layout when viewing details
          if ((_selectedFlight != null || _isAddingNew) && !isTabletLayout)
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
      floatingActionButton: (_selectedFlight == null && !_isAddingNew)
          ? FloatingActionButton(
        onPressed: _showCopyDataDialog,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  /// Builds the tablet and desktop layout with side-by-side master-detail view.
  /// Shows the flight list on the left and the form on the right,
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
                  '${localizations?.translate('flights_count') ?? 'Flights'} (${_flights.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(child: _buildFlightList()),
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
            child: _buildFlightForm(),
          ),
        ),
      ],
    );
  }

  /// Builds the phone layout with full-screen switching between list and details.
  /// On phones, this shows either the flight list or the form in full screen,
  /// switching between them based on the current state.
  Widget _buildPhoneLayout() {
    if (_selectedFlight != null || _isAddingNew) {
      // Show form page in full screen
      return _buildFlightForm();
    } else {
      // Show list page
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${AppLocalizations.of(context)?.translate('flights_count') ?? 'Flights'} (${_flights.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(child: _buildFlightList()),
        ],
      );
    }
  }

  /// Builds the flight form widget implementing Requirements 2 and 6.
  ///
  /// Creates a scrollable form with TextFields for flight data entry
  /// and appropriate action buttons based on the current mode
  /// (add new flight vs. edit existing flight).
  ///
  /// Form includes all required fields for flight topic:
  /// - Departure city with examples
  /// - Destination city with examples
  /// - Departure time in 24-hour format
  /// - Arrival time in 24-hour format
  Widget _buildFlightForm() {
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
                (_selectedFlight == null || _isAddingNew)
                    ? (localizations?.translate('add_new_flight') ?? 'Add New Flight')
                    : (localizations?.translate('edit_flight') ?? 'Edit Flight'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _departureCityController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('departure_city') ?? 'Departure City',
                  hintText: 'e.g., London',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destinationCityController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('destination_city') ?? 'Destination City',
                  hintText: 'e.g., New York',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _departureTimeController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('departure_time') ?? 'Departure Time',
                  hintText: 'e.g., 14:30',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _arrivalTimeController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('arrival_time') ?? 'Arrival Time',
                  hintText: 'e.g., 18:45',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedFlight == null || _isAddingNew) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addFlight,
                        child: Text(localizations?.translate('submit') ?? 'Submit'),
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
                        onPressed: _updateFlight,
                        child: Text(localizations?.translate('update') ?? 'Update'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _deleteFlight,
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

  /// Builds the flight list widget implementing Requirement 1.
  ///
  /// Displays a scrollable ListView of flights using ListView.builder()
  /// as demonstrated in the course slides. Shows loading indicator when
  /// data is being fetched, and an empty state message when no flights exist.
  ///
  /// Each list item is a Card with flight information that can be tapped
  /// to select and edit the flight details (Requirement 4).
  Widget _buildFlightList() {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_flights.isEmpty) {
      return Center(
        child: Text(
          localizations?.translate('no_flights_found') ?? 'No flights found. Add a flight to get started.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _flights.length,
      itemBuilder: (context, index) {
        final flight = _flights[index];
        final isSelected = _selectedFlight?.id == flight.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: const Icon(Icons.flight_takeoff, color: Colors.green),
            title: Text('${flight.departureCity} → ${flight.destinationCity}'),
            subtitle: Text('${localizations?.translate('depart') ?? 'Depart'}: ${flight.departureTime} • ${localizations?.translate('arrive') ?? 'Arrive'}: ${flight.arrivalTime}'),
            trailing: const Icon(Icons.flight_land, color: Colors.red),
            onTap: () {
              setState(() {
                _selectedFlight = flight;
                _isAddingNew = false;
              });
              _departureCityController.text = flight.departureCity;
              _destinationCityController.text = flight.destinationCity;
              _departureTimeController.text = flight.departureTime;
              _arrivalTimeController.text = flight.arrivalTime;
            },
          ),
        );
      },
    );
  }
}