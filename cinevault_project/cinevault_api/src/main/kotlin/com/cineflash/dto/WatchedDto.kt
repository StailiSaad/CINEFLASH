package com.cineflash.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import java.util.*

data class WatchedRequest(
    @field:NotNull
    val tmdbId: Int,
    
    @field:NotBlank
    val mediaType: String, // movie or tv
    
    @field:NotBlank
    val title: String,
    
    val posterPath: String? = null,
    val rating: Double? = null
)

data class WatchedResponse(
    val id: UUID?,
    val tmdbId: Int,
    val mediaType: String,
    val title: String,
    val posterPath: String?,
    val rating: Double?,
    val watchedAt: java.time.Instant
)