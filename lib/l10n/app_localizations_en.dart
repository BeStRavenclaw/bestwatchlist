// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navBrowse => 'Browse';

  @override
  String get navCinema => 'Cinema';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get refresh => 'Refresh';

  @override
  String get exportAction => 'Export';

  @override
  String get importAction => 'Import';

  @override
  String get clearAll => 'Clear All';

  @override
  String get selectFile => 'Select File';

  @override
  String get moreActions => 'More actions';

  @override
  String get searchTmdbHint => 'Search movies on TMDb...';

  @override
  String get upcomingMoviesNext2Weeks => 'Upcoming Movies (Next 2 Weeks)';

  @override
  String get upcomingMovies => 'Upcoming Movies';

  @override
  String get noMoviesFound => 'No movies found';

  @override
  String get noUpcomingMovies => 'No upcoming movies';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get checkBackLater => 'Check back later or use search to find movies';

  @override
  String get removeFromWatchlist => 'Remove from watchlist';

  @override
  String get addToWatchlist => 'Add to watchlist';

  @override
  String movieRemovedFromWatchlist(String title) {
    return '$title removed from watchlist';
  }

  @override
  String movieAddedToWatchlist(String title) {
    return '$title added to watchlist';
  }

  @override
  String get searchCinemaHint => 'Search cinema movies...';

  @override
  String get noCinemaMovies => 'No cinema movies yet';

  @override
  String get addMoviesFromBrowse => 'Add movies to your watchlist from Browse';

  @override
  String get released => 'Released';

  @override
  String get upcomingReleases => 'Upcoming Releases';

  @override
  String movieMarkedWatched(String title) {
    return '$title marked as watched';
  }

  @override
  String movieAddedRewatch(String title) {
    return '$title added to rewatch list';
  }

  @override
  String movieMovedStreaming(String title) {
    return '$title moved to streaming list';
  }

  @override
  String movieDeleted(String title) {
    return '$title deleted';
  }

  @override
  String couldNotOpenCineman(String error) {
    return 'Could not open Cineman: $error';
  }

  @override
  String get searchLibraryHint => 'Search your library...';

  @override
  String get watched => 'Watched';

  @override
  String get streamingWatchlist => 'Streaming WatchList';

  @override
  String get noWatchedMovies => 'No watched movies yet';

  @override
  String get noMoviesToStream => 'No movies to stream';

  @override
  String get markMoviesWatched => 'Mark movies as watched from Cinema';

  @override
  String get markMoviesForStreaming =>
      'Mark movies as \"Save for Streaming\" or \"Want to Rewatch\"';

  @override
  String get tryDifferentSearchOrFilter => 'Try a different search or filter';

  @override
  String get wantToRewatch => 'Want to Rewatch';

  @override
  String get saveForStreaming => 'Save for Streaming';

  @override
  String alsoOn(String title) {
    return '$title is also on';
  }

  @override
  String get alsoOnOtherServices => 'Also on other services';

  @override
  String get sectionDataManagement => 'Data Management';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionStreamingServices => 'Streaming Services';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionAbout => 'About';

  @override
  String get automaticUpdates => 'Automatic Updates';

  @override
  String get automaticUpdatesSubtitle =>
      'Release dates update automatically every week';

  @override
  String get refreshFromTmdb => 'Refresh Data from TMDb';

  @override
  String get refreshFromTmdbDescription =>
      'Updates all movies with latest data from TMDb (release dates, streaming availability, etc.).\nThis runs automatically every week in the background.';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get exportImportDescription =>
      'Export or import your watchlist and library data as JSON files.';

  @override
  String get clearAllMovies => 'Clear All Movies';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkThemeEnabled => 'Dark theme enabled';

  @override
  String get lightThemeEnabled => 'Light theme enabled';

  @override
  String get movieTitleLanguage => 'Movie Title Language';

  @override
  String get releaseDateCountry => 'Release Date Country';

  @override
  String get displayLanguage => 'Display Language';

  @override
  String get displayLanguageAuto => 'Auto (device language)';

  @override
  String get manageStreamingServices => 'Manage Streaming Services';

  @override
  String servicesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services selected',
      one: '1 service selected',
      zero: 'No services selected',
    );
    return '$_temp0';
  }

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get masterNotificationToggle => 'Master notification toggle';

  @override
  String get sundayBeforeRelease => 'Sunday Before Release';

  @override
  String get sundayBeforeReleaseSubtitle =>
      'Get reminded the Sunday before a movie releases';

  @override
  String get releaseDayNotification => 'Release Day';

  @override
  String get releaseDaySubtitle => 'Get notified when a movie releases';

  @override
  String get saturdayAfterRelease => 'Saturday After Release';

  @override
  String get saturdayAfterReleaseSubtitle =>
      'Get reminded the Saturday after release';

  @override
  String get leftCinema => 'Left Cinema';

  @override
  String get leftCinemaSubtitle => 'Get notified when a movie leaves cinema';

  @override
  String get streamingAvailableNotification => 'Streaming Available';

  @override
  String get streamingAvailableSubtitle =>
      'Get notified when available on your streaming services';

  @override
  String get versionLabel => 'Version';

  @override
  String get selectReleaseDateCountry => 'Select Release Date Country';

  @override
  String get selectTitleLanguage => 'Select Title Language';

  @override
  String get selectDisplayLanguage => 'Select Display Language';

  @override
  String releaseCountrySet(String country) {
    return 'Release country set to $country. Refresh data to apply.';
  }

  @override
  String updatingMovieTitles(String language) {
    return 'Updating movie titles to $language...';
  }

  @override
  String updatedMovieTitles(int count, String language) {
    return 'Updated $count movie(s) to $language';
  }

  @override
  String get refreshFromTmdbTitle => 'Refresh Data from TMDb?';

  @override
  String get refreshFromTmdbConfirmation =>
      'This will update all movies with the latest data from TMDb (release dates, streaming availability, posters, etc.). This may take a moment.';

  @override
  String get exportDataTitle => 'Export Data';

  @override
  String get selectWhatToExport => 'Select what to export:';

  @override
  String get exportWatchlist => 'Watchlist';

  @override
  String get exportWatchlistSubtitle => 'Movies you want to watch (Cinema)';

  @override
  String get exportLibrary => 'Library';

  @override
  String get exportLibrarySubtitle => 'Watched, rewatch, streaming';

  @override
  String get exportSettingsLabel => 'Settings';

  @override
  String get exportSettingsSubtitle => 'Notifications, streaming services';

  @override
  String get dataExportedSuccess => 'Data exported successfully';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get importDataTitle => 'Import Data';

  @override
  String get importDataDescription =>
      'Select a BeStWatchList JSON file to import. Duplicate movies will be skipped.';

  @override
  String importedMovies(int movies, int skipped) {
    return 'Imported $movies movie(s), $skipped skipped';
  }

  @override
  String importedMoviesWithSettings(int movies, int skipped) {
    return 'Imported $movies movie(s), $skipped skipped. Settings restored.';
  }

  @override
  String get clearAllMoviesTitle => 'Clear All Movies?';

  @override
  String get clearAllMoviesConfirmation =>
      'This will delete all your movies from local storage. This action cannot be undone. Are you sure?';

  @override
  String get allMoviesCleared => 'All movies cleared';

  @override
  String get streamingServicesTitle => 'Streaming Services';

  @override
  String get streamingServicesDescription =>
      'Select the streaming services you subscribe to. We\'ll notify you when movies become available on your services.';

  @override
  String get searchServicesHint => 'Search streaming services...';

  @override
  String get noStreamingProviders => 'No streaming providers available';

  @override
  String get checkTmdbConfig => 'Please check your TMDB API configuration.';

  @override
  String get noServicesFound => 'No services found';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get menuMarkWatched => 'Mark as Watched';

  @override
  String get menuWantToRewatch => 'Want to Rewatch';

  @override
  String get menuDelete => 'Delete';

  @override
  String get menuRemoveFromLibrary => 'Remove from Library';

  @override
  String get menuSaveForStreaming => 'Add to Streaming WatchList';

  @override
  String get menuViewShowtimes => 'View on Cineman';

  @override
  String get releaseDateTbd => 'Release Date: TBD';

  @override
  String releasesInDays(String date, int days) {
    return 'Releases $date (in $days days)';
  }

  @override
  String releasedOnDate(String date) {
    return 'Released $date';
  }

  @override
  String get openTmdb => 'Open TMDb';

  @override
  String get openImdb => 'Open IMDb';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get tmdbApiKeyMissing =>
      'TMDB API key not configured — movie browsing is unavailable.';

  @override
  String get tmdbApiKeyInvalid =>
      'TMDB API key is invalid or expired — movie browsing is unavailable.';
}
