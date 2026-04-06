# BeStWatchList - Complete Project Documentation

## Overview

**BeStWatchList** is a Flutter movie watchlist app focused on cinema releases in the DACH region (Germany/Austria/Switzerland). Users browse upcoming movies via the TMDb API, add them to a cinema watchlist, get notified around release dates, track what they've watched, and manage a streaming watchlist. Includes an Android home screen widget showing the cinema watchlist.

**Package name:** `com.example.bestwatchlist`
**Flutter SDK:** `^3.10.4`
**State management:** Provider (ChangeNotifier)
**Local database:** Hive
**Architecture:** MVC (Models, Controllers, Repositories, Services, Screens/Widgets)

---

## Project Structure

```
lib/
  main.dart
  models/
    movie.dart              # Movie model (Hive typeId: 0)
    movie.g.dart            # Generated Hive adapter
    user_settings.dart      # Settings model (Hive typeId: 2)
    user_settings.g.dart    # Generated Hive adapter
  controllers/
    movie_controller.dart   # Movie business logic (ChangeNotifier)
    settings_controller.dart # Settings business logic (ChangeNotifier)
  repositories/
    movie_repository.dart   # Hive CRUD for movies
    settings_repository.dart # Hive CRUD for settings
    tmdb_repository.dart    # TMDb API client
  services/
    notification_service.dart  # Local notifications (flutter_local_notifications)
    background_sync.dart       # Weekly background sync (workmanager)
    home_widget_service.dart   # Android widget via MethodChannel
    import_export_service.dart # JSON import/export via file_picker
  screens/
    browse_screen.dart          # TMDb search + upcoming movies
    cinema_screen.dart          # Cinema watchlist (wantToWatch)
    streaming_screen.dart       # Library (watched + streaming watchlist)
    settings_screen.dart        # App settings
    streaming_services_screen.dart # Streaming service picker
  views/widgets/
    movie_card.dart            # Reusable movie card + MovieInfoButton + MovieActionButtons
  widgets/
    app_logo_header.dart       # Styled "BeStWatchList" header with SVG logo
    showtime_dialog.dart       # Cineman URL launcher
    action_buttons.dart        # ActionPopupMenu, ActionMenuItem, ActionIconButton, EmptyStateWidget
  constants/
    app_colors.dart            # Color constants
    app_icons.dart             # Icon constants + sizes
    menu_items.dart            # Predefined MenuItemData instances
assets/
  logo.svg                     # App logo (monitor + clapperboard, gold on dark)
android/app/src/main/
  kotlin/com/example/bestwatchlist/
    MainActivity.kt            # MethodChannel handler for widget data
    CinemaWidgetProvider.kt    # AppWidgetProvider + updateAppWidget()
    CinemaWidgetService.kt     # RemoteViewsService for widget ListView
    MidnightUpdateReceiver.kt  # Daily midnight widget refresh alarm
    BootReceiver.kt            # Reschedule alarm after device boot
  res/
    layout/cinema_widget_simple.xml  # Widget layout (header + ListView)
    layout/cinema_widget_item.xml    # Widget list item (title + date)
    xml/cinema_widget_info.xml       # Widget metadata (250x180dp min)
    drawable/widget_background.xml   # Dark rounded rect (#1A1A1A, 16dp radius)
    drawable/widget_item_background.xml # Item background (#2A2A2A, 8dp radius)
    drawable/widget_logo.xml         # Vector drawable logo for widget
    drawable/logo.xml                # Vector drawable logo
    values/colors.xml                # Widget color definitions
    values/strings.xml               # App name + widget description
```

---

## Environment Setup

### .env file (root of project)
```
TMDB_API_KEY=your_tmdb_api_key_here
```
Get an API key from https://www.themoviedb.org/settings/api

### .env.example
```
# TMDB API Configuration
# Get your API key from https://www.themoviedb.org/settings/api
TMDB_API_KEY=YOUR_API_KEY_HERE
```

The `.env` file is loaded via `flutter_dotenv` and listed as an asset in `pubspec.yaml`.

---

## Dependencies (pubspec.yaml)

