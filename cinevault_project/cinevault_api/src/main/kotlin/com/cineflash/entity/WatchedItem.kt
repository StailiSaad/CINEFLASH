package com.cineflash.entity

import jakarta.persistence.*
import java.time.Instant
import java.util.*

@Entity
@Table(name = "watched_items")
data class WatchedItem(

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

    @Column
    val rating: Double? = null,

    @Column(name = "watched_at")
    val watchedAt: Instant = Instant.now(),

    @Column(name = "updated_at")
    val updatedAt: Instant = Instant.now()
)