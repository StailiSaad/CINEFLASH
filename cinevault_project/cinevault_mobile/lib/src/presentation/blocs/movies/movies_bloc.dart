import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cineflash/src/data/models/movie_model.dart';
import 'package:cineflash/src/data/repositories/movie_repository.dart';
import 'package:cineflash/src/core/utils/result.dart';

// Events
abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingMovies extends MoviesEvent {
  final int page;
  const LoadTrendingMovies({this.page = 1});
}

class LoadPopularMovies extends MoviesEvent {
  final int page;
  const LoadPopularMovies({this.page = 1});
}

class LoadTopRatedMovies extends MoviesEvent {
  final int page;
  const LoadTopRatedMovies({this.page = 1});
}

class LoadTrendingTv extends MoviesEvent {
  final int page;
  const LoadTrendingTv({this.page = 1});
}

class RefreshMovies extends MoviesEvent {}

// States
abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  final List<MovieModel> trendingMovies;
  final List<MovieModel> popularMovies;
  final List<MovieModel> topRatedMovies;
  final List<MovieModel> trendingTv;
  final bool hasMoreTrending;
  final bool hasMorePopular;
  final bool hasMoreTopRated;
  final bool hasMoreTv;
  final int trendingPage;
  final int popularPage;
  final int topRatedPage;
  final int tvPage;

  const MoviesLoaded({
    this.trendingMovies = const [],
    this.popularMovies = const [],
    this.topRatedMovies = const [],
    this.trendingTv = const [],
    this.hasMoreTrending = true,
    this.hasMorePopular = true,
    this.hasMoreTopRated = true,
    this.hasMoreTv = true,
    this.trendingPage = 1,
    this.popularPage = 1,
    this.topRatedPage = 1,
    this.tvPage = 1,
  });

  MoviesLoaded copyWith({
    List<MovieModel>? trendingMovies,
    List<MovieModel>? popularMovies,
    List<MovieModel>? topRatedMovies,
    List<MovieModel>? trendingTv,
    bool? hasMoreTrending,
    bool? hasMorePopular,
    bool? hasMoreTopRated,
    bool? hasMoreTv,
    int? trendingPage,
    int? popularPage,
    int? topRatedPage,
    int? tvPage,
  }) {
    return MoviesLoaded(
      trendingMovies: trendingMovies ?? this.trendingMovies,
      popularMovies: popularMovies ?? this.popularMovies,
      topRatedMovies: topRatedMovies ?? this.topRatedMovies,
      trendingTv: trendingTv ?? this.trendingTv,
      hasMoreTrending: hasMoreTrending ?? this.hasMoreTrending,
      hasMorePopular: hasMorePopular ?? this.hasMorePopular,
      hasMoreTopRated: hasMoreTopRated ?? this.hasMoreTopRated,
      hasMoreTv: hasMoreTv ?? this.hasMoreTv,
      trendingPage: trendingPage ?? this.trendingPage,
      popularPage: popularPage ?? this.popularPage,
      topRatedPage: topRatedPage ?? this.topRatedPage,
      tvPage: tvPage ?? this.tvPage,
    );
  }

  @override
  List<Object?> get props => [
    trendingMovies,
    popularMovies,
    topRatedMovies,
    trendingTv,
    hasMoreTrending,
    hasMorePopular,
    hasMoreTopRated,
    hasMoreTv,
    trendingPage,
    popularPage,
    topRatedPage,
    tvPage,
  ];
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final MovieRepository movieRepository;

  MoviesBloc({required this.movieRepository}) : super(MoviesInitial()) {
    on<LoadTrendingMovies>(_onLoadTrending);
    on<LoadPopularMovies>(_onLoadPopular);
    on<LoadTopRatedMovies>(_onLoadTopRated);
    on<LoadTrendingTv>(_onLoadTv);
    on<RefreshMovies>(_onRefresh);
  }

  Future<void> _onLoadTrending(
    LoadTrendingMovies event,
    Emitter<MoviesState> emit,
  ) async {
    if (state is! MoviesLoaded) {
      emit(MoviesLoading());
    }

    final result = await movieRepository.getTrendingMovies(page: event.page);
    final currentState = state is MoviesLoaded
        ? state as MoviesLoaded
        : const MoviesLoaded();

    switch (result) {
      case Success<List<MovieModel>>(:final data):
        emit(
          currentState.copyWith(
            trendingMovies: event.page == 1
                ? data
                : [...currentState.trendingMovies, ...data],
            hasMoreTrending: data.isNotEmpty,
            trendingPage: event.page,
          ),
        );
      case Failure<List<MovieModel>>(:final exception):
        emit(MoviesError(exception.toString()));
    }
  }

  Future<void> _onLoadPopular(
    LoadPopularMovies event,
    Emitter<MoviesState> emit,
  ) async {
    final result = await movieRepository.getPopularMovies(page: event.page);
    final currentState = state is MoviesLoaded
        ? state as MoviesLoaded
        : const MoviesLoaded();

    switch (result) {
      case Success<List<MovieModel>>(:final data):
        emit(
          currentState.copyWith(
            popularMovies: event.page == 1
                ? data
                : [...currentState.popularMovies, ...data],
            hasMorePopular: data.isNotEmpty,
            popularPage: event.page,
          ),
        );
      case Failure<List<MovieModel>>(:final exception):
        emit(MoviesError(exception.toString()));
    }
  }

  Future<void> _onLoadTopRated(
    LoadTopRatedMovies event,
    Emitter<MoviesState> emit,
  ) async {
    final result = await movieRepository.getTopRatedMovies(page: event.page);
    final currentState = state is MoviesLoaded
        ? state as MoviesLoaded
        : const MoviesLoaded();

    switch (result) {
      case Success<List<MovieModel>>(:final data):
        emit(
          currentState.copyWith(
            topRatedMovies: event.page == 1
                ? data
                : [...currentState.topRatedMovies, ...data],
            hasMoreTopRated: data.isNotEmpty,
            topRatedPage: event.page,
          ),
        );
      case Failure<List<MovieModel>>(:final exception):
        emit(MoviesError(exception.toString()));
    }
  }

  Future<void> _onLoadTv(
    LoadTrendingTv event,
    Emitter<MoviesState> emit,
  ) async {
    final result = await movieRepository.getTrendingTv(page: event.page);
    final currentState = state is MoviesLoaded
        ? state as MoviesLoaded
        : const MoviesLoaded();

    switch (result) {
      case Success<List<MovieModel>>(:final data):
        emit(
          currentState.copyWith(
            trendingTv: event.page == 1
                ? data
                : [...currentState.trendingTv, ...data],
            hasMoreTv: data.isNotEmpty,
            tvPage: event.page,
          ),
        );
      case Failure<List<MovieModel>>(:final exception):
        emit(MoviesError(exception.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(MoviesLoading());

    final trendingRes = await movieRepository.getTrendingMovies();
    final popularRes = await movieRepository.getPopularMovies();
    final topRatedRes = await movieRepository.getTopRatedMovies();
    final tvRes = await movieRepository.getTrendingTv();

    if (trendingRes is Success<List<MovieModel>> &&
        popularRes is Success<List<MovieModel>> &&
        topRatedRes is Success<List<MovieModel>> &&
        tvRes is Success<List<MovieModel>>) {
      emit(
        MoviesLoaded(
          trendingMovies: trendingRes.data,
          popularMovies: popularRes.data,
          topRatedMovies: topRatedRes.data,
          trendingTv: tvRes.data,
        ),
      );
    } else {
      final errors = <String>[];
      if (trendingRes is Failure) errors.add('Trending: ${(trendingRes as Failure).exception}');
      if (popularRes is Failure) errors.add('Popular: ${(popularRes as Failure).exception}');
      if (topRatedRes is Failure) errors.add('TopRated: ${(topRatedRes as Failure).exception}');
      if (tvRes is Failure) errors.add('TV: ${(tvRes as Failure).exception}');
      
      emit(MoviesError("Failed to refresh: ${errors.join(', ')}"));
    }
  }
}