```yaml
name: bestwatchlist
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.4

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.2.0
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2
  flutter_timezone: ^3.0.1
  workmanager: ^0.6.0
  provider: ^6.1.1
  url_launcher: ^6.2.3
  shared_preferences: ^2.2.2
  path_provider: ^2.1.2
  home_widget: ^0.6.0
  flutter_dotenv: ^5.1.0
  flutter_svg: ^2.0.10
  file_picker: ^8.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/logo.svg
```

---

## Data Models

### Movie (Hive typeId: 0)

| HiveField | Name | Type | Default | Notes |
|-----------|------|------|---------|-------|
| 0 | id | String | required | Format: `tmdb_{tmdbId}` |
| 1 | title | String | required | |
| 2 | releaseDate | DateTime | required | Year 9999 = TBD |
| 3 | posterUrl | String? | null | TMDb image URL (`w500`) |
| 4 | description | String? | null | TMDb overview |
| 5 | status | WatchStatus | wantToWatch | Enum |
| 8 | availableOnStreamingServices | List\<String\>? | null | Provider names |
| 9 | notificationSundayBefore | DateTime? | null | |
| 10 | notificationReleaseDay | DateTime? | null | |
| 11 | notificationSaturdayAfter | DateTime? | null | |
| 12 | notifiedLeftCinema | bool | false | |
| 13 | notifiedStreamingAvailable | bool | false | |
| 14 | imdbId | String? | null | |
| 15 | lastModified | DateTime? | DateTime.now() | |
| 16 | needsSync | bool | true | |
| 17 | originalReleaseYear | int? | null | Earliest premiere year (for Cineman URLs) |

**Note:** HiveFields 6 and 7 are skipped (previously used, removed).

### WatchStatus (Hive typeId: 1)

| Index | Value | Usage |
|-------|-------|-------|
| 0 | wantToWatch | Cinema watchlist |
| 1 | watched | Watched library |
| 2 | lostInterest | (defined but not actively used in UI) |
| 3 | wantToRewatch | Streaming watchlist |
| 4 | saveForStreaming | Streaming watchlist |

### UserSettings (Hive typeId: 2)

| HiveField | Name | Type | Default |
|-----------|------|------|---------|
| 1 | streamingServices | List\<String\> | [] |
| 2 | notificationsEnabled | bool | true |
| 3 | sundayBeforeNotifications | bool | true |
| 4 | releaseDayNotifications | bool | true |
| 5 | saturdayAfterNotifications | bool | true |
| 6 | leftCinemaNotifications | bool | true |
| 7 | streamingAvailableNotifications | bool | true |
| 8 | darkMode | bool | true |
| 9 | lastModified | DateTime? | DateTime.now() |
| 10 | needsSync | bool | true |
| 11 | titleLanguage | String | 'en' |

**Note:** HiveField 0 is skipped.

---

## App Initialization (main.dart)

1. Load `.env` via `flutter_dotenv`
2. Initialize Hive, register adapters (Movie=0, WatchStatus=1, UserSettings=2)
3. Open Hive boxes: `movies`, `settings`
4. Create default settings if box is empty; migrate old format if `darkMode` field missing
5. Initialize `BackgroundSyncService` (skipped on Windows)
6. Initialize `HomeWidgetService` (Android only)
7. Run `BeStWatchListApp`

### App Widget Tree

```
MultiProvider
  ├── ChangeNotifierProvider<MovieController>
  └── ChangeNotifierProvider<SettingsController>
      └── Consumer<SettingsController>  (for theme switching)
          └── MaterialApp
              ├── theme: light (gold + black)
              ├── darkTheme: dark (gold + deep black)
              ├── themeMode: from settings.darkMode
              └── HomeScreen (StatefulWidget)
                  ├── AppBar with AppLogoHeader
                  ├── Body: IndexedStack of 4 screens
                  └── BottomNavigationBar (4 tabs)
```

Both controllers receive the **same** `TMDbRepository` instance for language sync.

### Bottom Navigation Tabs

| Index | Label | Screen | Icon |
|-------|-------|--------|------|
| 0 | Browse | BrowseScreen | Icons.explore |
| 1 | Cinema | CinemaScreen | Icons.local_movies |
| 2 | Library | StreamingScreen | Icons.video_library |
| 3 | Settings | SettingsScreen | Icons.settings |

**Default tab:** Cinema (index 1)

---

## Theme / Colors

