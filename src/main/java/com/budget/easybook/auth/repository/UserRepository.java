package com.budget.easybook.auth.repository;

import com.budget.easybook.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * Find user by email address
     * @param email user's email
     * @return Optional containing user if found
     */
    Optional<User> findByEmail(String email);
    
    /**
     * Find user by OAuth provider and provider ID
     * @param provider OAuth provider (google, kakao, naver)
     * @param providerId ID from OAuth provider
     * @return Optional containing user if found
     */
    Optional<User> findByProviderAndProviderId(String provider, String providerId);
    
    /**
     * Check if email already exists
     * @param email email to check
     * @return true if exists
     */
    boolean existsByEmail(String email);
    
    /**
     * Check if provider account already exists
     * @param provider OAuth provider
     * @param providerId ID from OAuth provider
     * @return true if exists
     */
    boolean existsByProviderAndProviderId(String provider, String providerId);
}
