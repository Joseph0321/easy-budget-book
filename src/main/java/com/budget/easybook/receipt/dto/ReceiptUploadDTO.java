package com.budget.easybook.receipt.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReceiptUploadDTO {
    private Long receiptId;
    private String imageUrl;
    private String message;
    private boolean processed;
}