### Brand Colors (AppColors)
- **Gold:** `#D4AF37` - Primary brand color
- **Black:** `#1A1A1A` - Secondary/accent, app bar background
- **Dark Background:** `#0D0D0D` - Scaffold background in dark mode
- **Dark Border:** `#2A2A2A` - Card borders in dark mode

### Semantic Colors
- **Destructive:** `Colors.red`
- **Bookmark Active:** `Colors.deepPurple`
- **Rewatch:** `Colors.orange`
- **Streaming:** `Colors.blue`
- **Unselected Light:** `#888888`
- **Unselected Dark:** `#666666`

### Theme Configuration
- Both themes: AppBar is black background with gold foreground, elevation 0
- Dark mode: scaffold `#0D0D0D`, cards `#1A1A1A` with `#2A2A2A` border, 12dp radius
- Material 3 enabled, `ColorScheme.fromSeed` with gold seed

---

## Screens

### BrowseScreen
- Search bar at top (searches TMDb via `movieController.searchMovies()`)
- When not searching: shows "Upcoming Movies" from TMDb
  - Filters to movies releasing within next 2 weeks (DE region)
  - Falls back to all upcoming if none in 2-week window
  - Sorted by release date, TBD movies at end
- Each movie shows: poster, title, release date, description
- Trailing: MovieInfoButton (TMDb/IMDb link) + bookmark toggle icon
- Bookmark toggle: adds/removes from watchlist with `WatchStatus.wantToWatch`
- Bookmark active color: `Colors.deepPurple`

### CinemaScreen
- Search bar filters local watchlist
- Shows only movies with `WatchStatus.wantToWatch`
- Split into "Released" and "Upcoming Releases" sections with gold headers
- Section headers show category name
- Sorted by release date
- Tapping a movie card opens Cineman showtimes
- Each card: poster, title, release date (no description), MovieInfoButton + popup menu
- Popup menu actions: View on Cineman, Mark as Watched, Want to Rewatch, Add to Streaming WatchList, Delete

### StreamingScreen (Library)
- Search bar filters local library
- Toggle between "Watched" and "Streaming WatchList" via ChoiceChips
- **Watched tab:** movies with `WatchStatus.watched`, sorted by title
- **Streaming WatchList tab:** movies with `WatchStatus.saveForStreaming` OR `WatchStatus.wantToRewatch`, sorted by title
- Shows streaming availability chips if available
- Status labels: "Want to Rewatch" (orange), "Save for Streaming" (blue)
- Card uses `Card > ListTile` with poster, title, status, streaming chips
- Popup menu adapts to status:
  - From watched: Want to Rewatch, Remove
  - From rewatch/streaming: Mark as Watched, Remove

### SettingsScreen
- **Data Management:**
  - Info tile about automatic weekly updates
  - "Refresh Data from TMDb" button (gold) - manual full refresh with confirmation dialog
  - "Export Data" button (gold) - shows dialog with checkboxes (Watchlist, Library, Settings)
  - "Import Data" button (gold) - confirmation then file picker for JSON
  - "Clear All Movies" button (red outlined) - destructive with confirmation dialog
- **Appearance:**
  - Dark Mode toggle (SwitchListTile)
  - Movie Title Language selector (ListTile -> dialog with RadioListTile)
    - Languages: English, Deutsch, Francais, Espanol, Italiano
    - Changing language auto-refreshes all movie data from TMDb
- **Streaming Services:**
  - Shows count and chips of selected services (removable via chip delete)
  - Navigates to StreamingServicesScreen
- **Notifications:** Master toggle + 5 sub-toggles (Sunday Before, Release Day, Saturday After, Left Cinema, Streaming Available)
- **About:** Version tile showing "BeStWatchList v1.0.0"

### StreamingServicesScreen
- Full-screen page with AppBar (gold background, black text)
- Description text explaining the feature
- Search bar to filter services
- Loads available providers from TMDb API (`getAllAvailableProvidersForSwitzerland()`)
- CheckboxListTile for each provider (gold active color)
- Selected services saved via `settingsController.updateStreamingServices()`

---

## TMDb API Integration (TMDbRepository)

