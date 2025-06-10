module vwebx

// Alt modülleri export et
pub use vwebx.server
pub use vwebx.database
pub use vwebx.template
pub use vwebx.json
pub use vwebx.middleware
pub use vwebx.context
pub use vwebx.errors
pub use vwebx.config
pub use vwebx.validator

// Versiyon bilgisi
pub const version = '0.1.0'
pub const author = 'VWebX Contributors'
pub const license = 'MIT'

// Modül açıklaması
pub const description = 'VWebX - V programlama dili için modern web framework'
pub const homepage = 'https://github.com/vwebx/vwebx'
pub const repository = 'https://github.com/vwebx/vwebx.git'

// Bağımlılıklar
pub const dependencies = {
    'v': '>= 0.4.0'
    'db.sqlite': '>= 0.1.0'
}

// Modül yapısı
/*
vwebx/
├── src/
│   ├── server.v     (HTTP sunucu ve routing)
│   ├── database.v   (Veritabanı işlemleri)
│   ├── template.v   (Template engine)
│   ├── json.v       (JSON işlemleri)
│   ├── middleware.v (Middleware yönetimi)
│   ├── context.v    (Context yapısı)
│   ├── errors.v     (Hata yönetimi)
│   ├── config.v     (Konfigürasyon yönetimi)
│   └── validator.v  (Veri doğrulama)
├── examples/
│   └── hello_world.v
├── v.mod
├── vwebx.v
├── LICENSE
├── README.md
└── .gitignore
*/

// Örnek kullanım
/*
import vwebx

struct App {
    vwebx.App
}

fn new_app() &App {
    mut app := &App{
        App: vwebx.new_app()
    }
    return app
}

fn (mut app App) index() vwebx.Result {
    return app.text('Hello, VWebX!')
}

fn main() {
    mut app := new_app()
    app.get('/', app.index)
    app.run()
}
*/ 