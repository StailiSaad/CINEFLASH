package com.cineflash.repository

import com.cineflash.entity.WatchedItem
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface WatchedRepository : JpaRepository<WatchedItem, UUID> {
    
    fun findByUserId(userId: UUID?): List<WatchedItem>
    
    fun findByUserIdAndTmdbIdAndMediaType(userId: UUID?, tmdbId: Int, mediaType: String): WatchedItem?
    
    fun existsByUserIdAndTmdbIdAndMediaType(userId: UUID?, tmdbId: Int, mediaType: String): Boolean
}