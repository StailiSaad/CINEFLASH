package com.cineflash.entity

import jakarta.persistence.*
import java.time.Instant
import java.util.*

@Entity
@Table(name = "users")
data class User(

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false, unique = true)
    val email: String = "",

    @Column(name = "display_name")
    val displayName: String? = null,

    @Column(name = "avatar_url")
    val avatarUrl: String? = null,

    @Column(name = "google_id", unique = true)
    val googleId: String? = null,

    @Column(name = "created_at")
    val createdAt: Instant = Instant.now(),

    @Column(name = "updated_at")
    val updatedAt: Instant = Instant.now()
)