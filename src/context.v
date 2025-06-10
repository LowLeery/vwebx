module vwebx

import net
import net.http
import time

// Context yapısı
pub struct Context {
    pub req http.Request
    pub conn net.TcpConn
mut:
    pub headers map[string]string
    pub status int = 200
    pub body string
    pub start_time time.Time
    pub path string
    pub method string
    pub params map[string]string
    pub query map[string]string
    pub middleware_index int
    pub middleware_chain []MiddlewareFn
    pub json_body string
    pub app &App
}

// Response helper fonksiyonları
pub fn (mut ctx Context) text(text string) Result {
    ctx.headers['Content-Type'] = 'text/plain'
    ctx.body = text
    return text
}

pub fn (mut ctx Context) json(data any) Result {
    ctx.headers['Content-Type'] = 'application/json'
    return json_encode(data)
}

pub fn (mut ctx Context) html(html string) Result {
    ctx.headers['Content-Type'] = 'text/html'
    ctx.body = html
    return html
}

pub fn (mut ctx Context) status(code int) {
    ctx.status = code
}

pub fn (mut ctx Context) redirect(url string) Result {
    ctx.status = 302
    ctx.headers['Location'] = url
    return ''
}

pub fn (mut ctx Context) file(path string) !Result {
    if !os.exists(path) {
        return error('File not found: ${path}')
    }
    
    content := os.read_file(path)!
    ext := os.file_ext(path)
    
    mime_type := match ext {
        '.html' { 'text/html' }
        '.css' { 'text/css' }
        '.js' { 'application/javascript' }
        '.json' { 'application/json' }
        '.png' { 'image/png' }
        '.jpg', '.jpeg' { 'image/jpeg' }
        '.gif' { 'image/gif' }
        '.svg' { 'image/svg+xml' }
        '.ico' { 'image/x-icon' }
        '.pdf' { 'application/pdf' }
        '.txt' { 'text/plain' }
        else { 'application/octet-stream' }
    }
    
    ctx.headers['Content-Type'] = mime_type
    ctx.body = content
    return content
}

pub fn (mut ctx Context) cookie(name string, value string, options CookieOptions) {
    mut cookie := '${name}=${value}'
    
    if options.max_age > 0 {
        cookie += '; Max-Age=${options.max_age}'
    }
    if options.expires != time.Time{} {
        cookie += '; Expires=${options.expires.format_rfc1123()}'
    }
    if options.path != '' {
        cookie += '; Path=${options.path}'
    }
    if options.domain != '' {
        cookie += '; Domain=${options.domain}'
    }
    if options.secure {
        cookie += '; Secure'
    }
    if options.http_only {
        cookie += '; HttpOnly'
    }
    if options.same_site != '' {
        cookie += '; SameSite=${options.same_site}'
    }
    
    ctx.headers['Set-Cookie'] = cookie
}

pub fn (mut ctx Context) clear_cookie(name string) {
    ctx.cookie(name, '', CookieOptions{
        max_age: -1
        expires: time.now().add(-24 * time.hour)
    })
}

// Cookie seçenekleri
pub struct CookieOptions {
    pub max_age int
    pub expires time.Time
    pub path string
    pub domain string
    pub secure bool
    pub http_only bool
    pub same_site string // 'Strict', 'Lax', 'None'
}

// JSON encode helper
fn json_encode(data any) string {
    return json.encode(data) or { '{"error": "Failed to encode JSON"}' }
} 
