import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class MovieModel {
  final int id;
  final String? title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final String? mediaType;
  final List<int>? genreIds;

  MovieModel({
    required this.id,
    this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.mediaType,
    this.genreIds,
  });

  String get displayTitle => title ?? 'Unknown';
  String get displayDate => releaseDate ?? '';

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final voteAvg = json['vote_average'] ?? json['voteAverage'] ?? json['rating'];
    final voteCnt = json['vote_count'] ?? json['voteCount'];
    final genres = json['genre_ids'] ?? json['genreIds'];
    
    String? poster = (json['poster_path'] ?? json['posterPath'])?.toString();
    if (poster != null && poster.isNotEmpty && !poster.startsWith('/')) {
      poster = '/$poster';
    }
    
    String? backdrop = (json['backdrop_path'] ?? json['backdropPath'])?.toString();
    if (backdrop != null && backdrop.isNotEmpty && !backdrop.startsWith('/')) {
      backdrop = '/$backdrop';
    }

    return MovieModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      title: (json['title'] ?? json['name'] ?? json['original_title'])?.toString(),
      overview: (json['overview'] ?? json['description'] ?? json['summary'])?.toString(),
      posterPath: poster,
      backdropPath: backdrop,
      releaseDate: (json['release_date'] ?? json['releaseDate'] ?? json['first_air_date'] ?? json['firstAirDate'])?.toString(),
      voteAverage: voteAvg is num ? voteAvg.toDouble() : 0.0,
      voteCount: voteCnt is num ? voteCnt.toInt() : 0,
      mediaType: (json['media_type'] ?? json['mediaType'])?.toString(),
      genreIds: genres is List 
          ? genres.map((e) => e is int ? e : 0).toList().cast<int>() 
          : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'media_type': mediaType,
      'genre_ids': genreIds,
    };
  }

  MovieModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    String? mediaType,
    List<int>? genreIds,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      mediaType: mediaType ?? this.mediaType,
      genreIds: genreIds ?? this.genreIds,
    );
  }
}

class MovieListResponse {
  final int page;
  final List<MovieModel> results;
  final int totalPages;
  final int totalResults;

  MovieListResponse({
    this.page = 1,
    this.results = const [],
    this.totalPages = 1,
    this.totalResults = 0,
  });

  factory MovieListResponse.fromJson(Map<String, dynamic> json) {
    return MovieListResponse(
      page: json['page'] is int ? json['page'] : 1,
      results: json['results'] is List 
          ? (json['results'] as List).map((e) => MovieModel.fromJson(e as Map<String, dynamic>)).toList() 
          : [],
      totalPages: json['total_pages'] is int ? json['total_pages'] : 1,
      totalResults: json['total_results'] is int ? json['total_results'] : 0,
    );
  }
}

class MovieDetailModel extends MovieModel {
  final String? tagline;
  final int? runtime;
  final List<GenreModel>? genres;
  final String? trailerKey;
  final List<CastModel>? cast;

  MovieDetailModel({
    required super.id,
    super.title,
    super.overview,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    super.voteAverage,
    super.voteCount,
    super.mediaType,
    super.genreIds,
    this.tagline,
    this.runtime,
    this.genres,
    this.trailerKey,
    this.cast,
  });

  @override
  MovieDetailModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    String? mediaType,
    List<int>? genreIds,
    String? tagline,
    int? runtime,
    List<GenreModel>? genres,
    String? trailerKey,
    List<CastModel>? cast,
  }) {
    return MovieDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      mediaType: mediaType ?? this.mediaType,
      genreIds: genreIds ?? this.genreIds,
      tagline: tagline ?? this.tagline,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      trailerKey: trailerKey ?? this.trailerKey,
      cast: cast ?? this.cast,
    );
  }

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    final movie = MovieModel.fromJson(json);
    
    // Find the YouTube trailer
    String? trailerKey;
    if (json['videos'] != null && json['videos']['results'] != null) {
      final videos = json['videos']['results'] as List;
      final trailer = videos.firstWhere(
        (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube' && v['official'] == true,
        orElse: () => videos.firstWhere(
          (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
          orElse: () => videos.firstWhere(
            (v) => v['site'] == 'YouTube',
            orElse: () => null,
          ),
        ),
      );
      if (trailer != null) {
        trailerKey = trailer['key']?.toString();
      }
    }

    // Find the Cast
    List<CastModel>? cast;
    if (json['credits'] != null && json['credits']['cast'] != null) {
      final castList = json['credits']['cast'] as List;
      cast = castList.take(10).map((e) => CastModel.fromJson(e as Map<String, dynamic>)).toList();
    }

    return MovieDetailModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      mediaType: movie.mediaType,
      genreIds: movie.genreIds,
      tagline: json['tagline']?.toString(),
      runtime: json['runtime'] is num ? (json['runtime'] as num).toInt() : null,
      genres: json['genres'] is List 
          ? (json['genres'] as List).map((e) => GenreModel.fromJson(e as Map<String, dynamic>)).toList() 
          : null,
      trailerKey: trailerKey,
      cast: cast,
    );
  }
}

class GenreModel {
  final int id;
  final String? name;

  GenreModel({required this.id, this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString(),
    );
  }
}

class CastModel {
  final int id;
  final String? name;
  final String? character;
  final String? profilePath;

  CastModel({required this.id, this.name, this.character, this.profilePath});

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      id: json['id'] is int ? json['id'] : 0,
      name: (json['name'] ?? json['original_name'])?.toString(),
      character: json['character']?.toString(),
      profilePath: json['profile_path']?.toString(),
    );
  }
}