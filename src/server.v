module vwebx

import net
import net.http
import time
import strings

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

// Result tipi
pub type Result = string | int | bool | map[string]string

// Middleware fonksiyon tipi
pub type MiddlewareFn = fn (mut Context) bool

// Middleware yapısı
pub struct Middleware {
    pub name string
    pub handler ?MiddlewareFn
    pub is_global bool
}

// Route yapısı
pub struct Route {
    pub method http.Method
    pub path string
    pub handler ?fn (mut Context) Result
}

// App yapısı
pub struct App {
mut:
    pub routes []Route
    pub middleware []Middleware
    pub global_middleware []MiddlewareFn
    pub db Database
    pub Context
}

// Yeni App oluştur
pub fn new_app() &App {
    mut app := &App{
        routes: []Route{}
        middleware: []Middleware{}
        global_middleware: []MiddlewareFn{}
        db: Database{}
        Context: Context{
            headers: map[string]string{}
            app: unsafe { nil }
        }
    }
    app.Context.app = app
    return app
}

// Sunucuyu başlat
pub fn (mut app App) run(port int) {
    println('Server starting on http://localhost:${port}')
    
    // Global middleware'leri ekle
    app.use(logging_middleware)
    
    mut server := net.listen_tcp(.ip, 'localhost:${port}', net.ListenOptions{}) or {
        panic('Failed to start server: ${err}')
    }
    
    for {
        mut conn := server.accept() or {
            continue
        }
        
        go handle_connection(mut conn, mut app)
    }
}

// Bağlantıyı işle
fn handle_connection(mut conn net.TcpConn, mut app App) {
    defer {
        conn.close() or {}
    }
    
    // Request'i oku
    mut buf := []u8{len: 4096}
    n := conn.read(mut buf) or { return }
    if n == 0 { return }
    
    request_str := buf[..n].bytestr()
    lines := request_str.split('\n')
    if lines.len == 0 { return }
    
    // Request satırını parse et
    request_line := lines[0].trim_space()
    parts := request_line.split(' ')
    if parts.len != 3 { return }
    
    method_str := parts[0]
    mut path := parts[1]
    
    // Query parametrelerini parse et
    mut query := map[string]string{}
    if query_start := path.index('?') {
        query_str := path[query_start + 1..]
        path = path[..query_start]
        
        for param in query_str.split('&') {
            param_parts := param.split('=')
            if param_parts.len == 2 {
                query[param_parts[0]] = param_parts[1]
            }
        }
    }
    
    // Method string'ini http.Method'a çevir
    method := match method_str {
        'GET' { http.Method.get }
        'POST' { http.Method.post }
        'PUT' { http.Method.put }
        'DELETE' { http.Method.delete }
        else { http.Method.get }
    }
    
    // Header'ları oku ve content length'i bul
    mut headers := http.new_header()
    mut content_length := 0
    mut body_start := 0
    
    for i := 1; i < lines.len; i++ {
        line := lines[i].trim_space()
        if line == '' { 
            body_start = i + 1
            break 
        }
        
        header_parts := line.split(': ')
        if header_parts.len == 2 {
            headers.add_custom(header_parts[0], header_parts[1]) or {}
            if header_parts[0].to_lower() == 'content-length' {
                content_length = header_parts[1].int()
            }
        }
    }
    
    // Body'yi oku
    mut body := ''
    if content_length > 0 && body_start < lines.len {
        body = lines[body_start..].join('\n')
    }
    
    // Context oluştur
    mut ctx := Context{
        req: http.Request{
            method: method
            url: path
            header: headers
        }
        conn: conn
        headers: map[string]string{}
        start_time: time.now()
        path: path
        method: method_str
        params: map[string]string{}
        query: query
        middleware_index: 0
        middleware_chain: app.global_middleware.clone()
        json_body: body
        app: app
    }
    
    // Route'u bul ve işle
    mut found := false
    for route in app.routes {
        route_parts := route.path.split('/')
        path_parts := path.split('/')
        
        if route_parts.len != path_parts.len {
            continue
        }
        
        mut matches := true
        mut params := map[string]string{}
        
        for i := 0; i < route_parts.len; i++ {
            if route_parts[i].starts_with(':') {
                param_name := route_parts[i][1..]
                params[param_name] = path_parts[i]
            } else if route_parts[i] != path_parts[i] {
                matches = false
                break
            }
        }
        
        if matches && route.method == method {
            for middleware in app.middleware {
                if !middleware.is_global {
                    if handler := middleware.handler {
                        ctx.middleware_chain << handler
                    }
                }
            }
            
            ctx.params = params.clone()
            
            if handler := route.handler {
                if ctx.next() {
                    result := handler(mut ctx)
                    write_response(mut conn, ctx, result)
                    found = true
                }
                break
            }
        }
    }
    
    if !found {
        ctx.status = 404
        write_response(mut conn, ctx, 'Not Found')
    }
}

// Yanıt yaz
fn write_response(mut conn net.TcpConn, ctx Context, result Result) {
    mut response := strings.new_builder(1024)
    
    response.write_string('HTTP/1.1 ${ctx.status} ${get_status_text(ctx.status)}\r\n')
    
    for key, value in ctx.headers {
        response.write_string('${key}: ${value}\r\n')
    }
    
    body := match result {
        string { result }
        map[string]string { '{"error": "JSON serialization not implemented yet"}' }
        else { result.str() }
    }
    
    response.write_string('Content-Length: ${body.len}\r\n')
    response.write_string('\r\n')
    response.write_string(body)
    
    conn.write_string(response.str()) or {}
}

// Status text'i al
fn get_status_text(code int) string {
    return match code {
        200 { 'OK' }
        201 { 'Created' }
        400 { 'Bad Request' }
        404 { 'Not Found' }
        500 { 'Internal Server Error' }
        else { 'Unknown' }
    }
}

// Route ekleme fonksiyonları
pub fn (mut app App) get(path string, handler fn (mut Context) Result) {
    app.routes << Route{
        method: http.Method.get
        path: path
        handler: handler
    }
}

pub fn (mut app App) post(path string, handler fn (mut Context) Result) {
    app.routes << Route{
        method: http.Method.post
        path: path
        handler: handler
    }
}

pub fn (mut app App) put(path string, handler fn (mut Context) Result) {
    app.routes << Route{
        method: http.Method.put
        path: path
        handler: handler
    }
}

pub fn (mut app App) delete(path string, handler fn (mut Context) Result) {
    app.routes << Route{
        method: http.Method.delete
        path: path
        handler: handler
    }
}

// Middleware ekleme fonksiyonları
pub fn (mut app App) use(middleware MiddlewareFn) {
    app.global_middleware << middleware
}

pub fn (mut app App) use_named(name string, middleware MiddlewareFn, is_global bool) {
    app.middleware << Middleware{
        name: name
        handler: middleware
        is_global: is_global
    }
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

// Response helper fonksiyonları
pub fn (mut ctx Context) text(text string) Result {
    ctx.headers['Content-Type'] = 'text/plain'
    ctx.body = text
    return text
}

pub fn (mut ctx Context) json(data map[string]string) Result {
    ctx.headers['Content-Type'] = 'application/json'
    return json.encode(data)
}

pub fn (mut ctx Context) html(html string) Result {
    ctx.headers['Content-Type'] = 'text/html'
    ctx.body = html
    return html
}

pub fn (mut ctx Context) status(code int) {
    ctx.status = code
} 
