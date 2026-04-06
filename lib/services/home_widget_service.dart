import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../models/movie.dart';

/// Service for managing the Android home screen widget
class HomeWidgetService {
  static const _channel = MethodChannel('io.github.bestravenclaw.bestwatchlist/widget');

  /// Update the home screen widget with the latest cinema movies
  static Future<void> updateWidget(List<Movie> cinemaMovies) async {
    try {
      // Filter to only wantToWatch movies and sort by release date
      final watchlistMovies = cinemaMovies
          .where((movie) => movie.status == WatchStatus.wantToWatch)
          .toList()
        ..sort((a, b) => a.releaseDate.compareTo(b.releaseDate));

      // Prepare data for native side
      final titles = watchlistMovies.map((m) => m.title).toList();
      final dates = watchlistMovies
          .map((m) => m.releaseDate.millisecondsSinceEpoch)
          .toList();

      // Single method channel call that saves data AND updates widget
      // This bypasses the buggy home_widget plugin entirely
      final widgetCount = await _channel.invokeMethod<int>('saveAndUpdateWidget', {
        'movie_count': watchlistMovies.length,
        'titles': titles,
        'dates': dates,
      });

      developer.log(
        'Widget update completed: $widgetCount widget(s)',
        name: 'HomeWidget',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error updating home widget',
        name: 'HomeWidget',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Initialize the widget when the app starts
  static Future<void> initialize() async {
    try {
      // Android doesn't need app group ID like iOS
      developer.log('Home widget initialized', name: 'HomeWidget');
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing home widget',
        name: 'HomeWidget',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Register a callback for widget interactions
  /// Note: We bypass the home_widget plugin now, so this is a no-op
  static Future<void> registerInteractivity() async {
    developer.log('Widget interactivity skipped (using direct method channel)', name: 'HomeWidget');
  }
}
