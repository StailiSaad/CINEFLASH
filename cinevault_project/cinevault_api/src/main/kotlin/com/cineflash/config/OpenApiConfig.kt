package com.cineflash.config

import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.info.Contact
import io.swagger.v3.oas.models.info.License
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig {

    @Bean
    fun openAPI(): OpenAPI {
        return OpenAPI()
            .info(
                Info()
                    .title("CineFlash API")
                    .description("Professional Movie & TV Watchlist API")
                    .version("1.0.0")
                    .contact(
                        Contact()
                            .name("CineFlash Team")
                            .email("support@cineflash.app")
                    )
                    .license(
                        License()
                            .name("MIT License")
                    )
            )
    }
}