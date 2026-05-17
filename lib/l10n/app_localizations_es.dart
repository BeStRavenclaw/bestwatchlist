// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navBrowse => 'Explorar';

  @override
  String get navCinema => 'Cine';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get exportAction => 'Exportar';

  @override
  String get importAction => 'Importar';

  @override
  String get clearAll => 'Eliminar todo';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get searchTmdbHint => 'Buscar películas en TMDb...';

  @override
  String get upcomingMoviesNext2Weeks =>
      'Próximas películas (próximas 2 semanas)';

  @override
  String get upcomingMovies => 'Próximas películas';

  @override
  String get noMoviesFound => 'No se encontraron películas';

  @override
  String get noUpcomingMovies => 'No hay próximas películas';

  @override
  String get tryDifferentSearch => 'Intenta con otro término de búsqueda';

  @override
  String get checkBackLater => 'Vuelve más tarde o usa la búsqueda';

  @override
  String get removeFromWatchlist => 'Quitar de la lista';

  @override
  String get addToWatchlist => 'Agregar a la lista';

  @override
  String movieRemovedFromWatchlist(String title) {
    return '$title quitada de la lista';
  }

  @override
  String movieAddedToWatchlist(String title) {
    return '$title agregada a la lista';
  }

  @override
  String get searchCinemaHint => 'Buscar películas de cine...';

  @override
  String get noCinemaMovies => 'Sin películas de cine aún';

  @override
  String get addMoviesFromBrowse => 'Agrega películas desde Explorar';

  @override
  String get released => 'Estrenadas';

  @override
  String get upcomingReleases => 'Próximos estrenos';

  @override
  String movieMarkedWatched(String title) {
    return '$title marcada como vista';
  }

  @override
  String movieAddedRewatch(String title) {
    return '$title agregada a la lista de repetición';
  }

  @override
  String movieMovedStreaming(String title) {
    return '$title movida a la lista de streaming';
  }

  @override
  String movieDeleted(String title) {
    return '$title eliminada';
  }

  @override
  String couldNotOpenCineman(String error) {
    return 'No se pudo abrir Cineman: $error';
  }

  @override
  String get searchLibraryHint => 'Buscar en tu biblioteca...';

  @override
  String get watched => 'Vistas';

  @override
  String get streamingWatchlist => 'Lista de streaming';

  @override
  String get noWatchedMovies => 'Sin películas vistas aún';

  @override
  String get noMoviesToStream => 'Sin películas para streaming';

  @override
  String get markMoviesWatched => 'Marca películas como vistas desde Cine';

  @override
  String get markMoviesForStreaming =>
      'Marca películas como \"Guardar para streaming\" o \"Volver a ver\"';

  @override
  String get tryDifferentSearchOrFilter => 'Intenta con otra búsqueda o filtro';

  @override
  String get wantToRewatch => 'Volver a ver';

  @override
  String get saveForStreaming => 'Guardar para streaming';

  @override
  String alsoOn(String title) {
    return '$title también está en';
  }

  @override
  String get alsoOnOtherServices => 'También en otros servicios';

  @override
  String get sectionDataManagement => 'Gestión de datos';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get sectionStreamingServices => 'Servicios de streaming';

  @override
  String get sectionNotifications => 'Notificaciones';

  @override
  String get sectionAbout => 'Acerca de';

  @override
  String get automaticUpdates => 'Actualizaciones automáticas';

  @override
  String get automaticUpdatesSubtitle =>
      'Las fechas de estreno se actualizan automáticamente cada semana';

  @override
  String get refreshFromTmdb => 'Actualizar desde TMDb';

  @override
  String get refreshFromTmdbDescription =>
      'Actualiza todas las películas con los últimos datos de TMDb (fechas de estreno, disponibilidad en streaming, etc.).\nEsto se ejecuta automáticamente cada semana en segundo plano.';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get importData => 'Importar datos';

  @override
  String get exportImportDescription =>
      'Exporta o importa tus datos de lista y biblioteca como archivos JSON.';

  @override
  String get clearAllMovies => 'Eliminar todas las películas';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get darkThemeEnabled => 'Tema oscuro activado';

  @override
  String get lightThemeEnabled => 'Tema claro activado';

  @override
  String get movieTitleLanguage => 'Idioma de títulos';

  @override
  String get releaseDateCountry => 'País de estreno';

  @override
  String get displayLanguage => 'Idioma de la app';

  @override
  String get displayLanguageAuto => 'Auto (idioma del dispositivo)';

  @override
  String get manageStreamingServices => 'Gestionar servicios de streaming';

  @override
  String servicesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servicios seleccionados',
      one: '1 servicio seleccionado',
      zero: 'Sin servicios seleccionados',
    );
    return '$_temp0';
  }

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get masterNotificationToggle =>
      'Interruptor principal de notificaciones';

  @override
  String get sundayBeforeRelease => 'Domingo antes del estreno';

  @override
  String get sundayBeforeReleaseSubtitle =>
      'Recibe un recordatorio el domingo antes del estreno';

  @override
  String get releaseDayNotification => 'Día de estreno';

  @override
  String get releaseDaySubtitle =>
      'Notificado el día del estreno de una película';

  @override
  String get saturdayAfterRelease => 'Sábado después del estreno';

  @override
  String get saturdayAfterReleaseSubtitle =>
      'Recibe un recordatorio el sábado después del estreno';

  @override
  String get leftCinema => 'Salida del cine';

  @override
  String get leftCinemaSubtitle =>
      'Notificado cuando una película sale del cine';

  @override
  String get streamingAvailableNotification => 'Disponible en streaming';

  @override
  String get streamingAvailableSubtitle =>
      'Notificado cuando está disponible en tus servicios de streaming';

  @override
  String get versionLabel => 'Versión';

  @override
  String get selectReleaseDateCountry => 'Seleccionar país de estreno';

  @override
  String get selectTitleLanguage => 'Seleccionar idioma de títulos';

  @override
  String get selectDisplayLanguage => 'Seleccionar idioma de la app';

  @override
  String releaseCountrySet(String country) {
    return 'País de estreno establecido en $country. Actualiza los datos para aplicar.';
  }

  @override
  String updatingMovieTitles(String language) {
    return 'Actualizando títulos en $language...';
  }

  @override
  String updatedMovieTitles(int count, String language) {
    return '$count película(s) actualizada(s) en $language';
  }

  @override
  String get refreshFromTmdbTitle => '¿Actualizar desde TMDb?';

  @override
  String get refreshFromTmdbConfirmation =>
      'Todas las películas se actualizarán con los últimos datos de TMDb (fechas de estreno, disponibilidad en streaming, pósters, etc.). Puede tardar un momento.';

  @override
  String get exportDataTitle => 'Exportar datos';

  @override
  String get selectWhatToExport => 'Selecciona qué exportar:';

  @override
  String get exportWatchlist => 'Lista';

  @override
  String get exportWatchlistSubtitle => 'Películas que quieres ver (Cine)';

  @override
  String get exportLibrary => 'Biblioteca';

  @override
  String get exportLibrarySubtitle => 'Vistas, repetición, streaming';

  @override
  String get exportSettingsLabel => 'Ajustes';

  @override
  String get exportSettingsSubtitle => 'Notificaciones, servicios de streaming';

  @override
  String get dataExportedSuccess => 'Datos exportados correctamente';

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get importDataTitle => 'Importar datos';

  @override
  String get importDataDescription =>
      'Selecciona un archivo JSON de BeStWatchList para importar. Las películas duplicadas serán omitidas.';

  @override
  String importedMovies(int movies, int skipped) {
    return '$movies película(s) importada(s), $skipped omitida(s)';
  }

  @override
  String importedMoviesWithSettings(int movies, int skipped) {
    return '$movies película(s) importada(s), $skipped omitida(s). Ajustes restaurados.';
  }

  @override
  String get clearAllMoviesTitle => '¿Eliminar todas las películas?';

  @override
  String get clearAllMoviesConfirmation =>
      'Todas las películas se eliminarán del almacenamiento local. Esta acción no se puede deshacer. ¿Estás seguro?';

  @override
  String get allMoviesCleared => 'Todas las películas eliminadas';

  @override
  String get streamingServicesTitle => 'Servicios de streaming';

  @override
  String get streamingServicesDescription =>
      'Selecciona los servicios de streaming a los que estás suscrito. Te notificaremos cuando las películas estén disponibles en tus servicios.';

  @override
  String get searchServicesHint => 'Buscar servicios de streaming...';

  @override
  String get noStreamingProviders =>
      'No hay proveedores de streaming disponibles';

  @override
  String get checkTmdbConfig =>
      'Por favor verifica tu configuración de API de TMDB.';

  @override
  String get noServicesFound => 'No se encontraron servicios';

  @override
  String get subscribed => 'Suscrito';

  @override
  String get menuMarkWatched => 'Marcar como vista';

  @override
  String get menuWantToRewatch => 'Volver a ver';

  @override
  String get menuDelete => 'Eliminar';

  @override
  String get menuRemoveFromLibrary => 'Quitar de la biblioteca';

  @override
  String get menuSaveForStreaming => 'Agregar a lista de streaming';

  @override
  String get menuViewShowtimes => 'Ver en Cineman';

  @override
  String get releaseDateTbd => 'Fecha de estreno: TBD';

  @override
  String releasesInDays(String date, int days) {
    return 'Sale el $date (en $days días)';
  }

  @override
  String releasedOnDate(String date) {
    return 'Estrenada el $date';
  }

  @override
  String get openTmdb => 'Abrir TMDb';

  @override
  String get openImdb => 'Abrir IMDb';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get tmdbApiKeyMissing =>
      'Clave API TMDB no configurada — la búsqueda de películas no está disponible.';

  @override
  String get tmdbApiKeyInvalid =>
      'Clave API TMDB inválida o expirada — la búsqueda de películas no está disponible.';
}
