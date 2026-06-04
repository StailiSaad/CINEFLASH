import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cineflash/src/core/theme/app_theme.dart';
import 'package:cineflash/src/core/constants/api_constants.dart';
import 'package:cineflash/src/data/models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final bool? isTv;

  const MovieCard({super.key, required this.movie, this.isTv});

  @override
  Widget build(BuildContext context) {
    final effectiveIsTv = isTv ?? (movie.mediaType == 'tv');
    
    return GestureDetector(
      onTap: () {
        if (effectiveIsTv) {
          context.push('/tv/${movie.id}');
        } else {
          context.push('/movie/${movie.id}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            (movie.posterPath != null && movie.posterPath!.isNotEmpty)
                ? Image.network(
                    '${ApiConstants.tmdbImageBaseUrl}/${ApiConstants.posterSize}${movie.posterPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage?.toStringAsFixed(1) ?? '0.0',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: context.surface,
      child: const Center(
        child: Icon(Icons.movie_creation_outlined, color: AppColors.textMuted, size: 32),
      ),
    );
  }
}
