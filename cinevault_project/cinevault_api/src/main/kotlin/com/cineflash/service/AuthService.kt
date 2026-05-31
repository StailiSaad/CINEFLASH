package com.cineflash.service

import com.cineflash.dto.AuthRequest
import com.cineflash.dto.TokenResponse
import com.cineflash.dto.UserDto
import com.cineflash.entity.User
import com.cineflash.repository.UserRepository
import com.cineflash.security.JwtTokenProvider
import org.springframework.stereotype.Service
import java.util.*

@Service
class AuthService(
    private val userRepository: UserRepository,
    private val jwtTokenProvider: JwtTokenProvider
) {

    fun authenticateOrCreate(request: AuthRequest): TokenResponse {
        var user = request.googleId?.let {
            userRepository.findByGoogleId(it)
        } ?: userRepository.findByEmail(request.email)

        if (user == null) {
            user = userRepository.save(
                User(
                    email = request.email,
                    displayName = request.displayName,
                    avatarUrl = request.avatarUrl,
                    googleId = request.googleId
                )
            )
        }

        val token = jwtTokenProvider.generateToken(user.email)
        
        return TokenResponse(
            accessToken = token,
            tokenType = "Bearer",
            expiresIn = 86400
        )
    }

    fun getCurrentUser(email: String): UserDto? {
        return userRepository.findByEmail(email)?.let { toDto(it) }
    }

    private fun toDto(user: User): UserDto {
        return UserDto(
            id = user.id,
            email = user.email,
            displayName = user.displayName,
            avatarUrl = user.avatarUrl,
            createdAt = user.createdAt
        )
    }
}