const console = @import("console.zig");
const gl = @import("gfx.zig").gl;
const ui = @import("ui.zig");

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

var height: i32 = 0;

export fn frame(millis: f32) void {
    gl.setupViewport();

    const t = 0.001 * millis;
    gl.clearColor(0.2, 0.1, 0.1 + 0.3 * @sin(t), 1);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.useProgram(prog);
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    const data = [_]f32{ 0, 0, 0, @intToFloat(f32, height) * 0.1, 0.7, 0 };
    gl.bufferData(gl.ARRAY_BUFFER, data[0..], gl.STREAM_DRAW);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
}

const std = @import("std");

export fn uiSide() void {
    ui.elemOpen("div", .{ .class = "container" });
    ui.text("hello from zig! :O");
    ui.elemClose("div");

    ui.elemOpen("div", .{ .class = "container" });
    ui.elem("img", .{ .src = "https://ziglang.org/img/zig-logo-light.svg" });
    ui.elemClose("div");

    ui.elemOpen("div", .{ .style = "overflow-y: scroll" });
    var i: i32 = 0;
    while (i < 50) : (i += 1) {
        ui.elemOpenKey("div", i, .{ .class = "container", .style = "flex-direction: row" });
        {
            ui.elemOpen("button", .{ .class = "plus" });
            height += ui.events("click");
            ui.elemClose("button");

            ui.elemOpen("div", .{ .class = "info" });
            var tmp: [16]u8 = undefined;
            const msg = std.fmt.bufPrint(tmp[0..], "{}", .{height}) catch "";
            ui.text(msg);
            ui.elemClose("div");

            ui.elemOpen("button", .{ .class = "minus" });
            height -= ui.events("click");
            ui.elemClose("button");
        }
        ui.elemClose("div");
    }
    ui.elemClose("div");
}
