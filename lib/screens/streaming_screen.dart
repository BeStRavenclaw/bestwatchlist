import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';
import '../controllers/settings_controller.dart';
import '../views/widgets/movie_card.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../constants/menu_items.dart';
import '../widgets/action_buttons.dart';

/// Streaming library screen showing watched and want to rewatch movies
class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showWatchedMovies = false; // Toggle: true = Watched, false = Want to Stream
  final Set<String> _selectedServiceFilters = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildToggleButton(),
        Expanded(
          child: Consumer<MovieController>(
            builder: (context, movieController, _) {
              final userServices =
                  Provider.of<SettingsController>(context, listen: false)
                      .streamingServices;

              // Get movies based on toggle
              var streamingMovies = movieController.movies
                  .where((movie) => _showWatchedMovies
                      ? movie.status == WatchStatus.watched
                      : (movie.status == WatchStatus.saveForStreaming ||
                          movie.status == WatchStatus.wantToRewatch))
                  .toList();

              // Collect unique services from this tab's movies (for filter chips)
              final allServices = <String>{};
              for (final m in streamingMovies) {
                allServices.addAll(m.availableOnStreamingServices ?? []);
              }
              final sortedServices = allServices.toList()
                ..sort((a, b) {
                  final aSubscribed = userServices.contains(a);
                  final bSubscribed = userServices.contains(b);
                  if (aSubscribed != bSubscribed) return aSubscribed ? -1 : 1;
                  return a.compareTo(b);
                });

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                streamingMovies = streamingMovies.where((movie) {
                  return movie.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (movie.description
                              ?.toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ??
                          false);
                }).toList();
              }

              // Apply service filter
              if (_selectedServiceFilters.isNotEmpty) {
                streamingMovies = streamingMovies.where((movie) {
                  final services = movie.availableOnStreamingServices ?? [];
                  return services
                      .any((s) => _selectedServiceFilters.contains(s));
                }).toList();
              }

              // Sort: for streaming watchlist, group by service availability
              if (!_showWatchedMovies) {
                int serviceGroup(Movie m) {
                  final services = m.availableOnStreamingServices ?? [];
                  if (services.any((s) => userServices.contains(s))) return 0;
                  if (services.isNotEmpty) return 1;
                  return 2;
                }

                streamingMovies.sort((a, b) {
                  final groupCmp = serviceGroup(a).compareTo(serviceGroup(b));
                  if (groupCmp != 0) return groupCmp;
                  return a.title.compareTo(b.title);
                });
              } else {
                streamingMovies.sort((a, b) => a.title.compareTo(b.title));
              }

              return Column(
                children: [
                  if (sortedServices.isNotEmpty)
                    _buildServiceFilterRow(sortedServices, userServices),
                  Expanded(
                    child: streamingMovies.isEmpty
                        ? EmptyStateWidget(
                            icon: AppIcons.videoLibrary,
                            title: _searchQuery.isEmpty &&
                                    _selectedServiceFilters.isEmpty
                                ? (_showWatchedMovies
                                    ? 'No watched movies yet'
                                    : 'No movies to stream')
                                : 'No movies found',
                            subtitle: _searchQuery.isEmpty &&
                                    _selectedServiceFilters.isEmpty
                                ? (_showWatchedMovies
                                    ? 'Mark movies as watched from Cinema'
                                    : 'Mark movies as "Save for Streaming" or "Want to Rewatch"')
                                : 'Try a different search or filter',
                          )
                        : ListView.builder(
                            itemCount: streamingMovies.length,
                            itemBuilder: (context, index) {
                              final movie = streamingMovies[index];
                              return _buildStreamingMovieCard(
                                  context, movieController, movie);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build toggle button for switching between watched and want to stream
  Widget _buildToggleButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text('Watched'),
              selected: _showWatchedMovies,
              onSelected: (selected) {
                setState(() {
                  _showWatchedMovies = true;
                  _selectedServiceFilters.clear();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: const Text('Streaming WatchList'),
              selected: !_showWatchedMovies,
              onSelected: (selected) {
                setState(() {
                  _showWatchedMovies = false;
                  _selectedServiceFilters.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build the horizontal filter chips row for streaming services
  Widget _buildServiceFilterRow(
      List<String> services, List<String> userServices) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final service = services[index];
          final isSubscribed = userServices.contains(service);
          final isSelected = _selectedServiceFilters.contains(service);
          return FilterChip(
            label: Text(service),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedServiceFilters.add(service);
                } else {
                  _selectedServiceFilters.remove(service);
                }
              });
            },
            backgroundColor: isSubscribed
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            labelStyle: const TextStyle(fontSize: 12),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  /// Build the search bar widget
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search your library...',
          prefixIcon: const Icon(AppIcons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(AppIcons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// Build a movie card for streaming screen
  Widget _buildStreamingMovieCard(
      BuildContext context, MovieController movieController, Movie movie) {
    final userServices =
        Provider.of<SettingsController>(context, listen: false).streamingServices;
    final myServices = (movie.availableOnStreamingServices ?? [])
        .where((s) => userServices.contains(s))
        .toList();
    final otherServices = (movie.availableOnStreamingServices ?? [])
        .where((s) => !userServices.contains(s))
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: movie.posterUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  movie.posterUrl!,
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderPoster();
                  },
                ),
              )
            : _buildPlaceholderPoster(),
        title: Text(
          movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.status == WatchStatus.wantToRewatch)
              const Text(
                'Want to Rewatch',
                style: TextStyle(
                  color: AppColors.rewatch,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (movie.status == WatchStatus.saveForStreaming)
              const Text(
                'Save for Streaming',
                style: TextStyle(
                  color: AppColors.streaming,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (myServices.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: myServices
                    .map((s) => Chip(
                          label: Text(s),
                          labelStyle: const TextStyle(fontSize: 11),
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (otherServices.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.live_tv_outlined),
                tooltip: 'Also on other services',
                onPressed: () =>
                    _showOtherServicesDialog(context, movie, otherServices),
              ),
            MovieInfoButton(movie: movie),
            ActionPopupMenu(
              onSelected: (value) =>
                  _handleMenuAction(context, movieController, movie, value),
              items: [
                // From watched: can mark as want to rewatch
                if (movie.status == WatchStatus.watched)
                  ActionMenuItem.fromData(AppMenuItems.rewatchCapitalized),
                // From want to rewatch or save for streaming: can mark as watched
                if (movie.status == WatchStatus.wantToRewatch ||
                    movie.status == WatchStatus.saveForStreaming)
                  ActionMenuItem.fromData(AppMenuItems.markWatchedOutline),
                ActionMenuItem.fromData(AppMenuItems.remove),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog listing streaming services the movie is on that the user doesn't subscribe to
  void _showOtherServicesDialog(
      BuildContext context, Movie movie, List<String> services) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${movie.title} is also on'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services
              .map((s) => Chip(
                    label: Text(s),
                    labelStyle: const TextStyle(fontSize: 13),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build placeholder poster widget
  Widget _buildPlaceholderPoster() {
    return Container(
      width: 50,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(AppIcons.movie),
    );
  }

  /// Handle popup menu action
  Future<void> _handleMenuAction(
    BuildContext context,
    MovieController movieController,
    Movie movie,
    String action,
  ) async {
    switch (action) {
      case 'watched':
        await movieController.markAsWatched(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${movie.title} marked as watched')),
          );
        }
        break;
      case 'rewatch':
        await movieController.markAsWantToRewatch(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${movie.title} added to rewatch list')),
          );
        }
        break;
      case 'remove':
        await movieController.deleteMovie(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${movie.title} deleted')),
          );
        }
        break;
    }
  }
}
