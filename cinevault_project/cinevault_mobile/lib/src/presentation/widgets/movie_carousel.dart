import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cineflash/src/data/models/movie_model.dart';
import 'package:cineflash/src/core/constants/api_constants.dart';
import 'package:cineflash/src/core/theme/app_theme.dart';

class MovieCarousel extends StatelessWidget {
  final List<MovieModel> movies;

  const MovieCarousel({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return InkWell(
            onTap: () => context.push('/movie/${movie.id}'),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.network(
                  '${ApiConstants.tmdbImageBaseUrl}/${ApiConstants.backdropSize}${movie.backdropPath ?? movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: context.surface),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: context.heroGradient,
                  ),
                ),
                // Movie info
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (movie.voteAverage != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.accent, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage!.toStringAsFixed(1),
                              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Text(
                        movie.displayTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (movie.overview != null)
                        Text(
                          movie.overview!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}