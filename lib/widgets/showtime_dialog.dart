import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';

/// Helper function to generate Cineman URL and launch it
Future<void> openCinemanShowtimes(Movie movie) async {
  final year = movie.originalReleaseYear ?? movie.releaseDate.year;
  final titleSlug = _generateCinemanTitleSlug(movie.title);

  // Try the calculated year first, then fall back to previous year
  // Cineman sometimes uses a different year than the actual release year
  final workingUrl = await _findWorkingCinemanUrl(titleSlug, year);

  if (workingUrl != null) {
    final uri = Uri.parse(workingUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // If no working URL found, try opening the original anyway
    final fallbackUrl = 'https://www.cineman.ch/en/movie/$year/$titleSlug/cinema.html';
    final uri = Uri.parse(fallbackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open Cineman URL: $fallbackUrl');
    }
  }
}

/// Try to find a working Cineman URL by checking if the page exists
Future<String?> _findWorkingCinemanUrl(String titleSlug, int year) async {
  // Try years in order: calculated year, year-1, year+1
  final yearsToTry = [year, year - 1, year + 1];

  for (final tryYear in yearsToTry) {
    final url = 'https://www.cineman.ch/en/movie/$tryYear/$titleSlug/cinema.html';
    try {
      final response = await http.head(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        return url;
      }
    } catch (e) {
      // Network error or timeout, continue to next year
    }
  }
  return null;
}

/// Generate a Cineman-compatible URL slug from movie title
String _generateCinemanTitleSlug(String title) {
  // Remove special characters and convert to PascalCase
  final cleaned = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();

  // Convert to PascalCase (e.g., "The Batman" -> "TheBatman")
  final words = cleaned.split(' ');
  return words.map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join('');
}
