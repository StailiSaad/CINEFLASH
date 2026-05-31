import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:cineflash/src/presentation/blocs/search/search_bloc.dart';
import 'package:cineflash/src/core/di/injection.dart';
import 'package:cineflash/src/data/repositories/movie_repository.dart';
import 'package:cineflash/src/presentation/widgets/movie_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(movieRepository: getIt<MovieRepository>()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            autofocus: true,
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
            onChanged: (value) => context.read<SearchBloc>().add(SearchQueryChanged(value)),
            decoration: InputDecoration(
              hintText: 'Search movies...',
              hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          if (state is SearchSuccess) {
            if (state.results.isEmpty) {
              return _buildMessage('No results found');
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final movie = state.results[index];
                return MovieCard(movie: movie);
              },
            );
          }

          if (state is SearchError) {
            return _buildMessage('Error occurred: ${state.message}');
          }

          return _buildMessage('Find your favorite films');
        },
      ),
    );
  }

  Widget _buildMessage(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_creation_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}