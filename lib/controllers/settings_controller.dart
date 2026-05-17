import 'package:flutter/foundation.dart';
import '../models/user_settings.dart';
import '../repositories/settings_repository.dart';
import '../services/notification_service.dart';
import '../repositories/movie_repository.dart';
import '../repositories/tmdb_repository.dart';

/// Controller for managing app settings
/// Extends ChangeNotifier for Provider pattern integration
class SettingsController extends ChangeNotifier {
  final SettingsRepository _repository;
  final NotificationService _notificationService;
  final MovieRepository _movieRepository;
  final TMDbRepository _tmdbRepository;
  UserSettings? _settings;
  bool _isLoading = false;

  SettingsController({
    SettingsRepository? repository,
    NotificationService? notificationService,
    MovieRepository? movieRepository,
    TMDbRepository? tmdbRepository,
  })  : _repository = repository ?? SettingsRepository(),
        _notificationService = notificationService ?? NotificationService(),
        _movieRepository = movieRepository ?? MovieRepository(),
        _tmdbRepository = tmdbRepository ?? TMDbRepository() {
    _loadSettings();
    _initializeNotificationsAndReschedule();
  }

  /// Initialize notification service and reschedule all notifications
  /// This ensures notifications are restored after device reboot or app reinstall
  Future<void> _initializeNotificationsAndReschedule() async {
    await _notificationService.initialize();

    // Wait for settings to be loaded
    while (_settings == null) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Reschedule all notifications if enabled
    // This handles cases where notifications were lost due to:
    // - Device reboot (Android clears all scheduled alarms)
    // - App being force-stopped
    // - App data being cleared
    if (_settings!.notificationsEnabled) {
      // Ensure permissions are granted (including exact alarm permission on Android 12+)
      await _notificationService.requestPermissions();
      await _rescheduleAllMovieNotifications();
    }
  }

  // Getters
  UserSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get darkMode => _settings?.darkMode ?? true;
  List<String> get streamingServices => _settings?.streamingServices ?? [];
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  String get titleLanguage => _settings?.titleLanguage ?? 'en';
  String get releaseCountry => _settings?.releaseDateCountry ?? 'DE';
  String get appLanguage => _settings?.appLanguage ?? '';

  /// Load settings from repository
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _repository.getSettings();

    // Sync title language and release country with TMDB repository
    _tmdbRepository.setTitleLanguage(_settings?.titleLanguage ?? 'en');
    _tmdbRepository.setReleaseCountry(_settings?.releaseDateCountry ?? 'DE');

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh settings from repository
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  /// Apply imported settings from a map, overwriting current settings
  Future<void> applyImportedSettings(Map<String, dynamic> map) async {
    final imported = UserSettings.fromMap(map);
    imported.markAsModified();
    await _repository.saveSettings(imported);
    await _loadSettings();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    if (_settings == null) return;
    _settings!.darkMode = !_settings!.darkMode;
    _settings!.markAsModified();
    await _repository.saveSettings(_settings!);
    notifyListeners();
  }

  /// Update streaming services list
  Future<void> updateStreamingServices(List<String> services) async {
    if (_settings == null) return;
    _settings!.streamingServices = services;
    _settings!.markAsModified();
    await _repository.saveSettings(_settings!);
    notifyListeners();
  }

  /// Update title language setting
  Future<void> updateTitleLanguage(String languageCode) async {
    if (_settings == null) return;
    _settings!.titleLanguage = languageCode;
    _settings!.markAsModified();
    await _repository.saveSettings(_settings!);

    // Sync with TMDB repository
    _tmdbRepository.setTitleLanguage(languageCode);

    notifyListeners();
  }

  /// Update app display language setting
  Future<void> updateAppLanguage(String languageCode) async {
    if (_settings == null) return;
    _settings!.appLanguage = languageCode;
    _settings!.markAsModified();
    await _repository.saveSettings(_settings!);
    notifyListeners();
  }

  /// Update release date country setting
  Future<void> updateReleaseCountry(String countryCode) async {
    if (_settings == null) return;
    _settings!.releaseDateCountry = countryCode;
    _settings!.markAsModified();
    await _repository.saveSettings(_settings!);

    // Sync with TMDB repository
    _tmdbRepository.setReleaseCountry(countryCode);

    notifyListeners();
  }

