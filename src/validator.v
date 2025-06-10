module vwebx

import regex
import time

// Doğrulama hatası
pub struct ValidationError {
    pub field string
    pub message string
}

// Doğrulama sonucu
pub struct ValidationResult {
    pub is_valid bool
    pub errors []ValidationError
}

// String doğrulama kuralları
pub struct StringRules {
    pub required bool
    pub min_len int
    pub max_len int
    pub pattern string
    pub enum_values []string
}

// Sayı doğrulama kuralları
pub struct NumberRules {
    pub required bool
    pub min f64
    pub max f64
    pub is_int bool
}

// Tarih doğrulama kuralları
pub struct DateRules {
    pub required bool
    pub min time.Time
    pub max time.Time
    pub format string
}

// Varsayılan string kuralları
pub fn default_string_rules() StringRules {
    return StringRules{
        required: false
        min_len: 0
        max_len: 0
        pattern: ''
        enum_values: []
    }
}

// Varsayılan sayı kuralları
pub fn default_number_rules() NumberRules {
    return NumberRules{
        required: false
        min: -1.7976931348623157e+308
        max: 1.7976931348623157e+308
        is_int: false
    }
}

// Varsayılan tarih kuralları
pub fn default_date_rules() DateRules {
    return DateRules{
        required: false
        min: time.Time{}
        max: time.Time{}
        format: 'YYYY-MM-DD'
    }
}

// String doğrulama
pub fn validate_string(value string, rules StringRules) ValidationResult {
    mut result := ValidationResult{
        is_valid: true
        errors: []
    }
    
    // Required kontrolü
    if rules.required && value == '' {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Field is required'
        }
        return result
    }
    
    // Boş değer kontrolü
    if value == '' {
        return result
    }
    
    // Uzunluk kontrolü
    if rules.min_len > 0 && value.len < rules.min_len {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Value is too short (minimum ${rules.min_len} characters)'
        }
    }
    
    if rules.max_len > 0 && value.len > rules.max_len {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Value is too long (maximum ${rules.max_len} characters)'
        }
    }
    
    // Pattern kontrolü
    if rules.pattern != '' {
        re := regex.regex_opt(rules.pattern) or { return result }
        if !re.matches_string(value) {
            result.is_valid = false
            result.errors << ValidationError{
                field: 'value'
                message: 'Value does not match required pattern'
            }
        }
    }
    
    // Enum kontrolü
    if rules.enum_values.len > 0 {
        mut found := false
        for enum_value in rules.enum_values {
            if value == enum_value {
                found = true
                break
            }
        }
        if !found {
            result.is_valid = false
            result.errors << ValidationError{
                field: 'value'
                message: 'Value is not in allowed values'
            }
        }
    }
    
    return result
}

// Sayı doğrulama
pub fn validate_number(value f64, rules NumberRules) ValidationResult {
    mut result := ValidationResult{
        is_valid: true
        errors: []
    }
    
    // Required kontrolü
    if rules.required && value == 0 {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Field is required'
        }
        return result
    }
    
    // Boş değer kontrolü
    if value == 0 {
        return result
    }
    
    // Integer kontrolü
    if rules.is_int && value != f64(int(value)) {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Value must be an integer'
        }
    }
    
    // Min/Max kontrolü
    if value < rules.min {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Value is too small (minimum ${rules.min})'
        }
    }
    
    if value > rules.max {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Value is too large (maximum ${rules.max})'
        }
    }
    
    return result
}

// Tarih doğrulama
pub fn validate_date(value time.Time, rules DateRules) ValidationResult {
    mut result := ValidationResult{
        is_valid: true
        errors: []
    }
    
    // Required kontrolü
    if rules.required && value == time.Time{} {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Field is required'
        }
        return result
    }
    
    // Boş değer kontrolü
    if value == time.Time{} {
        return result
    }
    
    // Min/Max kontrolü
    if rules.min != time.Time{} && value < rules.min {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Date is too early (minimum ${rules.min.format()})'
        }
    }
    
    if rules.max != time.Time{} && value > rules.max {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'value'
            message: 'Date is too late (maximum ${rules.max.format()})'
        }
    }
    
    return result
}

// Email doğrulama
pub fn validate_email(value string) ValidationResult {
    rules := StringRules{
        required: true
        pattern: r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    }
    return validate_string(value, rules)
}

// URL doğrulama
pub fn validate_url(value string) ValidationResult {
    rules := StringRules{
        required: true
        pattern: r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    }
    return validate_string(value, rules)
}

// Telefon numarası doğrulama
pub fn validate_phone(value string) ValidationResult {
    rules := StringRules{
        required: true
        pattern: r'^\+?[1-9]\d{1,14}$'
    }
    return validate_string(value, rules)
}

// Şifre doğrulama
pub fn validate_password(value string) ValidationResult {
    mut result := ValidationResult{
        is_valid: true
        errors: []
    }
    
    if value.len < 8 {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'password'
            message: 'Password must be at least 8 characters long'
        }
    }
    
    has_upper := regex.regex_opt(r'[A-Z]') or { return result }
    has_lower := regex.regex_opt(r'[a-z]') or { return result }
    has_digit := regex.regex_opt(r'[0-9]') or { return result }
    has_special := regex.regex_opt(r'[!@#$%^&*(),.?":{}|<>]') or { return result }
    
    if !has_upper.matches_string(value) {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'password'
            message: 'Password must contain at least one uppercase letter'
        }
    }
    
    if !has_lower.matches_string(value) {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'password'
            message: 'Password must contain at least one lowercase letter'
        }
    }
    
    if !has_digit.matches_string(value) {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'password'
            message: 'Password must contain at least one number'
        }
    }
    
    if !has_special.matches_string(value) {
        result.is_valid = false
        result.errors << ValidationError{
            field: 'password'
            message: 'Password must contain at least one special character'
        }
    }
    
    return result
} 
