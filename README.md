# VWebX

[![V Version](https://img.shields.io/badge/V-0.4.0-blue.svg)](https://vlang.io)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-latest-brightgreen.svg)](https://vwebx.github.io/docs)
[![GitHub Stars](https://img.shields.io/github/stars/LowLeery/vwebx?style=social)](https://github.com/LowLeery/vwebx/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/LowLeery/vwebx?style=social)](https://github.com/LowLeery/vwebx/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/LowLeery/vwebx)](https://github.com/LowLeery/vwebx/issues)

A modern, fast, and flexible web framework for the V programming language.

## Features

- 🚀 **High Performance**: Built on V's fast HTTP server
- 🔌 **Middleware Support**: Easy to extend with custom middleware
- 📦 **JSON Processing**: Built-in JSON encoding/decoding
- 🎨 **Template Engine**: Simple and powerful templating
- 💾 **Database Integration**: SQLite support out of the box
- 🔒 **Security**: Built-in security features
- 📝 **Validation**: Request validation and sanitization
- ⚙️ **Configuration**: Flexible configuration system
- 🛠 **Developer Experience**: Clean API and helpful error messages

## Quick Start

### Installation

```bash
v install vwebx
```

### Basic Example

```v
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
    return app.json({
        'message': 'Hello, VWebX!'
    })
}

fn main() {
    mut app := new_app()
    app.get('/', app.index)
    app.run()
}
```

## Documentation

For detailed documentation, visit [vwebx.github.io/docs](https://vwebx.github.io/docs)

### API Reference

#### HTTP Methods

```v
app.get('/path', handler)
app.post('/path', handler)
app.put('/path', handler)
app.delete('/path', handler)
```

#### Middleware

```v
app.use(middleware_fn)
app.use_global(global_middleware_fn)
```

#### Response Helpers

```v
ctx.text('Hello')      // Text response
ctx.json(data)         // JSON response
ctx.html('<h1>Hi</h1>') // HTML response
ctx.file('file.txt')   // File response
```

## Examples

Check out the [examples](examples/) directory for more usage examples:

- [Hello World](examples/hello_world.v)
- [REST API](examples/rest_api.v)
- [Template Usage](examples/template.v)
- [Database Integration](examples/database.v)

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [ ] Authentication & Authorization
- [ ] WebSocket Support
- [ ] PostgreSQL Support
- [ ] Redis Integration
- [ ] GraphQL Support
- [ ] OpenAPI/Swagger Integration
- [ ] Testing Framework
- [ ] CLI Tool

## Community

- [Discord Server](https://discord.gg/vwebx)
- [GitHub Discussions](https://github.com/vwebx/vwebx/discussions)
- [Twitter](https://twitter.com/vwebx)

## License

VWebX is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [V Programming Language](https://vlang.io)
- [All Contributors](https://github.com/vwebx/vwebx/graphs/contributors)

---

Made with ❤️ by the VWebX Contributors 
