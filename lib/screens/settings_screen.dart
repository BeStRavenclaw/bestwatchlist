import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/movie_controller.dart';
import '../services/import_export_service.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'streaming_services_screen.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        return ListView(
          children: [
            _buildSectionHeader(l10n.sectionDataManagement),
            _buildDataManagementSection(context, l10n),
            const Divider(),
            _buildSectionHeader(l10n.sectionAppearance),
            _buildDisplayLanguageSelector(settingsController, l10n),
            _buildDarkModeToggle(settingsController, l10n),
            _buildTitleLanguageSelector(settingsController, l10n),
            _buildReleaseCountrySelector(settingsController, l10n),
            const Divider(),
            _buildSectionHeader(l10n.sectionStreamingServices),
            _buildStreamingServicesButton(context, settingsController, l10n),
            const Divider(),
            _buildSectionHeader(l10n.sectionNotifications),
            _buildNotificationSettings(settingsController, l10n),
            const Divider(),
            _buildSectionHeader(l10n.sectionAbout),
            _buildAboutTile(l10n),
          ],
        );
      },
    );
  }

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

  Widget _buildDataManagementSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(AppIcons.update),
          title: Text(l10n.automaticUpdates),
          subtitle: Text(l10n.automaticUpdatesSubtitle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _refreshDataFromTMDb(context, l10n),
            icon: const Icon(AppIcons.refresh),
            label: Text(l10n.refreshFromTmdb),
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
            l10n.refreshFromTmdbDescription,
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
            onPressed: () => _showExportDialog(context, l10n),
            icon: const Icon(AppIcons.export),
            label: Text(l10n.exportData),
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
            onPressed: () => _importData(context, l10n),
            icon: const Icon(AppIcons.import),
            label: Text(l10n.importData),
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
            l10n.exportImportDescription,
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
            onPressed: () => _clearDatabase(context, l10n),
            icon: const Icon(AppIcons.deletePermanent, color: AppColors.destructive),
            label: Text(l10n.clearAllMovies,
                style: const TextStyle(color: AppColors.destructive)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.destructive),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayLanguageSelector(
      SettingsController settingsController, AppLocalizations l10n) {
    const languages = {
      '': 'Auto',
      'en': 'English',
      'de': 'Deutsch',
      'fr': 'Français',
      'it': 'Italiano',
      'es': 'Español',
    };

    final current = settingsController.appLanguage;
    final currentName = languages[current] ?? l10n.displayLanguageAuto;

    return ListTile(
      leading: const Icon(AppIcons.language),
      title: Text(l10n.displayLanguage),
      subtitle: Text(current.isEmpty ? l10n.displayLanguageAuto : currentName),
      trailing: const Icon(AppIcons.chevronRight),
      onTap: () => _showDisplayLanguageDialog(settingsController, languages, l10n),
    );
  }

  Widget _buildDarkModeToggle(
      SettingsController settingsController, AppLocalizations l10n) {
    return SwitchListTile(
      secondary: Icon(
        settingsController.darkMode ? AppIcons.darkMode : AppIcons.lightMode,
      ),
      title: Text(l10n.darkMode),
      subtitle: Text(settingsController.darkMode
          ? l10n.darkThemeEnabled
          : l10n.lightThemeEnabled),
      value: settingsController.darkMode,
      onChanged: (_) => settingsController.toggleDarkMode(),
    );
  }

  Widget _buildTitleLanguageSelector(
      SettingsController settingsController, AppLocalizations l10n) {
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
      title: Text(l10n.movieTitleLanguage),
      subtitle: Text(currentLanguageName),
      trailing: const Icon(AppIcons.chevronRight),
      onTap: () => _showLanguageDialog(settingsController, languages, l10n),
    );
  }

  Widget _buildReleaseCountrySelector(
      SettingsController settingsController, AppLocalizations l10n) {
    const countries = {
      'DE': 'Germany',
      'CH': 'Switzerland',
      'AT': 'Austria',
      'US': 'United States',
      'GB': 'United Kingdom',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
    };

    final currentCountry = settingsController.releaseCountry;
    final currentCountryName = countries[currentCountry] ?? currentCountry;

    return ListTile(
      leading: const Icon(AppIcons.location),
      title: Text(l10n.releaseDateCountry),
      subtitle: Text(currentCountryName),
      trailing: const Icon(AppIcons.chevronRight),
      onTap: () => _showCountryDialog(settingsController, countries, l10n),
    );
  }

  Future<void> _showDisplayLanguageDialog(
    SettingsController settingsController,
    Map<String, String> languages,
    AppLocalizations l10n,
  ) async {
    final current = settingsController.appLanguage;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectDisplayLanguage),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.entries.map((entry) {
              final displayName = entry.key.isEmpty
                  ? l10n.displayLanguageAuto
                  : entry.value;
              return RadioListTile<String>(
                title: Text(displayName),
                value: entry.key,
                groupValue: current,
                activeColor: AppColors.gold,
                onChanged: (value) => Navigator.of(context).pop(value),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selected != null && selected != current) {
      await settingsController.updateAppLanguage(selected);
    }
  }

  Future<void> _showCountryDialog(
    SettingsController settingsController,
    Map<String, String> countries,
    AppLocalizations l10n,
  ) async {
    final currentCountry = settingsController.releaseCountry;

    final selectedCountry = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectReleaseDateCountry),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: countries.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: currentCountry,
                activeColor: AppColors.gold,
                onChanged: (value) => Navigator.of(context).pop(value),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selectedCountry != null && selectedCountry != currentCountry) {
      await settingsController.updateReleaseCountry(selectedCountry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.updatingMovieTitles(countries[selectedCountry]!),
            ),
            backgroundColor: AppColors.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );

        final movieController = context.read<MovieController>();
        final updatedCount = await movieController.refreshAllDataFromTMDb();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.updatedMovieTitles(updatedCount, countries[selectedCountry]!),
              ),
              backgroundColor: AppColors.gold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _showLanguageDialog(
    SettingsController settingsController,
    Map<String, String> languages,
    AppLocalizations l10n,
  ) async {
    final currentLanguage = settingsController.titleLanguage;

    final selectedLanguage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTitleLanguage),
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
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selectedLanguage != null && selectedLanguage != currentLanguage) {
      await settingsController.updateTitleLanguage(selectedLanguage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updatingMovieTitles(languages[selectedLanguage]!)),
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
                l10n.updatedMovieTitles(updatedCount, languages[selectedLanguage]!),
              ),
              backgroundColor: AppColors.gold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildStreamingServicesButton(
      BuildContext context,
      SettingsController settingsController,
      AppLocalizations l10n) {
    final selectedCount = settingsController.streamingServices.length;

    return Column(
      children: [
        ListTile(
          leading: const Icon(AppIcons.subscriptions),
          title: Text(l10n.manageStreamingServices),
          subtitle: Text(l10n.servicesSelected(selectedCount)),
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

  Widget _buildNotificationSettings(
      SettingsController settingsController, AppLocalizations l10n) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(AppIcons.notifications),
          title: Text(l10n.enableNotifications),
          subtitle: Text(l10n.masterNotificationToggle),
          value: settingsController.notificationsEnabled,
          onChanged: (_) => settingsController.toggleNotifications(),
        ),
        if (settingsController.notificationsEnabled) ...[
          _buildNotificationToggle(
            l10n.sundayBeforeRelease,
            l10n.sundayBeforeReleaseSubtitle,
            settingsController.settings?.sundayBeforeNotifications ?? true,
            () => settingsController.toggleSundayBeforeNotification(),
          ),
          _buildNotificationToggle(
            l10n.releaseDayNotification,
            l10n.releaseDaySubtitle,
            settingsController.settings?.releaseDayNotifications ?? true,
            () => settingsController.toggleReleaseDayNotification(),
          ),
          _buildNotificationToggle(
            l10n.saturdayAfterRelease,
            l10n.saturdayAfterReleaseSubtitle,
            settingsController.settings?.saturdayAfterNotifications ?? true,
            () => settingsController.toggleSaturdayAfterNotification(),
          ),
          _buildNotificationToggle(
            l10n.leftCinema,
            l10n.leftCinemaSubtitle,
            settingsController.settings?.leftCinemaNotifications ?? true,
            () => settingsController.toggleLeftCinemaNotification(),
          ),
          _buildNotificationToggle(
            l10n.streamingAvailableNotification,
            l10n.streamingAvailableSubtitle,
            settingsController.settings?.streamingAvailableNotifications ?? true,
            () => settingsController.toggleStreamingAvailableNotification(),
          ),
        ],
      ],
    );
  }

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

  Widget _buildAboutTile(AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(AppIcons.info),
      title: Text(l10n.versionLabel),
      subtitle: Text('BeStWatchList v$_appVersion'),
    );
  }

  Future<void> _refreshDataFromTMDb(
      BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.refreshFromTmdbTitle),
        content: Text(l10n.refreshFromTmdbConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.refresh),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final movieController = context.read<MovieController>();
      await movieController.refreshAllDataFromTMDb();
    }
  }

  Future<void> _showExportDialog(
      BuildContext context, AppLocalizations l10n) async {
    bool includeWatchlist = true;
    bool includeLibrary = true;
    bool includeSettings = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.exportDataTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.selectWhatToExport),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text(l10n.exportWatchlist),
                subtitle: Text(l10n.exportWatchlistSubtitle),
                value: includeWatchlist,
                onChanged: (value) {
                  setState(() => includeWatchlist = value ?? true);
                },
                activeColor: AppColors.gold,
              ),
              CheckboxListTile(
                title: Text(l10n.exportLibrary),
                subtitle: Text(l10n.exportLibrarySubtitle),
                value: includeLibrary,
                onChanged: (value) {
                  setState(() => includeLibrary = value ?? true);
                },
                activeColor: AppColors.gold,
              ),
              CheckboxListTile(
                title: Text(l10n.exportSettingsLabel),
                subtitle: Text(l10n.exportSettingsSubtitle),
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
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: (includeWatchlist || includeLibrary || includeSettings)
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: Text(l10n.exportAction),
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
            SnackBar(
              content: Text(l10n.dataExportedSuccess),
              backgroundColor: AppColors.gold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (result.error == 'cancelled') {
          // User cancelled, no need to show message
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.exportFailed(result.error ?? '')),
              backgroundColor: AppColors.destructive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _importData(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importDataTitle),
        content: Text(l10n.importDataDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.selectFile),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final movieController = context.read<MovieController>();
      final settingsController = context.read<SettingsController>();
      final result = await movieController.importData(
        applySettings: settingsController.applyImportedSettings,
      );

      if (context.mounted) {
        if (result.success) {
          final message = result.settingsImported
              ? l10n.importedMoviesWithSettings(
                  result.moviesImported, result.moviesSkipped)
              : l10n.importedMovies(result.moviesImported, result.moviesSkipped);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.gold,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? l10n.importData),
              backgroundColor: AppColors.destructive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearDatabase(
      BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllMoviesTitle),
        content: Text(l10n.clearAllMoviesConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final movieController = context.read<MovieController>();
      await movieController.clearAllMovies();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.allMoviesCleared),
            backgroundColor: AppColors.gold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
