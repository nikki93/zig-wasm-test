extern fn consoleLog(msgPtr: *const u8, msgLen: c_uint) void;
pub fn log(msg: []const u8) void {
    consoleLog(&msg[0], msg.len);
}
