import '../constants/app_icons.dart';
import '../widgets/action_buttons.dart';

/// Predefined menu items for movie actions
/// Use these with ActionMenuItem.fromData() or directly in PopupMenuButton
abstract class AppMenuItems {
  // ============ Movie Action Menu Items ============

  /// Mark movie as watched
  static const markWatched = MenuItemData(
    value: 'watched',
    icon: AppIcons.markWatched,
    label: 'Mark as watched',
  );

  /// Mark movie as watched (outline variant for different contexts)
  static const markWatchedOutline = MenuItemData(
    value: 'watched',
    icon: AppIcons.markWatchedOutline,
    label: 'Mark as Watched',
  );

  /// Want to rewatch movie
  static const rewatch = MenuItemData(
    value: 'rewatch',
    icon: AppIcons.rewatch,
    label: 'Want to rewatch',
  );

  /// Want to rewatch (capitalized variant)
  static const rewatchCapitalized = MenuItemData(
    value: 'rewatch',
    icon: AppIcons.rewatch,
    label: 'Want to Rewatch',
  );

  /// Delete movie from list
  static const delete = MenuItemData(
    value: 'delete',
    icon: AppIcons.delete,
    label: 'Delete',
  );

  /// Remove from library
  static const remove = MenuItemData(
    value: 'remove',
    icon: AppIcons.delete,
    label: 'Remove from Library',
  );

  /// Save for streaming
  static const saveForStreaming = MenuItemData(
    value: 'save_for_streaming',
    icon: AppIcons.saveForStreaming,
    label: 'Add to Streaming WatchList',
  );

  /// View showtimes on Cineman
  static const showtimes = MenuItemData(
    value: 'showtimes',
    icon: AppIcons.showtimes,
    label: 'View on Cineman',
  );
}
