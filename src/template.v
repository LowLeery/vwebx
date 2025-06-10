module vwebx

import os
import strings

// Template yapısı
pub struct Template {
    content string
}

// Template'i dosyadan yükle
pub fn load_template(path string) !Template {
    if !os.exists(path) {
        return error('Template file not found: ${path}')
    }
    
    content := os.read_file(path)!
    return Template{content: content}
}

// Template'i string'den yükle
pub fn template_from_string(content string) Template {
    return Template{content: content}
}

// Template'i render et
pub fn (t Template) render(data map[string]string) string {
    mut result := t.content
    
    for key, value in data {
        placeholder := '{{' + key + '}}'
        result = result.replace(placeholder, value)
    }
    
    return result
}

// HTML escape
pub fn html_escape(s string) string {
    return s.replace('&', '&amp;')
        .replace('<', '&lt;')
        .replace('>', '&gt;')
        .replace('"', '&quot;')
        .replace("'", '&#39;')
}

// Template'i HTML escape ile render et
pub fn (t Template) render_safe(data map[string]string) string {
    mut safe_data := map[string]string{}
    
    for key, value in data {
        safe_data[key] = html_escape(value)
    }
    
    return t.render(safe_data)
} 
