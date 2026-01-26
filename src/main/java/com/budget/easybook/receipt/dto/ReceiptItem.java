package com.budget.easybook.receipt.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReceiptItem {
    private String itemName;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal amount;
}
