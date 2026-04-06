import 'package:flutter/material.dart';

/// Centralized icon definitions for the app
/// Provides consistent icons and sizes throughout the application
abstract class AppIcons {
  // ============ Icon Sizes ============
  /// Standard size for action icons in menus and buttons
  static const double actionSize = 20.0;

  /// Standard size for navigation and header icons
  static const double navSize = 24.0;

  /// Size for empty state illustrations
  static const double emptyStateSize = 64.0;

  // ============ Navigation Icons ============
  static const IconData browse = Icons.explore;
  static const IconData cinema = Icons.local_movies;
  static const IconData library = Icons.video_library;
  static const IconData settings = Icons.settings;

  // ============ Action Icons ============
  static const IconData moreActions = Icons.more_vert;
  static const IconData info = Icons.info_outline;
  static const IconData markWatched = Icons.check;
  static const IconData markWatchedOutline = Icons.check_circle_outline;
  static const IconData rewatch = Icons.replay;
  static const IconData delete = Icons.delete_outline;
  static const IconData deletePermanent = Icons.delete_forever;
  static const IconData saveForStreaming = Icons.playlist_add;
  static const IconData showtimes = Icons.schedule;

  // ============ Search & Filter Icons ============
  static const IconData search = Icons.search;
  static const IconData clear = Icons.clear;
  static const IconData searchOff = Icons.search_off;

  // ============ Bookmark Icons ============
  static const IconData bookmark = Icons.bookmark;
  static const IconData bookmarkOutline = Icons.bookmark_border;

  // ============ Content Icons ============
  static const IconData movie = Icons.movie;
  static const IconData movieOutline = Icons.movie_outlined;
  static const IconData upcoming = Icons.upcoming;
  static const IconData videoLibrary = Icons.video_library_outlined;

  // ============ Settings Icons ============
  static const IconData update = Icons.update;
  static const IconData refresh = Icons.refresh;
  static const IconData export = Icons.download;
  static const IconData import = Icons.upload_file;
  static const IconData darkMode = Icons.dark_mode;
  static const IconData lightMode = Icons.light_mode;
  static const IconData translate = Icons.translate;
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData subscriptions = Icons.subscriptions;
  static const IconData notifications = Icons.notifications;

  // ============ Status Icons ============
  static const IconData error = Icons.error_outline;
}
