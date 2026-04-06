import 'package:hive/hive.dart';
import '../models/user_settings.dart';

/// Repository for managing user settings persistence with Hive
class SettingsRepository {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'user_settings';
  Box<UserSettings>? _box;

  /// Get the Hive box for settings (lazy initialization)
  Future<Box<UserSettings>> get _settingsBox async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<UserSettings>(_boxName);
    }
    return _box!;
  }

  /// Get user settings (creates default if not exists)
  Future<UserSettings> getSettings() async {
    final box = await _settingsBox;
    UserSettings? settings = box.get(_settingsKey);

    if (settings == null) {
      settings = UserSettings.getDefault();
      await box.put(_settingsKey, settings);
    }

    return settings;
  }

  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    final box = await _settingsBox;
    await box.put(_settingsKey, settings);
  }

  /// Update a single field using a callback function (DRY helper method)
  Future<void> updateField(Function(UserSettings) update) async {
    final settings = await getSettings();
    update(settings);
    settings.markAsModified();
    await saveSettings(settings);
  }

  /// Get the listenable box for reactive UI updates
  Future<Box<UserSettings>> getListenableBox() async {
    return await _settingsBox;
  }
}
