package com.cineflash.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import java.util.*

data class WatchlistRequest(
    @field:NotNull
    val tmdbId: Int,
    
    @field:NotBlank
    val mediaType: String, // movie or tv
    
    @field:NotBlank
    val title: String,
    
    val posterPath: String? = null,
    val overview: String? = null,
    val releaseDate: String? = null,
    val voteAverage: Double? = null
)

data class WatchlistResponse(
    val id: UUID?,
    val tmdbId: Int,
    val mediaType: String,
    val title: String,
    val posterPath: String?,
    val overview: String?,
    val releaseDate: String?,
    val voteAverage: Double?,
    val addedAt: java.time.Instant
)