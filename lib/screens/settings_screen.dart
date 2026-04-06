import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/movie_controller.dart';
import '../services/import_export_service.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import 'streaming_services_screen.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        return ListView(
          children: [
            _buildSectionHeader('Data Management'),
            _buildDataManagementSection(context),
            const Divider(),
            _buildSectionHeader('Appearance'),
            _buildDarkModeToggle(settingsController),
            _buildTitleLanguageSelector(settingsController),
            const Divider(),
            _buildSectionHeader('Streaming Services'),
            _buildStreamingServicesButton(context, settingsController),
            const Divider(),
            _buildSectionHeader('Notifications'),
            _buildNotificationSettings(settingsController),
            const Divider(),
            _buildSectionHeader('About'),
            _buildAboutTile(),
          ],
        );
      },
    );
  }

  /// Build section header with gold styling
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
      ),
    );
  }

  /// Build data management section
  Widget _buildDataManagementSection(BuildContext context) {
    return Column(
      children: [
        const ListTile(
          leading: Icon(AppIcons.update),
          title: Text('Automatic Updates'),
          subtitle: Text('Release dates update automatically every week'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _refreshDataFromTMDb(context),
            icon: const Icon(AppIcons.refresh),
            label: const Text('Refresh Data from TMDb'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Updates all movies with latest data from TMDb (release dates, streaming availability, etc.).\nThis runs automatically every week in the background.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _showExportDialog(context),
            icon: const Icon(AppIcons.export),
            label: const Text('Export Data'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _importData(context),
            icon: const Icon(AppIcons.import),
            label: const Text('Import Data'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Export or import your watchlist and library data as JSON files.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            onPressed: () => _clearDatabase(context),
            icon: const Icon(AppIcons.deletePermanent, color: AppColors.destructive),
            label: const Text('Clear All Movies',
                style: TextStyle(color: AppColors.destructive)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.destructive),
            ),
          ),
        ),
      ],
    );
  }

  /// Build dark mode toggle
  Widget _buildDarkModeToggle(SettingsController settingsController) {
    return SwitchListTile(
      secondary: Icon(
        settingsController.darkMode ? AppIcons.darkMode : AppIcons.lightMode,
      ),
      title: const Text('Dark Mode'),
      subtitle: Text(settingsController.darkMode
          ? 'Dark theme enabled'
          : 'Light theme enabled'),
      value: settingsController.darkMode,
      onChanged: (_) => settingsController.toggleDarkMode(),
    );
  }

  /// Build title language selector
  Widget _buildTitleLanguageSelector(SettingsController settingsController) {
    const languages = {
      'en': 'English',
      'de': 'Deutsch',
      'fr': 'Français',
      'es': 'Español',
      'it': 'Italiano',
    };

    final currentLanguage = settingsController.titleLanguage;
    final currentLanguageName = languages[currentLanguage] ?? 'English';

    return ListTile(
      leading: const Icon(AppIcons.translate),
      title: const Text('Movie Title Language'),
      subtitle: Text(currentLanguageName),
      trailing: const Icon(AppIcons.chevronRight),
      onTap: () => _showLanguageDialog(settingsController, languages),
    );
  }

  /// Show language selection dialog
  Future<void> _showLanguageDialog(
    SettingsController settingsController,
    Map<String, String> languages,
  ) async {
    final currentLanguage = settingsController.titleLanguage;

    final selectedLanguage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Title Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: currentLanguage,
              activeColor: AppColors.gold,
              onChanged: (value) => Navigator.of(context).pop(value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedLanguage != null && selectedLanguage != currentLanguage) {
      await settingsController.updateTitleLanguage(selectedLanguage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Updating movie titles to ${languages[selectedLanguage]}...',
            ),
            backgroundColor: AppColors.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Auto-refresh movie titles with new language
        final movieController = context.read<MovieController>();
        final updatedCount = await movieController.refreshAllDataFromTMDb();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Updated $updatedCount movie(s) to ${languages[selectedLanguage]}',
              ),
              backgroundColor: AppColors.gold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Build streaming services button
  Widget _buildStreamingServicesButton(
      BuildContext context, SettingsController settingsController) {
    final selectedCount = settingsController.streamingServices.length;

    return Column(
      children: [
        ListTile(
          leading: const Icon(AppIcons.subscriptions),
          title: const Text('Manage Streaming Services'),
          subtitle: Text(
            selectedCount > 0
                ? '$selectedCount service${selectedCount == 1 ? '' : 's'} selected'
                : 'No services selected',
          ),
          trailing: const Icon(AppIcons.chevronRight),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StreamingServicesScreen(),
              ),
            );
          },
        ),
        if (selectedCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: settingsController.streamingServices.map((service) {
                return Chip(
                  label: Text(
                    service,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppColors.goldWithOpacity(0.2),
                  deleteIconColor: AppColors.black,
                  onDeleted: () {
                    final newServices =
                        List<String>.from(settingsController.streamingServices);
                    newServices.remove(service);
                    settingsController.updateStreamingServices(newServices);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// Build notification settings section
  Widget _buildNotificationSettings(SettingsController settingsController) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(AppIcons.notifications),
          title: const Text('Enable Notifications'),
          subtitle: const Text('Master notification toggle'),
          value: settingsController.notificationsEnabled,
          onChanged: (_) => settingsController.toggleNotifications(),
        ),
        if (settingsController.notificationsEnabled) ...[
          _buildNotificationToggle(
            'Sunday Before Release',
            'Get reminded the Sunday before a movie releases',
            settingsController.settings?.sundayBeforeNotifications ?? true,
            () => settingsController.toggleSundayBeforeNotification(),
          ),
          _buildNotificationToggle(
            'Release Day',
            'Get notified when a movie releases',
            settingsController.settings?.releaseDayNotifications ?? true,
            () => settingsController.toggleReleaseDayNotification(),
          ),
          _buildNotificationToggle(
            'Saturday After Release',
            'Get reminded the Saturday after release',
            settingsController.settings?.saturdayAfterNotifications ?? true,
            () => settingsController.toggleSaturdayAfterNotification(),
          ),
          _buildNotificationToggle(
            'Left Cinema',
            'Get notified when a movie leaves cinema',
            settingsController.settings?.leftCinemaNotifications ?? true,
            () => settingsController.toggleLeftCinemaNotification(),
          ),
          _buildNotificationToggle(
            'Streaming Available',
            'Get notified when available on your streaming services',
            settingsController.settings?.streamingAvailableNotifications ??
                true,
            () => settingsController.toggleStreamingAvailableNotification(),
          ),
        ],
      ],
    );
  }

  /// Build individual notification toggle
  Widget _buildNotificationToggle(
      String title, String subtitle, bool value, VoidCallback onToggle) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.only(left: 56, right: 16),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: (_) => onToggle(),
    );
  }

  /// Build about tile
  Widget _buildAboutTile() {
    return const ListTile(
      leading: Icon(AppIcons.info),
      title: Text('Version'),
      subtitle: Text('BeStWatchList v1.0.0'),
    );
  }

  /// Refresh all data from TMDb for all movies
  Future<void> _refreshDataFromTMDb(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh Data from TMDb?'),
        content: const Text(
          'This will update all movies with the latest data from TMDb '
          '(release dates, streaming availability, posters, etc.). This may take a moment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final movieController = context.read<MovieController>();
      await movieController.refreshAllDataFromTMDb();
    }
  }

  /// Show export dialog with options
  Future<void> _showExportDialog(BuildContext context) async {
    bool includeWatchlist = true;
    bool includeLibrary = true;
    bool includeSettings = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select what to export:'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Watchlist'),
                subtitle: const Text('Movies you want to watch (Cinema)'),
                value: includeWatchlist,
                onChanged: (value) {
                  setState(() => includeWatchlist = value ?? true);
                },
                activeColor: AppColors.gold,
              ),
              CheckboxListTile(
                title: const Text('Library'),
                subtitle: const Text('Watched, rewatch, streaming'),
                value: includeLibrary,
                onChanged: (value) {
                  setState(() => includeLibrary = value ?? true);
                },
                activeColor: AppColors.gold,
              ),
              CheckboxListTile(
                title: const Text('Settings'),
                subtitle: const Text('Notifications, streaming services'),
                value: includeSettings,
                onChanged: (value) {
                  setState(() => includeSettings = value ?? true);
                },
                activeColor: AppColors.gold,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: (includeWatchlist || includeLibrary || includeSettings)
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final movieController = context.read<MovieController>();
      final options = ExportOptions(
        includeWatchlist: includeWatchlist,
        includeLibrary: includeLibrary,
        includeSettings: includeSettings,
      );

      final result = await movieController.exportData(options);

      if (context.mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data exported successfully'),
              backgroundColor: AppColors.gold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (result.error == 'cancelled') {
          // User cancelled, no need to show message
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${result.error}'),
              backgroundColor: AppColors.destructive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Import data from a file
  Future<void> _importData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'Select a BeStWatchList JSON file to import. '
          'Duplicate movies will be skipped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Select File'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final movieController = context.read<MovieController>();
      final result = await movieController.importData();

      if (context.mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Imported ${result.moviesImported} movie(s), '
                '${result.moviesSkipped} skipped',
              ),
              backgroundColor: AppColors.gold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Import failed'),
              backgroundColor: AppColors.destructive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Clear all movies from database
  Future<void> _clearDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Movies?'),
        content: const Text(
          'This will delete all your movies from local storage. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final movieController = context.read<MovieController>();
      await movieController.clearAllMovies();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All movies cleared'),
            backgroundColor: AppColors.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
