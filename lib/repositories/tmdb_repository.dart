import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/movie.dart';

enum TmdbApiStatus { ok, notConfigured, unauthorized }

/// Repository for fetching movie data from The Movie Database (TMDb) API
class TMDbRepository {
  /// API key injected at build time via --dart-define=TMDB_API_KEY=...
  static const String _apiKey = String.fromEnvironment('TMDB_API_KEY');

  TmdbApiStatus _apiStatus = _apiKey.isEmpty
      ? TmdbApiStatus.notConfigured
      : TmdbApiStatus.ok;

  TmdbApiStatus get apiStatus => _apiStatus;

  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Language code for movie titles (e.g., 'en', 'de', 'fr')
  String _titleLanguage = 'en';

  /// ISO 3166-1 country code used for theatrical release dates (e.g., 'DE', 'CH', 'US')
  String _releaseCountry = 'DE';

  /// Set the language for movie titles
  void setTitleLanguage(String languageCode) {
    _titleLanguage = languageCode;
  }

  /// Set the country for release date lookups
  void setReleaseCountry(String countryCode) {
    _releaseCountry = countryCode;
  }

  /// Get the TMDB language parameter (e.g., 'en-US', 'de-DE')
  String get _languageParam {
    switch (_titleLanguage) {
      case 'de':
        return 'de-DE';
      case 'fr':
        return 'fr-FR';
      case 'es':
        return 'es-ES';
      case 'it':
        return 'it-IT';
      case 'en':
      default:
        return 'en-US';
    }
  }

  /// Check if API key is configured
  bool get isConfigured => _apiKey.isNotEmpty;

  /// Search for movies by query
  Future<List<Movie>> searchMovies(String query) async {
    return _fetchMovies(
      '/search/movie',
      {'query': Uri.encodeComponent(query)},
    );
  }

