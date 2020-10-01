// Console

const console = struct {
    extern fn consoleLog(msgPtr: *const u8, msgLen: c_uint) void;

    pub fn log(msg: []const u8) void {
        consoleLog(&msg[0], msg.len);
    }
};

// GL

const gl = struct {
    extern fn glClearColor(r: f32, g: f32, b: f32, a: f32) void;
    pub const clearColor = glClearColor;

    extern fn glClear(mask: c_uint) void;
    pub const clear = glClear;

    pub const COLOR_BUFFER_BIT: c_uint = 16384;
};

// Entry points

export fn init() void {
    console.log("hello from zig!\n");
}

export fn frame(millis: f32) void {
    const t = 0.001 * millis;
    gl.clearColor(0.3 + 0.6 * @sin(t), 0.2, 0.6, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);
}
