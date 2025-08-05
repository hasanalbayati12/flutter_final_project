import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/customers_page.dart';
// TODO: Teammates will uncomment these when they add their files
// import 'pages/airplanes_page.dart';
// import 'pages/flights_page.dart';
// import 'pages/reservations_page.dart';
import 'utils/localizations.dart';

/// Entry point for the CST2335 Final Project - Airline Management System.
/// Team integration project with all four modules.
void main() {
  runApp(const MyApp());
}

/// Main application widget with internationalization support.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Changes application language dynamically.
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

/// State class managing application locale.
class _MyAppState extends State<MyApp> {
  /// Current application locale.
  Locale _locale = const Locale('en', '');

  /// Updates application language.
  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airline Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('fr', ''), // French
        Locale('es', ''), // Spanish
      ],
      home: const MainPage(),
    );
  }
}

/// Main landing page with navigation to all four project modules.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  /// Shows help dialog with application instructions.
  void _showHelpDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('application_instructions') ?? 'Application Instructions'),
          content: SingleChildScrollView(
            child: Text(
              localizations?.translate('help_content') ??
                  'Airline Management System\n\n'
                      '• Customer List: Manage customer information\n'
                      '• Airplane List: Track company aircraft\n'
                      '• Flights List: Manage flight routes\n'
                      '• Reservations: Book customers on flights\n\n'
                      'Each section allows you to add, view, update, and delete records.\n'
                      'All data is automatically saved to database.',
            ),
          ),
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

  /// Shows language selection dialog.
  void _showLanguageDialog(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations?.translate('app_title') ?? 'Airline Management System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: localizations?.translate('language') ?? 'Language',
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => _showHelpDialog(context),
            tooltip: localizations?.translate('help') ?? 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations?.translate('welcome_message') ?? 'Welcome to Airline Management System',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                //Customer Management
                _buildNavigationButton(
                  context,
                  localizations?.translate('customer_list') ?? 'Customer List',
                  Icons.people,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomersPage()),
                  ),
                ),
                const SizedBox(height: 20),

                // TODO: Teammates will uncomment these when they add their files
                _buildDisabledButton(
                  context,
                  localizations?.translate('airplane_list') ?? 'Airplane List',
                  Icons.flight,
                  'Coming Soon - Teammate Module',
                ),
                /* TODO: Uncomment when teammate adds airplanes_page.dart
                _buildNavigationButton(
                  context,
                  localizations?.translate('airplane_list') ?? 'Airplane List',
                  Icons.flight,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AirplanesPage()),
                  ),
                ),
                */
                const SizedBox(height: 20),

                _buildDisabledButton(
                  context,
                  localizations?.translate('flights_list') ?? 'Flights List',
                  Icons.flight_takeoff,
                  'Coming Soon - Teammate Module',
                ),
                /* TODO: Uncomment when teammate adds flights_page.dart
                _buildNavigationButton(
                  context,
                  localizations?.translate('flights_list') ?? 'Flights List',
                  Icons.flight_takeoff,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FlightsPage()),
                  ),
                ),
                */
                const SizedBox(height: 20),

                _buildDisabledButton(
                  context,
                  localizations?.translate('reservations') ?? 'Reservations',
                  Icons.book_online,
                  'Coming Soon - Teammate Module',
                ),
                /* TODO: Uncomment when teammate adds reservations_page.dart
                _buildNavigationButton(
                  context,
                  localizations?.translate('reservations') ?? 'Reservations',
                  Icons.book_online,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReservationsPage()),
                  ),
                ),
                */

                const SizedBox(height: 40), // Extra space at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds styled navigation button for implemented modules.
  Widget _buildNavigationButton(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds disabled button for modules not yet implemented.
  Widget _buildDisabledButton(
      BuildContext context,
      String title,
      IconData icon,
      String subtitle,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: null, // Disabled
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}