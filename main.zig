// Imports

extern fn print_(msgPtr: *const u8, msgLen: c_uint) void;
fn print(msg: []const u8) void {
    print_(&msg[0], msg.len);
}

extern fn glClearColor(r: f32, g: f32, b: f32, a: f32) void;
extern fn glClear(mask: c_uint) void;

const GL_COLOR_BUFFER_BIT: c_uint = 16384;

// Entry points

export fn init() void {
    print("hello from zig!\n");
}

export fn frame() void {
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
}
