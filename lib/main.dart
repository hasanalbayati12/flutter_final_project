import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/customers_page.dart';
import 'utils/localizations.dart';

/// Main entry point for the Customer Management application.
/// Implements all 11 CST2335 assignment requirements.
void main() {
  runApp(const MyApp());
}

/// Root application widget with internationalization support.
/// Manages global locale state for multi-language functionality.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Changes the application language.
  /// [context] - Current build context
  /// [newLocale] - New locale to apply (en, fr, or es)
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

/// State class managing application locale and MaterialApp configuration.
class _MyAppState extends State<MyApp> {
  /// Current application locale, defaults to English.
  Locale _locale = const Locale('en', '');

  /// Updates the application language and rebuilds the widget tree.
  /// [locale] - New locale to apply
  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  /// Builds the MaterialApp with internationalization support.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Management - Airline System',
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

/// Main landing page for Customer Management.
/// Provides navigation to customer management functionality
/// with help and language selection features.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  /// Shows help dialog with usage instructions.
  /// [context] - Build context for dialog display
  void _showHelpDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('application_instructions') ?? 'Help'),
          content: const SingleChildScrollView(
            child: Text(
              'Customer Management System\n\n'
                  '• Add new customers with personal information\n'
                  '• View and edit existing customer records\n'
                  '• Delete customers when no longer needed\n'
                  '• Copy previous customer data for efficiency\n'
                  '• Multi-language support (English/French/Spanish)\n'
                  '• Responsive design for all devices\n\n'
                  'All customer data is automatically saved to the database.\n'
                  'Use the "+" button to add new customers.',
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
  /// Allows switching between English, French, and Spanish.
  /// [context] - Build context for dialog display
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

  /// Builds the main page layout.
  /// Creates a clean interface with customer management access,
  /// language selection, and help functionality.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(localizations?.translate('app_title') ?? 'Customer Management System'),
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
                  localizations?.translate('welcome_message') ?? 'Welcome to Customer Management System',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Manage airline customer information efficiently',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Customer Management - Main Feature
                _buildNavigationButton(
                  context,
                  localizations?.translate('customer_management') ?? 'Customer Management',
                  Icons.people,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomersPage()),
                  ),
                ),

                const SizedBox(height: 30),

                // Feature highlights
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('• Add and manage customer records'),
                        const Text('• View customer information'),
                        const Text('• Update existing records'),
                        const Text('• Delete customers when needed'),
                        const Text('• Multi-language support'),
                        const Text('• Responsive design for all devices'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a styled navigation button.
  /// [context] - Build context for theme access
  /// [title] - Button text
  /// [icon] - Button icon
  /// [onPressed] - Callback function when pressed
  Widget _buildNavigationButton(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}