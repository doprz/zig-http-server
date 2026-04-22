const std = @import("std");
const log = std.log.scoped(.server);

const LISTEN_ADDR = "127.0.0.1";
const LISTEN_PORT = 8000;

fn startServer(io: std.Io) !void {
    log.info("Listening on http://{s}:{d}", .{ LISTEN_ADDR, LISTEN_PORT });
    const addr = std.Io.net.IpAddress.parseIp4(LISTEN_ADDR, LISTEN_PORT) catch unreachable;

    // TCP layer: bind the port and accept the raw streams
    var server = try addr.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    while (true) {
        log.info("Waiting for connection...", .{});
        var stream = try server.accept(io);
        defer stream.close(io);
        log.info("TCP connection established", .{});

        // Wrap the raw stream in buffered Io.Reader / Io.Writer
        var read_buffer: [1024]u8 = undefined;
        var write_buffer: [1024]u8 = undefined;
        var reader = stream.reader(io, &read_buffer);
        var writer = stream.writer(io, &write_buffer);

        // HTTP layer: parse the byte stream at HTTP/1.1
        var http_server = std.http.Server.init(&reader.interface, &writer.interface);
        var req = try http_server.receiveHead();
        log.info("{s} {s}", .{ @tagName(req.head.method), req.head.target });

        try req.respond("Hello World!", .{ .status = .ok });
        log.info("Response sent, closing connection", .{});
    }
}

pub fn main(init: std.process.Init) !void {
    log.info("Starting server", .{});
    try startServer(init.io);
}
