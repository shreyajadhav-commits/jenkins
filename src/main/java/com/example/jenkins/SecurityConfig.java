package com.example.jenkins; // Ensure this matches your main app package

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Required to allow POST/PUT requests
            .authorizeHttpRequests(auth -> auth
                .anyRequest().permitAll() // This is what actually "disables" the login requirement
            )
            .headers(headers -> headers.frameOptions(frame -> frame.sameOrigin())); // Fixes H2 Console
            
        return http.build();
    }
}