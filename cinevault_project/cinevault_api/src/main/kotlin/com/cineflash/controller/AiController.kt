package com.cineflash.controller

import com.cineflash.service.HuggingFaceService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/ai")
class AiController(private val huggingFaceService: HuggingFaceService) {

    @PostMapping("/sentiment")
    fun analyzeSentiment(@RequestBody request: SentimentRequest): ResponseEntity<Any> {
        return huggingFaceService.analyzeSentiment(request.text)
            .map { ResponseEntity.ok(it as Any) }
            .block() ?: ResponseEntity.badRequest().build()
    }

    @PostMapping("/recommendations")
    fun getRecommendations(@RequestBody request: RecommendationRequest): ResponseEntity<Any> {
        return huggingFaceService.getRecommendations(request.movies)
            .map { ResponseEntity.ok(mapOf("recommendations" to it) as Any) }
            .block() ?: ResponseEntity.badRequest().build()
    }

    data class SentimentRequest(val text: String)
    data class RecommendationRequest(val movies: List<String>)
}