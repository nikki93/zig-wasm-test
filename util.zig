fn CPtr(comptime T: type) type {
    const p = @typeInfo(T).Pointer;
    if (p.is_const) {
        return *const p.child;
    } else {
        return *p.child;
    }
}

/// Return a pointer to the start of the slice. Returns an unspecified value if
/// the slice is 0-length, without panicking. You probably shouldn't actually
/// read/write memory at that location. Useful when passing pointer-length
/// pairs to the non-Zig world.
pub fn cPtr(slice: anytype) CPtr(@TypeOf(slice)) {
    if (slice.len > 0) {
        return &slice[0];
    } else {
        return @intToPtr(CPtr(@TypeOf(slice)), 128);
    }
}
