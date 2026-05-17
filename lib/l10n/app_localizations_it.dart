// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get navBrowse => 'Esplora';

  @override
  String get navCinema => 'Cinema';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get cancel => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get exportAction => 'Esporta';

  @override
  String get importAction => 'Importa';

  @override
  String get clearAll => 'Elimina tutto';

  @override
  String get selectFile => 'Seleziona file';

  @override
  String get moreActions => 'Altre azioni';

  @override
  String get searchTmdbHint => 'Cerca film su TMDb...';

  @override
  String get upcomingMoviesNext2Weeks =>
      'Film in uscita (prossime 2 settimane)';

  @override
  String get upcomingMovies => 'Film in uscita';

  @override
  String get noMoviesFound => 'Nessun film trovato';

  @override
  String get noUpcomingMovies => 'Nessun film in uscita';

  @override
  String get tryDifferentSearch => 'Prova un termine di ricerca diverso';

  @override
  String get checkBackLater => 'Ricontrolla più tardi o usa la ricerca';

  @override
  String get removeFromWatchlist => 'Rimuovi dalla lista';

  @override
  String get addToWatchlist => 'Aggiungi alla lista';

  @override
  String movieRemovedFromWatchlist(String title) {
    return '$title rimosso dalla lista';
  }

  @override
  String movieAddedToWatchlist(String title) {
    return '$title aggiunto alla lista';
  }

  @override
  String get searchCinemaHint => 'Cerca film al cinema...';

  @override
  String get noCinemaMovies => 'Nessun film al cinema';

  @override
  String get addMoviesFromBrowse => 'Aggiungi film dalla sezione Esplora';

  @override
  String get released => 'Usciti';

  @override
  String get upcomingReleases => 'Prossime uscite';

  @override
  String movieMarkedWatched(String title) {
    return '$title segnato come visto';
  }

  @override
  String movieAddedRewatch(String title) {
    return '$title aggiunto alla lista da rivedere';
  }

  @override
  String movieMovedStreaming(String title) {
    return '$title spostato alla lista streaming';
  }

  @override
  String movieDeleted(String title) {
    return '$title eliminato';
  }

  @override
  String couldNotOpenCineman(String error) {
    return 'Impossibile aprire Cineman: $error';
  }

  @override
  String get searchLibraryHint => 'Cerca nella tua libreria...';

  @override
  String get watched => 'Visti';

  @override
  String get streamingWatchlist => 'Lista streaming';

  @override
  String get noWatchedMovies => 'Nessun film visto';

  @override
  String get noMoviesToStream => 'Nessun film da guardare in streaming';

  @override
  String get markMoviesWatched =>
      'Segna i film come visti nella sezione Cinema';

  @override
  String get markMoviesForStreaming =>
      'Segna i film come \"Salva per streaming\" o \"Da rivedere\"';

  @override
  String get tryDifferentSearchOrFilter =>
      'Prova una ricerca o un filtro diverso';

  @override
  String get wantToRewatch => 'Da rivedere';

  @override
  String get saveForStreaming => 'Salva per streaming';

  @override
  String alsoOn(String title) {
    return '$title è anche su';
  }

  @override
  String get alsoOnOtherServices => 'Anche su altri servizi';

  @override
  String get sectionDataManagement => 'Gestione dati';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get sectionStreamingServices => 'Servizi streaming';

  @override
  String get sectionNotifications => 'Notifiche';

  @override
  String get sectionAbout => 'Informazioni';

  @override
  String get automaticUpdates => 'Aggiornamenti automatici';

  @override
  String get automaticUpdatesSubtitle =>
      'Le date di uscita si aggiornano automaticamente ogni settimana';

  @override
  String get refreshFromTmdb => 'Aggiorna da TMDb';

  @override
  String get refreshFromTmdbDescription =>
      'Aggiorna tutti i film con i dati più recenti di TMDb (date di uscita, disponibilità streaming, ecc.).\nQuesto viene eseguito automaticamente ogni settimana in background.';

  @override
  String get exportData => 'Esporta dati';

  @override
  String get importData => 'Importa dati';

  @override
  String get exportImportDescription =>
      'Esporta o importa la tua lista e i dati della libreria come file JSON.';

  @override
  String get clearAllMovies => 'Elimina tutti i film';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get darkThemeEnabled => 'Tema scuro attivo';

  @override
  String get lightThemeEnabled => 'Tema chiaro attivo';

  @override
  String get movieTitleLanguage => 'Lingua dei titoli';

  @override
  String get releaseDateCountry => 'Paese di uscita';

  @override
  String get displayLanguage => 'Lingua di visualizzazione';

  @override
  String get displayLanguageAuto => 'Auto (lingua del dispositivo)';

  @override
  String get manageStreamingServices => 'Gestisci servizi streaming';

  @override
  String servicesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servizi selezionati',
      one: '1 servizio selezionato',
      zero: 'Nessun servizio selezionato',
    );
    return '$_temp0';
  }

  @override
  String get enableNotifications => 'Abilita notifiche';

  @override
  String get masterNotificationToggle => 'Interruttore principale notifiche';

  @override
  String get sundayBeforeRelease => 'Domenica prima dell\'uscita';

  @override
  String get sundayBeforeReleaseSubtitle =>
      'Ricevi un promemoria la domenica prima dell\'uscita';

  @override
  String get releaseDayNotification => 'Giorno di uscita';

  @override
  String get releaseDaySubtitle =>
      'Notificato il giorno dell\'uscita di un film';

  @override
  String get saturdayAfterRelease => 'Sabato dopo l\'uscita';

  @override
  String get saturdayAfterReleaseSubtitle =>
      'Ricevi un promemoria il sabato dopo l\'uscita';

  @override
  String get leftCinema => 'Lasciato il cinema';

  @override
  String get leftCinemaSubtitle => 'Notificato quando un film lascia il cinema';

  @override
  String get streamingAvailableNotification => 'Disponibile in streaming';

  @override
  String get streamingAvailableSubtitle =>
      'Notificato quando disponibile sui tuoi servizi streaming';

  @override
  String get versionLabel => 'Versione';

  @override
  String get selectReleaseDateCountry => 'Seleziona paese di uscita';

  @override
  String get selectTitleLanguage => 'Seleziona lingua dei titoli';

  @override
  String get selectDisplayLanguage => 'Seleziona lingua di visualizzazione';

  @override
  String releaseCountrySet(String country) {
    return 'Paese di uscita impostato su $country. Aggiorna i dati per applicare.';
  }

  @override
  String updatingMovieTitles(String language) {
    return 'Aggiornamento titoli film in $language...';
  }

  @override
  String updatedMovieTitles(int count, String language) {
    return '$count film aggiornati in $language';
  }

  @override
  String get refreshFromTmdbTitle => 'Aggiornare da TMDb?';

  @override
  String get refreshFromTmdbConfirmation =>
      'Tutti i film verranno aggiornati con i dati più recenti di TMDb (date di uscita, disponibilità streaming, poster, ecc.). Potrebbe richiedere un momento.';

  @override
  String get exportDataTitle => 'Esporta dati';

  @override
  String get selectWhatToExport => 'Seleziona cosa esportare:';

  @override
  String get exportWatchlist => 'Lista';

  @override
  String get exportWatchlistSubtitle => 'Film che vuoi vedere (Cinema)';

  @override
  String get exportLibrary => 'Libreria';

  @override
  String get exportLibrarySubtitle => 'Visti, da rivedere, streaming';

  @override
  String get exportSettingsLabel => 'Impostazioni';

  @override
  String get exportSettingsSubtitle => 'Notifiche, servizi streaming';

  @override
  String get dataExportedSuccess => 'Dati esportati con successo';

  @override
  String exportFailed(String error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String get importDataTitle => 'Importa dati';

  @override
  String get importDataDescription =>
      'Seleziona un file JSON BeStWatchList da importare. I film duplicati verranno saltati.';

  @override
  String importedMovies(int movies, int skipped) {
    return '$movies film importati, $skipped saltati';
  }

  @override
  String importedMoviesWithSettings(int movies, int skipped) {
    return '$movies film importati, $skipped saltati. Impostazioni ripristinate.';
  }

  @override
  String get clearAllMoviesTitle => 'Eliminare tutti i film?';

  @override
  String get clearAllMoviesConfirmation =>
      'Tutti i film verranno eliminati dalla memoria locale. Questa azione non può essere annullata. Sei sicuro?';

  @override
  String get allMoviesCleared => 'Tutti i film eliminati';

  @override
  String get streamingServicesTitle => 'Servizi streaming';

  @override
  String get streamingServicesDescription =>
      'Seleziona i servizi streaming a cui sei abbonato. Ti notificheremo quando i film saranno disponibili sui tuoi servizi.';

  @override
  String get searchServicesHint => 'Cerca servizi streaming...';

  @override
  String get noStreamingProviders => 'Nessun provider streaming disponibile';

  @override
  String get checkTmdbConfig => 'Controlla la configurazione API TMDB.';

  @override
  String get noServicesFound => 'Nessun servizio trovato';

  @override
  String get subscribed => 'Abbonato';

  @override
  String get menuMarkWatched => 'Segna come visto';

  @override
  String get menuWantToRewatch => 'Da rivedere';

  @override
  String get menuDelete => 'Elimina';

  @override
  String get menuRemoveFromLibrary => 'Rimuovi dalla libreria';

  @override
  String get menuSaveForStreaming => 'Aggiungi alla lista streaming';

  @override
  String get menuViewShowtimes => 'Vedi su Cineman';

  @override
  String get releaseDateTbd => 'Data di uscita: TBD';

  @override
  String releasesInDays(String date, int days) {
    return 'Esce il $date (tra $days giorni)';
  }

  @override
  String releasedOnDate(String date) {
    return 'Uscito il $date';
  }

  @override
  String get openTmdb => 'Apri TMDb';

  @override
  String get openImdb => 'Apri IMDb';

  @override
  String get couldNotOpenLink => 'Impossibile aprire il link';

  @override
  String get tmdbApiKeyMissing =>
      'Chiave API TMDB non configurata — la ricerca film non è disponibile.';

  @override
  String get tmdbApiKeyInvalid =>
      'Chiave API TMDB non valida o scaduta — la ricerca film non è disponibile.';
}
