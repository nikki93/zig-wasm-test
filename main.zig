//
// JS imports
//

extern fn JS_print(msgPtr: *const u8, msgLen: c_uint) void;

export fn init() void {
    const msg = "woah!\n";
    JS_print(&msg[0], msg.len);
}

export fn frame() void {}
