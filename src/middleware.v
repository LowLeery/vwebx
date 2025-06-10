module LowLeery.vwebx

import time

// Middleware fonksiyon tipi
pub type MiddlewareFn = fn (mut Context) bool

// Middleware yapısı
pub struct Middleware {
    pub name string
    pub handler ?MiddlewareFn
    pub is_global bool
}

// Logging middleware'i
pub fn logging_middleware(mut ctx Context) bool {
    if ctx.start_time == time.Time{} {
        ctx.start_time = time.now()
    }
    
    if ctx.middleware_index == 0 {
        println('${time.now().format()} | ${ctx.method} ${ctx.path} | Started')
    }
    
    if ctx.middleware_index == ctx.middleware_chain.len {
        duration := time.since(ctx.start_time)
        println('${time.now().format()} | ${ctx.method} ${ctx.path} | Completed in ${duration.milliseconds()}ms | Status: ${ctx.status}')
    }
    
    return true
}

// CORS middleware'i
pub fn cors_middleware(mut ctx Context) bool {
    ctx.headers['Access-Control-Allow-Origin'] = '*'
    ctx.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    ctx.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    
    if ctx.method == 'OPTIONS' {
        ctx.status = 204
        return false
    }
    
    return true
}

// JSON middleware'i
pub fn json_middleware(mut ctx Context) bool {
    if ctx.req.method == .post || ctx.req.method == .put {
        content_type := ctx.req.header.get(.content_type) or { return true }
        if content_type.contains('application/json') {
            ctx.json_body = ctx.req.body
        }
    }
    return true
}

// Recovery middleware'i
pub fn recovery_middleware(mut ctx Context) bool {
    defer {
        if err := recover() {
            ctx.status = 500
            ctx.json(json_error('Internal Server Error', 500))
        }
    }
    return true
}

// Rate limiting middleware'i
pub struct RateLimiter {
mut:
    requests map[string][]time.Time
    window time.Duration
    max_requests int
}

pub fn new_rate_limiter(window time.Duration, max_requests int) &RateLimiter {
    return &RateLimiter{
        requests: map[string][]time.Time{}
        window: window
        max_requests: max_requests
    }
}

pub fn (mut limiter RateLimiter) rate_limit_middleware(mut ctx Context) bool {
    ip := ctx.req.header.get(.x_forwarded_for) or { ctx.req.remote_addr }
    now := time.now()
    
    // Eski istekleri temizle
    mut requests := limiter.requests[ip] or { []time.Time{} }
    mut valid_requests := []time.Time{}
    
    for req_time in requests {
        if now.diff(req_time) < limiter.window {
            valid_requests << req_time
        }
    }
    
    // İstek sayısını kontrol et
    if valid_requests.len >= limiter.max_requests {
        ctx.status = 429
        ctx.json(json_error('Too Many Requests', 429))
        return false
    }
    
    // Yeni isteği ekle
    valid_requests << now
    limiter.requests[ip] = valid_requests
    
    return true
}

// Auth middleware'i
pub fn auth_middleware(mut ctx Context) bool {
    auth_header := ctx.req.header.get(.authorization) or { return false }
    
    if !auth_header.starts_with('Bearer ') {
        ctx.status = 401
        ctx.json(json_error('Invalid authorization header', 401))
        return false
    }
    
    token := auth_header[7..]
    // TODO: Token doğrulama işlemleri
    
    return true
}

// Middleware zincirini çalıştır
pub fn (mut ctx Context) next() bool {
    if ctx.middleware_index >= ctx.middleware_chain.len {
        return true
    }
    
    current_middleware := ctx.middleware_chain[ctx.middleware_index]
    ctx.middleware_index++
    
    return current_middleware(mut ctx)
} 
