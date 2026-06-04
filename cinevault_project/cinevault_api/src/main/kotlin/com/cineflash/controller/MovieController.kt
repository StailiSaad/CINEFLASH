package com.cineflash.controller

import com.cineflash.dto.TmdbMovieResponse
import com.cineflash.service.TmdbService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/movies")
class MovieController(private val tmdbService: TmdbService) {

    @GetMapping("/trending")
    fun getTrendingMovies(@RequestParam(defaultValue = "1") page: Int): ResponseEntity<TmdbMovieResponse> {
        return tmdbService.getTrendingMovies(page)
            .map { ResponseEntity.ok(it) }
            .block() ?: ResponseEntity.notFound().build()
    }

    @GetMapping("/top-rated")
    fun getTopRatedMovies(@RequestParam(defaultValue = "1") page: Int): ResponseEntity<TmdbMovieResponse> {
        return tmdbService.getTopRatedMovies(page)
            .map { ResponseEntity.ok(it) }
            .block() ?: ResponseEntity.notFound().build()
    }

    @GetMapping("/popular")
    fun getPopularMovies(@RequestParam(defaultValue = "1") page: Int): ResponseEntity<TmdbMovieResponse> {
        return tmdbService.getPopularMovies(page)
            .map { ResponseEntity.ok(it) }
            .block() ?: ResponseEntity.notFound().build()
    }

    @GetMapping("/{movieId}")
    fun getMovieDetails(@PathVariable movieId: Int): ResponseEntity<Any> {
        return tmdbService.getMovieDetails(movieId)
            .map { ResponseEntity.ok(it as Any) }
            .block() ?: ResponseEntity.notFound().build()
    }

    @GetMapping("/search")
    fun searchMovies(@RequestParam query: String, @RequestParam(defaultValue = "1") page: Int): ResponseEntity<TmdbMovieResponse> {
        return tmdbService.searchMovies(query, page)
            .map { ResponseEntity.ok(it) }
            .block() ?: ResponseEntity.notFound().build()
    }
}