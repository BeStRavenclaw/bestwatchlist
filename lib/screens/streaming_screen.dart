import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';
import '../controllers/settings_controller.dart';
import '../views/widgets/movie_card.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../widgets/action_buttons.dart';
import '../l10n/app_localizations.dart';

/// Streaming library screen showing watched and want to rewatch movies
class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  State<StreamingScreen> createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showWatchedMovies = false;
  final Set<String> _selectedServiceFilters = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildSearchBar(l10n),
        _buildToggleButton(l10n),
        Expanded(
          child: Consumer<MovieController>(
            builder: (context, movieController, _) {
              final userServices =
                  Provider.of<SettingsController>(context, listen: false)
                      .streamingServices;

              var streamingMovies = movieController.movies
                  .where((movie) => _showWatchedMovies
                      ? movie.status == WatchStatus.watched
                      : (movie.status == WatchStatus.saveForStreaming ||
                          movie.status == WatchStatus.wantToRewatch))
                  .toList();

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

              if (_selectedServiceFilters.isNotEmpty) {
                streamingMovies = streamingMovies.where((movie) {
                  final services = movie.availableOnStreamingServices ?? [];
                  return services
                      .any((s) => _selectedServiceFilters.contains(s));
                }).toList();
              }

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
                                    ? l10n.noWatchedMovies
                                    : l10n.noMoviesToStream)
                                : l10n.noMoviesFound,
                            subtitle: _searchQuery.isEmpty &&
                                    _selectedServiceFilters.isEmpty
                                ? (_showWatchedMovies
                                    ? l10n.markMoviesWatched
                                    : l10n.markMoviesForStreaming)
                                : l10n.tryDifferentSearchOrFilter,
                          )
                        : ListView.builder(
                            itemCount: streamingMovies.length,
                            itemBuilder: (context, index) {
                              final movie = streamingMovies[index];
                              return _buildStreamingMovieCard(
                                  context, movieController, movie, l10n);
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

  Widget _buildToggleButton(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: Text(l10n.watched),
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
              label: Text(l10n.streamingWatchlist),
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

  Widget _buildSearchBar(AppLocalizations l10n) {
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
          hintText: l10n.searchLibraryHint,
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

  Widget _buildStreamingMovieCard(
      BuildContext context,
      MovieController movieController,
      Movie movie,
      AppLocalizations l10n) {
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
              Text(
                l10n.wantToRewatch,
                style: const TextStyle(
                  color: AppColors.rewatch,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (movie.status == WatchStatus.saveForStreaming)
              Text(
                l10n.saveForStreaming,
                style: const TextStyle(
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
                tooltip: l10n.alsoOnOtherServices,
                onPressed: () =>
                    _showOtherServicesDialog(context, movie, otherServices, l10n),
              ),
            MovieInfoButton(movie: movie),
            ActionPopupMenu(
              tooltip: l10n.moreActions,
              onSelected: (value) =>
                  _handleMenuAction(context, movieController, movie, value, l10n),
              items: [
                if (movie.status == WatchStatus.watched)
                  ActionMenuItem(
                    value: 'rewatch',
                    icon: AppIcons.rewatch,
                    label: l10n.menuWantToRewatch,
                  ),
                if (movie.status == WatchStatus.wantToRewatch ||
                    movie.status == WatchStatus.saveForStreaming)
                  ActionMenuItem(
                    value: 'watched',
                    icon: AppIcons.markWatchedOutline,
                    label: l10n.menuMarkWatched,
                  ),
                ActionMenuItem(
                  value: 'remove',
                  icon: AppIcons.delete,
                  label: l10n.menuRemoveFromLibrary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOtherServicesDialog(
      BuildContext context,
      Movie movie,
      List<String> services,
      AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.alsoOn(movie.title)),
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
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

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

  Future<void> _handleMenuAction(
    BuildContext context,
    MovieController movieController,
    Movie movie,
    String action,
    AppLocalizations l10n,
  ) async {
    switch (action) {
      case 'watched':
        await movieController.markAsWatched(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.movieMarkedWatched(movie.title))),
          );
        }
        break;
      case 'rewatch':
        await movieController.markAsWantToRewatch(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.movieAddedRewatch(movie.title))),
          );
        }
        break;
      case 'remove':
        await movieController.deleteMovie(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.movieDeleted(movie.title))),
          );
        }
        break;
    }
  }
}
