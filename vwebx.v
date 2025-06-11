module vwebx

// Alt modülleri import et
import vwebx.server
import vwebx.database
import vwebx.template
import vwebx.middleware
import vwebx.validator
import vwebx.json
import vwebx.errors
import vwebx.context
import vwebx.config

// Server modülünü dışarıya aç
pub type App = server.App
pub type Context = context.Context
pub type Result = server.Result
pub type Route = server.Route
pub type Middleware = middleware.Middleware
pub type MiddlewareFn = middleware.MiddlewareFn

// Server fonksiyonlarını dışarıya aç
pub fn new_app() App {
    return server.new_app()
}

pub fn (mut app App) get(path string, handler fn (mut Context) string) {
    app.server.get(path, handler)
}

pub fn (mut app App) post(path string, handler fn (mut Context) string) {
    app.server.post(path, handler)
}

pub fn (mut app App) put(path string, handler fn (mut Context) string) {
    app.server.put(path, handler)
}

pub fn (mut app App) delete(path string, handler fn (mut Context) string) {
    app.server.delete(path, handler)
}

pub fn (mut app App) patch(path string, handler fn (mut Context) string) {
    app.server.patch(path, handler)
}

pub fn (mut app App) options(path string, handler fn (mut Context) string) {
    app.server.options(path, handler)
}

pub fn (mut app App) head(path string, handler fn (mut Context) string) {
    app.server.head(path, handler)
}

pub fn (mut app App) use(middleware Middleware) {
    app.server.use(middleware)
}

pub fn (mut app App) run(port int) {
    app.server.run(port)
}

// Context fonksiyonlarını dışarıya aç
pub fn (mut ctx Context) text(text string) Result {
    return context.text(mut ctx, text)
}

pub fn (mut ctx Context) json(data any) Result {
    return context.json(mut ctx, data)
}

pub fn (mut ctx Context) html(html string) Result {
    return context.html(mut ctx, html)
}

pub fn (mut ctx Context) status(code int) {
    context.status(mut ctx, code)
}

pub fn (mut ctx Context) redirect(url string) Result {
    return context.redirect(mut ctx, url)
}

pub fn (mut ctx Context) file(path string) !Result {
    return context.file(mut ctx, path)
}

// Database fonksiyonlarını dışarıya aç
pub type Database = database.Database
pub type User = database.User

pub fn init_db() !Database {
    return database.init_db()
}

// Template fonksiyonlarını dışarıya aç
pub type Template = template.Template

pub fn load_template(path string) !Template {
    return template.load_template(path)
}

pub fn template_from_string(content string) Template {
    return template.template_from_string(content)
}

// Validator fonksiyonlarını dışarıya aç
pub type ValidationError = validator.ValidationError
pub type ValidationResult = validator.ValidationResult
pub type StringRules = validator.StringRules
pub type NumberRules = validator.NumberRules
pub type DateRules = validator.DateRules

pub fn validate_string(value string, rules StringRules) ValidationResult {
    return validator.validate_string(value, rules)
}

pub fn validate_number(value f64, rules NumberRules) ValidationResult {
    return validator.validate_number(value, rules)
}

pub fn validate_date(value time.Time, rules DateRules) ValidationResult {
    return validator.validate_date(value, rules)
}

pub fn validate_email(value string) ValidationResult {
    return validator.validate_email(value)
}

pub fn validate_url(value string) ValidationResult {
    return validator.validate_url(value)
}

pub fn validate_phone(value string) ValidationResult {
    return validator.validate_phone(value)
}

pub fn validate_password(value string) ValidationResult {
    return validator.validate_password(value)
}

// JSON fonksiyonlarını dışarıya aç
pub fn json_response(data any, status int) string {
    return json.json_response(data, status)
}

pub fn json_error(message string, status int) string {
    return json.json_error(message, status)
}

pub fn json_success(data any) string {
    return json.json_success(data)
}

pub fn json_list[T](items []T) string {
    return json.json_list(items)
}

pub fn json_paginated[T](items []T, page int, per_page int, total int) string {
    return json.json_paginated(items, page, per_page, total)
}

// Error fonksiyonlarını dışarıya aç
pub type HttpError = errors.HttpError
pub type ValidationErrors = errors.ValidationErrors
pub type DatabaseError = errors.DatabaseError
pub type FileError = errors.FileError

pub fn new_error(code int, message string, details string) HttpError {
    return errors.new_error(code, message, details)
}

pub fn bad_request(message string, details string) HttpError {
    return errors.bad_request(message, details)
}

pub fn unauthorized(message string, details string) HttpError {
    return errors.unauthorized(message, details)
}

pub fn forbidden(message string, details string) HttpError {
    return errors.forbidden(message, details)
}

pub fn not_found(message string, details string) HttpError {
    return errors.not_found(message, details)
}

pub fn method_not_allowed(message string, details string) HttpError {
    return errors.method_not_allowed(message, details)
}

pub fn conflict(message string, details string) HttpError {
    return errors.conflict(message, details)
}

pub fn too_many_requests(message string, details string) HttpError {
    return errors.too_many_requests(message, details)
}

pub fn internal_server_error(message string, details string) HttpError {
    return errors.internal_server_error(message, details)
}

// Config fonksiyonlarını dışarıya aç
pub type Config = config.Config

pub fn load_config(path string) !Config {
    return config.load_config(path)
}

pub fn default_config() Config {
    return config.default_config()
} 
