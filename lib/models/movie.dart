import 'package:hive/hive.dart';

part 'movie.g.dart';

/// Watch status enumeration for movies
@HiveType(typeId: 1)
enum WatchStatus {
  @HiveField(0)
  wantToWatch,

  @HiveField(1)
  watched,

  @HiveField(2)
  lostInterest,

  @HiveField(3)
  wantToRewatch,

  @HiveField(4)
  saveForStreaming,
}

/// Movie model with Hive persistence
@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime releaseDate;

  @HiveField(3)
  String? posterUrl;

  @HiveField(4)
  String? description;

  @HiveField(5)
  WatchStatus status;

  @HiveField(8)
  List<String>? availableOnStreamingServices;

  @HiveField(9)
  DateTime? notificationSundayBefore;

  @HiveField(10)
  DateTime? notificationReleaseDay;

  @HiveField(11)
  DateTime? notificationSaturdayAfter;

  @HiveField(12)
  bool notifiedLeftCinema;

  @HiveField(13)
  bool notifiedStreamingAvailable;

  @HiveField(14)
  String? imdbId;

  @HiveField(15)
  DateTime? lastModified;

  @HiveField(16)
  bool needsSync;

  @HiveField(17)
  int? originalReleaseYear;

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    this.posterUrl,
    this.description,
    this.status = WatchStatus.wantToWatch,
    this.availableOnStreamingServices,
    this.notificationSundayBefore,
    this.notificationReleaseDay,
    this.notificationSaturdayAfter,
    this.notifiedLeftCinema = false,
    this.notifiedStreamingAvailable = false,
    this.imdbId,
    DateTime? lastModified,
    this.needsSync = true,
    this.originalReleaseYear,
  }) : lastModified = lastModified ?? DateTime.now();

  /// Sentinel date for TBD release dates (year 9999)
  static final DateTime tbdDate = DateTime(9999, 12, 31);

  /// Check if movie is on the watchlist
  bool get isOnWatchlist =>
      status == WatchStatus.wantToWatch || status == WatchStatus.wantToRewatch;

  /// Check if release date is TBD
  bool get isTbd => releaseDate.year == 9999;

  /// Get the number of days until release
  int get daysUntilRelease =>
      isTbd ? -1 : releaseDate.difference(DateTime.now()).inDays;

  /// Check if movie has been released
  bool get hasBeenReleased => isTbd ? false : DateTime.now().isAfter(releaseDate);

  /// Get IMDB URL if IMDB ID is available
  String? get imdbUrl =>
      imdbId != null ? 'https://www.imdb.com/title/$imdbId/' : null;

  /// Get TMDb URL if ID is a TMDb ID
  String? get tmdbUrl {
    if (id.startsWith('tmdb_')) {
      final tmdbId = id.substring(5);
      return 'https://www.themoviedb.org/movie/$tmdbId';
    }
    return null;
  }

  /// Convert movie to a Map for syncing purposes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'releaseDate': releaseDate.toIso8601String(),
      'posterUrl': posterUrl,
      'description': description,
      'status': status.index,
      'availableOnStreamingServices': availableOnStreamingServices,
      'notificationSundayBefore': notificationSundayBefore?.toIso8601String(),
      'notificationReleaseDay': notificationReleaseDay?.toIso8601String(),
      'notificationSaturdayAfter': notificationSaturdayAfter?.toIso8601String(),
      'notifiedLeftCinema': notifiedLeftCinema,
      'notifiedStreamingAvailable': notifiedStreamingAvailable,
      'imdbId': imdbId,
      'lastModified': lastModified?.toIso8601String(),
      'originalReleaseYear': originalReleaseYear,
    };
  }

  /// Mark the movie as modified for sync purposes
  void markAsModified() {
    lastModified = DateTime.now();
    needsSync = true;
  }

  /// Create a copy of this movie with updated fields
  Movie copyWith({
    String? id,
    String? title,
    DateTime? releaseDate,
    String? posterUrl,
    String? description,
    WatchStatus? status,
    List<String>? availableOnStreamingServices,
    DateTime? notificationSundayBefore,
    DateTime? notificationReleaseDay,
    DateTime? notificationSaturdayAfter,
    bool? notifiedLeftCinema,
    bool? notifiedStreamingAvailable,
    String? imdbId,
    DateTime? lastModified,
    bool? needsSync,
    int? originalReleaseYear,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      releaseDate: releaseDate ?? this.releaseDate,
      posterUrl: posterUrl ?? this.posterUrl,
      description: description ?? this.description,
      status: status ?? this.status,
      availableOnStreamingServices:
          availableOnStreamingServices ?? this.availableOnStreamingServices,
      notificationSundayBefore:
          notificationSundayBefore ?? this.notificationSundayBefore,
      notificationReleaseDay:
          notificationReleaseDay ?? this.notificationReleaseDay,
      notificationSaturdayAfter:
          notificationSaturdayAfter ?? this.notificationSaturdayAfter,
      notifiedLeftCinema: notifiedLeftCinema ?? this.notifiedLeftCinema,
      notifiedStreamingAvailable:
          notifiedStreamingAvailable ?? this.notifiedStreamingAvailable,
      imdbId: imdbId ?? this.imdbId,
      lastModified: lastModified ?? this.lastModified,
      needsSync: needsSync ?? this.needsSync,
      originalReleaseYear: originalReleaseYear ?? this.originalReleaseYear,
    );
  }
}
