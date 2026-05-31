import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cineflash/src/data/models/movie_model.dart';
import 'package:cineflash/src/data/repositories/movie_repository.dart';
import 'package:cineflash/src/data/database/app_database.dart';
import 'package:cineflash/src/core/utils/result.dart';

import 'package:cineflash/src/data/datasources/supabase_service.dart';

// Events
abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMovieDetails extends MovieDetailsEvent {
  final int movieId;
  final bool isTv;
  const LoadMovieDetails(this.movieId, {this.isTv = false});
  @override
  List<Object?> get props => [movieId, isTv];
}

class ToggleWatchlist extends MovieDetailsEvent {
  final MovieModel movie;
  final bool isTv;
  const ToggleWatchlist(this.movie, {this.isTv = false});
}

class ToggleWatched extends MovieDetailsEvent {
  final MovieModel movie;
  final bool isTv;
  const ToggleWatched(this.movie, {this.isTv = false});
}

// States
abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();
  @override
  List<Object?> get props => [];
}

class MovieDetailsInitial extends MovieDetailsState {}
class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieDetailModel movie;
  final bool isInWatchlist;
  final bool isWatched;

  const MovieDetailsLoaded({
    required this.movie,
    this.isInWatchlist = false,
    this.isWatched = false,
  });

  MovieDetailsLoaded copyWith({
    MovieDetailModel? movie,
    bool? isInWatchlist,
    bool? isWatched,
  }) {
    return MovieDetailsLoaded(
      movie: movie ?? this.movie,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isWatched: isWatched ?? this.isWatched,
    );
  }

  @override
  List<Object?> get props => [movie, isInWatchlist, isWatched];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;
  const MovieDetailsError(this.message);
}

// BLoC
class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final MovieRepository movieRepository;
  final AppDatabase database;
  final SupabaseService supabaseService;

  MovieDetailsBloc({
    required this.movieRepository,
    required this.database,
    required this.supabaseService,
  }) : super(MovieDetailsInitial()) {
    on<LoadMovieDetails>(_onLoadDetails);
    on<ToggleWatchlist>(_onToggleWatchlist);
    on<ToggleWatched>(_onToggleWatched);
  }

  Future<void> _onLoadDetails(LoadMovieDetails event, Emitter<MovieDetailsState> emit) async {
    emit(MovieDetailsLoading());
    final type = event.isTv ? 'tv' : 'movie';
    final result = event.isTv 
        ? await movieRepository.getTvDetails(event.movieId)
        : await movieRepository.getMovieDetails(event.movieId);
    
    final inWatchlist = await database.isInWatchlist(event.movieId, type);
    final watched = await database.isWatched(event.movieId, type);

    result.when(
      success: (data) {
        final movieWithCorrectType = data.copyWith(mediaType: type);
        emit(MovieDetailsLoaded(
          movie: movieWithCorrectType as MovieDetailModel,
          isInWatchlist: inWatchlist,
          isWatched: watched,
        ));
      },
      failure: (error) => emit(MovieDetailsError(error.toString())),
    );
  }

  Future<void> _onToggleWatchlist(ToggleWatchlist event, Emitter<MovieDetailsState> emit) async {
    if (state is MovieDetailsLoaded) {
      final currentState = state as MovieDetailsLoaded;
      final movie = event.movie;
      final type = event.isTv ? 'tv' : 'movie';
      
      if (currentState.isInWatchlist) {
        await database.removeFromWatchlist(movie.id, type);
        // Fire and forget: run in background so UI toggles instantly
        supabaseService.removeWatchlistItem(movie.id, type);
        emit(currentState.copyWith(isInWatchlist: false));
      } else {
        final watchlistMovie = WatchlistMovy(
          tmdbId: movie.id,
          title: movie.displayTitle,
          mediaType: type,
          posterPath: movie.posterPath,
          overview: movie.overview,
          releaseDate: movie.releaseDate,
          voteAverage: movie.voteAverage ?? 0.0,
          addedAt: DateTime.now(),
        );
        await database.addToWatchlist(watchlistMovie);
        // Fire and forget: run in background so UI toggles instantly
        supabaseService.uploadWatchlistItem(watchlistMovie);
        emit(currentState.copyWith(isInWatchlist: true));
      }
    }
  }

  Future<void> _onToggleWatched(ToggleWatched event, Emitter<MovieDetailsState> emit) async {
    if (state is MovieDetailsLoaded) {
      final currentState = state as MovieDetailsLoaded;
      final movie = event.movie;
      final type = event.isTv ? 'tv' : 'movie';
      
      if (currentState.isWatched) {
        await database.removeFromWatched(movie.id, type);
        // Fire and forget: run in background so UI toggles instantly
        supabaseService.removeWatchedItem(movie.id, type);
        emit(currentState.copyWith(isWatched: false));
      } else {
        final watchedMovie = WatchedMovy(
          tmdbId: movie.id,
          title: movie.displayTitle,
          mediaType: type,
          posterPath: movie.posterPath,
          rating: movie.voteAverage ?? 0.0,
          watchedAt: DateTime.now(),
        );
        await database.markAsWatched(watchedMovie);
        // Fire and forget: run in background so UI toggles instantly
        supabaseService.uploadWatchedItem(watchedMovie);
        emit(currentState.copyWith(isWatched: true));
      }
    }
  }
}
