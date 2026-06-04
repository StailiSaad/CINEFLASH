package com.cineflash.dto

// TMDB API response DTOs
data class TmdbMovieResponse(
    val page: Int,
    val results: List<TmdbMovie>,
    val totalPages: Int,
    val totalResults: Int
)

data class TmdbMovie(
    val id: Int,
    val title: String? = null,
    val name: String? = null, // for TV
    val originalTitle: String? = null,
    val overview: String? = null,
    val posterPath: String? = null,
    val backdropPath: String? = null,
    val releaseDate: String? = null,
    val firstAirDate: String? = null,
    val voteAverage: Double? = null,
    val voteCount: Int? = null,
    val genreIds: List<Int>? = null,
    val mediaType: String? = null
)

data class TmdbMovieDetail(
    val id: Int,
    val title: String? = null,
    val name: String? = null,
    val overview: String? = null,
    val tagline: String? = null,
    val posterPath: String? = null,
    val backdropPath: String? = null,
    val releaseDate: String? = null,
    val firstAirDate: String? = null,
    val runtime: Int? = null,
    val voteAverage: Double? = null,
    val genres: List<TmdbGenre>? = null,
    val videos: TmdbVideos? = null,
    val credits: TmdbCredits? = null
)

data class TmdbGenre(
    val id: Int,
    val name: String
)

data class TmdbVideos(
    val results: List<TmdbVideo>? = null
)

data class TmdbVideo(
    val id: String,
    val name: String? = null,
    val site: String? = null, // YouTube
    val key: String? = null, // video ID
    val type: String? = null
)

data class TmdbCredits(
    val cast: List<TmdbCast>? = null,
    val crew: List<TmdbCrew>? = null
)

data class TmdbCast(
    val id: Int,
    val name: String? = null,
    val character: String? = null,
    val profilePath: String? = null,
    val order: Int? = null
)

data class TmdbCrew(
    val id: Int,
    val name: String? = null,
    val job: String? = null,
    val department: String? = null,
    val profilePath: String? = null
)

data class TmdbWatchProviders(
    val results: Map<String, TmdbCountryProviders>? = null
)

data class TmdbCountryProviders(
    val link: String? = null,
    val flatrate: List<TmdbProvider>? = null,
    val rent: List<TmdbProvider>? = null,
    val buy: List<TmdbProvider>? = null
)

data class TmdbProvider(
    val logoPath: String? = null,
    val providerId: Int? = null,
    val providerName: String? = null,
    val displayPriority: Int? = null
)