### Base Configuration
- Base URL: `https://api.themoviedb.org/3`
- Image base URL: `https://image.tmdb.org/t/p/w500`
- API key from `.env` file (`TMDB_API_KEY`)
- Language parameter mapped from settings: `en` -> `en-US`, `de` -> `de-DE`, `fr` -> `fr-FR`, `es` -> `es-ES`, `it` -> `it-IT`

### Endpoints Used

**Search:** `GET /search/movie` with `query` param

**Popular:** `GET /movie/popular`

**Now Playing:** `GET /movie/now_playing` with `region=DE`

**Upcoming (Discover):** `GET /discover/movie` with:
- `region=DE`
- `sort_by=release_date.asc`
- `with_release_type=2|3` (theatrical limited + theatrical)
- `release_date.gte={today}`

**Movie Details:** `GET /movie/{id}` with `append_to_response=external_ids,release_dates`

**Streaming Providers:** `GET /movie/{id}/watch/providers` - reads `CH` (Switzerland) flatrate providers

**All CH Providers:** `GET /watch/providers/movie` with `watch_region=CH`

### Movie Parsing Logic (_parseMovie)

1. **Release date resolution:** Looks for German (DE) theatrical release (type 2 or 3) in `release_dates`. Falls back to base `release_date`. Uses `DateTime(9999, 12, 31)` for TBD.
2. **Original release year:** Finds the earliest premiere/theatrical release globally (type 1, 2, or 3) across all regions. Compares with base `release_date` and uses the earlier year. Used for Cineman URL generation.
3. **IMDB ID:** From `external_ids.imdb_id` or `imdb_id` field.
4. **Movie ID format:** `tmdb_{tmdbId}`

### Provider Name Normalization
Maps TMDb provider names to standardized names:
- `Amazon Prime Video` -> `Prime Video`
- `Disney Plus` -> `Disney+`
- `Apple TV Plus` -> `Apple TV+`
- `Paramount Plus` -> `Paramount+`
- `blue TV` / `Blue TV` / `Swisscom blue TV` -> `blue TV`
- `Sky Go` -> `Sky`
- `Joyn Plus` -> `Joyn+`
- Others pass through unchanged

### _fetchMovies (DRY pattern)
All list endpoints go through `_fetchMovies()` which:
1. Builds query params with API key and language
2. Fetches the list endpoint
3. For each result, calls `getMovieDetails(tmdbId)` to get full data with release dates
4. Returns list of fully-parsed Movie objects

---

## Notification System (NotificationService)

Singleton pattern. Uses `flutter_local_notifications`.

### Initialization
- Initializes timezone data via `flutter_timezone`
- Android: `@mipmap/ic_launcher` notification icon
- iOS: deferred permission requests
- Creates 3 Android notification channels:
  - `release_notifications` (High importance)
  - `cinema_notifications` (Default importance)
  - `streaming_notifications` (Default importance)

### Scheduled Notifications (3 types per movie)

All scheduled at 10:00 AM local time. Skip if date has passed. Skip TBD movies. Uses exact alarms when permission granted, falls back to inexact.

1. **Sunday Before Release:** The Sunday before the release week. If release is on Sunday, goes back 7 days.
   - Title: "Movie releasing this week!"
   - Body: "{title} releases on {dd.mm.yyyy}"

2. **Release Day:** On the release date.
   - Title: "Movie released today!"
   - Body: "{title} is now available in theaters!"

3. **Saturday After Release:** The Saturday after release. If release is on Saturday, goes forward 7 days.
   - Title: "Have you seen it yet?"
   - Body: "{title} was released this week. Don't forget to watch it!"

### Immediate Notifications (2 types, triggered by background sync)

4. **Left Cinema:** When movie is 80-90 days past release and still `wantToWatch`.
   - Title: "Movie leaving theaters soon"
   - Body: "{title} is leaving theaters. Last chance to watch it on the big screen!"

5. **Streaming Available:** When a movie becomes available on user's subscribed streaming services.
   - Title: "Now streaming!"
   - Body: "{title} is now available on {service}"

### Notification ID Generation
`movieId.hashCode.abs() & 0x007FFFFF` * 10 + type (1-5). Fits in 32-bit signed int.

### Permission Handling
- iOS: requests alert, badge, sound
- Android 13+: requests `POST_NOTIFICATIONS`
- Android 12+: requests exact alarm permission via system settings

---

## Background Sync (BackgroundSyncService)

