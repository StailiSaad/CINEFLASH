import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import 'package:cineflash/src/data/database/app_database.dart';
import 'package:cineflash/src/data/models/movie_model.dart';
import 'package:cineflash/src/presentation/widgets/movie_card.dart';

class WatchedScreen extends StatelessWidget {
  const WatchedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = getIt<AppDatabase>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Seen Movies',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<WatchedMovy>>(
        future: database.getWatchedMovies(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final movies = snapshot.data!;
          if (movies.isEmpty) {
            return _buildEmptyState();
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
                  voteAverage: movie.rating,
                  mediaType: movie.mediaType,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 80, color: AppColors.textMuted.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No movies marked as seen',
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep track of what you have watched',
            style: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}