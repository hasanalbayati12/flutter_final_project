import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/airplane.dart';
import '../repositories/airplane_repository.dart';
import '../utils/localizations.dart';
import '../main.dart';

/// Airplane management page with CRUD functionality
class AirplanesPage extends StatefulWidget {
  const AirplanesPage({super.key});

  @override
  State<AirplanesPage> createState() => _AirplanesPageState();
}

class _AirplanesPageState extends State<AirplanesPage> {
  final AirplaneRepository _repo = AirplaneRepository();
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  List<Airplane> _planes = [];
  Airplane? _selected;
  bool _loading = true;
  bool _addingNew = false;

  // Form controllers
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlanes();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _seatsController.dispose();
    _speedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  /// Close details view
  void _closeDetails() {
    _clearForm();
  }

  /// Load all airplanes from database
  Future<void> _loadPlanes() async {
    setState(() => _loading = true);
    try {
      final planes = await _repo.getAllAirplanes();
      setState(() {
        _planes = planes;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Error loading planes: $e');
    }
  }

  /// Load previous airplane data from preferences
  Future<void> _loadPreviousData() async {
    try {
      final type = await _prefs.getString('prev_type') ?? '';
      final seats = await _prefs.getString('prev_seats') ?? '';
      final speed = await _prefs.getString('prev_speed') ?? '';
      final range = await _prefs.getString('prev_range') ?? '';

      if (type.isNotEmpty) {
        _typeController.text = type;
        _seatsController.text = seats;
        _speedController.text = speed;
        _rangeController.text = range;
      }
    } catch (e) {
      debugPrint('Error loading previous data: $e');
    }
  }

  /// Save airplane data to preferences
  Future<void> _savePreviousData() async {
    try {
      await _prefs.setString('prev_type', _typeController.text);
      await _prefs.setString('prev_seats', _seatsController.text);
      await _prefs.setString('prev_speed', _speedController.text);
      await _prefs.setString('prev_range', _rangeController.text);
    } catch (e) {
      debugPrint('Error saving previous data: $e');
    }
  }

  /// Validate form fields
  bool _validateFields() {
    final localizations = AppLocalizations.of(context);
    if (_typeController.text.trim().isEmpty ||
        _seatsController.text.trim().isEmpty ||
        _speedController.text.trim().isEmpty ||
        _rangeController.text.trim().isEmpty) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          localizations?.translate('all_fields_required') ?? 'All fields must be filled out.'
      );
      return false;
    }

    if (int.tryParse(_seatsController.text.trim()) == null) {
      _showAlertDialog(
          localizations?.translate('validation_error') ?? 'Validation Error',
          'Seats must be a valid number.'
      );
      return false;
    }

    return true;
  }