Uses `workmanager` package. Skipped on Windows.

### Schedule
- Periodic task named `weekly_release_date_update`
- Frequency: 7 days
- Requires network connectivity
- Exponential backoff starting at 15 minutes

### Background Task (callbackDispatcher)

Top-level function. Runs in a separate isolate:

1. Initializes Hive, registers adapters, opens boxes
2. Initializes NotificationService
3. **Refresh release dates:** For each TMDb movie, fetches latest details. Updates title, release date, poster, description, originalReleaseYear. Reschedules notifications if release date changed.
4. **Refresh streaming availability:** For each TMDb movie, fetches latest providers. Sends streaming notification if a new provider matches user's subscribed services (and not previously notified).
5. **Check cinema departure:** For movies 80-90 days past release with `wantToWatch` status, sends "left cinema" notification (if not previously notified).

---

## Android Home Screen Widget

### Architecture
- **MethodChannel:** `com.example.bestwatchlist/widget`
- **SharedPreferences key:** `HomeWidgetPreferences`
- Data flow: Flutter -> MethodChannel (`saveAndUpdateWidget`) -> SharedPreferences -> Widget refresh

### Data Format in SharedPreferences
- `movie_count`: Int
- `last_update`: Long (timestamp)
- `movie_title_{i}`: String
- `movie_date_{i}`: Long (milliseconds since epoch)

### Widget Components

**CinemaWidgetProvider** (AppWidgetProvider):
- `onUpdate`: calls `updateAppWidget()` for each widget, ensures midnight alarm is scheduled
- `onEnabled`: schedules midnight alarm
- `onDisabled`: cancels midnight alarm

**updateAppWidget()** (top-level function):
- Creates RemoteViews with `cinema_widget_simple` layout
- Sets click handlers on header elements to open app
- Sets up RemoteViewsService with unique data URI (prevents caching)
- Calls `notifyAppWidgetViewDataChanged` to refresh list
- Fallback: shows "Error: Tap to open" on failure

