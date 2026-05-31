import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../repositories/tmdb_repository.dart';
export '../repositories/tmdb_repository.dart' show TmdbApiStatus;
import '../repositories/settings_repository.dart';
import '../services/home_widget_service.dart';
import '../services/notification_service.dart';
import '../services/import_export_service.dart';

/// Controller for managing movie-related business logic
/// Extends ChangeNotifier for Provider pattern integration
class MovieController extends ChangeNotifier {
  final MovieRepository _movieRepository;
  final TMDbRepository _tmdbRepository;
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;

  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  MovieController({
    MovieRepository? movieRepository,
    TMDbRepository? tmdbRepository,
    NotificationService? notificationService,
    SettingsRepository? settingsRepository,
  })  : _movieRepository = movieRepository ?? MovieRepository(),
        _tmdbRepository = tmdbRepository ?? TMDbRepository(),
        _notificationService = notificationService ?? NotificationService(),
        _settingsRepository = settingsRepository ?? SettingsRepository() {
    _loadMovies();
  }

  // Getters
  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TmdbApiStatus get tmdbApiStatus => _tmdbRepository.apiStatus;

  /// Get movies filtered by status
  List<Movie> getMoviesByStatus(WatchStatus status) {
    return _movies.where((movie) => movie.status == status).toList();
  }

  /// Get upcoming movies (want to watch, not yet released)
  List<Movie> getUpcomingMovies() {
    return _movies
        .where((movie) =>
            movie.status == WatchStatus.wantToWatch && !movie.hasBeenReleased)
        .toList();
  }

  /// Load all movies from repository
  Future<void> _loadMovies() async {
    _movies = await _movieRepository.getAllMovies();
    notifyListeners();
    // Update home screen widget with cinema movies
    await _updateWidget();
  }

  /// Update the home screen widget
  Future<void> _updateWidget() async {
    try {
      await HomeWidgetService.updateWidget(_movies);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update widget from movie controller',
        name: 'MovieController',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Refresh movies list
  Future<void> refreshMovies() async {
    _setLoading(true);
    await _loadMovies();
    _setLoading(false);
  }

  /// Add a movie to the watchlist
  Future<void> addToWatchlist(Movie movie) async {
    try {
      // Check if movie already exists
      if (await _movieRepository.movieExists(movie.id)) {
        _errorMessage = '${movie.title} is already in your watchlist';
        notifyListeners();
        return;
      }

      // Fetch streaming providers if this is a TMDb movie
      List<String>? streamingServices;
      if (movie.id.startsWith('tmdb_')) {
        try {
          final tmdbId = int.parse(movie.id.substring(5));
          streamingServices =
              await _tmdbRepository.getStreamingProviders(tmdbId);
        } catch (e) {
          developer.log(
            'Failed to fetch streaming providers for ${movie.title}',
            name: 'MovieController',
            error: e,
          );
        }
      }

      // Create movie with proper status and streaming data
      final newMovie = Movie(
        id: movie.id,
        title: movie.title,
        releaseDate: movie.releaseDate,
        posterUrl: movie.posterUrl,
        description: movie.description,
        status: WatchStatus.wantToWatch,
        imdbId: movie.imdbId,
        availableOnStreamingServices: streamingServices,
      );

      await _movieRepository.addMovie(newMovie);

      // Schedule notifications for the new movie
      await _scheduleNotificationsForMovie(newMovie);

      await _loadMovies();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add movie: $e';
      notifyListeners();
    }
  }

  /// Schedule notifications for a movie based on current settings
  Future<void> _scheduleNotificationsForMovie(Movie movie) async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (!settings.notificationsEnabled) return;

      await _notificationService.scheduleSundayBeforeNotification(
          movie, settings);
      await _notificationService.scheduleReleaseDayNotification(
          movie, settings);
      await _notificationService.scheduleSaturdayAfterNotification(
          movie, settings);
    } catch (e) {
      developer.log(
        'Failed to schedule notifications for ${movie.title}',
        name: 'MovieController',
        error: e,
      );
    }
  }

