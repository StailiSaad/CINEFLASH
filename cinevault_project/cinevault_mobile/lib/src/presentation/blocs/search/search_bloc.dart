import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cineflash/src/data/models/movie_model.dart';
import 'package:cineflash/src/data/repositories/movie_repository.dart';
import 'package:cineflash/src/core/utils/result.dart';
import 'dart:async';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

// States
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<MovieModel> results;
  const SearchSuccess(this.results);
  @override
  List<Object?> get props => [results];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MovieRepository movieRepository;
  Timer? _debounce;

  SearchBloc({required this.movieRepository}) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
  }

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    final result = await movieRepository.searchMovies(event.query);
    
    result.when(
      success: (data) => emit(SearchSuccess(data)),
      failure: (error) => emit(SearchError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
