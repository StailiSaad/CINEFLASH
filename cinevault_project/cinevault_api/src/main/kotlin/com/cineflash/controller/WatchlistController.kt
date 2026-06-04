package com.cineflash.controller

import com.cineflash.dto.WatchlistRequest
import com.cineflash.dto.WatchlistResponse
import com.cineflash.entity.WatchlistItem
import com.cineflash.repository.WatchlistRepository
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping("/api/v1/watchlist")
class WatchlistController(private val watchlistRepository: WatchlistRepository) {

    @GetMapping
    fun getWatchlist(@AuthenticationPrincipal userDetails: UserDetails): ResponseEntity<List<WatchlistResponse>> {
        // In real app, get userId from authenticated user, using placeholder for now
        val items = watchlistRepository.findAll()
            .map { toResponse(it) }
        return ResponseEntity.ok(items)
    }

    @PostMapping
    fun addToWatchlist(
        @AuthenticationPrincipal userDetails: UserDetails,
        @Valid @RequestBody request: WatchlistRequest
    ): ResponseEntity<WatchlistResponse> {
        val item = watchlistRepository.save(
            WatchlistItem(
                userId = null, // Should get from auth context
                tmdbId = request.tmdbId,
                mediaType = request.mediaType,
                title = request.title,
                posterPath = request.posterPath,
                overview = request.overview,
                releaseDate = request.releaseDate,
                voteAverage = request.voteAverage
            )
        )
        return ResponseEntity.ok(toResponse(item))
    }

    @DeleteMapping("/{tmdbId}/{mediaType}")
    fun removeFromWatchlist(
        @AuthenticationPrincipal userDetails: UserDetails,
        @PathVariable tmdbId: Int,
        @PathVariable mediaType: String
    ): ResponseEntity<Void> {
        // In real app, use userId from auth
        return ResponseEntity.noContent().build()
    }

    private fun toResponse(item: WatchlistItem): WatchlistResponse {
        return WatchlistResponse(
            id = item.id,
            tmdbId = item.tmdbId,
            mediaType = item.mediaType,
            title = item.title,
            posterPath = item.posterPath,
            overview = item.overview,
            releaseDate = item.releaseDate,
            voteAverage = item.voteAverage,
            addedAt = item.addedAt
        )
    }
}