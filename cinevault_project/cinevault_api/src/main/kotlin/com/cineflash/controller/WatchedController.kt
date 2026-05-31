package com.cineflash.controller

import com.cineflash.dto.WatchedRequest
import com.cineflash.dto.WatchedResponse
import com.cineflash.entity.WatchedItem
import com.cineflash.repository.WatchedRepository
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/watched")
class WatchedController(private val watchedRepository: WatchedRepository) {

    @GetMapping
    fun getWatchedHistory(@AuthenticationPrincipal userDetails: UserDetails): ResponseEntity<List<WatchedResponse>> {
        val items = watchedRepository.findAll().map { toResponse(it) }
        return ResponseEntity.ok(items)
    }

    @PostMapping
    fun markAsWatched(
        @AuthenticationPrincipal userDetails: UserDetails,
        @Valid @RequestBody request: WatchedRequest
    ): ResponseEntity<WatchedResponse> {
        val item = watchedRepository.save(
            WatchedItem(
                userId = null, // Should get from auth context
                tmdbId = request.tmdbId,
                mediaType = request.mediaType,
                title = request.title,
                posterPath = request.posterPath,
                rating = request.rating
            )
        )
        return ResponseEntity.ok(toResponse(item))
    }

    private fun toResponse(item: WatchedItem): WatchedResponse {
        return WatchedResponse(
            id = item.id,
            tmdbId = item.tmdbId,
            mediaType = item.mediaType,
            title = item.title,
            posterPath = item.posterPath,
            rating = item.rating,
            watchedAt = item.watchedAt
        )
    }
}