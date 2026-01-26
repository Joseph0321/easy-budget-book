package com.budget.easybook.expense.entity;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.category.entity.Category;
import com.budget.easybook.receipt.entity.Receipt;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "expenses", indexes = {
    @Index(name = "idx_expense_user", columnList = "user_id"),
    @Index(name = "idx_expense_user_date", columnList = "user_id, expense_date"),
    @Index(name = "idx_expense_category", columnList = "category_id")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Expense {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "expense_id")
    private Long expenseId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receipt_id")
    private Receipt receipt;
    
    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    @Column(name = "amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "merchant_name", length = 200)
    private String merchantName;
    
    @Column(name = "memo", columnDefinition = "TEXT")
    private String memo;
    
    @Column(name = "payment_method", length = 50)
    private String paymentMethod;
    
    @Column(name = "receipt_image_path", length = 500)
    private String receiptImagePath;
    
    @NotNull(message = "Expense date is required")
    @Column(name = "expense_date", nullable = false)
    private LocalDate expenseDate;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
