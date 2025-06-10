module vwebx

import os
import json

// Konfigürasyon yapısı
pub struct Config {
    pub host string
    pub port int
    pub env string
    pub debug bool
    pub database DatabaseConfig
    pub cors CORSConfig
    pub rate_limit RateLimitConfig
    pub static StaticConfig
    pub security SecurityConfig
}

// Database konfigürasyonu
pub struct DatabaseConfig {
    pub driver string
    pub host string
    pub port int
    pub name string
    pub user string
    pub password string
    pub max_connections int
    pub idle_connections int
    pub connection_lifetime int
}

// CORS konfigürasyonu
pub struct CORSConfig {
    pub allowed_origins []string
    pub allowed_methods []string
    pub allowed_headers []string
    pub exposed_headers []string
    pub allow_credentials bool
    pub max_age int
}

// Rate limit konfigürasyonu
pub struct RateLimitConfig {
    pub enabled bool
    pub window time.Duration
    pub max_requests int
    pub by_ip bool
    pub by_user bool
}

// Static dosya konfigürasyonu
pub struct StaticConfig {
    pub enabled bool
    pub prefix string
    pub directory string
    pub index_files []string
    pub cache_control string
}

// Güvenlik konfigürasyonu
pub struct SecurityConfig {
    pub secret_key string
    pub token_lifetime int
    pub cookie_secure bool
    pub cookie_http_only bool
    pub cookie_same_site string
    pub allowed_hosts []string
}

// Varsayılan konfigürasyon
pub fn default_config() Config {
    return Config{
        host: 'localhost'
        port: 8080
        env: 'development'
        debug: true
        database: DatabaseConfig{
            driver: 'sqlite'
            host: 'localhost'
            port: 0
            name: 'vwebx.db'
            user: ''
            password: ''
            max_connections: 10
            idle_connections: 5
            connection_lifetime: 3600
        }
        cors: CORSConfig{
            allowed_origins: ['*']
            allowed_methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
            allowed_headers: ['Content-Type', 'Authorization']
            exposed_headers: []
            allow_credentials: false
            max_age: 86400
        }
        rate_limit: RateLimitConfig{
            enabled: false
            window: 1 * time.minute
            max_requests: 100
            by_ip: true
            by_user: false
        }
        static: StaticConfig{
            enabled: true
            prefix: '/static'
            directory: 'static'
            index_files: ['index.html', 'index.htm']
            cache_control: 'public, max-age=3600'
        }
        security: SecurityConfig{
            secret_key: 'your-secret-key'
            token_lifetime: 86400
            cookie_secure: false
            cookie_http_only: true
            cookie_same_site: 'Lax'
            allowed_hosts: ['localhost']
        }
    }
}

// Konfigürasyonu dosyadan yükle
pub fn load_config(path string) !Config {
    if !os.exists(path) {
        return error('Config file not found: ${path}')
    }
    
    content := os.read_file(path)!
    mut config := default_config()
    
    json.decode(Config, content) or { return error('Invalid config file: ${err}') }
    
    return config
}

// Konfigürasyonu environment variables'dan yükle
pub fn load_config_from_env() Config {
    mut config := default_config()
    
    if host := os.getenv('VWEBX_HOST') {
        config.host = host
    }
    if port := os.getenv('VWEBX_PORT') {
        config.port = port.int()
    }
    if env := os.getenv('VWEBX_ENV') {
        config.env = env
    }
    if debug := os.getenv('VWEBX_DEBUG') {
        config.debug = debug == 'true'
    }
    
    // Database
    if db_host := os.getenv('VWEBX_DB_HOST') {
        config.database.host = db_host
    }
    if db_port := os.getenv('VWEBX_DB_PORT') {
        config.database.port = db_port.int()
    }
    if db_name := os.getenv('VWEBX_DB_NAME') {
        config.database.name = db_name
    }
    if db_user := os.getenv('VWEBX_DB_USER') {
        config.database.user = db_user
    }
    if db_pass := os.getenv('VWEBX_DB_PASS') {
        config.database.password = db_pass
    }
    
    // Security
    if secret_key := os.getenv('VWEBX_SECRET_KEY') {
        config.security.secret_key = secret_key
    }
    if token_lifetime := os.getenv('VWEBX_TOKEN_LIFETIME') {
        config.security.token_lifetime = token_lifetime.int()
    }
    
    return config
}

// Konfigürasyonu kaydet
pub fn (config Config) save(path string) ! {
    content := json.encode_pretty(config) or { return error('Failed to encode config: ${err}') }
    os.write_file(path, content)!
}

// Konfigürasyonu doğrula
pub fn (config Config) validate() ! {
    // Port kontrolü
    if config.port < 1 || config.port > 65535 {
        return error('Invalid port number: ${config.port}')
    }
    
    // Database kontrolü
    if config.database.driver == '' {
        return error('Database driver is required')
    }
    if config.database.name == '' {
        return error('Database name is required')
    }
    
    // Security kontrolü
    if config.security.secret_key == '' {
        return error('Secret key is required')
    }
    if config.security.token_lifetime < 1 {
        return error('Token lifetime must be positive')
    }
    
    // Static dosya kontrolü
    if config.static.enabled && !os.exists(config.static.directory) {
        return error('Static directory not found: ${config.static.directory}')
    }
} 