# zig-http-server

A simple yet performant HTTP/1.1 server written in Zig 0.16

~50 lines of Zig standard library code, no external dependencies, and it matches Caddy's throughput on a Hello World benchmark (~448k req/s).

## Requirements
- Zig 0.16

## Files
| File | Description |
| -------------- | --------------- |
| `main.zig` | Minimal single-connection HTTP/1.1 server |
| `main-async.zig` | Concurrent version using `std.Io.Group`, keep-alive, and tuned buffers |

## Blog Post
- Zig 0.16's new `Io` instance and "Juicy Main"
- The two-layer model: TCP server vs. HTTP server
- Adding concurrency with `std.Io.Group`
- Keep-alive connections, buffer tuning, and logging tradeoffs
- Benchmarking against Caddy with `wrk`

> [Read the full blog post here ->](https://doprz.dev/blog/posts/zig-http-server/) 

## License
MIT
