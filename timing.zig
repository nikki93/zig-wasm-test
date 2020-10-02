pub var t: f64 = 0;
pub var dt: f64 = 0;
var prev_t: f64 = 0;
var first_frame: bool = true;

var frames_since_fps_update: i32 = 0;
var secs_since_fps_update: f64 = 0;
pub var fps: f64 = 0;

extern fn timingMillis() f64;
pub fn frame() void {
    t = 0.001 * timingMillis();
    if (first_frame) {
        prev_t = t;
        first_frame = false;
    }
    dt = t - prev_t;
    prev_t = t;

    secs_since_fps_update += dt;
    frames_since_fps_update += 1;
    if (secs_since_fps_update > 1) {
        fps = @intToFloat(f32, frames_since_fps_update) / secs_since_fps_update;
        secs_since_fps_update = 0;
        frames_since_fps_update = 0;
    }
}
