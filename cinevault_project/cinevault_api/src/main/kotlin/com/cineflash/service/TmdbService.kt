package com.cineflash.service

import com.cineflash.dto.*
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.bodyToMono
import reactor.core.publisher.Mono

@Service
class TmdbService(
    @Qualifier("tmdbWebClient") private val webClient: WebClient,
    private val objectMapper: ObjectMapper
) {

    fun getTrendingMovies(page: Int = 1): Mono<TmdbMovieResponse> {
        return webClient.get()
            .uri("/trending/movie/week?page=$page")
            .retrieve()
            .bodyToMono<String>()
            .map { parseMovieResponse(it) }
    }

    fun getTopRatedMovies(page: Int = 1): Mono<TmdbMovieResponse> {
        return webClient.get()
            .uri("/movie/top_rated?page=$page")
            .retrieve()
            .bodyToMono<String>()
            .map { parseMovieResponse(it) }
    }

    fun getPopularMovies(page: Int = 1): Mono<TmdbMovieResponse> {
        return webClient.get()
            .uri("/movie/popular?page=$page")
            .retrieve()
            .bodyToMono<String>()
            .map { parseMovieResponse(it) }
    }

    fun getMovieDetails(movieId: Int): Mono<TmdbMovieDetail> {
        return webClient.get()
            .uri("/movie/$movieId?append_to_response=videos,credits,watch/providers")
            .retrieve()
            .bodyToMono(TmdbMovieDetail::class.java)
    }

    fun searchMovies(query: String, page: Int = 1): Mono<TmdbMovieResponse> {
        return webClient.get()
            .uri("/search/multi?query=$query&page=$page&include_adult=false")
            .retrieve()
            .bodyToMono<String>()
            .map { parseMovieResponse(it) }
    }

    fun getTrendingTv(page: Int = 1): Mono<TmdbMovieResponse> {
        return webClient.get()
            .uri("/trending/tv/week?page=$page")
            .retrieve()
            .bodyToMono<String>()
            .map { parseMovieResponse(it) }
    }

    fun getPopularTv(page: Int = 1): Mono<TmdbMovieResponse> {
        return webClient.get()
            .uri("/tv/popular?page=$page")
            .retrieve()
            .bodyToMono<String>()
            .map { parseMovieResponse(it) }
    }

    private fun parseMovieResponse(json: String): TmdbMovieResponse {
        val tree = objectMapper.readTree(json)
        val results = tree.get("results")?.map { node ->
            TmdbMovie(
                id = node.get("id")?.asInt() ?: 0,
                title = node.get("title")?.asText() ?: node.get("name")?.asText(),
                overview = node.get("overview")?.asText(),
                posterPath = node.get("poster_path")?.asText(),
                backdropPath = node.get("backdrop_path")?.asText(),
                releaseDate = node.get("release_date")?.asText() ?: node.get("first_air_date")?.asText(),
                voteAverage = node.get("vote_average")?.asDouble(),
                voteCount = node.get("vote_count")?.asInt(),
                mediaType = node.get("media_type")?.asText()
            )
        } ?: emptyList()

        return TmdbMovieResponse(
            page = tree.get("page")?.asInt() ?: 1,
            results = results,
            totalPages = tree.get("total_pages")?.asInt() ?: 1,
            totalResults = tree.get("total_results")?.asInt() ?: 0
        )
    }
}