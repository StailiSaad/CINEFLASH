package com.cineflash.dto

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank

data class AuthRequest(
    @field:NotBlank
    @field:Email
    val email: String,
    
    val displayName: String? = null,
    val avatarUrl: String? = null,
    val googleId: String? = null
)

data class TokenResponse(
    val accessToken: String,
    val refreshToken: String? = null,
    val tokenType: String = "Bearer",
    val expiresIn: Long = 86400
)

data class UserDto(
    val id: java.util.UUID?,
    val email: String,
    val displayName: String?,
    val avatarUrl: String?,
    val createdAt: java.time.Instant
)