  /// Get popular movies
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    return _fetchMovies('/movie/popular', {'page': page.toString()});
  }

  /// Get now playing movies (configured release country region)
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    return _fetchMovies('/movie/now_playing', {
      'page': page.toString(),
      'region': _releaseCountry,
    });
  }

  /// Get upcoming movies (not yet released in configured release country)
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    return _fetchMovies('/discover/movie', {
      'page': page.toString(),
      'region': _releaseCountry,
      'sort_by': 'release_date.asc',
      'with_release_type': '2|3', // Theatrical (limited) and Theatrical
      'release_date.gte': today,
    });
  }

  /// Get movie details by TMDb ID
  Future<Movie?> getMovieDetails(int tmdbId) async {
    if (!isConfigured) return null;

    final url = Uri.parse(
      '$_baseUrl/movie/$tmdbId?api_key=$_apiKey&language=$_languageParam&append_to_response=external_ids,release_dates',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _apiStatus = TmdbApiStatus.ok;
        final data = json.decode(response.body);
        return _parseMovie(data);
      }
      if (response.statusCode == 401) {
        _apiStatus = TmdbApiStatus.unauthorized;
      }
      return null;
    } catch (e) {
      developer.log('Error getting movie details: $e', name: 'TMDbRepository');
      return null;
    }
  }

  /// Get theatrical release date for a movie in the configured release country
  Future<DateTime?> getTheatricalReleaseDate(int tmdbId) async {
    if (!isConfigured) return null;

    final url = Uri.parse(
      '$_baseUrl/movie/$tmdbId/release_dates?api_key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        final countryReleases = results.firstWhere(
          (result) => result['iso_3166_1'] == _releaseCountry,
          orElse: () => null,
        );

        if (countryReleases != null) {
          final releaseDates = countryReleases['release_dates'] as List;

          // Type 3 = Theatrical, Type 2 = Theatrical (limited)
          final theatricalRelease = releaseDates.firstWhere(
            (release) => release['type'] == 3 || release['type'] == 2,
            orElse: () => releaseDates.isNotEmpty ? releaseDates.first : null,
          );

          if (theatricalRelease != null &&
              theatricalRelease['release_date'] != null) {
            return DateTime.parse(theatricalRelease['release_date']);
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('Error getting release dates: $e', name: 'TMDbRepository');
      return null;
    }
  }

  /// Get streaming providers for a movie (Switzerland - CH)
  Future<List<String>> getStreamingProviders(int tmdbId) async {
    if (!isConfigured) return [];

    final url = Uri.parse(
      '$_baseUrl/movie/$tmdbId/watch/providers?api_key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as Map<String, dynamic>?;

        if (results == null) return [];

        // Get Swiss providers
        final chProviders = results['CH'] as Map<String, dynamic>?;
        if (chProviders == null) return [];

        final providers = <String>[];

        // Check flatrate (subscription services)
        final flatrate = chProviders['flatrate'] as List?;
        if (flatrate != null) {
          for (final provider in flatrate) {
            final providerName = provider['provider_name'] as String?;
            if (providerName != null) {
              providers.add(_normalizeProviderName(providerName));
            }
          }
        }

        return providers;
      }
      return [];
    } catch (e) {
      developer.log('Error getting streaming providers: $e', name: 'TMDbRepository');
      return [];
    }
  }

  /// Get all available streaming providers for Switzerland
  Future<List<String>> getAllAvailableProvidersForSwitzerland() async {
    if (!isConfigured) return [];

    final url = Uri.parse(
      '$_baseUrl/watch/providers/movie?api_key=$_apiKey&watch_region=CH',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;

        if (results == null) return [];

        final providers = <String>[];
        for (final provider in results) {
          final providerName = provider['provider_name'] as String?;
          if (providerName != null) {
            providers.add(_normalizeProviderName(providerName));
          }
        }

        // Remove duplicates and sort alphabetically
        final uniqueProviders = providers.toSet().toList();
        uniqueProviders.sort();
        return uniqueProviders;
      }
      return [];
    } catch (e) {
      developer.log('Error getting all available providers: $e', name: 'TMDbRepository');
      return [];
    }
  }

  /// Normalize provider names to match user settings format
  String _normalizeProviderName(String providerName) {
    // Map TMDb provider names to app's standardized format (Switzerland - CH)
    final Map<String, String> providerMapping = {
      'Netflix': 'Netflix',
      'Amazon Prime Video': 'Prime Video',
      'Disney Plus': 'Disney+',
      'Apple TV Plus': 'Apple TV+',
      'Paramount Plus': 'Paramount+',
      'HBO Max': 'HBO Max',
      'blue TV': 'blue TV',
      'Blue TV': 'blue TV',
      'Play Suisse': 'Play Suisse',
      'Swisscom blue TV': 'blue TV',
      'YouTube Premium': 'YouTube Premium',
      'Crunchyroll': 'Crunchyroll',
      'WOW': 'WOW',
      'Sky Go': 'Sky',
      'Joyn Plus': 'Joyn+',
      'RTL+': 'RTL+',
      'MagentaTV': 'MagentaTV',
    };

    return providerMapping[providerName] ?? providerName;
  }

  /// Generic method to fetch movies from TMDb API (DRY principle)
  Future<List<Movie>> _fetchMovies(
    String endpoint,
    Map<String, String> params,
  ) async {
    if (!isConfigured) return [];

    final queryParams = {
      'api_key': _apiKey,
      'language': _languageParam,
      ...params,
    };

    final url = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Fetch detailed release dates for each movie
        final movies = <Movie>[];
        for (final movieData in results) {
          final tmdbId = movieData['id'] as int;
          final detailedMovie = await getMovieDetails(tmdbId);
          if (detailedMovie != null) {
            movies.add(detailedMovie);
          }
        }
        return movies;
      }

      if (response.statusCode == 401) {
        _apiStatus = TmdbApiStatus.unauthorized;
      }
      developer.log('Failed to fetch from $endpoint: ${response.statusCode}', name: 'TMDbRepository');
      return [];
    } catch (e) {
      developer.log('Error fetching from $endpoint: $e', name: 'TMDbRepository');
      return [];
    }
  }

  /// Parse movie data from TMDb API response
  Movie _parseMovie(Map<String, dynamic> data) {
    DateTime releaseDate;
    int? originalReleaseYear;

    // Try to get release dates from the release_dates endpoint
    if (data['release_dates'] != null) {
      final releaseDatesData = data['release_dates'];
      final results = releaseDatesData['results'] as List;

      // Find earliest premiere/theatrical release globally for Cineman URL
      // Cineman uses the earliest release year (premiere/festival year, not regional theatrical)
      // Type 1 = Premiere, Type 2 = Theatrical (limited), Type 3 = Theatrical
      DateTime? earliestRelease;
      for (final regionData in results) {
        final releaseDates = regionData['release_dates'] as List?;
        if (releaseDates == null) continue;

        for (final release in releaseDates) {
          final type = release['type'] as int?;
          final dateStr = release['release_date'] as String?;
          // Only consider premiere and theatrical releases
          if (type != null && (type == 1 || type == 2 || type == 3)) {
            if (dateStr != null && dateStr.isNotEmpty) {
              try {
                final date = DateTime.parse(dateStr);
                if (earliestRelease == null || date.isBefore(earliestRelease)) {
                  earliestRelease = date;
                }
              } catch (e) {
                // Ignore parsing errors
              }
            }
          }
        }
      }

      // Also check the base release_date field - TMDB's main release_date is often
      // more accurate for the original/international release year than the detailed
      // release_dates which may only have future regional theatrical releases
      final baseReleaseDateStr = data['release_date'] as String?;
      DateTime? baseReleaseDate;
      if (baseReleaseDateStr != null && baseReleaseDateStr.isNotEmpty) {
        try {
          baseReleaseDate = DateTime.parse(baseReleaseDateStr);
        } catch (e) {
          // Ignore parsing errors
        }
      }

      // Use the earlier of: earliest premiere/theatrical OR base release_date
      // This handles cases where TMDB has future theatrical releases but the movie
      // already premiered (e.g., at festivals) in an earlier year
      if (earliestRelease != null && baseReleaseDate != null) {
        final effectiveDate = earliestRelease.isBefore(baseReleaseDate)
            ? earliestRelease
            : baseReleaseDate;
        originalReleaseYear = effectiveDate.year;
      } else if (earliestRelease != null) {
        originalReleaseYear = earliestRelease.year;
      } else if (baseReleaseDate != null) {
        originalReleaseYear = baseReleaseDate.year;
      }

      // Find releases for the configured country
      final countryReleases = results.firstWhere(
        (result) => result['iso_3166_1'] == _releaseCountry,
        orElse: () => null,
      );

      if (countryReleases != null) {
        final releaseDates = countryReleases['release_dates'] as List;

        // Type 3 = Theatrical, Type 2 = Theatrical (limited)
        final theatricalRelease = releaseDates.firstWhere(
          (release) => release['type'] == 3 || release['type'] == 2,
          orElse: () => releaseDates.isNotEmpty ? releaseDates.first : null,
        );

        if (theatricalRelease != null &&
            theatricalRelease['release_date'] != null) {
          try {
            releaseDate = DateTime.parse(theatricalRelease['release_date']);
          } catch (e) {
            releaseDate = Movie.tbdDate;
          }
        } else {
          releaseDate = Movie.tbdDate;
        }
      } else {
        // No release found for configured country, use default release_date
        final releaseDateStr = data['release_date'] as String?;
        releaseDate = releaseDateStr != null && releaseDateStr.isNotEmpty
            ? DateTime.parse(releaseDateStr)
            : Movie.tbdDate;
      }
    } else {
      // Fallback to basic release_date field
      final releaseDateStr = data['release_date'] as String?;
      releaseDate = releaseDateStr != null && releaseDateStr.isNotEmpty
          ? DateTime.parse(releaseDateStr)
          : Movie.tbdDate;
      originalReleaseYear = releaseDate != Movie.tbdDate ? releaseDate.year : null;
    }

    final posterPath = data['poster_path'] as String?;
    final posterUrl = posterPath != null ? '$_imageBaseUrl$posterPath' : null;

    // Get IMDB ID if available
    String? imdbId;
    if (data['external_ids'] != null) {
      imdbId = data['external_ids']['imdb_id'] as String?;
    } else if (data['imdb_id'] != null) {
      imdbId = data['imdb_id'] as String?;
    }

    final tmdbId = data['id'] as int;

    return Movie(
      id: 'tmdb_$tmdbId',
      title: data['title'] as String? ?? 'Unknown Title',
      releaseDate: releaseDate,
      posterUrl: posterUrl,
      description: data['overview'] as String?,
      status: WatchStatus.wantToWatch, // Default status for browsed movies
      imdbId: imdbId,
      originalReleaseYear: originalReleaseYear,
    );
  }

  /// Get movie details with streaming providers included
  Future<Movie?> getMovieDetailsWithStreaming(int tmdbId) async {
    final movie = await getMovieDetails(tmdbId);
    if (movie == null) return null;

    // Fetch streaming providers
    final providers = await getStreamingProviders(tmdbId);
    if (providers.isNotEmpty) {
      movie.availableOnStreamingServices = providers;
    }

    return movie;
  }
}