**CinemaWidgetService** (RemoteViewsService):
- Factory loads movies from SharedPreferences
- Formats dates relative to today: "Released", "Today", "Tomorrow", "In X days", or "dd.mm.yyyy"
- Released/Today dates shown in green (#4CAF50), others in grey (#BBBBBB)
- Shows "No cinema movies yet" with subtitle if empty

**MidnightUpdateReceiver** (BroadcastReceiver):
- Scheduled via AlarmManager at midnight + 5 seconds
- Uses exact alarm if permission granted, falls back to inexact
- Reschedules itself after each trigger
- Updates all widget instances

**BootReceiver** (BroadcastReceiver):
- Listens for `BOOT_COMPLETED`
- Reschedules midnight alarm and triggers immediate widget update

### Widget Layout (cinema_widget_simple.xml)
- Dark background (#1A1A1A, 16dp rounded corners)
- Header: logo (28dp) + "Be" (12sp, light) + "St" (12sp, bold) + "WatchList" (18sp, bold) - all gold (#D4AF37)
- Scrollable ListView below header
- Items: horizontal layout with title (14sp, white) + date (12sp, grey), #2A2A2A background, 8dp rounded corners

### Widget Metadata (cinema_widget_info.xml)
- Min size: 250dp x 180dp
- Resizable: horizontal + vertical
- Update period: 0 (manual updates only)
- Category: home_screen

---

## Cineman Integration (showtime_dialog.dart)

Opens Cineman.ch (Swiss cinema listings) for a movie.

### URL Pattern
`https://www.cineman.ch/en/movie/{year}/{TitleSlug}/cinema.html`

### Title Slug Generation
1. Remove non-word characters except spaces and hyphens
2. Split by spaces
3. PascalCase each word (first letter uppercase, rest lowercase)
4. Join without separator
- Example: "The Batman" -> "TheBatman"

### Year Resolution
1. Uses `originalReleaseYear` if available (earliest global premiere year)
2. Falls back to `releaseDate.year`
3. Tries years in order: calculated, year-1, year+1
4. Validates via HTTP HEAD request (200 = exists)
5. Falls back to original URL if none return 200

---

## Import/Export (ImportExportService)

### Export
- Version: `1.0.0`
- Format: JSON with `version`, `exportDate`, `appName`, `exportOptions`, `movies[]`, optional `settings`
- Filter by: watchlist only, library only, or both
- File name pattern: `bestwatchlist_{full|watchlist|library}_{yyyy-MM-dd}.json`
- Uses `file_picker` saveFile dialog
- Movies serialized via `Movie.toMap()`

### Import
- Picks `.json` files via `file_picker`
- Validates: must have `version` and `movies` array
- Skips duplicates (checks by movie ID)
- Recreates Movie objects from map data
- Schedules notifications for imported movies

---

## Reusable Widgets

### AppLogoHeader
- SVG logo (32x32) + RichText: "Be" (14sp, light, gold) + "St" (14sp, bold, gold) + "WatchList" (20sp, bold, gold)

### MovieCard
- Card with ListTile: poster (50x75, rounded 4dp), bold title, subtitle (date + optional description)
- Date format: "Releases dd.mm.yyyy (in X days)" or "Released dd.mm.yyyy" or "Release Date: TBD"
- Configurable: trailing widget, onTap, showDescription flag

### MovieInfoButton
- Opens TMDb URL (preferred) or IMDb URL in external browser
- Hidden if no URLs available

### ActionPopupMenu
- PopupMenuButton with configurable items, icon defaults to `more_vert` at 20dp

### ActionMenuItem
- PopupMenuItem with icon (20dp) + label in a Row
- Factory constructor `fromData(MenuItemData)` for use with predefined menu items

### EmptyStateWidget
- Centered column: icon (64dp, grey) + title (18sp) + subtitle (14sp)

### Predefined Menu Items (AppMenuItems)
- markWatched, markWatchedOutline, rewatch, rewatchCapitalized, delete, remove, saveForStreaming, showtimes

---

## Android Configuration

### AndroidManifest.xml Permissions
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### Registered Components
- `.MainActivity` - main Flutter activity
- `.CinemaWidgetProvider` - widget receiver
- `es.antonborri.home_widget.HomeWidgetBackgroundReceiver` - home_widget plugin receiver
- `.CinemaWidgetService` - widget list service (BIND_REMOTEVIEWS permission)
- `.MidnightUpdateReceiver` - daily widget refresh
- `.BootReceiver` - reschedule on boot
- `ScheduledNotificationReceiver` - flutter_local_notifications
- `ScheduledNotificationBootReceiver` - reschedule notifications on boot/update

### build.gradle.kts
- `namespace = "com.example.bestwatchlist"`
- Core library desugaring enabled (`com.android.tools:desugar_jdk_libs:2.0.4`)
- Signing config loaded from `key.properties` if exists, falls back to debug
- Java/Kotlin target: 1.8

---

## Logo / Assets

### assets/logo.svg (512x512)
Monitor/screen with clapperboard inside, play button, monitor stand. Gold (#D4AF37) on dark (#1A1A1A) background.

### android/res/drawable/widget_logo.xml
Same design as SVG but as Android vector drawable, transparent background.

---

## Key Behavioral Details

1. **TBD Date Sentinel:** `DateTime(9999, 12, 31)` - movies with unknown release dates. Excluded from notifications and 2-week filter. Sorted to end of lists.

2. **Region-specific behavior:**
   - Release dates: German (DE) theatrical releases
   - Streaming providers: Switzerland (CH) flatrate only
   - Upcoming movies: DE region with theatrical release types

3. **Settings migration:** On startup, if existing settings lack `darkMode` field, the settings box is cleared and recreated with defaults.

4. **Widget updates triggered by:**
   - Movie added/removed/status changed (via MovieController -> HomeWidgetService)
   - Midnight alarm (MidnightUpdateReceiver)
   - Device boot (BootReceiver)
   - Widget placed on home screen (onUpdate)

5. **Notification rescheduling:** All notifications are rescheduled on app start (handles device reboot, force-stop, data clear). SettingsController calls `_initializeNotificationsAndReschedule()` in constructor.

6. **Title language sync:** TMDbRepository instance is shared between MovieController and SettingsController. When language changes, `setTitleLanguage()` is called on the shared instance, then all movies are refreshed from TMDb.

---

## Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Generate Hive adapters (after modifying models)
dart run build_runner build --delete-conflicting-outputs

# Run on connected device
flutter run

# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle
```
