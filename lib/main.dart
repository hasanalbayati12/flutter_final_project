import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/customers_page.dart';
import 'pages/airplanes_page.dart';
import 'pages/flights_page.dart';
import 'pages/reservations_page.dart';
import 'utils/localizations.dart';
// import 'package:flutter/services.dart';

/// Entry point for the CST2335 Final Project - Airline Management System.
/// This Flutter application implements all 11 requirements from the assignment:
/// 1. ListView with user-inserted items
/// 2. TextField + Button for data entry
/// 3. Database persistence using Floor/SQLite
/// 4. Responsive layouts for phone/tablet
/// 5. AlertDialog and Snackbar notifications
/// 6. EncryptedSharedPreferences for form data
/// 7. ActionBar with ActionItems
/// 8. Multi-language support (English/French/Spanish)
/// 9. Team integration via GitHub
/// 10. Professional UI design
/// 11. Comprehensive Dartdoc documentation
/// The application follows the patterns demonstrated in course slides and
/// implements the group project requirements where each team member creates
/// one of four modules: Customer, Airplane, Flight, or Reservation management.
void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);
  runApp(const MyApp());
}

/// Main application widget implementing internationalization support.
/// This StatefulWidget serves as the root of the application and manages
/// the global locale state for multi-language support (Requirement 8).
/// It follows the internationalization pattern from the course slides
/// using AppLocalizations and supports dynamic language switching.
/// The app provides a centralized navigation hub to access all four
/// major modules as required by the assignment specifications.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Static method to change the application language from any widget.
  /// This method implements the language switching pattern from the
  /// internationalization slides by finding the app's state and
  /// calling the changeLanguage method to update the locale.
  /// [context] - Build context to locate the app state
  /// [newLocale] - New locale to switch to (en, fr, or es)
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

/// State class for MyApp managing the application locale.
/// This class maintains the current locale state and provides the
/// MaterialApp configuration including localization delegates,
/// supported locales, and theme configuration following Material 3 design.
class _MyAppState extends State<MyApp> {
  /// Current application locale, defaults to English.
  /// Can be changed dynamically through the language selection dialog.
  Locale _locale = const Locale('en', '');

  /// Changes the application language and triggers a rebuild.
  /// This method updates the locale state and calls setState() to
  /// rebuild the widget tree with the new language configuration.
  /// All AppLocalizations throughout the app will automatically
  /// update to display text in the selected language.
  /// [locale] - New locale to apply to the application
  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  /// Builds the MaterialApp with full internationalization support.
  /// Configures the app with:
  /// - Material 3 theme with blue color scheme
  /// - Multi-language support via localization delegates
  /// - Support for English, French, and Spanish locales
  /// - MainPage as the home screen with navigation to all modules
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
/// Main landing page providing navigation to all four project modules.
/// This StatelessWidget serves as the central hub of the application,
/// implementing the assignment requirement for "a main page that shows
/// once your application is launched" with "4 buttons that launches
/// a page that is the landing page for your part of the project."
/// The page includes:
/// - Welcome message with internationalization
/// - Navigation buttons to Customer, Airplane, Flight, and Reservation pages
/// - Language selection and help functionality in the AppBar
/// - Professional Material 3 design with proper spacing and alignment
class MainPage extends StatelessWidget {
  const MainPage({super.key});
  /// Shows help dialog with application instructions implementing Requirement 7.
  /// Creates an AlertDialog that provides users with guidance on how to
  /// use the application, explaining each module's purpose and functionality.
  /// The dialog content is internationalized and scrollable for different
  /// screen sizes.
  /// [context] - Build context for showing the dialog
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
  /// Shows language selection dialog for internationalization.
  /// Creates an AlertDialog allowing users to switch between supported
  /// languages (English, French, Spanish). Each language option includes
  /// a flag emoji and calls MyApp.setLocale() to change the app language.
  /// This implements Requirement 8 for multi-language support.
  /// [context] - Build context for showing the dialog and locale changes
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
  /// Builds the main page layout with navigation to all modules.
  /// Creates a professional interface following Material 3 design principles
  /// with proper spacing, typography, and user experience patterns.
  /// The layout includes:
  /// - AppBar with language and help ActionItems (Requirement 7)
  /// - Welcome message with internationalization
  /// - Four navigation buttons for project modules
  /// - Responsive design that works on different screen sizes
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
                _buildNavigationButton(
                  context,
                  localizations?.translate('airplane_list') ?? 'Airplane List',
                  Icons.flight,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AirplanesPage()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildNavigationButton(
                  context,
                  localizations?.translate('flights_list') ?? 'Flights List',
                  Icons.flight_takeoff,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FlightsPage()),
                  ),
                ),
                const SizedBox(height: 20),
                _buildNavigationButton(
                  context,
                  localizations?.translate('reservations') ?? 'Reservations',
                  Icons.book_online,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReservationsPage()),
                  ),
                ),
                const SizedBox(height: 40), // Extra space at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a styled navigation button for module access.
  /// Creates a consistent, professional button design following Material 3
  /// principles with proper sizing, iconography, and typography.
  /// Each button navigates to one of the four required project modules.
  /// [context] - Build context for theme access
  /// [title] - Localized button text
  /// [icon] - Material icon for the button
  /// [onPressed] - Navigation callback function
  /// Returns a styled ElevatedButton with consistent design across all modules.
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
}