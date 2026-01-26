package com.budget.easybook.auth.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_provider", columnList = "provider, provider_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;
    
    @Column(name = "email", unique = true, nullable = false, length = 255)
    private String email;
    
    @Column(name = "name", length = 100)
    private String name;
    
    @Column(name = "provider", length = 50)
    private String provider;
    
    @Column(name = "provider_id", length = 255)
    private String providerId;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
