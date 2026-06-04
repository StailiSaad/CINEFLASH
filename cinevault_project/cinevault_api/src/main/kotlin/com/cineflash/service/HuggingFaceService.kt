package com.cineflash.service

import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono

@Service
class HuggingFaceService(
    @Qualifier("huggingFaceWebClient") private val webClient: WebClient
) {

    data class SentimentResponse(
        val label: String = "",
        val score: Double = 0.0
    )

    // Sentiment analysis for reviews
    fun analyzeSentiment(text: String): Mono<List<SentimentResponse>> {
        return webClient.post()
            .uri("/models/distilbert-base-uncased-finetuned-sst-2-english")
            .bodyValue(mapOf("inputs" to text))
            .retrieve()
            .bodyToMono()
            .onErrorResume { Mono.just(emptyList()) }
    }

    // Generate embeddings for recommendations
    fun getEmbeddings(text: String): Mono<List<List<Double>>> {
        return webClient.post()
            .uri("/models/sentence-transformers/all-MiniLM-L6-v2")
            .bodyValue(mapOf("inputs" to text))
            .retrieve()
            .bodyToMono()
            .onErrorResume { Mono.just(emptyList()) }
    }
}