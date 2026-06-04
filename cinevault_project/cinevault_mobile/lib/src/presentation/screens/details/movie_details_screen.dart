import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cineflash/src/core/theme/app_theme.dart';
import 'package:cineflash/src/core/constants/api_constants.dart';
import 'package:cineflash/src/presentation/blocs/movie_details/movie_details_bloc.dart';
import 'package:cineflash/src/core/di/injection.dart';
import 'package:cineflash/src/data/repositories/movie_repository.dart';
import 'package:cineflash/src/data/database/app_database.dart';
import 'package:cineflash/src/data/datasources/supabase_service.dart';
import 'package:cineflash/src/data/models/movie_model.dart';


class MovieDetailsScreen extends StatelessWidget {
  final int movieId;
  final bool isTv;

  const MovieDetailsScreen({
    super.key, 
    required this.movieId, 
    this.isTv = false
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailsBloc(
        movieRepository: getIt<MovieRepository>(),
        database: getIt<AppDatabase>(),
        supabaseService: getIt<SupabaseService>(),
      )..add(LoadMovieDetails(movieId, isTv: isTv)),
      child: MovieDetailsView(isTv: isTv),
    );
  }
}

class MovieDetailsView extends StatelessWidget {
  final bool isTv;
  const MovieDetailsView({super.key, required this.isTv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
        builder: (context, state) {
          if (state is MovieDetailsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          if (state is MovieDetailsError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          }

          if (state is MovieDetailsLoaded) {
            final movie = state.movie;
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, movie, state.isInWatchlist, state.isWatched),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainInfo(context, movie),
                        const SizedBox(height: 24),
                        if (movie.trailerKey != null) ...[
                          _buildTrailerButton(context, movie.trailerKey!),
                          const SizedBox(height: 16),
                        ],
                        _buildActionButtons(context, movie, state.isInWatchlist, state.isWatched),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, 'Overview'),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview ?? 'No overview available.',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: context.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (movie.cast != null && movie.cast!.isNotEmpty) ...[
                          _buildSectionTitle(context, 'Top Cast'),
                          const SizedBox(height: 12),
                          _buildCastSection(context, movie.cast!),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCastSection(BuildContext context, List<CastModel> cast) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final actor = cast[index];
          return SizedBox(
            width: 90,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: actor.profilePath != null
                        ? DecorationImage(
                            image: NetworkImage(
                              '${ApiConstants.tmdbImageBaseUrl}/w185${actor.profilePath}',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: context.surface,
                  ),
                  child: actor.profilePath == null
                      ? Icon(Icons.person, color: context.textMuted, size: 40)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  actor.name ?? '',
                  style: GoogleFonts.outfit(
                    color: context.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  actor.character ?? '',
                  style: GoogleFonts.outfit(
                    color: context.textSecondary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MovieDetailModel movie, bool inWatchlist, bool watched) {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      backgroundColor: context.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              '${ApiConstants.tmdbImageBaseUrl}/${ApiConstants.posterSize}${movie.posterPath ?? movie.backdropPath}',
              fit: BoxFit.cover,
              errorBuilder: (ctx, __, ___) => Container(
                color: context.surface,
                child: Center(child: Icon(Icons.movie_outlined, size: 50, color: ctx.textMuted)),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    context.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, MovieDetailModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movie.tagline != null && movie.tagline!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              movie.tagline!,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
          ),
        Text(
          movie.displayTitle,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage != null 
                  ? movie.voteAverage!.toStringAsFixed(1) 
                  : '0.0',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              movie.displayDate.split('-')[0],
              style: GoogleFonts.outfit(fontSize: 16, color: context.textSecondary),
            ),
            const SizedBox(width: 24),
            if (movie.runtime != null)
              Text(
                '${movie.runtime} min',
                style: GoogleFonts.outfit(fontSize: 16, color: context.textSecondary),
              ),
          ],
        ),
        if (movie.genres != null && movie.genres!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Wrap(
              spacing: 8,
              children: movie.genres!.map((g) => Chip(
                label: Text(g.name ?? '', style: TextStyle(fontSize: 12, color: context.textPrimary)),
                backgroundColor: context.surface,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailerButton(BuildContext context, String videoId) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _playTrailer(context, videoId),
          icon: const Icon(Icons.play_circle_fill, color: Colors.white),
          label: const Text('WATCH IN-APP'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openExternalYouTube(videoId),
          icon: const Icon(Icons.open_in_new, color: AppColors.primary),
          label: const Text('OPEN IN YOUTUBE APP'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary, width: 2),
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _openExternalYouTube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _playTrailer(BuildContext context, String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrailerPlayerPage(videoId: videoId),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MovieDetailModel movie, bool inWatchlist, bool watched) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            context,
            icon: inWatchlist ? Icons.bookmark : Icons.bookmark_border,
            label: inWatchlist ? 'In Watchlist' : 'Watchlist',
            isActive: inWatchlist,
            onTap: () => context.read<MovieDetailsBloc>().add(ToggleWatchlist(movie, isTv: isTv)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            context,
            icon: watched ? Icons.check_circle : Icons.check_circle_outline,
            label: watched ? 'Seen' : 'Mark Seen',
            isActive: watched,
            onTap: () => context.read<MovieDetailsBloc>().add(ToggleWatched(movie, isTv: isTv)),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primary : context.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isActive ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isActive ? Colors.white : context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
      ),
    );
  }
}

class TrailerPlayerPage extends StatefulWidget {
  final String videoId;
  const TrailerPlayerPage({super.key, required this.videoId});

  @override
  State<TrailerPlayerPage> createState() => _TrailerPlayerPageState();
}

class _TrailerPlayerPageState extends State<TrailerPlayerPage> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId.trim(),
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        isLive: false,
        forceHD: false,
      ),
    );
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _openInYouTube() async {
    final url = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Trailer',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        onReady: () => setState(() => _isPlayerReady = true),
        onEnded: (data) => Navigator.pop(context),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(child: player),
              if (!_isPlayerReady)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 24),
                      Text(
                        'Loading trailer...',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _openInYouTube,
                        icon: const Icon(Icons.open_in_new, color: Colors.white),
                        label: Text(
                          'Open in YouTube App',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
