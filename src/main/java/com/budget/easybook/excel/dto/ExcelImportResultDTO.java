package com.budget.easybook.excel.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExcelImportResultDTO {
    private int totalRows;
    private int successCount;
    private int failureCount;
    private int duplicateCount;
    private List<String> errors = new ArrayList<>();
    
    public void addError(String error) {
        this.errors.add(error);
    }
}
