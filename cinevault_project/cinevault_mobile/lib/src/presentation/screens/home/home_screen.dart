import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineflash/src/core/theme/app_theme.dart';
import 'package:cineflash/src/core/router/app_router.dart';
import 'package:cineflash/src/presentation/blocs/movies/movies_bloc.dart';
import 'package:cineflash/src/presentation/blocs/app/app_bloc.dart';
import 'package:cineflash/src/presentation/widgets/movie_carousel.dart';
import 'package:cineflash/src/presentation/widgets/movie_section.dart';
import 'package:cineflash/src/presentation/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<MoviesBloc>().add(const LoadTrendingMovies());
    context.read<MoviesBloc>().add(const LoadPopularMovies());
    context.read<MoviesBloc>().add(const LoadTopRatedMovies());
    context.read<MoviesBloc>().add(const LoadTrendingTv());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<MoviesBloc>().add(RefreshMovies());
        },
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const CustomAppBar(),
              SliverToBoxAdapter(
                child: BlocBuilder<MoviesBloc, MoviesState>(
                  builder: (context, state) {
                    if (state is MoviesLoaded && state.trendingMovies.isNotEmpty) {
                      return MovieCarousel(movies: state.trendingMovies.take(5).toList());
                    }
                    if (state is MoviesError) {
                      return SizedBox(
                        height: 220,
                        child: Center(
                          child: Text(
                            'Error: ${state.message}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Trending Movies'),
                      const SizedBox(height: 12),
                      BlocBuilder<MoviesBloc, MoviesState>(
                        builder: (context, state) {
                          if (state is MoviesLoaded) {
                            return MovieSection(movies: state.trendingMovies);
                          }
                          if (state is MoviesError) {
                            return const Center(child: Text('Failed to load trending movies'));
                          }
                          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Trending TV Shows'),
                      const SizedBox(height: 12),
                      BlocBuilder<MoviesBloc, MoviesState>(
                        builder: (context, state) {
                          if (state is MoviesLoaded) {
                            return MovieSection(movies: state.trendingTv, isTv: true);
                          }
                          if (state is MoviesError) {
                            return const Center(child: Text('Failed to load trending TV'));
                          }
                          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Popular'),
                      const SizedBox(height: 12),
                      BlocBuilder<MoviesBloc, MoviesState>(
                        builder: (context, state) {
                          if (state is MoviesLoaded) {
                            return MovieSection(movies: state.popularMovies);
                          }
                          if (state is MoviesError) {
                            return const Center(child: Text('Failed to load popular movies'));
                          }
                          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Top Rated'),
                      const SizedBox(height: 12),
                      BlocBuilder<MoviesBloc, MoviesState>(
                        builder: (context, state) {
                          if (state is MoviesLoaded) {
                            return MovieSection(movies: state.topRatedMovies);
                          }
                          if (state is MoviesError) {
                            return const Center(child: Text('Failed to load top rated movies'));
                          }
                          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
      ),
    );
  }
}