package com.cineflash.security

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.util.*

@Component
class JwtTokenProvider(
    @Value("\${jwt.secret}") private val jwtSecret: String,
    @Value("\${jwt.expiration}") private val jwtExpiration: Long
) {

    fun generateToken(email: String): String {
        val now = Date()
        val expiryDate = Date(now.time + jwtExpiration)

        return Jwts.builder()
            .subject(email)
            .issuedAt(now)
            .expiration(expiryDate)
            .signWith(Keys.hmacShaKeyFor(jwtSecret.toByteArray()))
            .compact()
    }

    fun getEmailFromToken(token: String): String {
        val claims = getAllClaimsFromToken(token)
        return claims.subject
    }

    fun validateToken(token: String): Boolean {
        return try {
            getAllClaimsFromToken(token)
            !isTokenExpired(token)
        } catch (e: Exception) {
            false
        }
    }

    private fun isTokenExpired(token: String): Boolean {
        val expiration = getAllClaimsFromToken(token).expiration
        return expiration.before(Date())
    }

    private fun getAllClaimsFromToken(token: String): Claims {
        return Jwts.parser()
            .verifyWith(Keys.hmacShaKeyFor(jwtSecret.toByteArray()))
            .build()
            .parseSignedClaims(token)
            .payload
    }
}