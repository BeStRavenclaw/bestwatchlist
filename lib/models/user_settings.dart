import 'package:hive/hive.dart';

part 'user_settings.g.dart';

/// User settings model with Hive persistence
@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(1)
  List<String> streamingServices;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  bool sundayBeforeNotifications;

  @HiveField(4)
  bool releaseDayNotifications;

  @HiveField(5)
  bool saturdayAfterNotifications;

  @HiveField(6)
  bool leftCinemaNotifications;

  @HiveField(7)
  bool streamingAvailableNotifications;

  @HiveField(8)
  bool darkMode;

  @HiveField(9)
  DateTime? lastModified;

  @HiveField(10)
  bool needsSync;

  @HiveField(11)
  String titleLanguage;

  UserSettings({
    this.streamingServices = const [],
    this.notificationsEnabled = true,
    this.sundayBeforeNotifications = true,
    this.releaseDayNotifications = true,
    this.saturdayAfterNotifications = true,
    this.leftCinemaNotifications = true,
    this.streamingAvailableNotifications = true,
    this.darkMode = true,
    DateTime? lastModified,
    this.needsSync = true,
    this.titleLanguage = 'en',
  }) : lastModified = lastModified ?? DateTime.now();

  /// Create default settings
  static UserSettings getDefault() {
    return UserSettings(
      streamingServices: [],
      notificationsEnabled: true,
      sundayBeforeNotifications: true,
      releaseDayNotifications: true,
      saturdayAfterNotifications: true,
      leftCinemaNotifications: true,
      streamingAvailableNotifications: true,
      darkMode: true,
      titleLanguage: 'en',
    );
  }

  /// Convert settings to a Map for syncing purposes
  Map<String, dynamic> toMap() {
    return {
      'streamingServices': streamingServices,
      'notificationsEnabled': notificationsEnabled,
      'sundayBeforeNotifications': sundayBeforeNotifications,
      'releaseDayNotifications': releaseDayNotifications,
      'saturdayAfterNotifications': saturdayAfterNotifications,
      'leftCinemaNotifications': leftCinemaNotifications,
      'streamingAvailableNotifications': streamingAvailableNotifications,
      'darkMode': darkMode,
      'titleLanguage': titleLanguage,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  /// Mark settings as modified for sync purposes
  void markAsModified() {
    lastModified = DateTime.now();
    needsSync = true;
  }

  /// Create a copy of settings with updated fields
  UserSettings copyWith({
    List<String>? streamingServices,
    bool? notificationsEnabled,
    bool? sundayBeforeNotifications,
    bool? releaseDayNotifications,
    bool? saturdayAfterNotifications,
    bool? leftCinemaNotifications,
    bool? streamingAvailableNotifications,
    bool? darkMode,
    DateTime? lastModified,
    bool? needsSync,
    String? titleLanguage,
  }) {
    return UserSettings(
      streamingServices: streamingServices ?? this.streamingServices,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      sundayBeforeNotifications:
          sundayBeforeNotifications ?? this.sundayBeforeNotifications,
      releaseDayNotifications:
          releaseDayNotifications ?? this.releaseDayNotifications,
      saturdayAfterNotifications:
          saturdayAfterNotifications ?? this.saturdayAfterNotifications,
      leftCinemaNotifications:
          leftCinemaNotifications ?? this.leftCinemaNotifications,
      streamingAvailableNotifications:
          streamingAvailableNotifications ?? this.streamingAvailableNotifications,
      darkMode: darkMode ?? this.darkMode,
      lastModified: lastModified ?? this.lastModified,
      needsSync: needsSync ?? this.needsSync,
      titleLanguage: titleLanguage ?? this.titleLanguage,
    );
  }
}
