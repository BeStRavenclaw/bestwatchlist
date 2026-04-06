import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/movie.dart';
import '../models/user_settings.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezones
    tz_data.initializeTimeZones();

    // Set the local timezone based on device timezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    await _createNotificationChannels();

    _initialized = true;
  }

  /// Request notification permissions (iOS and Android 13+)
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    // Request iOS permissions
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != true) return false;
    }

    // Request Android 13+ permissions
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted != true) return false;

      // Check and request exact alarm permission (required for Android 12+)
      final canScheduleExact = await androidPlugin.canScheduleExactNotifications();
      if (canScheduleExact != true) {
        // Open system settings for user to grant exact alarm permission
        await androidPlugin.requestExactAlarmsPermission();
        // Note: User needs to manually enable it in settings
        // We'll check again when actually scheduling
      }
    }

    return true;
  }

  /// Check if exact alarms can be scheduled (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.canScheduleExactNotifications() ?? false;
    }
    return true; // Non-Android platforms don't need this check
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Channel for release notifications
    const releaseChannel = AndroidNotificationChannel(
      'release_notifications',
      'Release Notifications',
      description: 'Notifications about movie releases',
      importance: Importance.high,
    );

    // Channel for cinema notifications
    const cinemaChannel = AndroidNotificationChannel(
      'cinema_notifications',
      'Cinema Notifications',
      description: 'Notifications about movies leaving cinema',
      importance: Importance.defaultImportance,
    );

    // Channel for streaming notifications
    const streamingChannel = AndroidNotificationChannel(
      'streaming_notifications',
      'Streaming Notifications',
      description: 'Notifications about streaming availability',
      importance: Importance.defaultImportance,
    );

    await androidPlugin.createNotificationChannel(releaseChannel);
    await androidPlugin.createNotificationChannel(cinemaChannel);
    await androidPlugin.createNotificationChannel(streamingChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Navigation to movie details can be implemented when navigation is set up
    // The payload contains the movie ID
  }

  /// Schedule Sunday before notification (the Sunday before release week)
  Future<void> scheduleSundayBeforeNotification(
    Movie movie,
    UserSettings settings,
  ) async {
    // Ensure service is initialized before scheduling
    if (!_initialized) {
      await initialize();
    }

    if (!settings.notificationsEnabled ||
        !settings.sundayBeforeNotifications) {
      return;
    }

    // Don't schedule notifications for TBD release dates
    if (movie.isTbd) return;

    final releaseDate = movie.releaseDate;
    // Calculate the Sunday before the release date
    // weekday: 1=Monday, 7=Sunday
    // If release is on Sunday, go back 7 days to previous Sunday
    // Otherwise, go back to the most recent Sunday
    final daysToSubtract = releaseDate.weekday == DateTime.sunday
        ? 7
        : releaseDate.weekday; // weekday gives days since Sunday (Mon=1, Sun=7)
    final notificationDate = releaseDate.subtract(Duration(days: daysToSubtract));
    final scheduledDate = tz.TZDateTime.from(
      DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        10, // 10 AM
      ),
      tz.local,
    );

    // Don't schedule if the date has passed
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // Use exact alarms if available, otherwise fall back to inexact
    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _notifications.zonedSchedule(
      _getSundayBeforeNotificationId(movie.id),
      'Movie releasing this week!',
      '${movie.title} releases on ${_formatDate(releaseDate)}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'release_notifications',
          'Release Notifications',
          channelDescription: 'Notifications about movie releases',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: movie.id,
    );
  }

  /// Schedule release day notification
  Future<void> scheduleReleaseDayNotification(
    Movie movie,
    UserSettings settings,
  ) async {
    // Ensure service is initialized before scheduling
    if (!_initialized) {
      await initialize();
    }

    if (!settings.notificationsEnabled || !settings.releaseDayNotifications) {
      return;
    }

    // Don't schedule notifications for TBD release dates
    if (movie.isTbd) return;

    final releaseDate = movie.releaseDate;
    final scheduledDate = tz.TZDateTime.from(
      DateTime(
        releaseDate.year,
        releaseDate.month,
        releaseDate.day,
        10, // 10 AM
      ),
      tz.local,
    );

    // Don't schedule if the date has passed
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // Use exact alarms if available, otherwise fall back to inexact
    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _notifications.zonedSchedule(
      _getReleaseDayNotificationId(movie.id),
      'Movie released today!',
      '${movie.title} is now available in theaters!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'release_notifications',
          'Release Notifications',
          channelDescription: 'Notifications about movie releases',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: movie.id,
    );
  }

  /// Schedule Saturday after notification (the Saturday after release)
  Future<void> scheduleSaturdayAfterNotification(
    Movie movie,
    UserSettings settings,
  ) async {
    // Ensure service is initialized before scheduling
    if (!_initialized) {
      await initialize();
    }

    if (!settings.notificationsEnabled ||
        !settings.saturdayAfterNotifications) {
      return;
    }

    // Don't schedule notifications for TBD release dates
    if (movie.isTbd) return;

    final releaseDate = movie.releaseDate;
    // Calculate the Saturday after the release date
    // weekday: 1=Monday, 7=Sunday, Saturday=6
    // If release is on Saturday, go forward 7 days to next Saturday
    // Otherwise, calculate days until next Saturday
    final daysUntilSaturday = releaseDate.weekday == DateTime.saturday
        ? 7
        : (DateTime.saturday - releaseDate.weekday + 7) % 7;
    // If daysUntilSaturday is 0 (shouldn't happen due to above check), use 7
    final daysToAdd = daysUntilSaturday == 0 ? 7 : daysUntilSaturday;
    final notificationDate = releaseDate.add(Duration(days: daysToAdd));
    final scheduledDate = tz.TZDateTime.from(
      DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        10, // 10 AM
      ),
      tz.local,
    );

    // Don't schedule if the date has passed
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // Use exact alarms if available, otherwise fall back to inexact
    final scheduleMode = await canScheduleExactAlarms()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    await _notifications.zonedSchedule(
      _getSaturdayAfterNotificationId(movie.id),
      'Have you seen it yet?',
      '${movie.title} was released this week. Don\'t forget to watch it!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'release_notifications',
          'Release Notifications',
          channelDescription: 'Notifications about movie releases',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: movie.id,
    );
  }

  /// Show left cinema notification (immediate)
  Future<void> showLeftCinemaNotification(
    Movie movie,
    UserSettings settings,
  ) async {
    // Ensure service is initialized before showing notification
    if (!_initialized) {
      await initialize();
    }

    if (!settings.notificationsEnabled || !settings.leftCinemaNotifications) {
      return;
    }

    if (movie.notifiedLeftCinema) return;

    await _notifications.show(
      _getLeftCinemaNotificationId(movie.id),
      'Movie leaving theaters soon',
      '${movie.title} is leaving theaters. Last chance to watch it on the big screen!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cinema_notifications',
          'Cinema Notifications',
          channelDescription: 'Notifications about movies leaving cinema',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: movie.id,
    );
  }

  /// Show streaming available notification (immediate)
  Future<void> showStreamingAvailableNotification(
    Movie movie,
    String streamingService,
    UserSettings settings,
  ) async {
    // Ensure service is initialized before showing notification
    if (!_initialized) {
      await initialize();
    }

    if (!settings.notificationsEnabled ||
        !settings.streamingAvailableNotifications) {
      return;
    }

    if (movie.notifiedStreamingAvailable) return;

    await _notifications.show(
      _getStreamingAvailableNotificationId(movie.id),
      'Now streaming!',
      '${movie.title} is now available on $streamingService',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streaming_notifications',
          'Streaming Notifications',
          channelDescription: 'Notifications about streaming availability',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: movie.id,
    );
  }

  /// Cancel all notifications for a movie
  Future<void> cancelMovieNotifications(String movieId) async {
    await _notifications.cancel(_getSundayBeforeNotificationId(movieId));
    await _notifications.cancel(_getReleaseDayNotificationId(movieId));
    await _notifications.cancel(_getSaturdayAfterNotificationId(movieId));
    await _notifications.cancel(_getLeftCinemaNotificationId(movieId));
    await _notifications.cancel(_getStreamingAvailableNotificationId(movieId));
  }

  /// Cancel specific notification types for a movie
  Future<void> cancelSundayBeforeNotification(String movieId) async {
    await _notifications.cancel(_getSundayBeforeNotificationId(movieId));
  }

  Future<void> cancelReleaseDayNotification(String movieId) async {
    await _notifications.cancel(_getReleaseDayNotificationId(movieId));
  }

  Future<void> cancelSaturdayAfterNotification(String movieId) async {
    await _notifications.cancel(_getSaturdayAfterNotificationId(movieId));
  }

  /// Reschedule all notifications for a movie (when release date changes)
  Future<void> rescheduleMovieNotifications(
    Movie movie,
    UserSettings settings,
  ) async {
    await cancelMovieNotifications(movie.id);
    await scheduleSundayBeforeNotification(movie, settings);
    await scheduleReleaseDayNotification(movie, settings);
    await scheduleSaturdayAfterNotification(movie, settings);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Generate unique notification IDs based on movie ID and type
  /// Uses smart ID generation to fit within 32-bit signed integer range
  int _getSundayBeforeNotificationId(String movieId) =>
      _generateNotificationId(movieId, 1);
  int _getReleaseDayNotificationId(String movieId) =>
      _generateNotificationId(movieId, 2);
  int _getSaturdayAfterNotificationId(String movieId) =>
      _generateNotificationId(movieId, 3);
  int _getLeftCinemaNotificationId(String movieId) =>
      _generateNotificationId(movieId, 4);
  int _getStreamingAvailableNotificationId(String movieId) =>
      _generateNotificationId(movieId, 5);

  /// Generate a notification ID that fits in 32-bit signed integer range
  int _generateNotificationId(String movieId, int type) {
    // Use bitwise operations to keep the ID in a safe range
    // Max value: 0x007FFFFF (134,217,727) * 10 + type = max 1,342,177,279 (safe!)
    final baseId = movieId.hashCode.abs() & 0x007FFFFF;
    return baseId * 10 + type;
  }

  /// Format date for display in notifications
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
