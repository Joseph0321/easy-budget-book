package com.budget.easybook.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/test")
public class DatabaseTestController {
    
    @Autowired
    private DataSource dataSource;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @GetMapping("/db-connection")
    public Map<String, Object> testDatabaseConnection() {
        Map<String, Object> result = new HashMap<>();
        
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            
            result.put("status", "SUCCESS");
            result.put("database", metaData.getDatabaseProductName());
            result.put("version", metaData.getDatabaseProductVersion());
            result.put("url", metaData.getURL());
            result.put("username", metaData.getUserName());
            result.put("driver", metaData.getDriverName());
            
            Integer count = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            result.put("testQuery", "SELECT 1 = " + count);
            
        } catch (Exception e) {
            result.put("status", "FAILED");
            result.put("error", e.getMessage());
            result.put("errorType", e.getClass().getName());
        }
        
        return result;
    }
    
    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> health = new HashMap<>();
        health.put("status", "UP");
        health.put("application", "Easy Budget Book");
        health.put("database", "PostgreSQL");
        return health;
    }
}
