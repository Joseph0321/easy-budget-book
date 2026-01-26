package com.budget.easybook.excel.service;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.auth.repository.UserRepository;
import com.budget.easybook.category.entity.Category;
import com.budget.easybook.category.repository.CategoryRepository;
import com.budget.easybook.excel.dto.ExcelImportResultDTO;
import com.budget.easybook.excel.dto.ExcelRowDTO;
import com.budget.easybook.expense.entity.Expense;
import com.budget.easybook.expense.repository.ExpenseRepository;
import com.budget.easybook.income.entity.Income;
import com.budget.easybook.income.repository.IncomeRepository;
import jakarta.transaction.Transactional;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@Transactional
public class ExcelService {
    
    @Autowired
    private IncomeRepository incomeRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    private static final String[] HEADERS = {"날짜", "구분", "카테고리", "금액", "결제수단", "메모"};
    
    public byte[] exportToExcel(Long userId, LocalDate startDate, LocalDate endDate) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("거래내역");
            
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle dateStyle = createDateStyle(workbook);
            CellStyle currencyStyle = createCurrencyStyle(workbook);
            
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < HEADERS.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(HEADERS[i]);
                cell.setCellStyle(headerStyle);
            }
            
            List<Object[]> transactions = new ArrayList<>();
            
            List<Income> incomes = incomeRepository.findByUserIdAndIncomeDateBetween(userId, startDate, endDate);
            for (Income income : incomes) {
                transactions.add(new Object[]{
                    income.getIncomeDate(),
                    "수입",
                    income.getCategory() != null ? income.getCategory().getName() : "",
                    income.getAmount(),
                    income.getPaymentMethod() != null ? income.getPaymentMethod() : "",
                    income.getMemo() != null ? income.getMemo() : ""
                });
            }
            
            List<Expense> expenses = expenseRepository.findByUserIdAndExpenseDateBetween(userId, startDate, endDate);
            for (Expense expense : expenses) {
                transactions.add(new Object[]{
                    expense.getExpenseDate(),
                    "지출",
                    expense.getCategory() != null ? expense.getCategory().getName() : "",
                    expense.getAmount(),
                    expense.getPaymentMethod() != null ? expense.getPaymentMethod() : "",
                    expense.getMemo() != null ? expense.getMemo() : ""
                });
            }
            
            transactions.sort((a, b) -> ((LocalDate) b[0]).compareTo((LocalDate) a[0]));
            
            int rowNum = 1;
            for (Object[] transaction : transactions) {
                Row row = sheet.createRow(rowNum++);
                
                Cell dateCell = row.createCell(0);
                dateCell.setCellValue(((LocalDate) transaction[0]).format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
                
                row.createCell(1).setCellValue((String) transaction[1]);
                row.createCell(2).setCellValue((String) transaction[2]);
                
                Cell amountCell = row.createCell(3);
                amountCell.setCellValue(((BigDecimal) transaction[3]).doubleValue());
                amountCell.setCellStyle(currencyStyle);
                
                row.createCell(4).setCellValue((String) transaction[4]);
                row.createCell(5).setCellValue((String) transaction[5]);
            }
            
            for (int i = 0; i < HEADERS.length; i++) {
                sheet.autoSizeColumn(i);
            }
            
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            workbook.write(outputStream);
            return outputStream.toByteArray();
        }
    }
    
    public ExcelImportResultDTO importFromExcel(Long userId, MultipartFile file) throws IOException {
        ExcelImportResultDTO result = new ExcelImportResultDTO();
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        List<Category> userCategories = categoryRepository.findByUserId(userId);
        Map<String, Category> categoryMap = new HashMap<>();
        for (Category cat : userCategories) {
            categoryMap.put(cat.getName(), cat);
        }
        
        try (Workbook workbook = WorkbookFactory.create(file.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            
            Row headerRow = sheet.getRow(0);
            if (!validateHeaders(headerRow)) {
                result.addError("엑셀 헤더가 올바르지 않습니다. 필수 컬럼: 날짜, 구분, 카테고리, 금액");
                return result;
            }
            
            List<ExcelRowDTO> validRows = new ArrayList<>();
            
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                try {
                    ExcelRowDTO rowData = parseRow(row, i + 1);
                    if (rowData != null) {
                        validRows.add(rowData);
                    }
                } catch (Exception e) {
                    result.addError("행 " + (i + 1) + ": " + e.getMessage());
                    result.setFailureCount(result.getFailureCount() + 1);
                }
            }
            
            result.setTotalRows(validRows.size() + result.getFailureCount());
            
            for (ExcelRowDTO rowData : validRows) {
                try {
                    if (isDuplicate(userId, rowData)) {
                        result.setDuplicateCount(result.getDuplicateCount() + 1);
                        result.addError("행 " + rowData.getRowNumber() + ": 중복 데이터 (동일 날짜, 금액, 카테고리)");
                        continue;
                    }
                    
                    Category category = categoryMap.get(rowData.getCategoryName());
                    if (category == null) {
                        result.addError("행 " + rowData.getRowNumber() + ": 카테고리 '" + rowData.getCategoryName() + "'을(를) 찾을 수 없습니다");
                        result.setFailureCount(result.getFailureCount() + 1);
                        continue;
                    }
                    
                    if ("수입".equals(rowData.getType()) || "INCOME".equalsIgnoreCase(rowData.getType())) {
                        if (!"income".equals(category.getType())) {
                            result.addError("행 " + rowData.getRowNumber() + ": 카테고리 타입이 일치하지 않습니다 (수입)");
                            result.setFailureCount(result.getFailureCount() + 1);
                            continue;
                        }
                        
                        Income income = new Income();
                        income.setUser(user);
                        income.setCategory(category);
                        income.setAmount(rowData.getAmount());
                        income.setIncomeDate(rowData.getDate());
                        income.setPaymentMethod(rowData.getPaymentMethod());
                        income.setMemo(rowData.getMemo());
                        incomeRepository.save(income);
                        result.setSuccessCount(result.getSuccessCount() + 1);
                        
                    } else if ("지출".equals(rowData.getType()) || "EXPENSE".equalsIgnoreCase(rowData.getType())) {
                        if (!"expense".equals(category.getType())) {
                            result.addError("행 " + rowData.getRowNumber() + ": 카테고리 타입이 일치하지 않습니다 (지출)");
                            result.setFailureCount(result.getFailureCount() + 1);
                            continue;
                        }
                        
                        Expense expense = new Expense();
                        expense.setUser(user);
                        expense.setCategory(category);
                        expense.setAmount(rowData.getAmount());
                        expense.setExpenseDate(rowData.getDate());
                        expense.setPaymentMethod(rowData.getPaymentMethod());
                        expense.setMemo(rowData.getMemo());
                        expenseRepository.save(expense);
                        result.setSuccessCount(result.getSuccessCount() + 1);
                        
                    } else {
                        result.addError("행 " + rowData.getRowNumber() + ": 구분은 '수입' 또는 '지출'이어야 합니다");
                        result.setFailureCount(result.getFailureCount() + 1);
                    }
                    
                } catch (Exception e) {
                    result.addError("행 " + rowData.getRowNumber() + ": " + e.getMessage());
                    result.setFailureCount(result.getFailureCount() + 1);
                }
            }
        }
        
        return result;
    }
    
    private boolean validateHeaders(Row headerRow) {
        if (headerRow == null) return false;
        
        String[] requiredHeaders = {"날짜", "구분", "카테고리", "금액"};
        for (int i = 0; i < requiredHeaders.length; i++) {
            Cell cell = headerRow.getCell(i);
            if (cell == null) return false;
            String value = cell.getStringCellValue().trim();
            if (!requiredHeaders[i].equals(value)) return false;
        }
        return true;
    }
    
    private ExcelRowDTO parseRow(Row row, int rowNumber) {
        ExcelRowDTO dto = new ExcelRowDTO();
        dto.setRowNumber(rowNumber);
        
        Cell dateCell = row.getCell(0);
        if (dateCell == null) return null;
        
        if (dateCell.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(dateCell)) {
            dto.setDate(dateCell.getLocalDateTimeCellValue().toLocalDate());
        } else if (dateCell.getCellType() == CellType.STRING) {
            String dateStr = dateCell.getStringCellValue().trim();
            if (dateStr.isEmpty()) return null;
            dto.setDate(LocalDate.parse(dateStr, DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        } else {
            throw new RuntimeException("날짜 형식이 올바르지 않습니다");
        }
        
        Cell typeCell = row.getCell(1);
        if (typeCell == null || typeCell.getStringCellValue().trim().isEmpty()) {
            throw new RuntimeException("구분이 비어있습니다");
        }
        dto.setType(typeCell.getStringCellValue().trim());
        
        Cell categoryCell = row.getCell(2);
        if (categoryCell == null || categoryCell.getStringCellValue().trim().isEmpty()) {
            throw new RuntimeException("카테고리가 비어있습니다");
        }
        dto.setCategoryName(categoryCell.getStringCellValue().trim());
        
        Cell amountCell = row.getCell(3);
        if (amountCell == null) {
            throw new RuntimeException("금액이 비어있습니다");
        }
        if (amountCell.getCellType() == CellType.NUMERIC) {
            dto.setAmount(BigDecimal.valueOf(amountCell.getNumericCellValue()));
        } else if (amountCell.getCellType() == CellType.STRING) {
            String amountStr = amountCell.getStringCellValue().replaceAll("[^0-9.]", "");
            dto.setAmount(new BigDecimal(amountStr));
        } else {
            throw new RuntimeException("금액 형식이 올바르지 않습니다");
        }
        
        Cell paymentCell = row.getCell(4);
        if (paymentCell != null && paymentCell.getCellType() == CellType.STRING) {
            dto.setPaymentMethod(paymentCell.getStringCellValue().trim());
        }
        
        Cell memoCell = row.getCell(5);
        if (memoCell != null && memoCell.getCellType() == CellType.STRING) {
            dto.setMemo(memoCell.getStringCellValue().trim());
        }
        
        return dto;
    }
    
    private boolean isDuplicate(Long userId, ExcelRowDTO rowData) {
        if ("수입".equals(rowData.getType()) || "INCOME".equalsIgnoreCase(rowData.getType())) {
            List<Income> existing = incomeRepository.findByUserIdAndIncomeDateBetween(
                userId, rowData.getDate(), rowData.getDate());
            for (Income income : existing) {
                if (income.getAmount().compareTo(rowData.getAmount()) == 0 &&
                    income.getCategory() != null && 
                    income.getCategory().getName().equals(rowData.getCategoryName())) {
                    return true;
                }
            }
        } else {
            List<Expense> existing = expenseRepository.findByUserIdAndExpenseDateBetween(
                userId, rowData.getDate(), rowData.getDate());
            for (Expense expense : existing) {
                if (expense.getAmount().compareTo(rowData.getAmount()) == 0 &&
                    expense.getCategory() != null &&
                    expense.getCategory().getName().equals(rowData.getCategoryName())) {
                    return true;
                }
            }
        }
        return false;
    }
    
    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }
    
    private CellStyle createDateStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        CreationHelper createHelper = workbook.getCreationHelper();
        style.setDataFormat(createHelper.createDataFormat().getFormat("yyyy-mm-dd"));
        return style;
    }
    
    private CellStyle createCurrencyStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        CreationHelper createHelper = workbook.getCreationHelper();
        style.setDataFormat(createHelper.createDataFormat().getFormat("#,##0"));
        return style;
    }
}
