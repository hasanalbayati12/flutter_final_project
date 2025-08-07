import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/airplane.dart';
import '../repositories/airplane_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';

/// Page for managing airplanes in the airline fleet
/// Implements CRUD operations and provides a user-friendly interface
/// for adding, editing, and deleting airplanes.
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
  bool _isAddingNew = false; 

  
  final TextEditingController _airplaneTypeController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();
  final TextEditingController _maxSpeedController = TextEditingController();
  final TextEditingController _rangeDistanceController = TextEditingController();

  /// Initializes the page by loading airplanes and previous data
  @override
  void initState() {
    super.initState();
    _loadAirplanes();
  }
/// Disposes the controllers to free up resources
  /// This is important to prevent memory leaks in the application.
  @override
  void dispose() {
    _airplaneTypeController.dispose();
    _passengersController.dispose();
    _maxSpeedController.dispose();
    _rangeDistanceController.dispose();
    super.dispose();
  }

/// Closes the airplane details view and clears the form
  void _closeDetails() {
    _clearForm();
  }

/// Loads all airplanes from the repository and updates the state
  /// This method fetches the airplane data from the database
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

/// Loads previous airplane data from shared preferences
  /// This method retrieves previously entered airplane data
  /// and populates the form fields if available.
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

/// Saves the current airplane data to shared preferences
  /// This method stores the current values of the form fields
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

/// Validates the form fields before adding or updating an airplane
  /// This method checks if all required fields are filled out
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

/// Adds a new airplane to the database
  /// This method creates a new Airplane object from the form fields
  /// and saves it to the database.
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

  /// Updates the currently selected airplane in the database.
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

  /// Clears the form fields and resets the state for adding a new airplane.
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

  /// Shows the dialog to copy previous airplane data or start with a blank form.
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

  /// Displays help dialog with instructions for using the app.
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

/// Shows the language selection dialog to change app language.
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
  /// Used for displaying success messages after CRUD operations
  /// and other important feedback to the user.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an alert dialog with the specified title and content.
  /// Used for validation errors, confirmation messages, and other alerts.
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

  /// Builds the main UI of the AirplanesPage.
  /// Implements the master-detail layout for tablet and desktop,
  /// and full-screen switching for phone layout.
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
          
          if ((_selectedAirplane != null || _isAddingNew) && !isTabletLayout)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _closeDetails,
              tooltip: 'Back to List',
            ),
          
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
      
      floatingActionButton: (_selectedAirplane == null && !_isAddingNew)
          ? FloatingActionButton(
        onPressed: _showCopyDataDialog,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  /// Builds the tablet layout with master-detail view.
  /// On tablets, this shows a list of airplanes on the left
  /// and the selected airplane details on the right.
  Widget _buildTabletLayout() {
    final localizations = AppLocalizations.of(context);

    return Row(
      children: [
        
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

  
  Widget _buildPhoneLayout() {
    if (_selectedAirplane != null || _isAddingNew) {
      
      return _buildAirplaneForm();
    } else {
      
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

  /// Builds the airplane form widget for adding or editing airplanes.
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

  /// Builds the list of airplanes.
  /// Displays each airplane in a card with its details.
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
