
import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../datasources/movie_api_service.dart';
import '../database/app_database.dart';
import 'package:cineflash/src/core/utils/result.dart';
import 'package:cineflash/src/core/constants/api_constants.dart';

abstract class MovieRepository {
  Future<Result<List<MovieModel>>> getTrendingMovies({int page = 1});
  Future<Result<List<MovieModel>>> getPopularMovies({int page = 1});
  Future<Result<List<MovieModel>>> getTopRatedMovies({int page = 1});
  Future<Result<MovieDetailModel>> getMovieDetails(int movieId);
  Future<Result<MovieDetailModel>> getTvDetails(int tvId);
  Future<Result<List<MovieModel>>> getTrendingTv({int page = 1});
  Future<Result<List<MovieModel>>> searchMovies(String query, {int page = 1});
}

class MovieRepositoryImpl implements MovieRepository {
  final MovieApiService _apiService;
  final AppDatabase _database;
  final Dio _directDio = Dio();

  MovieRepositoryImpl(this._apiService, this._database);

  @override
  Future<Result<List<MovieModel>>> getTrendingMovies({int page = 1}) async {
    try {
      final res = await _directDio.get(
        '${ApiConstants.tmdbBaseUrl}/trending/movie/week',
        queryParameters: {'api_key': ApiConstants.tmdbApiKey, 'page': page},
      );
      final list = MovieListResponse.fromJson(res.data).results;
      final movies = list.map((m) => m.copyWith(mediaType: 'movie')).toList();
      
      // Cache locally
      await _cacheMovies(movies, trending: true);
      
      return Result.success(movies);
    } catch (e) {
      try {
        final localData = await _database.getTrendingMovies();
        if (localData.isNotEmpty) {
          return Result.success(localData.map(_mapLocalToModel).toList());
        }
        return Result.failure(Exception('Failed to load Trending Movies. Network error: $e'));
      } catch (err) {
        return Result.failure(Exception('Failed to load Trending Movies. Network error: $e, DB error: $err'));
      }
    }
  }

  @override
  Future<Result<List<MovieModel>>> getPopularMovies({int page = 1}) async {
    try {
      final res = await _directDio.get(
        '${ApiConstants.tmdbBaseUrl}/movie/popular',
        queryParameters: {'api_key': ApiConstants.tmdbApiKey, 'page': page},
      );
      final list = MovieListResponse.fromJson(res.data).results;
      final movies = list.map((m) => m.copyWith(mediaType: 'movie')).toList();
      
      // Cache locally
      await _cacheMovies(movies, popular: true);
      
      return Result.success(movies);
    } catch (e) {
      try {
        final localData = await _database.getPopularMovies();
        if (localData.isNotEmpty) {
          return Result.success(localData.map(_mapLocalToModel).toList());
        }
        return Result.failure(Exception('Failed to load Popular Movies: $e'));
      } catch (err) {
        return Result.failure(Exception('Failed to load Popular Movies: $e, DB error: $err'));
      }
    }
  }

  @override
  Future<Result<List<MovieModel>>> getTopRatedMovies({int page = 1}) async {
    try {
      final res = await _directDio.get(
        '${ApiConstants.tmdbBaseUrl}/movie/top_rated',
        queryParameters: {'api_key': ApiConstants.tmdbApiKey, 'page': page},
      );
      final list = MovieListResponse.fromJson(res.data).results;
      final movies = list.map((m) => m.copyWith(mediaType: 'movie')).toList();
      
      // Cache locally
      await _cacheMovies(movies, topRated: true);
      
      return Result.success(movies);
    } catch (e) {
      try {
        final localData = await _database.getTopRatedMovies();
        if (localData.isNotEmpty) {
          return Result.success(localData.map(_mapLocalToModel).toList());
        }
        return Result.failure(Exception('Failed to load Top Rated Movies: $e'));
      } catch (err) {
        return Result.failure(Exception('Failed to load Top Rated Movies: $e, DB error: $err'));
      }
    }
  }

  @override
  Future<Result<MovieDetailModel>> getMovieDetails(int movieId) async {
    try {
      final res = await _directDio.get(
        '${ApiConstants.tmdbBaseUrl}/movie/$movieId',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'append_to_response': 'videos,credits',
        },
      );
      final detail = MovieDetailModel.fromJson(res.data);
      return Result.success(detail.copyWith(mediaType: 'movie'));
    } catch (e) {
      return Result.failure(Exception('Movie info failed. ID: $movieId'));
    }
  }

  @override
  Future<Result<MovieDetailModel>> getTvDetails(int tvId) async {
    try {
      final res = await _directDio.get(
        '${ApiConstants.tmdbBaseUrl}/tv/$tvId',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'append_to_response': 'videos,credits',
        },
      );
      final detail = MovieDetailModel.fromJson(res.data);
      return Result.success(detail.copyWith(mediaType: 'tv'));
    } catch (e) {
      return Result.failure(Exception('TV info failed. ID: $tvId'));
    }
  }

  @override
  Future<Result<List<MovieModel>>> getTrendingTv({int page = 1}) async {
    try {
      final res = await _directDio.get(
        '${ApiConstants.tmdbBaseUrl}/trending/tv/week',
        queryParameters: {'api_key': ApiConstants.tmdbApiKey, 'page': page},
      );
      final list = MovieListResponse.fromJson(res.data).results;
      final tvList = list.map((m) => m.copyWith(mediaType: 'tv')).toList();
      
      // Cache locally
      await _cacheMovies(tvList, trending: true);
      
      return Result.success(tvList);
    } catch (e) {
      try {
        final localData = await _database.getTrendingTv();
        if (localData.isNotEmpty) {
          return Result.success(localData.map(_mapLocalToModel).toList());
        }
        return Result.failure(Exception('Failed to load Trending TV: $e'));
      } catch (err) {
        return Result.failure(Exception('Failed to load Trending TV: $e, DB error: $err'));
      }
    }
  }

  @override
  Future<Result<List<MovieModel>>> searchMovies(String query, {int page = 1}) async {
    try {
      final res = await _directDio.get(
        '${ApiConstants.tmdbBaseUrl}/search/multi',
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'query': query,
          'page': page,
        },
      );
      final list = MovieListResponse.fromJson(res.data).results;
      final filtered = list
          .where((m) => m.mediaType != 'person')
          .map((m) => m.copyWith(mediaType: m.mediaType ?? 'movie'))
          .toList();
      return Result.success(filtered);
    } catch (e) {
      return Result.failure(Exception('Search failed.'));
    }
  }

  Future<void> _cacheMovies(List<MovieModel> movies, {bool trending = false, bool popular = false, bool topRated = false}) async {
    final companions = movies.map((m) => LocalMovy(
      id: m.id,
      title: m.displayTitle,
      overview: m.overview,
      posterPath: m.posterPath,
      backdropPath: m.backdropPath,
      releaseDate: m.displayDate,
      voteAverage: m.voteAverage ?? 0.0,
      mediaType: m.mediaType ?? 'movie',
      cachedAt: DateTime.now(),
    )).toList();
    await _database.cacheMovies(companions, trending: trending, popular: popular, topRated: topRated);
  }

  MovieModel _mapLocalToModel(LocalMovy local) {
    return MovieModel(
      id: local.id,
      title: local.title,
      overview: local.overview,
      posterPath: local.posterPath,
      backdropPath: local.backdropPath,
      releaseDate: local.releaseDate,
      voteAverage: local.voteAverage,
      mediaType: local.mediaType,
    );
  }
}
