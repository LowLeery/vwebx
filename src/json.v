module LowLeery.vwebx

import json

// JSON işleme fonksiyonları
pub fn json_response(data any, status int) string {
    return json.encode(data) or { '{"error": "Failed to encode JSON"}' }
}

pub fn json_error(message string, status int) string {
    return json.encode({
        'error': message
        'status': status
    }) or { '{"error": "Failed to encode JSON"}' }
}

pub fn parse_json[T](data string) !T {
    return json.decode(T, data) or { return error('Failed to parse JSON: ${err}') }
}

pub fn bind_json[T](data string) !T {
    return parse_json[T](data)
}

pub fn json_success(data any) string {
    return json.encode({
        'success': true
        'data': data
    }) or { '{"error": "Failed to encode JSON"}' }
}

pub fn json_list[T](items []T) string {
    return json.encode(items) or { '{"error": "Failed to encode JSON"}' }
}

pub fn json_paginated[T](items []T, page int, per_page int, total int) string {
    return json.encode({
        'items': items
        'page': page
        'per_page': per_page
        'total': total
        'total_pages': (total + per_page - 1) / per_page
    }) or { '{"error": "Failed to encode JSON"}' }
} 
