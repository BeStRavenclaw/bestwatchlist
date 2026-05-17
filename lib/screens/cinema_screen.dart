import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';
import '../views/widgets/movie_card.dart';
import '../widgets/showtime_dialog.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../widgets/action_buttons.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildSearchBar(l10n),
        Expanded(
          child: Consumer<MovieController>(
            builder: (context, movieController, _) {
              var watchlistMovies = movieController.movies
                  .where((movie) => movie.status == WatchStatus.wantToWatch)
                  .toList();

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

              watchlistMovies
                  .sort((a, b) => a.releaseDate.compareTo(b.releaseDate));

              final released =
                  watchlistMovies.where((m) => m.hasBeenReleased).toList();
              final upcoming =
                  watchlistMovies.where((m) => !m.hasBeenReleased).toList();

              if (watchlistMovies.isEmpty) {
                return EmptyStateWidget(
                  icon: AppIcons.bookmarkOutline,
                  title: _searchQuery.isEmpty
                      ? l10n.noCinemaMovies
                      : l10n.noMoviesFound,
                  subtitle: _searchQuery.isEmpty
                      ? l10n.addMoviesFromBrowse
                      : l10n.tryDifferentSearch,
                );
              }

              return ListView(
                children: [
                  if (released.isNotEmpty) ...[
                    _buildSectionHeader(l10n.released),
                    ...released.map((movie) =>
                        _buildCinemaMovieCard(context, movieController, movie, l10n)),
                    const Divider(height: 32, thickness: 2),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    _buildSectionHeader(l10n.upcomingReleases),
                    ...upcoming.map((movie) =>
                        _buildCinemaMovieCard(context, movieController, movie, l10n)),
                  ],
                ],
              );
            },
          ),
        ),
      ],
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
          hintText: l10n.searchCinemaHint,
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

  Widget _buildCinemaMovieCard(
      BuildContext context,
      MovieController movieController,
      Movie movie,
      AppLocalizations l10n) {
    return MovieCard(
      movie: movie,
      showDescription: false,
      onTap: () async {
        try {
          await openCinemanShowtimes(movie);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.couldNotOpenCineman(e.toString()))),
            );
          }
        }
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MovieInfoButton(movie: movie),
          ActionPopupMenu(
            tooltip: l10n.moreActions,
            onSelected: (value) =>
                _handleMenuAction(context, movieController, movie, value, l10n),
            items: [
              ActionMenuItem(
                value: 'showtimes',
                icon: AppIcons.showtimes,
                label: l10n.menuViewShowtimes,
              ),
              ActionMenuItem(
                value: 'watched',
                icon: AppIcons.markWatchedOutline,
                label: l10n.menuMarkWatched,
              ),
              ActionMenuItem(
                value: 'rewatch',
                icon: AppIcons.rewatch,
                label: l10n.menuWantToRewatch,
              ),
              ActionMenuItem(
                value: 'save_for_streaming',
                icon: AppIcons.saveForStreaming,
                label: l10n.menuSaveForStreaming,
              ),
              ActionMenuItem(
                value: 'delete',
                icon: AppIcons.delete,
                label: l10n.menuDelete,
              ),
            ],
          ),
        ],
      ),
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
      case 'showtimes':
        try {
          await openCinemanShowtimes(movie);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.couldNotOpenCineman(e.toString()))),
            );
          }
        }
        break;
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
      case 'save_for_streaming':
        await movieController.markAsSaveForStreaming(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.movieMovedStreaming(movie.title))),
          );
        }
        break;
      case 'delete':
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
