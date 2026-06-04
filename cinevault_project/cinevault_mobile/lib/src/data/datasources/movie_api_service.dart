import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import '../../core/constants/api_constants.dart';

class MovieApiService {
  final http.Client _client;

  MovieApiService(this._client);

  Future<MovieListResponse> _get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: queryParams);
    final response = await _client.get(uri);
    return MovieListResponse.fromJson(jsonDecode(response.body));
  }

  Future<MovieListResponse> getTrendingMovies({int page = 1}) async {
    return _get(ApiConstants.moviesTrending, queryParams: {'page': '$page'});
  }

  Future<MovieListResponse> getPopularMovies({int page = 1}) async {
    return _get(ApiConstants.moviesPopular, queryParams: {'page': '$page'});
  }

  Future<MovieListResponse> getTopRatedMovies({int page = 1}) async {
    return _get(ApiConstants.moviesTopRated, queryParams: {'page': '$page'});
  }

  Future<MovieDetailModel> getMovieDetails(int movieId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.movieDetails}/$movieId');
    final response = await _client.get(uri);
    return MovieDetailModel.fromJson(jsonDecode(response.body));
  }

  Future<MovieListResponse> searchMovies(String query, {int page = 1}) async {
    try {
      final uri = Uri.parse(ApiConstants.multiSearch).replace(queryParameters: {
        'api_key': ApiConstants.tmdbApiKey,
        'query': query,
        'page': '$page',
      });
      final response = await _client.get(uri);
      return MovieListResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return _get(ApiConstants.moviesSearch, queryParams: {'query': query, 'page': '$page'});
    }
  }

  Future<MovieListResponse> getTrendingTv({int page = 1}) async {
    return _get(ApiConstants.tvTrending, queryParams: {'page': '$page'});
  }

  Future<MovieListResponse> getPopularTv({int page = 1}) async {
    return _get(ApiConstants.tvPopular, queryParams: {'page': '$page'});
  }
}
