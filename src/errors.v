module vwebx

// HTTP hata kodları
pub const (
    status_ok = 200
    status_created = 201
    status_no_content = 204
    status_bad_request = 400
    status_unauthorized = 401
    status_forbidden = 403
    status_not_found = 404
    status_method_not_allowed = 405
    status_conflict = 409
    status_too_many_requests = 429
    status_internal_server_error = 500
    status_bad_gateway = 502
    status_service_unavailable = 503
)

// HTTP hata mesajları
pub const status_text = {
    status_ok: 'OK'
    status_created: 'Created'
    status_no_content: 'No Content'
    status_bad_request: 'Bad Request'
    status_unauthorized: 'Unauthorized'
    status_forbidden: 'Forbidden'
    status_not_found: 'Not Found'
    status_method_not_allowed: 'Method Not Allowed'
    status_conflict: 'Conflict'
    status_too_many_requests: 'Too Many Requests'
    status_internal_server_error: 'Internal Server Error'
    status_bad_gateway: 'Bad Gateway'
    status_service_unavailable: 'Service Unavailable'
}

// HTTP hata yapısı
pub struct HttpError {
    pub code int
    pub message string
    pub details string
}

// HTTP hatası oluştur
pub fn new_error(code int, message string, details string) HttpError {
    return HttpError{
        code: code
        message: message
        details: details
    }
}

// Yaygın hatalar
pub fn bad_request(message string, details string) HttpError {
    return new_error(status_bad_request, message, details)
}

pub fn unauthorized(message string, details string) HttpError {
    return new_error(status_unauthorized, message, details)
}

pub fn forbidden(message string, details string) HttpError {
    return new_error(status_forbidden, message, details)
}

pub fn not_found(message string, details string) HttpError {
    return new_error(status_not_found, message, details)
}

pub fn method_not_allowed(message string, details string) HttpError {
    return new_error(status_method_not_allowed, message, details)
}

pub fn conflict(message string, details string) HttpError {
    return new_error(status_conflict, message, details)
}

pub fn too_many_requests(message string, details string) HttpError {
    return new_error(status_too_many_requests, message, details)
}

pub fn internal_server_error(message string, details string) HttpError {
    return new_error(status_internal_server_error, message, details)
}

// Hata yanıtı oluştur
pub fn error_response(err HttpError) string {
    return json.encode({
        'error': err.message
        'details': err.details
        'status': err.code
    }) or { '{"error": "Failed to encode error response"}' }
}

// Panic handler
pub fn panic_handler(mut ctx Context) {
    if err := recover() {
        ctx.status = status_internal_server_error
        ctx.json(error_response(internal_server_error(
            'Internal Server Error',
            err.str()
        )))
    }
}

// Validation error
pub struct ValidationError {
    pub field string
    pub message string
}

pub struct ValidationErrors {
    pub errors []ValidationError
}

pub fn (err ValidationErrors) str() string {
    mut messages := []string{}
    for e in err.errors {
        messages << '${e.field}: ${e.message}'
    }
    return messages.join(', ')
}

// Database error
pub struct DatabaseError {
    pub operation string
    pub message string
    pub details string
}

pub fn (err DatabaseError) str() string {
    return 'Database error during ${err.operation}: ${err.message} (${err.details})'
}

// File error
pub struct FileError {
    pub operation string
    pub path string
    pub message string
}

pub fn (err FileError) str() string {
    return 'File error during ${err.operation} on ${err.path}: ${err.message}'
} 
