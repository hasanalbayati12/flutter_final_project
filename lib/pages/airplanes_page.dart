import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/airplane.dart';
import '../repositories/airplane_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';

/// Airplane management page implementing all CST2335 assignment requirements.
///
/// This page provides complete CRUD functionality for airplane management with:
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
class AirplanesPage extends StatefulWidget {
  const AirplanesPage({super.key});

  @override
  State<AirplanesPage> createState() => _AirplanesPageState();
}

class _AirplanesPageState extends State<AirplanesPage> {
  final AirplaneRepository _repository = AirplaneRepository();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  List<Airplane> _airplanes = [];
  Airplane? _selectedAirplane;
  bool _isLoading = true;
  bool _isAddingNew = false; // Track if we're adding a new airplane

  // Form controllers
  final TextEditingController _airplaneTypeController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();
  final TextEditingController _maxSpeedController = TextEditingController();
  final TextEditingController _rangeDistanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAirplanes();
  }

  @override
  void dispose() {
    _airplaneTypeController.dispose();
    _passengersController.dispose();
    _maxSpeedController.dispose();
    _rangeDistanceController.dispose();
    super.dispose();
  }

  /// Closes details view (for phone layout)
  void _closeDetails() {
    _clearForm();
  }

  /// Loads all airplanes from database following assignment slide patterns.
  ///
  /// Implements the ListView initialization pattern from course slides:
  /// 1. Sets loading state for user feedback
  /// 2. Fetches data using repository pattern
  /// 3. Updates UI state with setState()
  /// 4. Handles errors with user-friendly messages
  ///
  /// Called in initState() and after CRUD operations to maintain
  /// ListView synchronization with database as demonstrated in slides.
  Future<void> _loadAirplanes() async {
    setState(() => _isLoading = true);
    try {
      final airplanes = await _repository.getAllAirplanes();
      setState(() {
        _airplanes = airplanes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error loading aeroplanes: $e');
    }
  }

  /// Loads previous airplane data from EncryptedSharedPreferences.
  ///
  /// This implements Requirement 6 by allowing users to quickly populate
  /// form fields with data from the previously added airplane, reducing
  /// repetitive data entry as specified in the assignment.
  Future<void> _loadPreviousAirplaneData() async {
    try {
      final airplaneType = await _prefs.getString('prev_airplane_type') ?? '';
      final passengers = await _prefs.getString('prev_passengers') ?? '';
      final maxSpeed = await _prefs.getString('prev_max_speed') ?? '';
      final rangeDistance = await _prefs.getString('prev_range_distance') ?? '';

      if (airplaneType.isNotEmpty) {
        _airplaneTypeController.text = airplaneType;
        _passengersController.text = passengers;
        _maxSpeedController.text = maxSpeed;
        _rangeDistanceController.text = rangeDistance;
      }
    } catch (e) {
      debugPrint('Error loading previous aeroplane data: $e');
    }
  }

  /// Saves airplane data to EncryptedSharedPreferences.
  ///
  /// This data can be retrieved later when adding a new airplane to
  /// pre-populate form fields with similar information, implementing
  /// the "copy previous data" feature required by the assignment.
  Future<void> _savePreviousAirplaneData() async {
    try {
      await _prefs.setString('prev_airplane_type', _airplaneTypeController.text);
      await _prefs.setString('prev_passengers', _passengersController.text);
      await _prefs.setString('prev_max_speed', _maxSpeedController.text);
      await _prefs.setString('prev_range_distance', _rangeDistanceController.text);
    } catch (e) {
      debugPrint('Error saving previous aeroplane data: $e');
    }
  }

  /// Validates airplane form fields per assignment requirements.
  ///
  /// Checks all required fields for airplane topic:
  /// - Airplane type: Must not be empty (e.g., "Boeing 777", "Airbus A350")
  /// - Passengers: Must be valid positive integer
  /// - Max speed: Must not be empty (e.g., "560 mph")
  /// - Range distance: Must not be empty (e.g., "8,000 miles")
  ///
  /// Shows AlertDialog on validation failure (Requirement 5).
  /// Returns true if all fields valid, false otherwise.
  bool _validateFields() {
    final localizations = AppLocalizations.of(context);
    if (_airplaneTypeController.text.trim().isEmpty ||
        _passengersController.text.trim().isEmpty ||
        _maxSpeedController.text.trim().isEmpty ||
        _rangeDistanceController.text.trim().isEmpty) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          localizations?.translate('all_fields_required') ?? 'All fields must be filled out.'
      );
      return false;
    }

    if (int.tryParse(_passengersController.text.trim()) == null) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          'Passengers must be a valid number.'
      );
      return false;
    }

    return true;
  }

  /// Adds a new airplane to the database following the assignment pattern.
  ///
  /// Implements the CRUD operation pattern from course slides:
  /// 1. Validates form fields
  /// 2. Creates new Airplane object
  /// 3. Saves to database using repository
  /// 4. Updates SharedPreferences for next use
  /// 5. Refreshes ListView
  /// 6. Shows success feedback via Snackbar
  Future<void> _addAirplane() async {
    if (!_validateFields()) return;

    final airplane = Airplane(
      airplaneType: _airplaneTypeController.text.trim(),
      passengers: int.parse(_passengersController.text.trim()),
      maxSpeed: _maxSpeedController.text.trim(),
      rangeDistance: _rangeDistanceController.text.trim(),
    );

    try {
      await _repository.insertAirplane(airplane);
      await _savePreviousAirplaneData();
      _clearForm();
      _loadAirplanes();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('airplane_added') ?? 'Aeroplane added successfully!');
    } catch (e) {
      _showSnackBar('Error adding aeroplane: $e');
    }
  }

  /// Updates an existing airplane in the database.
  ///
  /// Validates form fields and updates the currently selected airplane
  /// with new data. Shows success message via Snackbar on completion.
  Future<void> _updateAirplane() async {
    if (_selectedAirplane == null || !_validateFields()) return;

    final airplane = Airplane(
      id: _selectedAirplane!.id,
      airplaneType: _airplaneTypeController.text.trim(),
      passengers: int.parse(_passengersController.text.trim()),
      maxSpeed: _maxSpeedController.text.trim(),
      rangeDistance: _rangeDistanceController.text.trim(),
    );

    try {
      await _repository.updateAirplane(airplane);
      _clearForm();
      _loadAirplanes();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('airplane_updated') ?? 'Aeroplane updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating aeroplane: $e');
    }
  }

  /// Deletes the currently selected airplane from the database.
  ///
  /// Removes the airplane from database and refreshes the airplane list.
  /// Shows success message via Snackbar on completion.
  Future<void> _deleteAirplane() async {
    if (_selectedAirplane == null) return;

    try {
      await _repository.deleteAirplane(_selectedAirplane!.id!);
      _clearForm();
      _loadAirplanes();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('airplane_deleted') ?? 'Aeroplane deleted successfully!');
    } catch (e) {
      _showSnackBar('Error deleting aeroplane: $e');
    }
  }

  /// Clears all form fields and resets the selected airplane state.
  /// This method is used to reset the form when navigating away from
  /// the details view or after completing CRUD operations.
  void _clearForm() {
    _airplaneTypeController.clear();
    _passengersController.clear();
    _maxSpeedController.clear();
    _rangeDistanceController.clear();
    setState(() {
      _selectedAirplane = null;
      _isAddingNew = false;
    });
  }

  /// Shows a dialog asking whether to copy previous airplane data or start blank.
  ///
  /// This implements the assignment requirement for users to have a choice
  /// to copy fields from the previous airplane or start with a blank page,
  /// as specified in the airplane topic requirements.
  void _showCopyDataDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('copy_previous_data') ?? 'Copy Previous Data'),
          content: Text(localizations?.translate('copy_previous_question') ??
              'Would you like to copy fields from the previous aeroplane or start with a blank page?'),
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
                _loadPreviousAirplaneData();
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
  /// Includes guidance on adding, editing, deleting airplanes,
  /// using the copy previous data feature, and aircraft type examples.
  void _showHelpDialog() {
    final localizations = AppLocalizations.of(context);
    _showAlertDialog(
      localizations?.translate('help') ?? 'Aeroplane Management Help',
      localizations?.translate('help_content') ??
          'Instructions:\n\n'
              '• Tap "+" to add a new aeroplane\n'
              '• Fill out all required fields\n'
              '• Select an aeroplane from the list to view/edit details\n'
              '• Use Update button to save changes\n'
              '• Use Delete button to remove aeroplane\n'
              '• Choose to copy previous data or start blank\n\n'
              'Aircraft Types: Airbus A350, A320, Boeing 777, etc.',
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
        title: Text(localizations?.translate('airplane_management') ?? 'Aeroplane Management'),
        centerTitle: true,
        actions: [
          // Back button for phone layout when viewing details
          if ((_selectedAirplane != null || _isAddingNew) && !isTabletLayout)
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
      floatingActionButton: (_selectedAirplane == null && !_isAddingNew)
          ? FloatingActionButton(
        onPressed: _showCopyDataDialog,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  /// Builds the tablet and desktop layout with side-by-side master-detail view.
  /// Shows the airplane list on the left and the form on the right,
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
                  '${localizations?.translate('airplanes_count') ?? 'Aeroplanes'} (${_airplanes.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(child: _buildAirplaneList()),
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
            child: _buildAirplaneForm(),
          ),
        ),
      ],
    );
  }

  /// Builds the phone layout with full-screen switching between list and details.
  /// On phones, this shows either the airplane list or the form in full screen,
  /// switching between them based on the current state.
  Widget _buildPhoneLayout() {
    if (_selectedAirplane != null || _isAddingNew) {
      // Show form page in full screen
      return _buildAirplaneForm();
    } else {
      // Show list page
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${AppLocalizations.of(context)?.translate('airplanes_count') ?? 'Aeroplanes'} (${_airplanes.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(child: _buildAirplaneList()),
        ],
      );
    }
  }

  /// Builds the airplane form widget implementing Requirements 2 and 6.
  ///
  /// Creates a scrollable form with TextFields for airplane data entry
  /// and appropriate action buttons based on the current mode
  /// (add new airplane vs. edit existing airplane).
  ///
  /// Form includes all required fields for airplane topic:
  /// - Airplane type with examples
  /// - Number of passengers with numeric validation
  /// - Maximum speed with unit examples
  /// - Range distance with unit examples
  Widget _buildAirplaneForm() {
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
                (_selectedAirplane == null || _isAddingNew)
                    ? (localizations?.translate('add_new_airplane') ?? 'Add New Aeroplane')
                    : (localizations?.translate('edit_airplane') ?? 'Edit Aeroplane'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _airplaneTypeController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('airplane_type') ?? 'Aeroplane Type (e.g., Boeing 777, Airbus A350)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passengersController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: localizations?.translate('passengers') ?? 'Number of Passengers',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _maxSpeedController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('max_speed') ?? 'Maximum Speed (e.g., 560 mph)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rangeDistanceController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('range_distance') ?? 'Range Distance (e.g., 8,000 miles)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedAirplane == null || _isAddingNew) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addAirplane,
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
                        onPressed: _updateAirplane,
                        child: Text(localizations?.translate('update') ?? 'Update'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _deleteAirplane,
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

  /// Builds the airplane list widget implementing Requirement 1.
  ///
  /// Displays a scrollable ListView of airplanes using ListView.builder()
  /// as demonstrated in the course slides. Shows loading indicator when
  /// data is being fetched, and an empty state message when no airplanes exist.
  ///
  /// Each list item is a Card with airplane information that can be tapped
  /// to select and edit the airplane details (Requirement 4).
  Widget _buildAirplaneList() {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_airplanes.isEmpty) {
      return Center(
        child: Text(
          localizations?.translate('no_airplanes_found') ?? 'No aeroplanes found. Add an aeroplane to get started.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _airplanes.length,
      itemBuilder: (context, index) {
        final airplane = _airplanes[index];
        final isSelected = _selectedAirplane?.id == airplane.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: const Icon(Icons.flight, color: Colors.blue),
            title: Text(airplane.airplaneType),
            subtitle: Text('${airplane.passengers} passengers • ${airplane.maxSpeed}'),
            trailing: Text('${localizations?.translate('range') ?? 'Range'}: ${airplane.rangeDistance}'),
            onTap: () {
              setState(() {
                _selectedAirplane = airplane;
                _isAddingNew = false;
              });
              _airplaneTypeController.text = airplane.airplaneType;
              _passengersController.text = airplane.passengers.toString();
              _maxSpeedController.text = airplane.maxSpeed;
              _rangeDistanceController.text = airplane.rangeDistance;
            },
          ),
        );
      },
    );
  }
}