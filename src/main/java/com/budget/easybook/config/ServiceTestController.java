package com.budget.easybook.config;

import com.budget.easybook.auth.entity.User;
import com.budget.easybook.auth.repository.UserRepository;
import com.budget.easybook.category.dto.CategoryCreateDTO;
import com.budget.easybook.category.dto.CategoryDTO;
import com.budget.easybook.category.service.CategoryService;
import com.budget.easybook.income.dto.IncomeCreateDTO;
import com.budget.easybook.income.dto.IncomeDTO;
import com.budget.easybook.income.service.IncomeService;
import com.budget.easybook.expense.dto.ExpenseCreateDTO;
import com.budget.easybook.expense.dto.ExpenseDTO;
import com.budget.easybook.expense.service.ExpenseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.budget.easybook.category.entity.Category;
import com.budget.easybook.category.repository.CategoryRepository;
import com.budget.easybook.income.entity.Income;
import com.budget.easybook.income.repository.IncomeRepository;
import com.budget.easybook.expense.entity.Expense;
import com.budget.easybook.expense.repository.ExpenseRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class ServiceTestController {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CategoryService categoryService;
    
    @Autowired
    private IncomeService incomeService;
    
    @Autowired
    private ExpenseService expenseService;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private IncomeRepository incomeRepository;
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @PostMapping("/generate-sample-data")
    public Map<String, Object> generateSampleData() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            User user = new User();
            user.setEmail("demo@easybook.com");
            user.setName("홍길동");
            user.setProvider("demo");
            user.setProviderId("demo2026");
            User savedUser = userRepository.save(user);
            Long userId = savedUser.getUserId();
            result.put("userId", userId);
            result.put("userName", savedUser.getName());
            
            Category 급여 = createCategory(savedUser, "급여", "income", "#4CAF50", "💰");
            Category 부수입 = createCategory(savedUser, "부수입", "income", "#8BC34A", "💵");
            Category 식비 = createCategory(savedUser, "식비", "expense", "#F44336", "🍔");
            Category 교통비 = createCategory(savedUser, "교통비", "expense", "#E91E63", "🚗");
            Category 쇼핑 = createCategory(savedUser, "쇼핑", "expense", "#9C27B0", "🛍️");
            Category 주거비 = createCategory(savedUser, "주거비", "expense", "#673AB7", "🏠");
            Category 통신비 = createCategory(savedUser, "통신비", "expense", "#3F51B5", "📱");
            Category 문화생활 = createCategory(savedUser, "문화생활", "expense", "#2196F3", "🎬");
            Category 카페 = createCategory(savedUser, "카페", "expense", "#795548", "☕");
            Category 의료비 = createCategory(savedUser, "의료비", "expense", "#009688", "🏥");
            Category 보험 = createCategory(savedUser, "보험", "expense", "#607D8B", "🛡️");
            Category 구독료 = createCategory(savedUser, "구독료", "expense", "#FF5722", "📺");
            Category 경조사 = createCategory(savedUser, "경조사", "expense", "#FFEB3B", "🎁");
            
            int incomeCount = 0;
            int expenseCount = 0;
            
            createIncome(savedUser, 급여, "2026-01-25", 3500000, "계좌이체", "1월 급여");
            incomeCount++;
            createIncome(savedUser, 부수입, "2026-01-15", 200000, "계좌이체", "프리랜서 부업 수입");
            incomeCount++;
            
            createExpense(savedUser, 주거비, "2026-01-01", 800000, "계좌이체", "1월 월세");
            expenseCount++;
            createExpense(savedUser, 주거비, "2026-01-05", 120000, "계좌이체", "1월 관리비");
            expenseCount++;
            createExpense(savedUser, 통신비, "2026-01-10", 65000, "계좌이체", "휴대폰 요금");
            expenseCount++;
            createExpense(savedUser, 통신비, "2026-01-10", 35000, "계좌이체", "인터넷 요금");
            expenseCount++;
            createExpense(savedUser, 보험, "2026-01-15", 150000, "계좌이체", "실비보험료");
            expenseCount++;
            createExpense(savedUser, 구독료, "2026-01-01", 17000, "신용카드", "넷플릭스 구독");
            expenseCount++;
            createExpense(savedUser, 구독료, "2026-01-05", 10900, "신용카드", "유튜브 프리미엄");
            expenseCount++;
            createExpense(savedUser, 구독료, "2026-01-08", 7900, "신용카드", "멜론 음악 스트리밍");
            expenseCount++;
            
            createExpense(savedUser, 식비, "2026-01-02", 8500, "신용카드", "점심 김치찌개");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-03", 12000, "신용카드", "점심 회식 (삼겹살)");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-04", 7000, "체크카드", "편의점 도시락");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-06", 45000, "신용카드", "주말 외식 (일식)");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-08", 32000, "신용카드", "마트 장보기");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-11", 9500, "신용카드", "점심 국밥");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-14", 15000, "신용카드", "치킨 배달");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-17", 28000, "신용카드", "피자 배달 (가족)");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-20", 42000, "신용카드", "마트 장보기");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-23", 8000, "체크카드", "점심 라멘");
            expenseCount++;
            createExpense(savedUser, 식비, "2026-01-26", 55000, "신용카드", "주말 외식 (한식뷔페)");
            expenseCount++;
            
            createExpense(savedUser, 교통비, "2026-01-02", 55000, "체크카드", "지하철 정기권");
            expenseCount++;
            createExpense(savedUser, 교통비, "2026-01-07", 15000, "현금", "택시 (야근)");
            expenseCount++;
            createExpense(savedUser, 교통비, "2026-01-13", 58000, "신용카드", "주유비");
            expenseCount++;
            createExpense(savedUser, 교통비, "2026-01-21", 12000, "현금", "택시 (비 오는 날)");
            expenseCount++;
            createExpense(savedUser, 교통비, "2026-01-28", 62000, "신용카드", "주유비");
            expenseCount++;
            
            createExpense(savedUser, 카페, "2026-01-03", 5500, "신용카드", "아메리카노");
            expenseCount++;
            createExpense(savedUser, 카페, "2026-01-06", 6800, "신용카드", "카페라떼");
            expenseCount++;
            createExpense(savedUser, 카페, "2026-01-10", 5500, "신용카드", "아메리카노");
            expenseCount++;
            createExpense(savedUser, 카페, "2026-01-15", 7200, "신용카드", "바닐라라떼");
            expenseCount++;
            createExpense(savedUser, 카페, "2026-01-20", 5500, "신용카드", "아메리카노");
            expenseCount++;
            createExpense(savedUser, 카페, "2026-01-24", 6000, "신용카드", "콜드브루");
            expenseCount++;
            
            createExpense(savedUser, 문화생활, "2026-01-12", 15000, "신용카드", "영화 관람 (주말)");
            expenseCount++;
            createExpense(savedUser, 문화생활, "2026-01-19", 25000, "신용카드", "전시회 입장료");
            expenseCount++;
            createExpense(savedUser, 문화생활, "2026-01-26", 18000, "신용카드", "볼링장");
            expenseCount++;
            
            createExpense(savedUser, 쇼핑, "2026-01-09", 89000, "신용카드", "겨울 니트");
            expenseCount++;
            createExpense(savedUser, 쇼핑, "2026-01-18", 45000, "신용카드", "운동화");
            expenseCount++;
            
            createExpense(savedUser, 의료비, "2026-01-16", 35000, "신용카드", "병원 진료비 (감기)");
            expenseCount++;
            createExpense(savedUser, 의료비, "2026-01-16", 12000, "현금", "약국 약값");
            expenseCount++;
            
            createExpense(savedUser, 경조사, "2026-01-22", 50000, "현금", "친구 결혼식 축의금");
            expenseCount++;
            
            result.put("incomeCount", incomeCount);
            result.put("expenseCount", expenseCount);
            result.put("totalTransactions", incomeCount + expenseCount);
            result.put("status", "SUCCESS");
            result.put("message", "1월 샘플 데이터 " + (incomeCount + expenseCount) + "건 생성 완료");
            
        } catch (Exception e) {
            result.put("status", "FAILED");
            result.put("error", e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }
    
    private Category createCategory(User user, String name, String type, String color, String icon) {
        Category category = new Category();
        category.setUser(user);
        category.setName(name);
        category.setType(type);
        category.setColor(color);
        category.setIcon(icon);
        return categoryRepository.save(category);
    }
    
    private void createIncome(User user, Category category, String dateStr, int amount, String paymentMethod, String memo) {
        Income income = new Income();
        income.setUser(user);
        income.setCategory(category);
        income.setAmount(new BigDecimal(amount));
        income.setIncomeDate(LocalDate.parse(dateStr));
        income.setPaymentMethod(paymentMethod);
        income.setMemo(memo);
        incomeRepository.save(income);
    }
    
    private void createExpense(User user, Category category, String dateStr, int amount, String paymentMethod, String memo) {
        Expense expense = new Expense();
        expense.setUser(user);
        expense.setCategory(category);
        expense.setAmount(new BigDecimal(amount));
        expense.setExpenseDate(LocalDate.parse(dateStr));
        expense.setPaymentMethod(paymentMethod);
        expense.setMemo(memo);
        expenseRepository.save(expense);
    }
    
    @PostMapping("/service-flow")
    public Map<String, Object> testServiceFlow() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 1. Create test user
            User user = new User();
            user.setEmail("test@example.com");
            user.setName("Test User");
            user.setProvider("test");
            user.setProviderId("test123");
            User savedUser = userRepository.save(user);
            result.put("userCreated", true);
            result.put("userId", savedUser.getUserId());
            
            Long userId = savedUser.getUserId();
            
            // 2. Create default categories
            List<CategoryDTO> categories = categoryService.createDefaultCategories(userId);
            result.put("categoriesCreated", categories.size());
            result.put("categories", categories);
            
            // 3. Get first income category
            CategoryDTO incomeCategory = categories.stream()
                    .filter(c -> "income".equals(c.getType()))
                    .findFirst()
                    .orElse(null);
            
            // 4. Create an income
            if (incomeCategory != null) {
                IncomeCreateDTO incomeDTO = new IncomeCreateDTO();
                incomeDTO.setCategoryId(incomeCategory.getCategoryId());
                incomeDTO.setAmount(new BigDecimal("3000000"));
                incomeDTO.setDescription("Test income - salary");
                incomeDTO.setIncomeDate(LocalDate.now());
                
                IncomeDTO createdIncome = incomeService.createIncome(userId, incomeDTO);
                result.put("incomeCreated", true);
                result.put("income", createdIncome);
            }
            
            // 5. Get first expense category
            CategoryDTO expenseCategory = categories.stream()
                    .filter(c -> "expense".equals(c.getType()))
                    .findFirst()
                    .orElse(null);
            
            // 6. Create an expense
            if (expenseCategory != null) {
                ExpenseCreateDTO expenseDTO = new ExpenseCreateDTO();
                expenseDTO.setCategoryId(expenseCategory.getCategoryId());
                expenseDTO.setAmount(new BigDecimal("50000"));
                expenseDTO.setDescription("Test expense - food");
                expenseDTO.setExpenseDate(LocalDate.now());
                
                ExpenseDTO createdExpense = expenseService.createExpense(userId, expenseDTO);
                result.put("expenseCreated", true);
                result.put("expense", createdExpense);
            }
            
            // 7. Get totals
            result.put("incomeTotal", incomeService.getMonthlyTotal(userId, 
                    LocalDate.now().getYear(), LocalDate.now().getMonthValue()));
            result.put("expenseTotal", expenseService.getMonthlyTotal(userId,
                    LocalDate.now().getYear(), LocalDate.now().getMonthValue()));
            
            // 8. Clean up
            userRepository.delete(savedUser);
            result.put("cleanedUp", true);
            
            result.put("status", "SUCCESS");
            
        } catch (Exception e) {
            result.put("status", "FAILED");
            result.put("error", e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }
}
