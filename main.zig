const std = @import("std");

const console = @import("console.zig");
const gl = @import("gfx.zig").gl;
const timing = @import("timing.zig");
const ui = @import("ui.zig");

// Triangle demo
//
const triangle_demo = struct {
    const vert_src =
        \\attribute vec4 a_position;
        \\void main() {
        \\  gl_Position = a_position;
        \\}
    ;

    const frag_src =
        \\precision mediump float;
        \\void main() {
        \\  gl_FragColor = vec4(1, 0, 0.5, 1);
        \\}
    ;

    var prog: c_uint = undefined;
    var buf: c_uint = undefined;

    var height: f32 = 2;

    fn init() void {
        const vert = gl.setupShader(gl.VERTEX_SHADER, vert_src);
        defer gl.deleteShader(vert);
        const frag = gl.setupShader(gl.FRAGMENT_SHADER, frag_src);
        defer gl.deleteShader(frag);
        prog = gl.setupProgram(vert, frag);

        buf = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, buf);

        const pos = gl.getAttribLocation(prog, "a_position");
        gl.enableVertexAttribArray(pos);
        gl.vertexAttribPointer(pos, 2, gl.FLOAT, false, 0, 0);
    }

    fn deinit() void {
        gl.deleteBuffer(buf);
        gl.deleteProgram(prog);
    }

    fn draw() void {
        gl.useProgram(prog);
        gl.bindBuffer(gl.ARRAY_BUFFER, buf);
        const data = [_]f32{ 0, 0, 0, height * 0.1, 0.7, 0 };
        gl.bufferData(gl.ARRAY_BUFFER, &data, gl.STREAM_DRAW);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
    }

    fn ui() void {
        ui.elemOpen("div", .{ .class = "section" });
        {
            ui.elemOpen("button", .{ .class = "plus" });
            if (ui.event("click")) {
                height += 1;
            }
            ui.elemClose("button");

            var tmp: [64]u8 = undefined;
            ui.elemOpen("input", .{
                .type = "number",
                .step = "any",
                .value = std.fmt.bufPrint(&tmp, "{d:.2}", .{height}) catch unreachable,
            });
            if (ui.event("change")) {
                height = std.fmt.parseFloat(f32, ui.value(&tmp)) catch height;
                ui.setValue(std.fmt.bufPrint(&tmp, "{d:.2}", .{height}) catch unreachable);
            }
            ui.elemClose("input");

            ui.elemOpen("button", .{ .class = "minus" });
            if (ui.event("click")) {
                height -= 1;
            }
            ui.elemClose("button");
        }
        ui.elemClose("div");
    }
};

// Text input demo
//
const text_input_demo = struct {
    var text_buf: [16]u8 = undefined;
    var text: []u8 = text_buf[0..0];

    fn ui() void {
        ui.elemOpen("div", .{ .class = "section" });
        {
            ui.elemOpen("input", .{
                .value = text,
                .placeholder = "type here!",
            });
            if (ui.event("input")) {
                text = ui.value(&text_buf);
                ui.setValue(text);
            }
            ui.elemClose("input");
        }
        ui.elemClose("div");
        ui.elemOpen("div", .{ .class = "section" });
        {
            var tmp: [text_buf.len + 32]u8 = undefined;
            ui.text(std.fmt.bufPrint(&tmp, "text: {}", .{text}) catch "");
        }
        ui.elemClose("div");
    }
};

// Top level
//
pub const panic = console.panic; // Install panic handler

export fn init() void {
    console.log("hello from zig!\n");

    triangle_demo.init();
}

export fn deinit() void {
    triangle_demo.deinit();
}

export fn frame() void {
    timing.frame();

    gl.setupViewport();

    gl.clearColor(0.2, 0.1, 0.1 + 0.3 * @sin(@floatCast(f32, timing.t)), 1);
    gl.clear(gl.COLOR_BUFFER_BIT);

    triangle_demo.draw();
}

export fn uiSide() void {
    ui.elemOpen("div", .{ .class = "section" });
    ui.text("hello from zig! :O");
    ui.elemClose("div");

    triangle_demo.ui();

    text_input_demo.ui();
}

export fn uiBottom() void {
    ui.elemOpen("div", .{ .class = "status" });
    var tmp: [16]u8 = undefined;
    ui.text(std.fmt.bufPrint(&tmp, "fps: {}", .{@floatToInt(i32, @round(timing.fps))}) catch "");
    ui.elemClose("div");
}