  /// Remove a movie from the watchlist
  Future<void> removeFromWatchlist(Movie movie) async {
    try {
      await _movieRepository.deleteMovie(movie);
      await _loadMovies();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to remove movie: $e';
      notifyListeners();
      return;
    }
    // Cancel notifications after successful delete — best-effort, must not block delete
    try {
      await _notificationService.cancelMovieNotifications(movie.id);
    } catch (e) {
      developer.log(
        'Failed to cancel notifications after delete for ${movie.id}',
        name: 'MovieController',
        error: e,
      );
    }
  }

  /// Update movie status (DRY helper method)
  Future<void> updateMovieStatus(Movie movie, WatchStatus newStatus) async {
    try {
      movie.status = newStatus;
      movie.markAsModified();
      await _movieRepository.updateMovie(movie);
      notifyListeners();
      await _updateWidget();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update movie: $e';
      notifyListeners();
    }
  }

  /// Mark movie as watched
  Future<void> markAsWatched(Movie movie) async {
    await updateMovieStatus(movie, WatchStatus.watched);
  }

  /// Mark movie as want to rewatch
  Future<void> markAsWantToRewatch(Movie movie) async {
    await updateMovieStatus(movie, WatchStatus.wantToRewatch);
  }

  /// Delete movie from library
  Future<void> deleteMovie(Movie movie) async {
    await removeFromWatchlist(movie);
  }

  /// Mark movie as save for streaming (no longer interested in cinema, but want streaming notification)
  Future<void> markAsSaveForStreaming(Movie movie) async {
    await updateMovieStatus(movie, WatchStatus.saveForStreaming);
  }

  /// Update streaming services for a movie
  Future<void> updateStreamingServices(
      Movie movie, List<String> services) async {
    try {
      movie.availableOnStreamingServices = services;
      movie.markAsModified();
      await _movieRepository.updateMovie(movie);
      notifyListeners();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update streaming services: $e';
      notifyListeners();
    }
  }

