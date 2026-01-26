package com.budget.easybook.receipt.dto;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.receipt.entity.Receipt;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

public class ReceiptMapper {
    
    private static final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule());
    
    public static ReceiptDTO toDTO(Receipt receipt, boolean hasLinkedExpenses) {
        if (receipt == null) return null;
        
        ReceiptDTO dto = new ReceiptDTO();
        dto.setReceiptId(receipt.getReceiptId());
        dto.setUserId(receipt.getUser().getUserId());
        dto.setImageUrl(receipt.getImageUrl());
        dto.setOriginalFilename(receipt.getOriginalFilename());
        dto.setProcessedAt(receipt.getProcessedAt());
        dto.setHasLinkedExpenses(hasLinkedExpenses);
        
        // Parse JSON string to ReceiptOCRResult
        if (receipt.getOcrResult() != null) {
            try {
                ReceiptOCRResult ocrResult = objectMapper.readValue(
                    receipt.getOcrResult(), 
                    ReceiptOCRResult.class
                );
                dto.setOcrResult(ocrResult);
            } catch (JsonProcessingException e) {
                // Log error and set null
                dto.setOcrResult(null);
            }
        }
        
        return dto;
    }
    
    public static Receipt toEntity(String imageUrl, String filename, User user) {
        Receipt receipt = new Receipt();
        receipt.setImageUrl(imageUrl);
        receipt.setOriginalFilename(filename);
        receipt.setUser(user);
        return receipt;
    }
    
    public static String ocrResultToJson(ReceiptOCRResult ocrResult) {
        try {
            return objectMapper.writeValueAsString(ocrResult);
        } catch (JsonProcessingException e) {
            return null;
        }
    }
}
