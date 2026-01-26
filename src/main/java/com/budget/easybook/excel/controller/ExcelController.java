package com.budget.easybook.excel.controller;

import com.budget.easybook.excel.dto.ExcelImportResultDTO;
import com.budget.easybook.excel.service.ExcelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api/transactions")
public class ExcelController {
    
    @Autowired
    private ExcelService excelService;
    
    @GetMapping("/export/excel")
    public ResponseEntity<byte[]> exportToExcel(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        
        try {
            byte[] excelData = excelService.exportToExcel(userId, start, end);
            
            String filename = "transactions_" + 
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + 
                ".xlsx";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
            headers.setContentDispositionFormData("attachment", filename);
            headers.setCacheControl("must-revalidate, post-check=0, pre-check=0");
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(excelData);
                    
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @PostMapping("/import/excel")
    public ResponseEntity<ExcelImportResultDTO> importFromExcel(
            @RequestParam Long userId,
            @RequestParam("file") MultipartFile file) {
        
        if (file.isEmpty()) {
            ExcelImportResultDTO result = new ExcelImportResultDTO();
            result.addError("파일이 비어있습니다");
            return ResponseEntity.badRequest().body(result);
        }
        
        String filename = file.getOriginalFilename();
        if (filename == null || (!filename.endsWith(".xlsx") && !filename.endsWith(".xls"))) {
            ExcelImportResultDTO result = new ExcelImportResultDTO();
            result.addError("엑셀 파일(.xlsx, .xls)만 업로드 가능합니다");
            return ResponseEntity.badRequest().body(result);
        }
        
        try {
            ExcelImportResultDTO result = excelService.importFromExcel(userId, file);
            return ResponseEntity.ok(result);
        } catch (IOException e) {
            ExcelImportResultDTO result = new ExcelImportResultDTO();
            result.addError("파일 처리 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(result);
        }
    }
}
