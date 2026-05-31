package com.cineflash.controller

import com.cineflash.dto.TmdbMovieResponse
import com.cineflash.service.TmdbService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/tv")
class TvController(private val tmdbService: TmdbService) {

    @GetMapping("/trending")
    fun getTrendingTv(@RequestParam(defaultValue = "1") page: Int): ResponseEntity<TmdbMovieResponse> {
        return tmdbService.getTrendingTv(page)
            .map { ResponseEntity.ok(it) }
            .block() ?: ResponseEntity.notFound().build()
    }

    @GetMapping("/popular")
    fun getPopularTv(@RequestParam(defaultValue = "1") page: Int): ResponseEntity<TmdbMovieResponse> {
        return tmdbService.getPopularTv(page)
            .map { ResponseEntity.ok(it) }
            .block() ?: ResponseEntity.notFound().build()
    }
}