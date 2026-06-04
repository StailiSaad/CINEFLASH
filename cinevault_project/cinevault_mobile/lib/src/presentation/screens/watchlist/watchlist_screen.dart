import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import 'package:cineflash/src/data/database/app_database.dart';
import 'package:cineflash/src/data/models/movie_model.dart';
import 'package:cineflash/src/presentation/widgets/movie_card.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = getIt<AppDatabase>();

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.background,
        elevation: 0,
        title: Text(
          'My Watchlist',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<WatchlistMovy>>(
        future: database.getWatchlist(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final movies = snapshot.data!;
          if (movies.isEmpty) {
            return _buildEmptyState(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: MovieModel(
                  id: movie.tmdbId,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  overview: movie.overview,
                  voteAverage: movie.voteAverage,
                  mediaType: movie.mediaType,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded, size: 80, color: context.textMuted.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: GoogleFonts.outfit(color: context.textSecondary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Add movies to watch them later',
            style: GoogleFonts.outfit(color: context.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
