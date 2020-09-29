// Imports

extern fn print(msgPtr: *const u8, msgLen: c_uint) void;

extern fn glClearColor(r: f32, g: f32, b: f32, a: f32) void;
extern fn glClear(mask: c_uint) void;

const GL_COLOR_BUFFER_BIT: c_uint = 16384;

// Entry points

export fn init() void {
    const msg = "hello from zig!\n";
    print(&msg[0], msg.len);
}

export fn frame() void {
    glClearColor(0.8, 0.894, 0.96, 1);
    glClear(GL_COLOR_BUFFER_BIT);
}
