package com.cineflash.controller

import com.cineflash.dto.AuthRequest
import com.cineflash.dto.TokenResponse
import com.cineflash.dto.UserDto
import com.cineflash.service.AuthService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/auth")
class AuthController(private val authService: AuthService) {

    @PostMapping("/login")
    fun login(@Valid @RequestBody request: AuthRequest): ResponseEntity<TokenResponse> {
        val token = authService.authenticateOrCreate(request)
        return ResponseEntity.ok(token)
    }

    @GetMapping("/me")
    fun getCurrentUser(@AuthenticationPrincipal userDetails: UserDetails): ResponseEntity<UserDto> {
        val user = authService.getCurrentUser(userDetails.username)
        return if (user != null) {
            ResponseEntity.ok(user)
        } else {
            ResponseEntity.notFound().build()
        }
    }
}