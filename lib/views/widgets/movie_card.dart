import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/movie.dart';
import '../../constants/app_icons.dart';
import '../../constants/menu_items.dart';
import '../../widgets/action_buttons.dart';

/// Reusable movie card widget (DRY principle)
class MovieCard extends StatelessWidget {
  final Movie movie;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDescription;

  const MovieCard({
    super.key,
    required this.movie,
    this.trailing,
    this.onTap,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _buildPoster(),
        title: Text(
          movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildSubtitle(),
        trailing: trailing,
      ),
    );
  }

  /// Build movie poster or placeholder
  Widget _buildPoster() {
    if (movie.posterUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          movie.posterUrl!,
          width: 50,
          height: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderPoster(),
        ),
      );
    }
    return _buildPlaceholderPoster();
  }

  /// Build placeholder poster
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

  /// Build subtitle with release date and description
  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(movie.releaseDate),
          style: const TextStyle(fontSize: 13),
        ),
        if (showDescription && movie.description != null)
          Text(
            movie.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  /// Format date helper
  String _formatDate(DateTime date) {
    // Check if TBD
    if (movie.isTbd) {
      return 'Release Date: TBD';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final releaseDay = DateTime(date.year, date.month, date.day);
    if (releaseDay.isAfter(today)) {
      final days = releaseDay.difference(today).inDays;
      return 'Releases ${date.day}.${date.month}.${date.year} (in $days days)';
    } else {
      return 'Released ${date.day}.${date.month}.${date.year}';
    }
  }
}

/// Icon button to open external URLs (TMDb/IMDb)
class MovieInfoButton extends StatelessWidget {
  final Movie movie;

  const MovieInfoButton({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    if (movie.tmdbUrl == null && movie.imdbUrl == null) {
      return const SizedBox.shrink();
    }

    return ActionIconButton(
      icon: AppIcons.info,
      tooltip: movie.tmdbUrl != null ? 'Open TMDb' : 'Open IMDb',
      onPressed: () => _launchUrl(context, movie.tmdbUrl ?? movie.imdbUrl!),
    );
  }

  /// Launch URL in external browser
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }
}

/// Quick action buttons for movie status changes (DRY principle)
class MovieActionButtons extends StatelessWidget {
  final Movie movie;
  final Function(Movie) onMarkWatched;
  final Function(Movie) onMarkRewatch;
  final Function(Movie) onDelete;

  const MovieActionButtons({
    super.key,
    required this.movie,
    required this.onMarkWatched,
    required this.onMarkRewatch,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionPopupMenu(
          onSelected: (value) {
            switch (value) {
              case 'watched':
                onMarkWatched(movie);
                break;
              case 'rewatch':
                onMarkRewatch(movie);
                break;
              case 'delete':
                onDelete(movie);
                break;
            }
          },
          items: [
            ActionMenuItem.fromData(AppMenuItems.markWatched),
            ActionMenuItem.fromData(AppMenuItems.rewatch),
            ActionMenuItem.fromData(AppMenuItems.delete),
          ],
        ),
      ],
    );
  }
}
