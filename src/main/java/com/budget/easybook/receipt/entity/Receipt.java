package com.budget.easybook.receipt.entity;

import com.budget.easybook.auth.entity.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

@Entity
@Table(name = "receipts", indexes = {
    @Index(name = "idx_receipt_user", columnList = "user_id"),
    @Index(name = "idx_receipt_processed", columnList = "processed_at")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Receipt {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "receipt_id")
    private Long receiptId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    private User user;
    
    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;
    
    @Column(name = "original_filename", length = 255)
    private String originalFilename;
    
    @Column(name = "ocr_result", columnDefinition = "TEXT")
    private String ocrResult;
    
    @CreationTimestamp
    @Column(name = "processed_at", nullable = false)
    private LocalDateTime processedAt;
}
