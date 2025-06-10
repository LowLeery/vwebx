import vwebx

// Uygulama yapısı
struct HelloApp {
    vwebx.App
}

// Yeni uygulama oluştur
fn new_app() HelloApp {
    return HelloApp{
        app: vwebx.new_app()
    }
}

// Ana sayfa
fn (mut app HelloApp) index(ctx vwebx.Context) vwebx.Result {
    template := vwebx.template_from_string('
        <!DOCTYPE html>
        <html>
        <head>
            <title>VWebX Example</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                h1 { color: #333; }
                .container { max-width: 800px; margin: 0 auto; }
                .card { background: #f5f5f5; padding: 20px; border-radius: 5px; margin: 20px 0; }
                .btn { background: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 3px; cursor: pointer; }
                .btn:hover { background: #0056b3; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Welcome to VWebX!</h1>
                <div class="card">
                    <h2>Features</h2>
                    <ul>
                        <li>Fast HTTP Server</li>
                        <li>Flexible Routing</li>
                        <li>Middleware Support</li>
                        <li>JSON Processing</li>
                        <li>Template Engine</li>
                        <li>SQLite Integration</li>
                        <li>Simple CRUD Operations</li>
                    </ul>
                </div>
                <div class="card">
                    <h2>API Endpoints</h2>
                    <ul>
                        <li>GET /api/users - List all users</li>
                        <li>POST /api/users - Create a new user</li>
                        <li>GET /api/users/:id - Get a user by ID</li>
                        <li>PUT /api/users/:id - Update a user</li>
                        <li>DELETE /api/users/:id - Delete a user</li>
                    </ul>
                </div>
                <a href="/api/users" class="btn">View Users</a>
            </div>
        </body>
        </html>
    ')
    
    return ctx.html(template.render({}))
}

// Kullanıcı listesi
fn (mut app HelloApp) list_users(ctx vwebx.Context) vwebx.Result {
    users := app.db.get_all_users()!
    return ctx.json(vwebx.json_list(users))
}

// Kullanıcı oluştur
fn (mut app HelloApp) create_user(ctx vwebx.Context) vwebx.Result {
    user := vwebx.bind_json[vwebx.User](ctx.req.body)!
    
    // Validasyon
    if user.name.len < 2 {
        return ctx.json(vwebx.json_error('Name must be at least 2 characters', 400))
    }
    if user.age < 18 {
        return ctx.json(vwebx.json_error('Age must be at least 18', 400))
    }
    
    // Kullanıcıyı oluştur
    new_user := app.db.create_user(user)!
    return ctx.json(vwebx.json_success(new_user))
}

// Kullanıcı getir
fn (mut app HelloApp) get_user(ctx vwebx.Context) vwebx.Result {
    id := ctx.req.params['id'].int()
    user := app.db.get_user(id)!
    return ctx.json(vwebx.json_success(user))
}

// Kullanıcı güncelle
fn (mut app HelloApp) update_user(ctx vwebx.Context) vwebx.Result {
    id := ctx.req.params['id'].int()
    user := vwebx.bind_json[vwebx.User](ctx.req.body)!
    
    // Validasyon
    if user.name.len > 0 && user.name.len < 2 {
        return ctx.json(vwebx.json_error('Name must be at least 2 characters', 400))
    }
    if user.age > 0 && user.age < 18 {
        return ctx.json(vwebx.json_error('Age must be at least 18', 400))
    }
    
    // Kullanıcıyı güncelle
    updated_user := app.db.update_user(id, user)!
    return ctx.json(vwebx.json_success(updated_user))
}

// Kullanıcı sil
fn (mut app HelloApp) delete_user(ctx vwebx.Context) vwebx.Result {
    id := ctx.req.params['id'].int()
    app.db.delete_user(id)!
    return ctx.json(vwebx.json_success({
        'message': 'User deleted successfully'
    }))
}

fn main() {
    // Yeni uygulama oluştur
    mut app := new_app()
    
    // Database'i başlat
    db := vwebx.init_db()!
    app.db = db
    
    // Route'ları tanımla
    app.get('/', app.index)
    app.get('/api/users', app.list_users)
    app.post('/api/users', app.create_user)
    app.get('/api/users/:id', app.get_user)
    app.put('/api/users/:id', app.update_user)
    app.delete('/api/users/:id', app.delete_user)
    
    // Sunucuyu başlat
    println('Server running at http://localhost:8080')
    app.run(':8080')!
} 