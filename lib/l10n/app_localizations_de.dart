// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navBrowse => 'Suchen';

  @override
  String get navCinema => 'Kino';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get exportAction => 'Exportieren';

  @override
  String get importAction => 'Importieren';

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get selectFile => 'Datei auswählen';

  @override
  String get moreActions => 'Weitere Aktionen';

  @override
  String get searchTmdbHint => 'Filme auf TMDb suchen...';

  @override
  String get upcomingMoviesNext2Weeks => 'Kommende Filme (Nächste 2 Wochen)';

  @override
  String get upcomingMovies => 'Kommende Filme';

  @override
  String get noMoviesFound => 'Keine Filme gefunden';

  @override
  String get noUpcomingMovies => 'Keine kommenden Filme';

  @override
  String get tryDifferentSearch => 'Versuche einen anderen Suchbegriff';

  @override
  String get checkBackLater => 'Schau später nochmal oder nutze die Suche';

  @override
  String get removeFromWatchlist => 'Von Merkliste entfernen';

  @override
  String get addToWatchlist => 'Zur Merkliste hinzufügen';

  @override
  String movieRemovedFromWatchlist(String title) {
    return '$title von der Merkliste entfernt';
  }

  @override
  String movieAddedToWatchlist(String title) {
    return '$title zur Merkliste hinzugefügt';
  }

  @override
  String get searchCinemaHint => 'Kinofilme suchen...';

  @override
  String get noCinemaMovies => 'Noch keine Kinofilme';

  @override
  String get addMoviesFromBrowse =>
      'Füge Filme aus der Suche zur Merkliste hinzu';

  @override
  String get released => 'Erschienen';

  @override
  String get upcomingReleases => 'Kommende Veröffentlichungen';

  @override
  String movieMarkedWatched(String title) {
    return '$title als gesehen markiert';
  }

  @override
  String movieAddedRewatch(String title) {
    return '$title zur Wiederholungsliste hinzugefügt';
  }

  @override
  String movieMovedStreaming(String title) {
    return '$title zur Streaming-Liste verschoben';
  }

  @override
  String movieDeleted(String title) {
    return '$title gelöscht';
  }

  @override
  String couldNotOpenCineman(String error) {
    return 'Cineman konnte nicht geöffnet werden: $error';
  }

  @override
  String get searchLibraryHint => 'Bibliothek durchsuchen...';

  @override
  String get watched => 'Gesehen';

  @override
  String get streamingWatchlist => 'Streaming-Merkliste';

  @override
  String get noWatchedMovies => 'Noch keine gesehenen Filme';

  @override
  String get noMoviesToStream => 'Keine Filme zum Streamen';

  @override
  String get markMoviesWatched => 'Markiere Filme als gesehen im Kino-Tab';

  @override
  String get markMoviesForStreaming =>
      'Markiere Filme als \"Für Streaming speichern\" oder \"Nochmal ansehen\"';

  @override
  String get tryDifferentSearchOrFilter =>
      'Versuche einen anderen Such- oder Filterbegriff';

  @override
  String get wantToRewatch => 'Nochmal ansehen';

  @override
  String get saveForStreaming => 'Für Streaming speichern';

  @override
  String alsoOn(String title) {
    return '$title ist auch auf';
  }

  @override
  String get alsoOnOtherServices => 'Auch auf anderen Diensten';

  @override
  String get sectionDataManagement => 'Datenverwaltung';

  @override
  String get sectionAppearance => 'Erscheinungsbild';

  @override
  String get sectionStreamingServices => 'Streaming-Dienste';

  @override
  String get sectionNotifications => 'Benachrichtigungen';

  @override
  String get sectionAbout => 'Über';

  @override
  String get automaticUpdates => 'Automatische Aktualisierungen';

  @override
  String get automaticUpdatesSubtitle =>
      'Erscheinungsdaten werden automatisch jede Woche aktualisiert';

  @override
  String get refreshFromTmdb => 'Daten von TMDb aktualisieren';

  @override
  String get refreshFromTmdbDescription =>
      'Aktualisiert alle Filme mit den neuesten Daten von TMDb (Erscheinungsdaten, Streaming-Verfügbarkeit, etc.).\nDies wird automatisch jede Woche im Hintergrund ausgeführt.';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get exportImportDescription =>
      'Exportiere oder importiere deine Merklisten- und Bibliotheksdaten als JSON-Dateien.';

  @override
  String get clearAllMovies => 'Alle Filme löschen';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get darkThemeEnabled => 'Dunkles Design aktiviert';

  @override
  String get lightThemeEnabled => 'Helles Design aktiviert';

  @override
  String get movieTitleLanguage => 'Filmtitel-Sprache';

  @override
  String get releaseDateCountry => 'Erscheinungsland';

  @override
  String get displayLanguage => 'Anzeigesprache';

  @override
  String get displayLanguageAuto => 'Auto (Gerätesprache)';

  @override
  String get manageStreamingServices => 'Streaming-Dienste verwalten';

  @override
  String servicesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dienste ausgewählt',
      one: '1 Dienst ausgewählt',
      zero: 'Keine Dienste ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get masterNotificationToggle => 'Haupt-Benachrichtigungsschalter';

  @override
  String get sundayBeforeRelease => 'Sonntag vor Veröffentlichung';

  @override
  String get sundayBeforeReleaseSubtitle =>
      'Werde am Sonntag vor dem Erscheinungsdatum erinnert';

  @override
  String get releaseDayNotification => 'Erscheinungstag';

  @override
  String get releaseDaySubtitle =>
      'Werde benachrichtigt, wenn ein Film erscheint';

  @override
  String get saturdayAfterRelease => 'Samstag nach Veröffentlichung';

  @override
  String get saturdayAfterReleaseSubtitle =>
      'Werde am Samstag nach dem Erscheinungsdatum erinnert';

  @override
  String get leftCinema => 'Kino verlassen';

  @override
  String get leftCinemaSubtitle =>
      'Werde benachrichtigt, wenn ein Film das Kino verlässt';

  @override
  String get streamingAvailableNotification => 'Streaming verfügbar';

  @override
  String get streamingAvailableSubtitle =>
      'Werde benachrichtigt, wenn ein Film auf deinen Streaming-Diensten verfügbar ist';

  @override
  String get versionLabel => 'Version';

  @override
  String get selectReleaseDateCountry => 'Erscheinungsland auswählen';

  @override
  String get selectTitleLanguage => 'Filmtitel-Sprache auswählen';

  @override
  String get selectDisplayLanguage => 'Anzeigesprache auswählen';

  @override
  String releaseCountrySet(String country) {
    return 'Erscheinungsland auf $country gesetzt. Daten aktualisieren, um anzuwenden.';
  }

  @override
  String updatingMovieTitles(String language) {
    return 'Filmtitel werden auf $language aktualisiert...';
  }

  @override
  String updatedMovieTitles(int count, String language) {
    return '$count Film(e) auf $language aktualisiert';
  }

  @override
  String get refreshFromTmdbTitle => 'Daten von TMDb aktualisieren?';

  @override
  String get refreshFromTmdbConfirmation =>
      'Alle Filme werden mit den neuesten Daten von TMDb aktualisiert (Erscheinungsdaten, Streaming-Verfügbarkeit, Poster, etc.). Dies kann einen Moment dauern.';

  @override
  String get exportDataTitle => 'Daten exportieren';

  @override
  String get selectWhatToExport => 'Wähle aus, was exportiert werden soll:';

  @override
  String get exportWatchlist => 'Merkliste';

  @override
  String get exportWatchlistSubtitle => 'Filme, die du sehen möchtest (Kino)';

  @override
  String get exportLibrary => 'Bibliothek';

  @override
  String get exportLibrarySubtitle => 'Gesehen, Wiederholen, Streaming';

  @override
  String get exportSettingsLabel => 'Einstellungen';

  @override
  String get exportSettingsSubtitle => 'Benachrichtigungen, Streaming-Dienste';

  @override
  String get dataExportedSuccess => 'Daten erfolgreich exportiert';

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get importDataTitle => 'Daten importieren';

  @override
  String get importDataDescription =>
      'Wähle eine BeStWatchList-JSON-Datei zum Importieren aus. Doppelte Filme werden übersprungen.';

  @override
  String importedMovies(int movies, int skipped) {
    return '$movies Film(e) importiert, $skipped übersprungen';
  }

  @override
  String importedMoviesWithSettings(int movies, int skipped) {
    return '$movies Film(e) importiert, $skipped übersprungen. Einstellungen wiederhergestellt.';
  }

  @override
  String get clearAllMoviesTitle => 'Alle Filme löschen?';

  @override
  String get clearAllMoviesConfirmation =>
      'Alle Filme werden aus dem lokalen Speicher gelöscht. Diese Aktion kann nicht rückgängig gemacht werden. Bist du sicher?';

  @override
  String get allMoviesCleared => 'Alle Filme gelöscht';

  @override
  String get streamingServicesTitle => 'Streaming-Dienste';

  @override
  String get streamingServicesDescription =>
      'Wähle die Streaming-Dienste aus, die du abonniert hast. Wir benachrichtigen dich, wenn Filme auf deinen Diensten verfügbar werden.';

  @override
  String get searchServicesHint => 'Streaming-Dienste suchen...';

  @override
  String get noStreamingProviders => 'Keine Streaming-Anbieter verfügbar';

  @override
  String get checkTmdbConfig => 'Bitte überprüfe deine TMDB-API-Konfiguration.';

  @override
  String get noServicesFound => 'Keine Dienste gefunden';

  @override
  String get subscribed => 'Abonniert';

  @override
  String get menuMarkWatched => 'Als gesehen markieren';

  @override
  String get menuWantToRewatch => 'Nochmal ansehen';

  @override
  String get menuDelete => 'Löschen';

  @override
  String get menuRemoveFromLibrary => 'Aus Bibliothek entfernen';

  @override
  String get menuSaveForStreaming => 'Zur Streaming-Merkliste hinzufügen';

  @override
  String get menuViewShowtimes => 'Auf Cineman ansehen';

  @override
  String get releaseDateTbd => 'Erscheinungsdatum: TBD';

  @override
  String releasesInDays(String date, int days) {
    return 'Erscheint $date (in $days Tagen)';
  }

  @override
  String releasedOnDate(String date) {
    return 'Erschienen am $date';
  }

  @override
  String get openTmdb => 'TMDb öffnen';

  @override
  String get openImdb => 'IMDb öffnen';

  @override
  String get couldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String get tmdbApiKeyMissing =>
      'TMDB-API-Schlüssel nicht konfiguriert — Film-Suche nicht verfügbar.';

  @override
  String get tmdbApiKeyInvalid =>
      'TMDB-API-Schlüssel ungültig oder abgelaufen — Film-Suche nicht verfügbar.';
}
