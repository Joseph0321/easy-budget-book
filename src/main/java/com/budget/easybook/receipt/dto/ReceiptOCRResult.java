package com.budget.easybook.receipt.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReceiptOCRResult {
    private String storeName;
    private LocalDate date;
    private List<ReceiptItem> items;
    private BigDecimal totalAmount;
    private String currency;
}
