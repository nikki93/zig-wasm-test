const util = @import("util.zig");

extern fn consoleLog(msgPtr: *const u8, msgLen: c_uint) void;
pub fn log(msg: []const u8) void {
    consoleLog(util.cPtr(msg), msg.len);
}

const std = @import("std");

pub fn panic(msg: []const u8, trace: ?*std.builtin.StackTrace) noreturn {
    @setCold(true);
    var buf: [512]u8 = undefined;
    log(std.fmt.bufPrint(&buf, "panic: {}", .{msg}) catch "");
    std.builtin.default_panic(msg, trace);
}
