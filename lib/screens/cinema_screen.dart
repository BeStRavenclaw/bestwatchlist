import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';
import '../views/widgets/movie_card.dart';
import '../widgets/showtime_dialog.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../constants/menu_items.dart';
import '../widgets/action_buttons.dart';

/// Cinema screen showing movies on the watchlist (want to watch status)
class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
        Expanded(
          child: Consumer<MovieController>(
            builder: (context, movieController, _) {
              var watchlistMovies = movieController.movies
                  .where((movie) => movie.status == WatchStatus.wantToWatch)
                  .toList();

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                watchlistMovies = watchlistMovies.where((movie) {
                  return movie.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (movie.description
                              ?.toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ??
                          false);
                }).toList();
              }

              // Sort by release date
              watchlistMovies
                  .sort((a, b) => a.releaseDate.compareTo(b.releaseDate));

              // Split into released and upcoming
              final released =
                  watchlistMovies.where((m) => m.hasBeenReleased).toList();
              final upcoming =
                  watchlistMovies.where((m) => !m.hasBeenReleased).toList();

              if (watchlistMovies.isEmpty) {
                return EmptyStateWidget(
                  icon: AppIcons.bookmarkOutline,
                  title: _searchQuery.isEmpty
                      ? 'No cinema movies yet'
                      : 'No movies found',
                  subtitle: _searchQuery.isEmpty
                      ? 'Add movies to your watchlist from Browse'
                      : 'Try a different search term',
                );
              }

              return ListView(
                children: [
                  if (released.isNotEmpty) ...[
                    _buildSectionHeader('Released'),
                    ...released.map((movie) =>
                        _buildCinemaMovieCard(context, movieController, movie)),
                    const Divider(height: 32, thickness: 2),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    _buildSectionHeader('Upcoming Releases'),
                    ...upcoming.map((movie) =>
                        _buildCinemaMovieCard(context, movieController, movie)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
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
          hintText: 'Search cinema movies...',
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

  /// Build section header with title and count
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

  /// Build a movie card for cinema screen
  Widget _buildCinemaMovieCard(
      BuildContext context, MovieController movieController, Movie movie) {
    return MovieCard(
      movie: movie,
      showDescription: false,
      onTap: () async {
        try {
          await openCinemanShowtimes(movie);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open Cineman: $e')),
            );
          }
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MovieInfoButton(movie: movie),
          ActionPopupMenu(
            onSelected: (value) =>
                _handleMenuAction(context, movieController, movie, value),
            items: [
              ActionMenuItem.fromData(AppMenuItems.showtimes),
              ActionMenuItem.fromData(AppMenuItems.markWatchedOutline),
              ActionMenuItem.fromData(AppMenuItems.rewatchCapitalized),
              ActionMenuItem.fromData(AppMenuItems.saveForStreaming),
              ActionMenuItem.fromData(AppMenuItems.delete),
            ],
          ),
        ],
      ),
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
      case 'showtimes':
        try {
          await openCinemanShowtimes(movie);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open Cineman: $e')),
            );
          }
        }
        break;
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
      case 'save_for_streaming':
        await movieController.markAsSaveForStreaming(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${movie.title} moved to streaming list')),
          );
        }
        break;
      case 'delete':
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
