// JS imports

extern fn JS_print(msgPtr: *const u8, msgLen: c_uint) void;

// Entry points

export fn init() void {
    const msg = "hello from zig!\n";
    JS_print(&msg[0], msg.len);
}
