import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';
import '../views/widgets/movie_card.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../widgets/action_buttons.dart';
import '../l10n/app_localizations.dart';

/// Browse screen for discovering and searching movies from TMDb
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  List<Movie> _upcomingMovies = [];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _showingFilteredResults = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUpcomingMovies() async {
    setState(() {
      _isLoading = true;
    });

    final movieController = context.read<MovieController>();
    final allUpcoming = await movieController.getUpcomingMoviesFromTMDb();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final twoWeeksFromNow = today.add(const Duration(days: 14));

    var filteredMovies = allUpcoming.where((movie) {
      if (movie.isTbd) return false;
      final releaseDate = DateTime(
        movie.releaseDate.year,
        movie.releaseDate.month,
        movie.releaseDate.day,
      );
      return (releaseDate.isAtSameMomentAs(today) ||
              releaseDate.isAfter(today)) &&
          (releaseDate.isBefore(twoWeeksFromNow) ||
              releaseDate.isAtSameMomentAs(twoWeeksFromNow));
    }).toList();

    final showingFilteredResults = filteredMovies.isNotEmpty;
    if (filteredMovies.isEmpty) {
      filteredMovies = allUpcoming;
    }

    filteredMovies.sort((a, b) {
      if (a.isTbd && b.isTbd) return 0;
      if (a.isTbd) return 1;
      if (b.isTbd) return -1;
      return a.releaseDate.compareTo(b.releaseDate);
    });

    setState(() {
      _upcomingMovies = filteredMovies;
      _showingFilteredResults = showingFilteredResults;
      _isLoading = false;
    });
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    final movieController = context.read<MovieController>();
    final results = await movieController.searchMovies(query);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final movieController = context.watch<MovieController>();
    final apiStatus = movieController.tmdbApiStatus;
    return Column(
      children: [
        if (apiStatus != TmdbApiStatus.ok) _buildApiWarningBanner(apiStatus, l10n),
        _buildSearchBar(l10n),
        if (!_isSearching) _buildUpcomingHeader(l10n),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMovieList(l10n),
        ),
      ],
    );
  }

  Widget _buildApiWarningBanner(TmdbApiStatus status, AppLocalizations l10n) {
    final message = status == TmdbApiStatus.notConfigured
        ? l10n.tmdbApiKeyMissing
        : l10n.tmdbApiKeyInvalid;
    return Container(
      width: double.infinity,
      color: Colors.orange[800],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
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
          hintText: l10n.searchTmdbHint,
          prefixIcon: const Icon(AppIcons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(AppIcons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearching = false;
                      _searchResults = [];
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
          _searchMovies(value);
        },
      ),
    );
  }

  Widget _buildUpcomingHeader(AppLocalizations l10n) {
    final headerText = _showingFilteredResults
        ? l10n.upcomingMoviesNext2Weeks
        : l10n.upcomingMovies;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.upcoming,
            size: AppIcons.actionSize,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            headerText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList(AppLocalizations l10n) {
    final movies = _isSearching ? _searchResults : _upcomingMovies;

    if (movies.isEmpty) {
      return EmptyStateWidget(
        icon: AppIcons.movieOutline,
        title: _isSearching ? l10n.noMoviesFound : l10n.noUpcomingMovies,
        subtitle: _isSearching
            ? l10n.tryDifferentSearch
            : l10n.checkBackLater,
      );
    }

    return Consumer<MovieController>(
      builder: (context, movieController, _) {
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];

            final existingMovie = movieController.movies
                .where((m) => m.id == movie.id)
                .firstOrNull;
            final isOnWatchlist = existingMovie?.isOnWatchlist ?? false;

            return MovieCard(
              movie: movie,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MovieInfoButton(movie: movie),
                  IconButton(
                    icon: Icon(
                      isOnWatchlist ? AppIcons.bookmark : AppIcons.bookmarkOutline,
                      color: isOnWatchlist ? AppColors.bookmarkActive : null,
                    ),
                    tooltip: isOnWatchlist
                        ? l10n.removeFromWatchlist
                        : l10n.addToWatchlist,
                    onPressed: () => _toggleWatchlist(
                      context,
                      movieController,
                      movie,
                      existingMovie,
                      isOnWatchlist,
                      l10n,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleWatchlist(
    BuildContext context,
    MovieController movieController,
    Movie movie,
    Movie? existingMovie,
    bool isCurrentlyOnWatchlist,
    AppLocalizations l10n,
  ) async {
    if (isCurrentlyOnWatchlist && existingMovie != null) {
      await movieController.deleteMovie(existingMovie);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.movieRemovedFromWatchlist(movie.title))),
        );
      }
    } else {
      if (existingMovie != null) {
        await movieController.updateMovieStatus(
            existingMovie, WatchStatus.wantToWatch);
      } else {
        await movieController.addToWatchlist(movie);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.movieAddedToWatchlist(movie.title))),
        );
      }
    }
  }
}
