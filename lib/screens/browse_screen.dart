import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../controllers/movie_controller.dart';
import '../views/widgets/movie_card.dart';
import '../constants/app_icons.dart';
import '../constants/app_colors.dart';
import '../widgets/action_buttons.dart';

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

  /// Load upcoming movies from TMDb
  Future<void> _loadUpcomingMovies() async {
    setState(() {
      _isLoading = true;
    });

    final movieController = context.read<MovieController>();
    final allUpcoming = await movieController.getUpcomingMoviesFromTMDb();

    // Filter to show only movies releasing in the next 2 weeks
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final twoWeeksFromNow = today.add(const Duration(days: 14));

    var filteredMovies = allUpcoming.where((movie) {
      // Exclude TBD movies from the 2-week filter
      if (movie.isTbd) return false;

      final releaseDate = DateTime(
        movie.releaseDate.year,
        movie.releaseDate.month,
        movie.releaseDate.day,
      );
      // Include movies from today up to 2 weeks from now
      return (releaseDate.isAtSameMomentAs(today) ||
              releaseDate.isAfter(today)) &&
          (releaseDate.isBefore(twoWeeksFromNow) ||
              releaseDate.isAtSameMomentAs(twoWeeksFromNow));
    }).toList();

    // If no movies in next 2 weeks, show all upcoming movies
    final showingFilteredResults = filteredMovies.isNotEmpty;
    if (filteredMovies.isEmpty) {
      filteredMovies = allUpcoming;
    }

    // Sort by release date (earliest first, TBD movies at the end)
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

  /// Search movies on TMDb
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
    return Column(
      children: [
        _buildSearchBar(),
        if (!_isSearching) _buildUpcomingHeader(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMovieList(),
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
          hintText: 'Search movies on TMDb...',
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

  /// Build the header showing upcoming movies section
  Widget _buildUpcomingHeader() {
    final headerText = _showingFilteredResults
        ? 'Upcoming Movies (Next 2 Weeks)'
        : 'Upcoming Movies';

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

  /// Build the movie list
  Widget _buildMovieList() {
    final movies = _isSearching ? _searchResults : _upcomingMovies;

    if (movies.isEmpty) {
      return EmptyStateWidget(
        icon: AppIcons.movieOutline,
        title: _isSearching ? 'No movies found' : 'No upcoming movies',
        subtitle: _isSearching
            ? 'Try a different search term'
            : 'Check back later or use search to find movies',
      );
    }

    return Consumer<MovieController>(
      builder: (context, movieController, _) {
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];

            // Check if movie is already on watchlist
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
                        ? 'Remove from watchlist'
                        : 'Add to watchlist',
                    onPressed: () => _toggleWatchlist(
                      context,
                      movieController,
                      movie,
                      existingMovie,
                      isOnWatchlist,
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

  /// Toggle movie watchlist status
  Future<void> _toggleWatchlist(
    BuildContext context,
    MovieController movieController,
    Movie movie,
    Movie? existingMovie,
    bool isCurrentlyOnWatchlist,
  ) async {
    if (isCurrentlyOnWatchlist && existingMovie != null) {
      // Remove from watchlist by deleting
      await movieController.deleteMovie(existingMovie);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${movie.title} removed from watchlist')),
        );
      }
    } else {
      if (existingMovie != null) {
        // Movie exists, update status to wantToWatch
        await movieController.updateMovieStatus(
            existingMovie, WatchStatus.wantToWatch);
      } else {
        // New movie, add to watchlist
        await movieController.addToWatchlist(movie);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${movie.title} added to watchlist')),
        );
      }
    }
  }
}
