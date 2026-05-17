// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navBrowse => 'Explorer';

  @override
  String get navCinema => 'Cinéma';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get refresh => 'Actualiser';

  @override
  String get exportAction => 'Exporter';

  @override
  String get importAction => 'Importer';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get selectFile => 'Sélectionner un fichier';

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String get searchTmdbHint => 'Rechercher des films sur TMDb...';

  @override
  String get upcomingMoviesNext2Weeks =>
      'Films à venir (2 prochaines semaines)';

  @override
  String get upcomingMovies => 'Films à venir';

  @override
  String get noMoviesFound => 'Aucun film trouvé';

  @override
  String get noUpcomingMovies => 'Aucun film à venir';

  @override
  String get tryDifferentSearch => 'Essayez un autre terme de recherche';

  @override
  String get checkBackLater => 'Revenez plus tard ou utilisez la recherche';

  @override
  String get removeFromWatchlist => 'Retirer de la liste de suivi';

  @override
  String get addToWatchlist => 'Ajouter à la liste de suivi';

  @override
  String movieRemovedFromWatchlist(String title) {
    return '$title retiré de la liste de suivi';
  }

  @override
  String movieAddedToWatchlist(String title) {
    return '$title ajouté à la liste de suivi';
  }

  @override
  String get searchCinemaHint => 'Rechercher des films au cinéma...';

  @override
  String get noCinemaMovies => 'Aucun film de cinéma pour l\'instant';

  @override
  String get addMoviesFromBrowse => 'Ajoutez des films depuis Explorer';

  @override
  String get released => 'Sortis';

  @override
  String get upcomingReleases => 'Sorties à venir';

  @override
  String movieMarkedWatched(String title) {
    return '$title marqué comme vu';
  }

  @override
  String movieAddedRewatch(String title) {
    return '$title ajouté à la liste de revisionnage';
  }

  @override
  String movieMovedStreaming(String title) {
    return '$title déplacé vers la liste de streaming';
  }

  @override
  String movieDeleted(String title) {
    return '$title supprimé';
  }

  @override
  String couldNotOpenCineman(String error) {
    return 'Impossible d\'ouvrir Cineman : $error';
  }

  @override
  String get searchLibraryHint => 'Rechercher dans votre bibliothèque...';

  @override
  String get watched => 'Vu';

  @override
  String get streamingWatchlist => 'Liste de streaming';

  @override
  String get noWatchedMovies => 'Aucun film vu pour l\'instant';

  @override
  String get noMoviesToStream => 'Aucun film à streamer';

  @override
  String get markMoviesWatched => 'Marquez des films comme vus depuis Cinéma';

  @override
  String get markMoviesForStreaming =>
      'Marquez des films comme \"Enregistrer pour streaming\" ou \"Revoir\"';

  @override
  String get tryDifferentSearchOrFilter =>
      'Essayez une autre recherche ou un autre filtre';

  @override
  String get wantToRewatch => 'Revoir';

  @override
  String get saveForStreaming => 'Enregistrer pour streaming';

  @override
  String alsoOn(String title) {
    return '$title est aussi sur';
  }

  @override
  String get alsoOnOtherServices => 'Aussi sur d\'autres services';

  @override
  String get sectionDataManagement => 'Gestion des données';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get sectionStreamingServices => 'Services de streaming';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionAbout => 'À propos';

  @override
  String get automaticUpdates => 'Mises à jour automatiques';

  @override
  String get automaticUpdatesSubtitle =>
      'Les dates de sortie se mettent à jour automatiquement chaque semaine';

  @override
  String get refreshFromTmdb => 'Actualiser depuis TMDb';

  @override
  String get refreshFromTmdbDescription =>
      'Met à jour tous les films avec les dernières données de TMDb (dates de sortie, disponibilité en streaming, etc.).\nCela s\'exécute automatiquement chaque semaine en arrière-plan.';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get importData => 'Importer les données';

  @override
  String get exportImportDescription =>
      'Exportez ou importez vos données de liste de suivi et de bibliothèque en tant que fichiers JSON.';

  @override
  String get clearAllMovies => 'Effacer tous les films';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get darkThemeEnabled => 'Thème sombre activé';

  @override
  String get lightThemeEnabled => 'Thème clair activé';

  @override
  String get movieTitleLanguage => 'Langue des titres de films';

  @override
  String get releaseDateCountry => 'Pays de sortie';

  @override
  String get displayLanguage => 'Langue d\'affichage';

  @override
  String get displayLanguageAuto => 'Auto (langue de l\'appareil)';

  @override
  String get manageStreamingServices => 'Gérer les services de streaming';

  @override
  String servicesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services sélectionnés',
      one: '1 service sélectionné',
      zero: 'Aucun service sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get masterNotificationToggle =>
      'Interrupteur principal des notifications';

  @override
  String get sundayBeforeRelease => 'Dimanche avant la sortie';

  @override
  String get sundayBeforeReleaseSubtitle =>
      'Rappel le dimanche avant la sortie d\'un film';

  @override
  String get releaseDayNotification => 'Jour de sortie';

  @override
  String get releaseDaySubtitle => 'Notifié le jour de la sortie d\'un film';

  @override
  String get saturdayAfterRelease => 'Samedi après la sortie';

  @override
  String get saturdayAfterReleaseSubtitle => 'Rappel le samedi après la sortie';

  @override
  String get leftCinema => 'Quitte le cinéma';

  @override
  String get leftCinemaSubtitle => 'Notifié quand un film quitte le cinéma';

  @override
  String get streamingAvailableNotification => 'Disponible en streaming';

  @override
  String get streamingAvailableSubtitle =>
      'Notifié quand disponible sur vos services de streaming';

  @override
  String get versionLabel => 'Version';

  @override
  String get selectReleaseDateCountry => 'Sélectionner le pays de sortie';

  @override
  String get selectTitleLanguage => 'Sélectionner la langue des titres';

  @override
  String get selectDisplayLanguage => 'Sélectionner la langue d\'affichage';

  @override
  String releaseCountrySet(String country) {
    return 'Pays de sortie défini sur $country. Actualisez les données pour appliquer.';
  }

  @override
  String updatingMovieTitles(String language) {
    return 'Mise à jour des titres de films en $language...';
  }

  @override
  String updatedMovieTitles(int count, String language) {
    return '$count film(s) mis à jour en $language';
  }

  @override
  String get refreshFromTmdbTitle => 'Actualiser depuis TMDb ?';

  @override
  String get refreshFromTmdbConfirmation =>
      'Tous les films seront mis à jour avec les dernières données de TMDb (dates de sortie, disponibilité en streaming, affiches, etc.). Cela peut prendre un moment.';

  @override
  String get exportDataTitle => 'Exporter les données';

  @override
  String get selectWhatToExport => 'Sélectionnez ce à exporter :';

  @override
  String get exportWatchlist => 'Liste de suivi';

  @override
  String get exportWatchlistSubtitle => 'Films que vous voulez voir (Cinéma)';

  @override
  String get exportLibrary => 'Bibliothèque';

  @override
  String get exportLibrarySubtitle => 'Vu, revoir, streaming';

  @override
  String get exportSettingsLabel => 'Paramètres';

  @override
  String get exportSettingsSubtitle => 'Notifications, services de streaming';

  @override
  String get dataExportedSuccess => 'Données exportées avec succès';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'export : $error';
  }

  @override
  String get importDataTitle => 'Importer les données';

  @override
  String get importDataDescription =>
      'Sélectionnez un fichier JSON BeStWatchList à importer. Les films en double seront ignorés.';

  @override
  String importedMovies(int movies, int skipped) {
    return '$movies film(s) importé(s), $skipped ignoré(s)';
  }

  @override
  String importedMoviesWithSettings(int movies, int skipped) {
    return '$movies film(s) importé(s), $skipped ignoré(s). Paramètres restaurés.';
  }

  @override
  String get clearAllMoviesTitle => 'Effacer tous les films ?';

  @override
  String get clearAllMoviesConfirmation =>
      'Tous les films seront supprimés du stockage local. Cette action est irréversible. Êtes-vous sûr ?';

  @override
  String get allMoviesCleared => 'Tous les films effacés';

  @override
  String get streamingServicesTitle => 'Services de streaming';

  @override
  String get streamingServicesDescription =>
      'Sélectionnez les services de streaming auxquels vous êtes abonné. Nous vous notifierons quand des films seront disponibles sur vos services.';

  @override
  String get searchServicesHint => 'Rechercher des services de streaming...';

  @override
  String get noStreamingProviders =>
      'Aucun fournisseur de streaming disponible';

  @override
  String get checkTmdbConfig =>
      'Veuillez vérifier votre configuration API TMDB.';

  @override
  String get noServicesFound => 'Aucun service trouvé';

  @override
  String get subscribed => 'Abonné';

  @override
  String get menuMarkWatched => 'Marquer comme vu';

  @override
  String get menuWantToRewatch => 'Revoir';

  @override
  String get menuDelete => 'Supprimer';

  @override
  String get menuRemoveFromLibrary => 'Retirer de la bibliothèque';

  @override
  String get menuSaveForStreaming => 'Ajouter à la liste de streaming';

  @override
  String get menuViewShowtimes => 'Voir sur Cineman';

  @override
  String get releaseDateTbd => 'Date de sortie : TBD';

  @override
  String releasesInDays(String date, int days) {
    return 'Sortie le $date (dans $days jours)';
  }

  @override
  String releasedOnDate(String date) {
    return 'Sorti le $date';
  }

  @override
  String get openTmdb => 'Ouvrir TMDb';

  @override
  String get openImdb => 'Ouvrir IMDb';

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get tmdbApiKeyMissing =>
      'Clé API TMDB non configurée — la recherche de films est indisponible.';

  @override
  String get tmdbApiKeyInvalid =>
      'Clé API TMDB invalide ou expirée — la recherche de films est indisponible.';
}