  /// Search movies on TMDb
  Future<List<Movie>> searchMovies(String query) async {
    _setLoading(true);
    try {
      final results = await _tmdbRepository.searchMovies(query);
      _errorMessage = null;
      return results;
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Get popular movies from TMDb
  Future<List<Movie>> getPopularMovies() async {
    return await _tmdbRepository.getPopularMovies();
  }

  /// Get now playing movies from TMDb
  Future<List<Movie>> getNowPlayingMovies() async {
    return await _tmdbRepository.getNowPlaying();
  }

  /// Get upcoming movies from TMDb
  Future<List<Movie>> getUpcomingMoviesFromTMDb() async {
    return await _tmdbRepository.getUpcoming();
  }

  /// Clear all movies from the database
  Future<void> clearAllMovies() async {
    try {
      await _movieRepository.clearAll();
      await _loadMovies();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to clear movies: $e';
      notifyListeners();
    }
  }

  /// Refresh all data from TMDb for all movies (same as weekly background sync)
  Future<int> refreshAllDataFromTMDb() async {
    _setLoading(true);
    int updatedCount = 0;

    try {
      final allMovies = await _movieRepository.getAllMovies();
      final settings = await _settingsRepository.getSettings();

      for (final movie in allMovies) {
        // Only refresh TMDb movies
        if (movie.id.startsWith('tmdb_')) {
          try {
            final tmdbId = int.parse(movie.id.substring(5));
            final updatedMovie = await _tmdbRepository.getMovieDetails(tmdbId);

            if (updatedMovie != null) {
              bool hasChanges = false;
              final List<String> changes = [];

              // Update title if changed (handles working title -> official title)
              if (movie.title != updatedMovie.title) {
                changes
                    .add('title: "${movie.title}" -> "${updatedMovie.title}"');
                movie.title = updatedMovie.title;
                hasChanges = true;
              }

              // Update release date if changed
              if (movie.releaseDate != updatedMovie.releaseDate) {
                changes.add(
                    'release date: ${movie.releaseDate} -> ${updatedMovie.releaseDate}');
                movie.releaseDate = updatedMovie.releaseDate;
                hasChanges = true;
              }

              // Update poster if changed
              if (movie.posterUrl != updatedMovie.posterUrl) {
                changes.add('poster URL');
                movie.posterUrl = updatedMovie.posterUrl;
                hasChanges = true;
              }

              // Update description if changed
              if (movie.description != updatedMovie.description) {
                changes.add('description');
                movie.description = updatedMovie.description;
                hasChanges = true;
              }

              // Update original release year if changed (for Cineman URLs)
              if (movie.originalReleaseYear != updatedMovie.originalReleaseYear) {
                changes.add('original release year: ${movie.originalReleaseYear} -> ${updatedMovie.originalReleaseYear}');
                movie.originalReleaseYear = updatedMovie.originalReleaseYear;
                hasChanges = true;
              }

              // Refresh streaming providers
              final providers = await _tmdbRepository.getStreamingProviders(tmdbId);
              final currentProviders = movie.availableOnStreamingServices ?? [];
              if (!_listsEqual(currentProviders, providers)) {
                changes.add('streaming providers');
                movie.availableOnStreamingServices = providers.isNotEmpty ? providers : null;
                hasChanges = true;
              }

              if (hasChanges) {
                movie.markAsModified();
                await _movieRepository.updateMovie(movie);

                // Reschedule notifications if release date changed
                if (changes.any((c) => c.contains('release date')) &&
                    settings.notificationsEnabled) {
                  await _notificationService.rescheduleMovieNotifications(
                      movie, settings);
                }

                updatedCount++;
                developer.log(
                  'Updated ${movie.title}: ${changes.join(", ")}',
                  name: 'MovieController',
                );
              }
            }
          } catch (e) {
            developer.log(
              'Failed to refresh ${movie.title}: $e',
              name: 'MovieController',
              error: e,
            );
          }
        }
      }

      await _loadMovies();
      _errorMessage = null;
      developer.log(
        'Refreshed data for $updatedCount movies',
        name: 'MovieController',
      );
    } catch (e) {
      _errorMessage = 'Failed to refresh data from TMDb: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }

    return updatedCount;
  }

  /// Helper to compare two lists for equality
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final set1 = list1.toSet();
    final set2 = list2.toSet();
    return set1.containsAll(set2) && set2.containsAll(set1);
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Export movies to a JSON file
  /// Returns ExportResult with file path or error
  Future<ExportResult> exportData(ExportOptions options) async {
    try {
      final settings = await _settingsRepository.getSettings();
      return await ImportExportService.exportData(
        movies: _movies,
        settings: settings,
        options: options,
      );
    } catch (e) {
      developer.log(
        'Failed to export data: $e',
        name: 'MovieController',
        error: e,
      );
      return ExportResult(error: e.toString());
    }
  }

  /// Import movies from a JSON file
  /// Returns ImportResult with details about the operation
  Future<ImportResult> importData({
    Future<void> Function(Map<String, dynamic>)? applySettings,
  }) async {
    _setLoading(true);
    try {
      final result = await ImportExportService.importData(
        addMovie: (movie) async {
          await _movieRepository.addMovie(movie);
          // Schedule notifications for imported movie
          await _scheduleNotificationsForMovie(movie);
        },
        movieExists: (id) => _movieRepository.movieExists(id),
        applySettings: applySettings,
      );

      if (result.success && result.moviesImported > 0) {
        await _loadMovies();
      }

      return result;
    } catch (e) {
      developer.log(
        'Failed to import data: $e',
        name: 'MovieController',
        error: e,
      );
      return ImportResult(error: 'Import failed: $e');
    } finally {
      _setLoading(false);
    }
  }
}
