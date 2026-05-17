import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @navBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get navBrowse;

  /// No description provided for @navCinema.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get navCinema;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportAction;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @searchTmdbHint.
  ///
  /// In en, this message translates to:
  /// **'Search movies on TMDb...'**
  String get searchTmdbHint;

  /// No description provided for @upcomingMoviesNext2Weeks.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Movies (Next 2 Weeks)'**
  String get upcomingMoviesNext2Weeks;

  /// No description provided for @upcomingMovies.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Movies'**
  String get upcomingMovies;

  /// No description provided for @noMoviesFound.
  ///
  /// In en, this message translates to:
  /// **'No movies found'**
  String get noMoviesFound;

  /// No description provided for @noUpcomingMovies.
  ///
  /// In en, this message translates to:
  /// **'No upcoming movies'**
  String get noUpcomingMovies;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later or use search to find movies'**
  String get checkBackLater;

  /// No description provided for @removeFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get removeFromWatchlist;

  /// No description provided for @addToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get addToWatchlist;

  /// No description provided for @movieRemovedFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'{title} removed from watchlist'**
  String movieRemovedFromWatchlist(String title);

  /// No description provided for @movieAddedToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'{title} added to watchlist'**
  String movieAddedToWatchlist(String title);

  /// No description provided for @searchCinemaHint.
  ///
  /// In en, this message translates to:
  /// **'Search cinema movies...'**
  String get searchCinemaHint;

  /// No description provided for @noCinemaMovies.
  ///
  /// In en, this message translates to:
  /// **'No cinema movies yet'**
  String get noCinemaMovies;

  /// No description provided for @addMoviesFromBrowse.
  ///
  /// In en, this message translates to:
  /// **'Add movies to your watchlist from Browse'**
  String get addMoviesFromBrowse;

  /// No description provided for @released.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get released;

  /// No description provided for @upcomingReleases.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Releases'**
  String get upcomingReleases;

  /// No description provided for @movieMarkedWatched.
  ///
  /// In en, this message translates to:
  /// **'{title} marked as watched'**
  String movieMarkedWatched(String title);

  /// No description provided for @movieAddedRewatch.
  ///
  /// In en, this message translates to:
  /// **'{title} added to rewatch list'**
  String movieAddedRewatch(String title);

  /// No description provided for @movieMovedStreaming.
  ///
  /// In en, this message translates to:
  /// **'{title} moved to streaming list'**
  String movieMovedStreaming(String title);

  /// No description provided for @movieDeleted.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted'**
  String movieDeleted(String title);

  /// No description provided for @couldNotOpenCineman.
  ///
  /// In en, this message translates to:
  /// **'Could not open Cineman: {error}'**
  String couldNotOpenCineman(String error);

  /// No description provided for @searchLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Search your library...'**
  String get searchLibraryHint;

  /// No description provided for @watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watched;

  /// No description provided for @streamingWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Streaming WatchList'**
  String get streamingWatchlist;

  /// No description provided for @noWatchedMovies.
  ///
  /// In en, this message translates to:
  /// **'No watched movies yet'**
  String get noWatchedMovies;

  /// No description provided for @noMoviesToStream.
  ///
  /// In en, this message translates to:
  /// **'No movies to stream'**
  String get noMoviesToStream;

  /// No description provided for @markMoviesWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark movies as watched from Cinema'**
  String get markMoviesWatched;

  /// No description provided for @markMoviesForStreaming.
  ///
  /// In en, this message translates to:
  /// **'Mark movies as \"Save for Streaming\" or \"Want to Rewatch\"'**
  String get markMoviesForStreaming;

  /// No description provided for @tryDifferentSearchOrFilter.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter'**
  String get tryDifferentSearchOrFilter;

  /// No description provided for @wantToRewatch.
  ///
  /// In en, this message translates to:
  /// **'Want to Rewatch'**
  String get wantToRewatch;

  /// No description provided for @saveForStreaming.
  ///
  /// In en, this message translates to:
  /// **'Save for Streaming'**
  String get saveForStreaming;

  /// No description provided for @alsoOn.
  ///
  /// In en, this message translates to:
  /// **'{title} is also on'**
  String alsoOn(String title);

  /// No description provided for @alsoOnOtherServices.
  ///
  /// In en, this message translates to:
  /// **'Also on other services'**
  String get alsoOnOtherServices;

  /// No description provided for @sectionDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get sectionDataManagement;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionStreamingServices.
  ///
  /// In en, this message translates to:
  /// **'Streaming Services'**
  String get sectionStreamingServices;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @automaticUpdates.
  ///
  /// In en, this message translates to:
  /// **'Automatic Updates'**
  String get automaticUpdates;

  /// No description provided for @automaticUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Release dates update automatically every week'**
  String get automaticUpdatesSubtitle;

  /// No description provided for @refreshFromTmdb.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data from TMDb'**
  String get refreshFromTmdb;

  /// No description provided for @refreshFromTmdbDescription.
  ///
  /// In en, this message translates to:
  /// **'Updates all movies with latest data from TMDb (release dates, streaming availability, etc.).\nThis runs automatically every week in the background.'**
  String get refreshFromTmdbDescription;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @exportImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export or import your watchlist and library data as JSON files.'**
  String get exportImportDescription;

  /// No description provided for @clearAllMovies.
  ///
  /// In en, this message translates to:
  /// **'Clear All Movies'**
  String get clearAllMovies;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkThemeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark theme enabled'**
  String get darkThemeEnabled;

  /// No description provided for @lightThemeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light theme enabled'**
  String get lightThemeEnabled;

  /// No description provided for @movieTitleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Movie Title Language'**
  String get movieTitleLanguage;

  /// No description provided for @releaseDateCountry.
  ///
  /// In en, this message translates to:
  /// **'Release Date Country'**
  String get releaseDateCountry;

  /// No description provided for @displayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display Language'**
  String get displayLanguage;

  /// No description provided for @displayLanguageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (device language)'**
  String get displayLanguageAuto;

  /// No description provided for @manageStreamingServices.
  ///
  /// In en, this message translates to:
  /// **'Manage Streaming Services'**
  String get manageStreamingServices;

  /// No description provided for @servicesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No services selected} =1{1 service selected} other{{count} services selected}}'**
  String servicesSelected(int count);

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @masterNotificationToggle.
  ///
  /// In en, this message translates to:
  /// **'Master notification toggle'**
  String get masterNotificationToggle;

  /// No description provided for @sundayBeforeRelease.
  ///
  /// In en, this message translates to:
  /// **'Sunday Before Release'**
  String get sundayBeforeRelease;

  /// No description provided for @sundayBeforeReleaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded the Sunday before a movie releases'**
  String get sundayBeforeReleaseSubtitle;

  /// No description provided for @releaseDayNotification.
  ///
  /// In en, this message translates to:
  /// **'Release Day'**
  String get releaseDayNotification;

  /// No description provided for @releaseDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a movie releases'**
  String get releaseDaySubtitle;

  /// No description provided for @saturdayAfterRelease.
  ///
  /// In en, this message translates to:
  /// **'Saturday After Release'**
  String get saturdayAfterRelease;

  /// No description provided for @saturdayAfterReleaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded the Saturday after release'**
  String get saturdayAfterReleaseSubtitle;

  /// No description provided for @leftCinema.
  ///
  /// In en, this message translates to:
  /// **'Left Cinema'**
  String get leftCinema;

  /// No description provided for @leftCinemaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a movie leaves cinema'**
  String get leftCinemaSubtitle;

  /// No description provided for @streamingAvailableNotification.
  ///
  /// In en, this message translates to:
  /// **'Streaming Available'**
  String get streamingAvailableNotification;

  /// No description provided for @streamingAvailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when available on your streaming services'**
  String get streamingAvailableSubtitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @selectReleaseDateCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Release Date Country'**
  String get selectReleaseDateCountry;

  /// No description provided for @selectTitleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Title Language'**
  String get selectTitleLanguage;

  /// No description provided for @selectDisplayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Display Language'**
  String get selectDisplayLanguage;

  /// No description provided for @releaseCountrySet.
  ///
  /// In en, this message translates to:
  /// **'Release country set to {country}. Refresh data to apply.'**
  String releaseCountrySet(String country);

  /// No description provided for @updatingMovieTitles.
  ///
  /// In en, this message translates to:
  /// **'Updating movie titles to {language}...'**
  String updatingMovieTitles(String language);

  /// No description provided for @updatedMovieTitles.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} movie(s) to {language}'**
  String updatedMovieTitles(int count, String language);

  /// No description provided for @refreshFromTmdbTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data from TMDb?'**
  String get refreshFromTmdbTitle;

  /// No description provided for @refreshFromTmdbConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will update all movies with the latest data from TMDb (release dates, streaming availability, posters, etc.). This may take a moment.'**
  String get refreshFromTmdbConfirmation;

  /// No description provided for @exportDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportDataTitle;

  /// No description provided for @selectWhatToExport.
  ///
  /// In en, this message translates to:
  /// **'Select what to export:'**
  String get selectWhatToExport;

  /// No description provided for @exportWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get exportWatchlist;

  /// No description provided for @exportWatchlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Movies you want to watch (Cinema)'**
  String get exportWatchlistSubtitle;

  /// No description provided for @exportLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get exportLibrary;

  /// No description provided for @exportLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watched, rewatch, streaming'**
  String get exportLibrarySubtitle;

  /// No description provided for @exportSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get exportSettingsLabel;

  /// No description provided for @exportSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications, streaming services'**
  String get exportSettingsSubtitle;

  /// No description provided for @dataExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get dataExportedSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @importDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importDataTitle;

  /// No description provided for @importDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a BeStWatchList JSON file to import. Duplicate movies will be skipped.'**
  String get importDataDescription;

  /// No description provided for @importedMovies.
  ///
  /// In en, this message translates to:
  /// **'Imported {movies} movie(s), {skipped} skipped'**
  String importedMovies(int movies, int skipped);

  /// No description provided for @importedMoviesWithSettings.
  ///
  /// In en, this message translates to:
  /// **'Imported {movies} movie(s), {skipped} skipped. Settings restored.'**
  String importedMoviesWithSettings(int movies, int skipped);

  /// No description provided for @clearAllMoviesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Movies?'**
  String get clearAllMoviesTitle;

  /// No description provided for @clearAllMoviesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your movies from local storage. This action cannot be undone. Are you sure?'**
  String get clearAllMoviesConfirmation;

  /// No description provided for @allMoviesCleared.
  ///
  /// In en, this message translates to:
  /// **'All movies cleared'**
  String get allMoviesCleared;

  /// No description provided for @streamingServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaming Services'**
  String get streamingServicesTitle;

  /// No description provided for @streamingServicesDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the streaming services you subscribe to. We\'ll notify you when movies become available on your services.'**
  String get streamingServicesDescription;

  /// No description provided for @searchServicesHint.
  ///
  /// In en, this message translates to:
  /// **'Search streaming services...'**
  String get searchServicesHint;

  /// No description provided for @noStreamingProviders.
  ///
  /// In en, this message translates to:
  /// **'No streaming providers available'**
  String get noStreamingProviders;

  /// No description provided for @checkTmdbConfig.
  ///
  /// In en, this message translates to:
  /// **'Please check your TMDB API configuration.'**
  String get checkTmdbConfig;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get noServicesFound;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @menuMarkWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark as Watched'**
  String get menuMarkWatched;

  /// No description provided for @menuWantToRewatch.
  ///
  /// In en, this message translates to:
  /// **'Want to Rewatch'**
  String get menuWantToRewatch;

  /// No description provided for @menuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get menuDelete;

  /// No description provided for @menuRemoveFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from Library'**
  String get menuRemoveFromLibrary;

  /// No description provided for @menuSaveForStreaming.
  ///
  /// In en, this message translates to:
  /// **'Add to Streaming WatchList'**
  String get menuSaveForStreaming;

  /// No description provided for @menuViewShowtimes.
  ///
  /// In en, this message translates to:
  /// **'View on Cineman'**
  String get menuViewShowtimes;

  /// No description provided for @releaseDateTbd.
  ///
  /// In en, this message translates to:
  /// **'Release Date: TBD'**
  String get releaseDateTbd;

  /// No description provided for @releasesInDays.
  ///
  /// In en, this message translates to:
  /// **'Releases {date} (in {days} days)'**
  String releasesInDays(String date, int days);

  /// No description provided for @releasedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Released {date}'**
  String releasedOnDate(String date);

  /// No description provided for @openTmdb.
  ///
  /// In en, this message translates to:
  /// **'Open TMDb'**
  String get openTmdb;

  /// No description provided for @openImdb.
  ///
  /// In en, this message translates to:
  /// **'Open IMDb'**
  String get openImdb;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// No description provided for @tmdbApiKeyMissing.
  ///
  /// In en, this message translates to:
  /// **'TMDB API key not configured — movie browsing is unavailable.'**
  String get tmdbApiKeyMissing;

  /// No description provided for @tmdbApiKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'TMDB API key is invalid or expired — movie browsing is unavailable.'**
  String get tmdbApiKeyInvalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