  /// Toggle notifications enabled
  Future<void> toggleNotifications() async {
    if (_settings == null) return;

    final wasEnabled = _settings!.notificationsEnabled;
    _settings!.notificationsEnabled = !wasEnabled;
    _settings!.markAsModified();

    // Request permissions if enabling notifications
    if (_settings!.notificationsEnabled) {
      final permissionGranted = await _notificationService.requestPermissions();
      if (!permissionGranted) {
        // Revert if permission denied
        _settings!.notificationsEnabled = false;
        _settings!.markAsModified();
        await _repository.saveSettings(_settings!);
        notifyListeners();
        return;
      }

      // Reschedule all notifications for existing movies
      await _rescheduleAllMovieNotifications();
    } else {
      // Cancel all notifications if disabling
      await _notificationService.cancelAllNotifications();
    }

    await _repository.saveSettings(_settings!);
    notifyListeners();
  }

  /// Check if exact alarms can be scheduled (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    return await _notificationService.canScheduleExactAlarms();
  }

  /// Request exact alarm permission (opens system settings on Android 12+)
  Future<void> requestExactAlarmPermission() async {
    await _notificationService.requestPermissions();
  }

  /// Reschedule notifications for all movies in watchlist
  Future<void> _rescheduleAllMovieNotifications() async {
    if (_settings == null) return;

    final movies = await _movieRepository.getAllMovies();
    for (final movie in movies) {
      await _notificationService.rescheduleMovieNotifications(
          movie, _settings!);
    }
  }

  /// Update specific notification setting (DRY helper)
  Future<void> _updateNotificationSetting(
    bool Function(UserSettings) getter,
    void Function(UserSettings, bool) setter,
    Future<void> Function()? rescheduleCallback,
  ) async {
    if (_settings == null) return;
    setter(_settings!, !getter(_settings!));
    _settings!.markAsModified();
    await _repository.saveSettings(_settings!);

    // Reschedule notifications if callback provided
    if (rescheduleCallback != null) {
      await rescheduleCallback();
    }

    notifyListeners();
  }

  /// Toggle Sunday before notification
  Future<void> toggleSundayBeforeNotification() async {
    await _updateNotificationSetting(
      (s) => s.sundayBeforeNotifications,
      (s, v) => s.sundayBeforeNotifications = v,
      () async {
        if (_settings == null) return;
        final movies = await _movieRepository.getAllMovies();
        for (final movie in movies) {
          if (_settings!.sundayBeforeNotifications) {
            await _notificationService.scheduleSundayBeforeNotification(
                movie, _settings!);
          } else {
            await _notificationService.cancelSundayBeforeNotification(movie.id);
          }
        }
      },
    );
  }

  /// Toggle release day notification
  Future<void> toggleReleaseDayNotification() async {
    await _updateNotificationSetting(
      (s) => s.releaseDayNotifications,
      (s, v) => s.releaseDayNotifications = v,
      () async {
        if (_settings == null) return;
        final movies = await _movieRepository.getAllMovies();
        for (final movie in movies) {
          if (_settings!.releaseDayNotifications) {
            await _notificationService.scheduleReleaseDayNotification(
                movie, _settings!);
          } else {
            await _notificationService.cancelReleaseDayNotification(movie.id);
          }
        }
      },
    );
  }

  /// Toggle Saturday after notification
  Future<void> toggleSaturdayAfterNotification() async {
    await _updateNotificationSetting(
      (s) => s.saturdayAfterNotifications,
      (s, v) => s.saturdayAfterNotifications = v,
      () async {
        if (_settings == null) return;
        final movies = await _movieRepository.getAllMovies();
        for (final movie in movies) {
          if (_settings!.saturdayAfterNotifications) {
            await _notificationService.scheduleSaturdayAfterNotification(
                movie, _settings!);
          } else {
            await _notificationService
                .cancelSaturdayAfterNotification(movie.id);
          }
        }
      },
    );
  }

  /// Toggle left cinema notification
  Future<void> toggleLeftCinemaNotification() async {
    await _updateNotificationSetting(
      (s) => s.leftCinemaNotifications,
      (s, v) => s.leftCinemaNotifications = v,
      null, // No reschedule needed - triggered by background sync
    );
  }

  /// Toggle streaming available notification
  Future<void> toggleStreamingAvailableNotification() async {
    await _updateNotificationSetting(
      (s) => s.streamingAvailableNotifications,
      (s, v) => s.streamingAvailableNotifications = v,
      null, // No reschedule needed - triggered by background sync
    );
  }
}
