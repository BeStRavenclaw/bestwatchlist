import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/movie.dart';
import 'models/user_settings.dart';
import 'screens/browse_screen.dart';
import 'screens/cinema_screen.dart';
import 'screens/streaming_screen.dart';
import 'screens/settings_screen.dart';
import 'services/background_sync.dart';
import 'services/home_widget_service.dart';
import 'controllers/movie_controller.dart';
import 'controllers/settings_controller.dart';
import 'repositories/tmdb_repository.dart';
import 'widgets/app_logo_header.dart';
import 'constants/app_icons.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(MovieAdapter());
  Hive.registerAdapter(WatchStatusAdapter());
  Hive.registerAdapter(UserSettingsAdapter());

  // Open Hive boxes
  await Hive.openBox<Movie>('movies');
  await Hive.openBox<UserSettings>('settings');

  // Initialize default settings if needed
  final settingsBox = Hive.box<UserSettings>('settings');
  if (settingsBox.isEmpty) {
    settingsBox.add(UserSettings.getDefault());
  } else {
    // Migration: If old settings exist without darkMode field, recreate
    try {
      final existingSettings = settingsBox.getAt(0);
      // Try to access darkMode to see if it exists
      existingSettings?.darkMode;
    } catch (e) {
      // Old format detected, clear and create new
      await settingsBox.clear();
      settingsBox.add(UserSettings.getDefault());
    }
  }

  // Initialize background sync (skip on Windows as workmanager is not supported)
  if (!Platform.isWindows) {
    await BackgroundSyncService.initialize();
    await BackgroundSyncService.schedulePeriodicSync();
  }

  // Initialize home widget service (Android only)
  if (Platform.isAndroid) {
    await HomeWidgetService.initialize();
    await HomeWidgetService.registerInteractivity();
  }

  runApp(const BeStWatchListApp());
}

/// Main application widget
class BeStWatchListApp extends StatelessWidget {
  const BeStWatchListApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Setup MVC controllers with Provider pattern
    // Share TMDbRepository instance between controllers for language sync
    final tmdbRepository = TMDbRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieController(tmdbRepository: tmdbRepository)),
        ChangeNotifierProvider(create: (_) => SettingsController(tmdbRepository: tmdbRepository)),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          final isDarkMode = settingsController.darkMode;

          return MaterialApp(
            title: 'BeStWatchList',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  /// Build light theme with gold primary color
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.light,
        primary: AppColors.gold,
        secondary: AppColors.black,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.unselectedLight,
      ),
    );
  }

  /// Build dark theme with gold primary color and deep black background
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.dark,
        primary: AppColors.gold,
        secondary: AppColors.black,
        surface: AppColors.black,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.unselectedDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),
    );
  }
}

/// Home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Start at Cinema tab (index 1)

  final List<Widget> _screens = [
    const BrowseScreen(),
    const CinemaScreen(),
    const StreamingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogoHeader(),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(AppIcons.browse),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.cinema),
            label: 'Cinema',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.library),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
