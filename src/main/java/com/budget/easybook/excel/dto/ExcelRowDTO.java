package com.budget.easybook.excel.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExcelRowDTO {
    private LocalDate date;
    private String type;
    private String categoryName;
    private BigDecimal amount;
    private String paymentMethod;
    private String memo;
    private int rowNumber;
}
