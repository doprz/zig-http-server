const std = @import("std");
const log = std.log.scoped(.server);

const LISTEN_ADDR = "127.0.0.1";
const LISTEN_PORT = 8000;

fn handleStream(io: std.Io, stream: std.Io.net.Stream) void {
    defer stream.close(io);

    var read_buffer: [4096]u8 = undefined;
    var write_buffer: [4096]u8 = undefined;
    var reader = stream.reader(io, &read_buffer);
    var writer = stream.writer(io, &write_buffer);

    var http_server = std.http.Server.init(&reader.interface, &writer.interface);

    while (true) {
        var req = http_server.receiveHead() catch |err| switch (err) {
            error.HttpConnectionClosing => return,
            else => return,
        };

        req.respond("Hello World!", .{ .status = .ok }) catch |err| {
            log.err("failed to respond: {}", .{err});
        };
    }
}

fn startServer(io: std.Io) !void {
    log.info("Listening on http://{s}:{d}", .{ LISTEN_ADDR, LISTEN_PORT });

    const addr = std.Io.net.IpAddress.parseIp4(LISTEN_ADDR, LISTEN_PORT) catch unreachable;
    var server = try addr.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    var group: std.Io.Group = .init;
    defer group.cancel(io);

    while (true) {
        const stream = try server.accept(io);
        group.async(io, handleStream, .{ io, stream });
    }

    try group.await(io);
}

pub fn main(init: std.process.Init) !void {
    try startServer(init.io);
}
