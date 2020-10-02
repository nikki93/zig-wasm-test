const util = @import("util.zig");

pub const gl = struct {
    // Shaders
    //
    extern fn myglSetupShader(typ: c_uint, sourcePtr: *const u8, sourceLen: c_uint) c_uint;
    pub fn setupShader(typ: c_uint, source: []const u8) c_uint {
        return myglSetupShader(typ, util.cPtr(source), source.len);
    }

    extern fn webglDeleteShader(shaderId: c_uint) void;
    pub const deleteShader = webglDeleteShader;

    // Programs
    //
    extern fn myglSetupProgram(vertId: c_uint, fragId: c_uint) c_uint;
    pub const setupProgram = myglSetupProgram;

    extern fn webglDeleteProgram(programId: c_uint) void;
    pub const deleteProgram = webglDeleteProgram;

    extern fn webglUseProgram(programId: c_uint) void;
    pub const useProgram = webglUseProgram;

    // Buffers
    //
    extern fn webglCreateBuffer() c_uint;
    pub const createBuffer = webglCreateBuffer;

    extern fn webglBindBuffer(target: c_uint, bufferId: c_uint) void;
    pub const bindBuffer = webglBindBuffer;

    extern fn webglBufferData(target: c_uint, dataPtr: *const f32, dataLen: c_uint, usage: c_uint) void;
    pub fn bufferData(target: c_uint, data: []const f32, usage: c_uint) void {
        webglBufferData(target, util.cPtr(data), data.len, usage);
    }

    extern fn webglDeleteBuffer(bufferId: c_uint) void;
    pub const deleteBuffer = webglDeleteBuffer;

    // Attributes
    //
    extern fn webglGetAttribLocation(programId: c_uint, namePtr: *const u8, nameLen: c_uint) c_int;
    pub fn getAttribLocation(programId: c_uint, name: []const u8) c_int {
        return webglGetAttribLocation(programId, util.cPtr(name), name.len);
    }

    extern fn webglEnableVertexAttribArray(index: c_int) void;
    pub const enableVertexAttribArray = webglEnableVertexAttribArray;

    extern fn webglDisableVertexAttribArray(index: c_int) void;
    pub const disableVertexAttribArray = webglDisableVertexAttribArray;

    extern fn webglVertexAttribPointer(
        index: c_int,
        size: c_uint,
        type: c_uint,
        normalize: bool,
        stride: c_uint,
        offset: c_uint,
    ) void;
    pub const vertexAttribPointer = webglVertexAttribPointer;

    // Draw
    //
    extern fn myglSetupViewport() void;
    pub const setupViewport = myglSetupViewport;

    extern fn webglClearColor(r: f32, g: f32, b: f32, a: f32) void;
    pub const clearColor = webglClearColor;

    extern fn webglClear(mask: c_uint) void;
    pub const clear = webglClear;

    extern fn webglDrawArrays(mode: c_uint, first: c_int, count: c_int) void;
    pub const drawArrays = webglDrawArrays;

    // Constants
    //
    pub const ARRAY_BUFFER: c_uint = 0x8892;
    pub const COLOR_BUFFER_BIT: c_uint = 0x00004000;
    pub const FLOAT: c_uint = 0x1406;
    pub const FRAGMENT_SHADER: c_uint = 0x8B30;
    pub const STREAM_DRAW: c_uint = 0x88E0;
    pub const STATIC_DRAW: c_uint = 0x88E4;
    pub const DYNAMIC_DRAW: c_uint = 0x88E8;
    pub const TRIANGLES: c_uint = 0x0004;
    pub const VERTEX_SHADER: c_uint = 0x8B31;
};
