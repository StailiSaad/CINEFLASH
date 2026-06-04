package com.cineflash.exception

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.reactive.function.client.WebClientResponseException
import java.time.Instant

@RestControllerAdvice
class GlobalExceptionHandler {

    @ExceptionHandler(WebClientResponseException::class)
    fun handleWebClientException(ex: WebClientResponseException): ResponseEntity<ErrorResponse> {
        val error = ErrorResponse(
            status = ex.statusCode.value(),
            message = "External API error: ${ex.message}",
            timestamp = Instant.now()
        )
        return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(error)
    }

    @ExceptionHandler(Exception::class)
    fun handleGenericException(ex: Exception): ResponseEntity<ErrorResponse> {
        val error = ErrorResponse(
            status = HttpStatus.INTERNAL_SERVER_ERROR.value(),
            message = ex.message ?: "An unexpected error occurred",
            timestamp = Instant.now()
        )
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error)
    }
}

data class ErrorResponse(
    val status: Int,
    val message: String,
    val timestamp: Instant
)