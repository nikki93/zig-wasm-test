// Console
//

pub const console = struct {
    extern fn consoleLog(msgPtr: *const u8, msgLen: c_uint) void;
    pub fn log(msg: []const u8) void {
        consoleLog(&msg[0], msg.len);
    }
};

// GL
//

pub const gl = struct {
    // Shaders
    //
    extern fn myglSetupShader(typ: c_uint, sourcePtr: *const u8, sourceLen: c_uint) c_uint;
    pub fn setupShader(typ: c_uint, source: []const u8) c_uint {
        return myglSetupShader(typ, &source[0], source.len);
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
        webglBufferData(target, &data[0], data.len, usage);
    }

    extern fn webglDeleteBuffer(bufferId: c_uint) void;
    pub const deleteBuffer = webglDeleteBuffer;

    // Attributes
    //
    extern fn webglGetAttribLocation(programId: c_uint, namePtr: *const u8, nameLen: c_uint) c_int;
    pub fn getAttribLocation(programId: c_uint, name: []const u8) c_int {
        return webglGetAttribLocation(programId, &name[0], name.len);
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

// UI
//

pub const ui = struct {
    // Elem
    //
    extern fn uiElemOpenStart(tagPtr: *const u8, tagLen: c_uint) void;
    pub fn elemOpenStart(tag: []const u8) void {
        uiElemOpenStart(&tag[0], tag.len);
    }

    extern fn uiElemOpenStartKeyInt(tagPtr: *const u8, tagLen: c_uint, key: c_int) void;
    extern fn uiElemOpenStartKeyStr(tagPtr: *const u8, tagLen: c_uint, keyPtr: *const u8, keyLen: c_uint) void;
    pub fn elemOpenStartKey(tag: []const u8, key: anytype) void {
        // TODO: Fill this in...
    }

    extern fn uiElemOpenEnd() void;
    pub const elemOpenEnd = uiElemOpenEnd;

    extern fn uiElemClose(tagPtr: *const u8, tagLen: c_uint) void;
    pub fn elemClose(tag: []const u8) void {
        uiElemClose(&tag[0], tag.len);
    }

    // Attr
    //
    extern fn uiAttrInt(namePtr: *const u8, nameLen: c_uint, value: c_int) void;
    pub fn attrInt(name: []const u8, value: i32) void {
        uiAttrInt(&name[0], name.len, value);
    }

    extern fn uiAttrDouble(namePtr: *const u8, nameLen: c_uint, value: f64) void;
    pub fn attrDouble(name: []const u8, value: f64) void {
        uiAttrDouble(&name[0], name.len, value);
    }

    pub fn attrBool(name: []const u8, value: bool) void {
        if (value) {
            attrStr(name, "");
        }
    }

    extern fn uiAttrStr(namePtr: *const u8, nameLen: c_uint, valuePtr: *const u8, valueLen: c_uint) void;
    pub fn attrStr(name: []const u8, value: []const u8) void {
        uiAttrStr(&name[0], name.len, &value[0], value.len);
    }

    extern fn uiAttrClass(classPtr: *const u8, classLen: c_uint) void;
    pub fn attrClass(class: []const u8) void {
        uiAttrClass(&class[0], class.len);
    }

    // Text
    //
    extern fn uiText(valuePtr: *const u8, valueLen: c_uint) void;
    pub fn text(value: []const u8) void {
        uiText(&value[0], value.len);
    }
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
    const data = [_]f32{ 0, 0, 0, 0.1 + 0.3 * @sin(t), 0.7, 0 };
    gl.bufferData(gl.ARRAY_BUFFER, data[0..], gl.STREAM_DRAW);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
}

export fn uiSide() void {
    ui.elemOpenStart("div");
    ui.attrClass("info");
    ui.elemOpenEnd();
    ui.text("hello from zig! :O");
    ui.elemClose("div");
}
