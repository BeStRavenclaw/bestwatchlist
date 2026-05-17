import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../repositories/tmdb_repository.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../widgets/action_buttons.dart';
import '../l10n/app_localizations.dart';

/// Screen for managing user's streaming service subscriptions
class StreamingServicesScreen extends StatefulWidget {
  const StreamingServicesScreen({super.key});

  @override
  State<StreamingServicesScreen> createState() =>
      _StreamingServicesScreenState();
}

class _StreamingServicesScreenState extends State<StreamingServicesScreen> {
  final TMDbRepository _tmdbRepository = TMDbRepository();
  final TextEditingController _searchController = TextEditingController();
  List<String> availableStreamingServices = [];
  List<String> filteredStreamingServices = [];
  bool _isLoadingProviders = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableProviders();
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableProviders() async {
    final providers =
        await _tmdbRepository.getAllAvailableProvidersForSwitzerland();
    setState(() {
      availableStreamingServices = providers;
      filteredStreamingServices = providers;
      _isLoadingProviders = false;
    });
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredStreamingServices = availableStreamingServices;
      } else {
        filteredStreamingServices = availableStreamingServices
            .where((service) => service.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.streamingServicesTitle),
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.black,
      ),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.streamingServicesDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchServicesHint,
                    prefixIcon: const Icon(AppIcons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(AppIcons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildStreamingServicesList(settingsController, l10n),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStreamingServicesList(
      SettingsController settingsController, AppLocalizations l10n) {
    final selectedServices = settingsController.streamingServices;

    if (_isLoadingProviders) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.gold,
        ),
      );
    }

    if (availableStreamingServices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.error,
                size: AppIcons.emptyStateSize,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noStreamingProviders,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.checkTmdbConfig,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredStreamingServices.isEmpty) {
      return EmptyStateWidget(
        icon: AppIcons.searchOff,
        title: l10n.noServicesFound,
        subtitle: l10n.tryDifferentSearch,
      );
    }

    return ListView.builder(
      itemCount: filteredStreamingServices.length,
      itemBuilder: (context, index) {
        final service = filteredStreamingServices[index];
        final isSelected = selectedServices.contains(service);

        return CheckboxListTile(
          title: Text(service),
          subtitle: isSelected ? Text(l10n.subscribed) : null,
          value: isSelected,
          activeColor: AppColors.gold,
          onChanged: (bool? value) {
            final newServices = List<String>.from(selectedServices);
            if (value == true) {
              newServices.add(service);
            } else {
              newServices.remove(service);
            }
            settingsController.updateStreamingServices(newServices);
          },
        );
      },
    );
  }
}