  /// Add new airplane
  Future<void> _addPlane() async {
    if (!_validateFields()) return;

    final plane = Airplane(
      type: _typeController.text.trim(),
      seats: int.parse(_seatsController.text.trim()),
      speed: _speedController.text.trim(),
      range: _rangeController.text.trim(),
    );

    try {
      await _repo.insertAirplane(plane);
      await _savePreviousData();
      _clearForm();
      _loadPlanes();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('airplane_added') ?? 'Plane added successfully!');
    } catch (e) {
      _showSnackBar('Error adding plane: $e');
    }
  }

  /// Update existing airplane
  Future<void> _updatePlane() async {
    if (_selected == null || !_validateFields()) return;

    final plane = Airplane(
      id: _selected!.id,
      type: _typeController.text.trim(),
      seats: int.parse(_seatsController.text.trim()),
      speed: _speedController.text.trim(),
      range: _rangeController.text.trim(),
    );

    try {
      await _repo.updateAirplane(plane);
      _clearForm();
      _loadPlanes();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('airplane_updated') ?? 'Plane updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating plane: $e');
    }
  }

  /// Delete selected airplane
  Future<void> _deletePlane() async {
    if (_selected == null) return;

    try {
      await _repo.deleteAirplane(_selected!.id!);
      _clearForm();
      _loadPlanes();
      final localizations = AppLocalizations.of(context);
      _showSnackBar(localizations?.translate('airplane_deleted') ?? 'Plane deleted successfully!');
    } catch (e) {
      _showSnackBar('Error deleting plane: $e');
    }
  }

  /// Clear form fields
  void _clearForm() {
    _typeController.clear();
    _seatsController.clear();
    _speedController.clear();
    _rangeController.clear();
    setState(() {
      _selected = null;
      _addingNew = false;
    });
  }

  /// Show copy data dialog
  void _showCopyDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('copy_previous_data') ?? 'Copy Previous Data'),
          content: Text(localizations?.translate('copy_previous_question') ??
              'Would you like to copy fields from the previous plane or start with a blank page?'),
          actions: [
            TextButton(
              onPressed: () {
                _clearForm();
                setState(() => _addingNew = true);
                Navigator.of(context).pop();
              },
              child: Text(localizations?.translate('blank_page') ?? 'Blank Page'),
            ),
            TextButton(
              onPressed: () {
                _loadPreviousData();
                setState(() => _addingNew = true);
                Navigator.of(context).pop();
              },
              child: Text(localizations?.translate('copy_previous_short') ?? 'Copy Previous'),
            ),
          ],
        );
      },
    );
  }

  /// Show help dialog
  void _showHelpDialog() {
    final localizations = AppLocalizations.of(context);
    _showAlertDialog(
      localizations?.translate('help') ?? 'Plane Management Help',
      localizations?.translate('help_content') ??
          'Instructions:\n\n'
              '• Tap "+" to add a new plane\n'
              '• Fill out all required fields\n'
              '• Select a plane from the list to view/edit details\n'
              '• Use Update button to save changes\n'
              '• Use Delete button to remove plane\n'
              '• Choose to copy previous data or start blank\n\n'
              'Aircraft Types: Airbus A350, A320, Boeing 777, etc.',
    );
  }

  /// Show language dialog
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

  /// Show snack bar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show alert dialog
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

  /// Build responsive layout
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    final isTablet = screenWidth > 600 && orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations?.translate('airplane_management') ?? 'Plane Management'),
        centerTitle: true,
        actions: [
          // Back button for phone layout
          if ((_selected != null || _addingNew) && !isTablet)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _closeDetails,
              tooltip: 'Back to List',
            ),
          // Help and language buttons
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
      body: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      floatingActionButton: (_selected == null && !_addingNew)
          ? FloatingActionButton(
              onPressed: _showCopyDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  /// Build tablet layout
  Widget _buildTabletLayout() {
    final localizations = AppLocalizations.of(context);

    return Row(
      children: [
        // List panel
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${localizations?.translate('airplanes_count') ?? 'Planes'} (${_planes.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(child: _buildPlaneList()),
            ],
          ),
        ),
        // Form panel
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
            child: _buildPlaneForm(),
          ),
        ),
      ],
    );
  }

  /// Build phone layout
  Widget _buildPhoneLayout() {
    if (_selected != null || _addingNew) {
      return _buildPlaneForm();
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${AppLocalizations.of(context)?.translate('airplanes_count') ?? 'Planes'} (${_planes.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(child: _buildPlaneList()),
        ],
      );
    }
  }

  /// Build airplane form
  Widget _buildPlaneForm() {
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
                (_selected == null || _addingNew)
                    ? (localizations?.translate('add_new_airplane') ?? 'Add New Plane')
                    : (localizations?.translate('edit_airplane') ?? 'Edit Plane'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('airplane_type') ?? 'Plane Type (e.g., Boeing 777, Airbus A350)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: localizations?.translate('passengers') ?? 'Number of Seats',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _speedController,
                decoration: InputDecoration(
                  labelText: localizations?.translate('max_speed') ?? 'Maximum Speed (e.g., 560 mph)',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rangeController,
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
                  if (_selected == null || _addingNew) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addPlane,
                        child: Text(localizations?.translate('submit') ?? 'Submit'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showCopyDialog,
                      child: Text(localizations?.translate('copy_previous') ?? 'Copy Previous'),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updatePlane,
                        child: Text(localizations?.translate('update') ?? 'Update'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _deletePlane,
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

  /// Build airplane list
  Widget _buildPlaneList() {
    final localizations = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_planes.isEmpty) {
      return Center(
        child: Text(
          localizations?.translate('no_airplanes_found') ?? 'No planes found. Add a plane to get started.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _planes.length,
      itemBuilder: (context, index) {
        final plane = _planes[index];
        final isSelected = _selected?.id == plane.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            leading: const Icon(Icons.flight, color: Colors.blue),
            title: Text(plane.type),
            subtitle: Text('${plane.seats} seats • ${plane.speed}'),
            trailing: Text('${localizations?.translate('range') ?? 'Range'}: ${plane.range}'),
            onTap: () {
              setState(() {
                _selected = plane;
                _addingNew = false;
              });
              _typeController.text = plane.type;
              _seatsController.text = plane.seats.toString();
              _speedController.text = plane.speed;
              _rangeController.text = plane.range;
            },
          ),
        );
      },
    );
  }
}
