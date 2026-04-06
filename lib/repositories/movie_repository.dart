import 'package:hive/hive.dart';
import '../models/movie.dart';

/// Repository for managing movie data persistence with Hive
class MovieRepository {
  static const String _boxName = 'movies';
  Box<Movie>? _box;

  /// Get the Hive box for movies (lazy initialization)
  Future<Box<Movie>> get _moviesBox async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Movie>(_boxName);
    }
    return _box!;
  }

  /// Get all movies from local storage
  Future<List<Movie>> getAllMovies() async {
    final box = await _moviesBox;
    return box.values.toList();
  }

  /// Get movies filtered by watch status
  Future<List<Movie>> getByStatus(WatchStatus status) async {
    final movies = await getAllMovies();
    return movies.where((movie) => movie.status == status).toList();
  }

  /// Get upcoming movies (not yet released, want to watch status)
  Future<List<Movie>> getUpcoming() async {
    final movies = await getAllMovies();
    return movies
        .where((movie) =>
            movie.status == WatchStatus.wantToWatch && !movie.hasBeenReleased)
        .toList();
  }

  /// Add a new movie to the database
  Future<void> addMovie(Movie movie) async {
    final box = await _moviesBox;
    await box.add(movie);
  }

  /// Update an existing movie
  Future<void> updateMovie(Movie movie) async {
    await movie.save();
  }

  /// Delete a movie from the database
  Future<void> deleteMovie(Movie movie) async {
    await movie.delete();
  }

  /// Find a movie by its external ID (e.g., TMDb ID)
  Future<Movie?> findByExternalId(String externalId) async {
    final movies = await getAllMovies();
    try {
      return movies.firstWhere((movie) => movie.id == externalId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a movie exists by external ID
  Future<bool> movieExists(String externalId) async {
    final movie = await findByExternalId(externalId);
    return movie != null;
  }

  /// Clear all movies from the database
  Future<void> clearAll() async {
    final box = await _moviesBox;
    await box.clear();
  }

  /// Get movies that need syncing
  Future<List<Movie>> getMoviesNeedingSync() async {
    final movies = await getAllMovies();
    return movies.where((movie) => movie.needsSync).toList();
  }

  /// Get the listenable box for reactive UI updates
  Future<Box<Movie>> getListenableBox() async {
    return await _moviesBox;
  }
}
