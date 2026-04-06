import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as developer;
import '../models/movie.dart';
import '../models/user_settings.dart';
import '../repositories/tmdb_repository.dart';
import '../repositories/movie_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/notification_service.dart';

/// Background task callback dispatcher
/// This must be a top-level function (not inside a class)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Hive for background isolate
      await Hive.initFlutter();

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(MovieAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(WatchStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(UserSettingsAdapter());
      }

      // Open Hive boxes
      await Hive.openBox<Movie>('movies');
      await Hive.openBox<UserSettings>('settings');

      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Perform release date refresh and notification rescheduling
      final result =
          await _refreshReleaseDatesAndNotifications(notificationService);

      // Refresh streaming availability for all movies
      await _refreshStreamingAvailability(notificationService);

      // Check for cinema and streaming notifications (~90 days)
      await _checkCinemaAndStreamingNotifications(notificationService);

      // Close Hive boxes
      await Hive.close();

      developer.log('Background sync completed. Updated: $result movies');
      return true;
    } catch (e) {
      developer.log('Background sync failed: $e');
      return false;
    }
  });
}

/// Refresh release dates and reschedule notifications
Future<int> _refreshReleaseDatesAndNotifications(
    NotificationService notificationService) async {
  final movieRepository = MovieRepository();
  final tmdbRepository = TMDbRepository();
  final settingsRepository = SettingsRepository();

  final movies = await movieRepository.getAllMovies();
  final settings = await settingsRepository.getSettings();
  int updatedCount = 0;

  for (final movie in movies) {
    // Only refresh TMDb movies
    if (movie.id.startsWith('tmdb_')) {
      try {
        final tmdbId = int.parse(movie.id.substring(5));
        final updatedMovie = await tmdbRepository.getMovieDetails(tmdbId);

        if (updatedMovie != null) {
          bool hasChanges = false;
          bool releaseDateChanged = false;

          // Update title if changed (handles working title -> official title)
          if (movie.title != updatedMovie.title) {
            developer.log(
                'Title changed: "${movie.title}" -> "${updatedMovie.title}"');
            movie.title = updatedMovie.title;
            hasChanges = true;
          }

          // Update release date if changed
          if (movie.releaseDate != updatedMovie.releaseDate) {
            developer.log(
                'Release date changed for ${movie.title}: ${movie.releaseDate} -> ${updatedMovie.releaseDate}');
            movie.releaseDate = updatedMovie.releaseDate;
            hasChanges = true;
            releaseDateChanged = true;
          }

          // Update poster if changed
          if (movie.posterUrl != updatedMovie.posterUrl) {
            movie.posterUrl = updatedMovie.posterUrl;
            hasChanges = true;
          }

          // Update description if changed
          if (movie.description != updatedMovie.description) {
            movie.description = updatedMovie.description;
            hasChanges = true;
          }

          // Update original release year if changed (for Cineman URLs)
          if (movie.originalReleaseYear != updatedMovie.originalReleaseYear) {
            movie.originalReleaseYear = updatedMovie.originalReleaseYear;
            hasChanges = true;
          }

          if (hasChanges) {
            movie.markAsModified();
            await movieRepository.updateMovie(movie);

            // Reschedule notifications if release date changed
            if (releaseDateChanged && settings.notificationsEnabled) {
              await notificationService.rescheduleMovieNotifications(
                  movie, settings);
            }

            updatedCount++;
          }
        }
      } catch (e) {
        developer.log('Failed to update ${movie.title}: $e');
      }
    }
  }

  return updatedCount;
}

/// Refresh streaming availability for all movies
Future<void> _refreshStreamingAvailability(
    NotificationService notificationService) async {
  final movieRepository = MovieRepository();
  final tmdbRepository = TMDbRepository();
  final settingsRepository = SettingsRepository();

  final movies = await movieRepository.getAllMovies();
  final settings = await settingsRepository.getSettings();

  for (final movie in movies) {
    // Only refresh TMDb movies
    if (movie.id.startsWith('tmdb_')) {
      try {
        final tmdbId = int.parse(movie.id.substring(5));
        final providers = await tmdbRepository.getStreamingProviders(tmdbId);

        // Check if streaming availability changed
        final currentProviders = movie.availableOnStreamingServices ?? [];
        final hasChanged = !_listsEqual(currentProviders, providers);

        if (hasChanged) {
          // Update streaming services
          movie.availableOnStreamingServices =
              providers.isNotEmpty ? providers : null;
          movie.markAsModified();
          await movieRepository.updateMovie(movie);

          developer.log('Updated streaming for ${movie.title}: $providers');

          // Check if we should notify (new services available on user's list)
          if (settings.notificationsEnabled &&
              settings.streamingAvailableNotifications &&
              !movie.notifiedStreamingAvailable &&
              providers.isNotEmpty) {
            final userServices = settings.streamingServices;
            final newMatchingServices = providers
                .where((service) => userServices.contains(service))
                .toList();

            // Only notify if there are new matches
            final oldMatchingServices = currentProviders
                .where((service) => userServices.contains(service))
                .toList();

            if (newMatchingServices.isNotEmpty && oldMatchingServices.isEmpty) {
              await notificationService.showStreamingAvailableNotification(
                movie,
                newMatchingServices.first,
                settings,
              );

              movie.notifiedStreamingAvailable = true;
              movie.markAsModified();
              await movieRepository.updateMovie(movie);

              developer.log(
                  'Sent streaming notification for ${movie.title} on ${newMatchingServices.first}');
            }
          }
        }
      } catch (e) {
        developer.log('Failed to refresh streaming for ${movie.title}: $e');
      }
    }
  }
}

/// Helper to compare two lists for equality
bool _listsEqual(List<String> list1, List<String> list2) {
  if (list1.length != list2.length) return false;
  final set1 = list1.toSet();
  final set2 = list2.toSet();
  return set1.containsAll(set2) && set2.containsAll(set1);
}

/// Check for cinema departure notifications (~90 days after release)
Future<void> _checkCinemaAndStreamingNotifications(
    NotificationService notificationService) async {
  final movieRepository = MovieRepository();
  final settingsRepository = SettingsRepository();

  final movies = await movieRepository.getAllMovies();
  final settings = await settingsRepository.getSettings();

  if (!settings.notificationsEnabled) return;

  final now = DateTime.now();

  for (final movie in movies) {
    try {
      // Check if movie has left cinema (approximately 90 days after release)
      if (settings.leftCinemaNotifications &&
          !movie.notifiedLeftCinema &&
          movie.status == WatchStatus.wantToWatch) {
        final daysSinceRelease = now.difference(movie.releaseDate).inDays;

        // Notify if movie is between 80-90 days old (near end of theatrical run)
        if (daysSinceRelease >= 80 && daysSinceRelease <= 90) {
          await notificationService.showLeftCinemaNotification(movie, settings);

          // Mark as notified
          movie.notifiedLeftCinema = true;
          movie.markAsModified();
          await movieRepository.updateMovie(movie);

          developer
              .log('Sent cinema departure notification for ${movie.title}');
        }
      }
    } catch (e) {
      developer.log('Failed to check cinema notification for ${movie.title}: $e');
    }
  }
}

/// Background sync service for managing periodic tasks
class BackgroundSyncService {
  static const String _taskName = 'weekly_release_date_update';

  /// Initialize the background service
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Schedule weekly periodic sync
  static Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(days: 7), // Weekly updates
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }

  /// Cancel periodic sync
  static Future<void> cancelPeriodicSync() async {
    await Workmanager().cancelByUniqueName(_taskName);
  }

  /// Cancel all background tasks
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
