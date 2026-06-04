package com.cineflash.entity

import jakarta.persistence.*
import java.time.Instant
import java.util.*

@Entity
@Table(name = "watchlist_items")
data class WatchlistItem(

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(name = "user_id", nullable = false)
    val userId: UUID? = null,

    @Column(name = "tmdb_id", nullable = false)
    val tmdbId: Int = 0,

    @Column(name = "media_type", nullable = false, length = 10)
    val mediaType: String = "", // movie or tv

    @Column(nullable = false)
    val title: String = "",

    @Column(name = "poster_path")
    val posterPath: String? = null,

    @Column(columnDefinition = "TEXT")
    val overview: String? = null,

    @Column(name = "release_date")
    val releaseDate: String? = null,

    @Column(name = "vote_average")
    val voteAverage: Double? = null,

    @Column(name = "added_at")
    val addedAt: Instant = Instant.now(),

    @Column(name = "updated_at")
    val updatedAt: Instant = Instant.now()
)