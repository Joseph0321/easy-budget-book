package com.budget.easybook.category.entity;

import com.budget.easybook.auth.entity.User;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

@Entity
@Table(name = "categories", indexes = {
    @Index(name = "idx_category_user", columnList = "user_id"),
    @Index(name = "idx_category_user_type", columnList = "user_id, type")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Category {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private Long categoryId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;
    
    @NotBlank(message = "Category name is required")
    @Column(name = "name", nullable = false, length = 100)
    private String name;
    
    @NotBlank(message = "Type is required")
    @Pattern(regexp = "income|expense", message = "Type must be 'income' or 'expense'")
    @Column(name = "type", nullable = false, length = 20)
    private String type;
    
    @Column(name = "color", length = 7)
    @Pattern(regexp = "^#[0-9A-Fa-f]{6}$", message = "Color must be valid hex code")
    private String color;
    
    @Column(name = "icon", length = 50)
    private String icon;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
