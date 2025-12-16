package com.waste.config;

import com.waste.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final AuthenticationProvider authenticationProvider;



    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> {}) // Enable CORS with default settings (uses CorsConfig)
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll() // Allow login/register
                .requestMatchers("/api/performance/**").permitAll() // Allow testing endpoints
                .requestMatchers("/api/points/**").hasRole("ADMIN") // CRUD only for Admin
                .requestMatchers("/api/employees/**").hasRole("ADMIN") // CRUD only for Admin
                .requestMatchers("/api/vehicles/**").hasRole("ADMIN") // CRUD only for Admin
                .requestMatchers("/api/monitoring/**").permitAll() // Public access as requested
                .requestMatchers("/api/routes/**").hasAnyRole("ADMIN", "MANAGER", "DRIVER")
                .requestMatchers("/api/incidents/**").authenticated() // Fine-grained control with @PreAuthorize
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authenticationProvider(authenticationProvider)
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
