// Console
//

const console = struct {
    extern fn consoleLog(msgPtr: *const u8, msgLen: c_uint) void;
    pub fn log(msg: []const u8) void {
        consoleLog(&msg[0], msg.len);
    }
};

// GL
//

const gl = struct {
    // Shaders
    //
    extern fn myglSetupShader(typ: c_uint, sourcePtr: *const u8, sourceLen: c_uint) c_uint;
    fn setupShader(typ: c_uint, source: []const u8) c_uint {
        return myglSetupShader(typ, &source[0], source.len);
    }

    extern fn webglDeleteShader(shaderId: c_uint) void;
    const deleteShader = webglDeleteShader;

    // Programs
    //
    extern fn myglSetupProgram(vertId: c_uint, fragId: c_uint) c_uint;
    const setupProgram = myglSetupProgram;

    extern fn webglDeleteProgram(programId: c_uint) void;
    const deleteProgram = webglDeleteProgram;

    extern fn webglUseProgram(programId: c_uint) void;
    const useProgram = webglUseProgram;

    // Buffers
    //
    extern fn webglCreateBuffer() c_uint;
    const createBuffer = webglCreateBuffer;

    extern fn webglBindBuffer(target: c_uint, bufferId: c_uint) void;
    const bindBuffer = webglBindBuffer;

    extern fn webglBufferData(target: c_uint, dataPtr: *const f32, dataLen: c_uint, usage: c_uint) void;
    fn bufferData(target: c_uint, data: []const f32, usage: c_uint) void {
        webglBufferData(target, &data[0], data.len, usage);
    }

    extern fn webglDeleteBuffer(bufferId: c_uint) void;
    const deleteBuffer = webglDeleteBuffer;

    // Attributes
    //
    extern fn webglGetAttribLocation(programId: c_uint, namePtr: *const u8, nameLen: c_uint) c_int;
    fn getAttribLocation(programId: c_uint, name: []const u8) c_int {
        return webglGetAttribLocation(programId, &name[0], name.len);
    }

    extern fn webglEnableVertexAttribArray(index: c_int) void;
    const enableVertexAttribArray = webglEnableVertexAttribArray;

    extern fn webglDisableVertexAttribArray(index: c_int) void;
    const disableVertexAttribArray = webglDisableVertexAttribArray;

    extern fn webglVertexAttribPointer(
        index: c_int,
        size: c_uint,
        type: c_uint,
        normalize: bool,
        stride: c_uint,
        offset: c_uint,
    ) void;
    const vertexAttribPointer = webglVertexAttribPointer;

    // Draw
    //
    extern fn myglSetupViewport() void;
    const setupViewport = myglSetupViewport;

    extern fn webglClearColor(r: f32, g: f32, b: f32, a: f32) void;
    pub const clearColor = webglClearColor;

    extern fn webglClear(mask: c_uint) void;
    pub const clear = webglClear;

    extern fn webglDrawArrays(mode: c_uint, first: c_int, count: c_int) void;
    pub const drawArrays = webglDrawArrays;

    // Constants
    //
    const ARRAY_BUFFER: c_uint = 34962;
    const COLOR_BUFFER_BIT: c_uint = 16384;
    const FLOAT: c_uint = 5126;
    const FRAGMENT_SHADER: c_uint = 35632;
    const STATIC_DRAW: c_uint = 35044;
    const TRIANGLES: c_uint = 4;
    const VERTEX_SHADER: c_uint = 35633;
};

// Main
//

const vertSrc =
    \\attribute vec4 a_position;
    \\void main() {
    \\  gl_Position = a_position;
    \\}
;

const fragSrc =
    \\precision mediump float;
    \\void main() {
    \\  gl_FragColor = vec4(1, 0, 0.5, 1);
    \\}
;

var prog: c_uint = undefined;
var buf: c_uint = undefined;

export fn init() void {
    console.log("hello from zig!\n");

    const vert = gl.setupShader(gl.VERTEX_SHADER, vertSrc);
    defer gl.deleteShader(vert);
    const frag = gl.setupShader(gl.FRAGMENT_SHADER, fragSrc);
    defer gl.deleteShader(frag);
    prog = gl.setupProgram(vert, frag);

    buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    const data = [_]f32{ 0, 0, 0, 0.5, 0.7, 0 };
    gl.bufferData(gl.ARRAY_BUFFER, data[0..], gl.STATIC_DRAW);

    const pos = gl.getAttribLocation(prog, "a_position");
    gl.enableVertexAttribArray(pos);
    gl.vertexAttribPointer(pos, 2, gl.FLOAT, false, 0, 0);
}

export fn deinit() void {
    gl.deleteBuffer(buf);
    gl.deleteProgram(prog);
}

export fn frame(millis: f32) void {
    gl.setupViewport();

    const t = 0.001 * millis;
    gl.clearColor(0.2, 0.1, 0.1 + 0.3 * @sin(t), 1);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.useProgram(prog);
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
}
