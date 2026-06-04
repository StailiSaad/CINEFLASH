package com.cineflash.repository

import com.cineflash.entity.WatchlistItem
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface WatchlistRepository : JpaRepository<WatchlistItem, UUID> {
    
    fun findByUserId(userId: UUID?): List<WatchlistItem>
    
    fun findByUserIdAndTmdbIdAndMediaType(userId: UUID?, tmdbId: Int, mediaType: String): WatchlistItem?
    
    fun existsByUserIdAndTmdbIdAndMediaType(userId: UUID?, tmdbId: Int, mediaType: String): Boolean
    
    fun deleteByUserIdAndTmdbIdAndMediaType(userId: UUID?, tmdbId: Int, mediaType: String)
}