package com.cineflash

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class CineFlashApplication

fun main(args: Array<String>) {
    runApplication<CineFlashApplication>(*args)
}