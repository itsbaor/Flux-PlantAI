import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/my_garden_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/plant_detail_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'models/plant.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Static method to change locale from anywhere
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleProvider _localeProvider = LocaleProvider();
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _localeProvider.addListener(_onLocaleChanged);
    _locale = _localeProvider.locale;
  }

  @override
  void dispose() {
    _localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {
      _locale = _localeProvider.locale;
    });
  }

  void setLocale(Locale locale) {
    _localeProvider.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return LocaleProviderInherited(
      provider: _localeProvider,
      child: MaterialApp(
        title: 'Plant AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF90EE90),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        locale: _locale,
        supportedLocales: LocaleProvider.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainNavigation(),
        onGenerateRoute: (settings) {
          if (settings.name == '/plant-detail') {
            final plant = settings.arguments as Plant;
            return MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plant: plant),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}

// InheritedWidget to provide LocaleProvider to descendants
class LocaleProviderInherited extends InheritedWidget {
  final LocaleProvider provider;

  const LocaleProviderInherited({
    super.key,
    required this.provider,
    required super.child,
  });

  static LocaleProvider of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<LocaleProviderInherited>();
    return inherited!.provider;
  }

  static LocaleProvider? maybeOf(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<LocaleProviderInherited>();
    return inherited?.provider;
  }

  @override
  bool updateShouldNotify(LocaleProviderInherited oldWidget) {
    return provider.locale != oldWidget.provider.locale;
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Method to change tab
  void _changeTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const MyGardenScreen(),
      ScanScreen(onClose: () => _changeTab(0)), // Pass callback to scan screen
      const ReminderScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
