import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/movie.dart';
import '../models/user_settings.dart';

/// Data export options
class ExportOptions {
  final bool includeWatchlist;
  final bool includeLibrary;
  final bool includeSettings;

  const ExportOptions({
    this.includeWatchlist = true,
    this.includeLibrary = true,
    this.includeSettings = true,
  });
}

/// Result of an export operation
class ExportResult {
  final String? filePath;
  final String? error;

  const ExportResult({this.filePath, this.error});

  bool get success => filePath != null && error == null;
}

/// Result of an import operation
class ImportResult {
  final int moviesImported;
  final int moviesSkipped;
  final bool settingsImported;
  final String? error;

  const ImportResult({
    this.moviesImported = 0,
    this.moviesSkipped = 0,
    this.settingsImported = false,
    this.error,
  });

  bool get success => error == null;
}

/// Service for importing and exporting watchlist data
class ImportExportService {
  static const String _exportVersion = '1.0.0';

  /// Export data to a JSON file
  /// Returns ExportResult with file path or error
  static Future<ExportResult> exportData({
    required List<Movie> movies,
    UserSettings? settings,
    required ExportOptions options,
  }) async {
    try {
      // Filter movies based on options
      final filteredMovies = movies.where((movie) {
        // Watchlist: only wantToWatch
        final isWatchlist = movie.status == WatchStatus.wantToWatch;

        // Library: watched, wantToRewatch, saveForStreaming
        final isLibrary = movie.status == WatchStatus.watched ||
            movie.status == WatchStatus.wantToRewatch ||
            movie.status == WatchStatus.saveForStreaming;

        if (options.includeWatchlist && options.includeLibrary) {
          return true;
        } else if (options.includeWatchlist) {
          return isWatchlist;
        } else if (options.includeLibrary) {
          return isLibrary;
        }
        return false;
      }).toList();

      // Build export data
      final exportData = <String, dynamic>{
        'version': _exportVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'appName': 'BeStWatchList',
        'exportOptions': {
          'includeWatchlist': options.includeWatchlist,
          'includeLibrary': options.includeLibrary,
        },
        'movies': filteredMovies.map((m) => m.toMap()).toList(),
      };

      // Include settings if available and requested
      if (options.includeSettings && settings != null) {
        exportData['settings'] = settings.toMap();
      }

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Let user pick save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Watchlist Data',
        fileName: _generateFileName(options),
        type: FileType.any,
        bytes: Uint8List.fromList(utf8.encode(jsonString)),
      );

      if (result == null) {
        return const ExportResult(error: 'cancelled');
      }

      // On some platforms, saveFile with bytes writes directly.
      // On others (like Windows), we need to write manually.
      final file = File(result);
      if (!await file.exists()) {
        await file.writeAsString(jsonString);
      }

      return ExportResult(filePath: result);
    } catch (e) {
      return ExportResult(error: e.toString());
    }
  }

  /// Import data from a JSON file
  /// Returns ImportResult with details about the operation
  static Future<ImportResult> importData({
    required Future<void> Function(Movie movie) addMovie,
    required Future<bool> Function(String id) movieExists,
    Future<void> Function(Map<String, dynamic>)? applySettings,
  }) async {
    try {
      // Let user pick a file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import Watchlist Data',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return const ImportResult(error: 'No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // Parse JSON
      final Map<String, dynamic> data;
      try {
        data = json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return const ImportResult(error: 'Invalid JSON format');
      }

      // Validate format
      if (!data.containsKey('movies') || data['movies'] is! List) {
        return const ImportResult(error: 'Invalid file format: missing movies array');
      }

      // Check version compatibility
      final version = data['version'] as String?;
      if (version == null) {
        return const ImportResult(error: 'Invalid file format: missing version');
      }

      int imported = 0;
      int skipped = 0;

      // Import movies
      final moviesList = data['movies'] as List;
      for (final movieData in moviesList) {
        if (movieData is! Map<String, dynamic>) continue;

        try {
          final movie = _movieFromMap(movieData);

          // Check if movie already exists
          if (await movieExists(movie.id)) {
            skipped++;
            continue;
          }

          await addMovie(movie);
          imported++;
        } catch (e) {
          skipped++;
        }
      }

      // Apply settings if present and callback provided
      bool settingsImported = false;
      if (applySettings != null &&
          data['settings'] is Map<String, dynamic>) {
        await applySettings(data['settings'] as Map<String, dynamic>);
        settingsImported = true;
      }

      return ImportResult(
        moviesImported: imported,
        moviesSkipped: skipped,
        settingsImported: settingsImported,
      );
    } catch (e) {
      return ImportResult(error: 'Import failed: $e');
    }
  }

  /// Generate a filename for export based on options
  static String _generateFileName(ExportOptions options) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    String suffix;
    if (options.includeWatchlist && options.includeLibrary) {
      suffix = 'full';
    } else if (options.includeWatchlist) {
      suffix = 'watchlist';
    } else {
      suffix = 'library';
    }

    return 'bestwatchlist_${suffix}_$dateStr.json';
  }

  /// Create a Movie from a map (reverse of toMap)
  static Movie _movieFromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as String,
      title: map['title'] as String,
      releaseDate: DateTime.parse(map['releaseDate'] as String),
      posterUrl: map['posterUrl'] as String?,
      description: map['description'] as String?,
      status: WatchStatus.values[map['status'] as int],
      availableOnStreamingServices: map['availableOnStreamingServices'] != null
          ? List<String>.from(map['availableOnStreamingServices'] as List)
          : null,
      notificationSundayBefore: map['notificationSundayBefore'] != null
          ? DateTime.parse(map['notificationSundayBefore'] as String)
          : null,
      notificationReleaseDay: map['notificationReleaseDay'] != null
          ? DateTime.parse(map['notificationReleaseDay'] as String)
          : null,
      notificationSaturdayAfter: map['notificationSaturdayAfter'] != null
          ? DateTime.parse(map['notificationSaturdayAfter'] as String)
          : null,
      notifiedLeftCinema: map['notifiedLeftCinema'] as bool? ?? false,
      notifiedStreamingAvailable: map['notifiedStreamingAvailable'] as bool? ?? false,
      imdbId: map['imdbId'] as String?,
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'] as String)
          : null,
    );
  }
}
