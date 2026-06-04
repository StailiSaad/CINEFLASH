import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cineflash/src/data/models/movie_model.dart';
import 'package:cineflash/src/core/constants/api_constants.dart';
import 'package:cineflash/src/core/theme/app_theme.dart';

class MovieSection extends StatelessWidget {
  final List<MovieModel> movies;
  final bool isTv;

  const MovieSection({super.key, required this.movies, this.isTv = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return _MovieCard(movie: movie, isTv: isTv);
        },
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  final bool isTv;

  const _MovieCard({required this.movie, required this.isTv});

  @override
  Widget build(BuildContext context) {
    final effectiveIsTv = isTv || movie.mediaType == 'tv';
    
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          if (effectiveIsTv) {
            context.push('/tv/${movie.id}');
          } else {
            context.push('/movie/${movie.id}');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                '${ApiConstants.tmdbImageBaseUrl}/${ApiConstants.posterSize}${movie.posterPath}',
                height: 200,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  width: 150,
                  color: AppColors.surface,
                  child: const Icon(Icons.movie, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              movie.displayTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.accent, size: 14),
                const SizedBox(width: 4),
                Text(
                  movie.voteAverage?.toStringAsFixed(1) ?? 'N/A',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}