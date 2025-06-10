module LowLeery.vwebx

import db.sqlite
import time
import json

// Database yapısı
pub struct Database {
    db sqlite.DB
}

// User modeli
pub struct User {
    pub id int @[primary; sql: serial]
    pub name string
    pub email string @[unique]
    pub age int
    pub created_at time.Time @[sql: 'DEFAULT CURRENT_TIMESTAMP']
}

// Database'i başlat
pub fn init_db() !Database {
    db := sqlite.connect('vwebx.db')!
    
    // Users tablosunu oluştur
    db.exec("CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        age INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )")!
    
    return Database{db: db}
}

// Database işlemleri için fonksiyonlar
pub fn (db Database) create_user(user User) !User {
    // Email kontrolü
    existing := db.db.exec('SELECT id FROM users WHERE email = "${user.email}"')!
    if existing.len > 0 {
        return error('Email already exists')
    }
    
    // User'ı ekle
    db.db.exec('INSERT INTO users (name, email, age) VALUES ("${user.name}", "${user.email}", ${user.age})')!
    
    // Eklenen user'ı getir
    row := db.db.exec('SELECT * FROM users WHERE email = "${user.email}"')!
    if row.len == 0 {
        return error('Failed to fetch created user')
    }
    
    return User{
        id: row[0].vals[0].int()
        name: row[0].vals[1]
        email: row[0].vals[2]
        age: row[0].vals[3].int()
        created_at: time.parse(row[0].vals[4])!
    }
}

pub fn (db Database) get_user(id int) !User {
    row := db.db.exec('SELECT * FROM users WHERE id = ${id}')!
    if row.len == 0 {
        return error('User not found')
    }
    
    return User{
        id: row[0].vals[0].int()
        name: row[0].vals[1]
        email: row[0].vals[2]
        age: row[0].vals[3].int()
        created_at: time.parse(row[0].vals[4])!
    }
}

pub fn (db Database) get_all_users() ![]User {
    rows := db.db.exec('SELECT * FROM users ORDER BY created_at DESC')!
    mut users := []User{}
    
    for row in rows {
        users << User{
            id: row.vals[0].int()
            name: row.vals[1]
            email: row.vals[2]
            age: row.vals[3].int()
            created_at: time.parse(row.vals[4])!
        }
    }
    
    return users
}

pub fn (db Database) update_user(id int, user User) !User {
    // Önce kullanıcının var olduğunu kontrol et
    existing := db.db.exec('SELECT id FROM users WHERE id = ${id}')!
    if existing.len == 0 {
        return error('User not found')
    }
    
    // Email değişiyorsa, yeni email'in başka kullanıcıda olmadığından emin ol
    if user.email != '' {
        email_check := db.db.exec('SELECT id FROM users WHERE email = "${user.email}" AND id != ${id}')!
        if email_check.len > 0 {
            return error('Email already exists')
        }
    }
    
    // Güncelleme sorgusunu oluştur
    mut updates := []string{}
    if user.name != '' {
        updates << 'name = "${user.name}"'
    }
    if user.email != '' {
        updates << 'email = "${user.email}"'
    }
    if user.age > 0 {
        updates << 'age = ${user.age}'
    }
    
    if updates.len == 0 {
        return error('No fields to update')
    }
    
    // Güncelleme sorgusunu çalıştır
    update_query := 'UPDATE users SET ${updates.join(', ')} WHERE id = ${id}'
    db.db.exec(update_query)!
    
    // Güncellenmiş kullanıcıyı getir
    return db.get_user(id)
}

pub fn (db Database) delete_user(id int) ! {
    // Önce kullanıcının var olduğunu kontrol et
    existing := db.db.exec('SELECT id FROM users WHERE id = ${id}')!
    if existing.len == 0 {
        return error('User not found')
    }
    
    // Kullanıcıyı sil
    db.db.exec('DELETE FROM users WHERE id = ${id}')!
} 
