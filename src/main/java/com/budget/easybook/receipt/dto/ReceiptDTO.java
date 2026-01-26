package com.budget.easybook.receipt.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReceiptDTO {
    private Long receiptId;
    private Long userId;
    private String imageUrl;
    private String originalFilename;
    private ReceiptOCRResult ocrResult;
    private LocalDateTime processedAt;
    private boolean hasLinkedExpenses; // Whether any expenses are linked
}
