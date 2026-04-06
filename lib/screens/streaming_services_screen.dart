import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../repositories/tmdb_repository.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../widgets/action_buttons.dart';

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

  /// Load available streaming providers from TMDb
  Future<void> _loadAvailableProviders() async {
    final providers =
        await _tmdbRepository.getAllAvailableProvidersForSwitzerland();
    setState(() {
      availableStreamingServices = providers;
      filteredStreamingServices = providers;
      _isLoadingProviders = false;
    });
  }

  /// Filter services based on search query
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streaming Services'),
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
                  'Select the streaming services you subscribe to. We\'ll notify you when movies become available on your services.',
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
                    hintText: 'Search streaming services...',
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
                child: _buildStreamingServicesList(settingsController),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build the list of streaming services
  Widget _buildStreamingServicesList(SettingsController settingsController) {
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
              const Text(
                'No streaming providers available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your TMDB API configuration.',
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
        title: 'No services found',
        subtitle: 'Try a different search term',
      );
    }

    return ListView.builder(
      itemCount: filteredStreamingServices.length,
      itemBuilder: (context, index) {
        final service = filteredStreamingServices[index];
        final isSelected = selectedServices.contains(service);

        return CheckboxListTile(
          title: Text(service),
          subtitle: isSelected ? const Text('Subscribed') : null,
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
