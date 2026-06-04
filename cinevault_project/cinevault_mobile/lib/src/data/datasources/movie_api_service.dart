import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../../core/constants/api_constants.dart';

class MovieApiService {
  final Dio _dio;

  MovieApiService(this._dio);

  Future<MovieListResponse> getTrendingMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.moviesTrending,
      queryParameters: {'page': page},
    );
    return MovieListResponse.fromJson(response.data);
  }

  Future<MovieListResponse> getPopularMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.moviesPopular,
      queryParameters: {'page': page},
    );
    return MovieListResponse.fromJson(response.data);
  }

  Future<MovieListResponse> getTopRatedMovies({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.moviesTopRated,
      queryParameters: {'page': page},
    );
    return MovieListResponse.fromJson(response.data);
  }

  Future<MovieDetailModel> getMovieDetails(int movieId) async {
    final response = await _dio.get('${ApiConstants.movieDetails}/$movieId');
    return MovieDetailModel.fromJson(response.data);
  }

  Future<MovieListResponse> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.multiSearch,
        queryParameters: {
          'api_key': ApiConstants.tmdbApiKey,
          'query': query, 
          'page': page
        },
      );
      return MovieListResponse.fromJson(response.data);
    } catch (e) {
      // Fallback to basic movie search if multi fails
      final response = await _dio.get(
        ApiConstants.moviesSearch,
        queryParameters: {'query': query, 'page': page},
      );
      return MovieListResponse.fromJson(response.data);
    }
  }

  Future<MovieListResponse> getTrendingTv({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.tvTrending,
      queryParameters: {'page': page},
    );
    return MovieListResponse.fromJson(response.data);
  }

  Future<MovieListResponse> getPopularTv({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.tvPopular,
      queryParameters: {'page': page},
    );
    return MovieListResponse.fromJson(response.data);
  }
}
