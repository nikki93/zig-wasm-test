const util = @import("util.zig");

// Elem
//
extern fn uiElemOpenStart(tagPtr: *const u8, tagLen: c_uint) void;
pub fn elemOpenStart(tag: []const u8) void {
    uiElemOpenStart(util.cPtr(tag), tag.len);
}

extern fn uiElemOpenStartKeyInt(tagPtr: *const u8, tagLen: c_uint, key: c_int) void;
extern fn uiElemOpenStartKeyStr(tagPtr: *const u8, tagLen: c_uint, keyPtr: *const u8, keyLen: c_uint) void;
pub fn elemOpenStartKey(tag: []const u8, key: anytype) void {
    const ti = @typeInfo(@TypeOf(key));
    switch (ti) {
        .Int => {
            uiElemOpenStartKeyInt(util.cPtr(tag), tag.len, key);
        },
        .Pointer => {
            uiElemOpenStartKeyStr(util.cPtr(tag), tag.len, util.cPtr(key), key.len);
        },
        else => {
            @compileError("UI key type '" ++ @typeName(@TypeOf(val)) ++ "' not supported");
        },
    }
}

extern fn uiElemOpenEnd() void;
pub const elemOpenEnd = uiElemOpenEnd;

extern fn uiElemClose(tagPtr: *const u8, tagLen: c_uint) void;
pub fn elemClose(tag: []const u8) void {
    uiElemClose(util.cPtr(tag), tag.len);
}

pub fn elemOpen(tag: []const u8, attrStruct: anytype) void {
    elemOpenStart(tag);
    attrs(attrStruct);
    elemOpenEnd();
}
pub fn elemOpenKey(tag: []const u8, key: anytype, attrStruct: anytype) void {
    elemOpenStartKey(tag, key);
    attrs(attrStruct);
    elemOpenEnd();
}

pub fn elem(tag: []const u8, attrStruct: anytype) void {
    elemOpen(tag, attrStruct);
    elemClose(tag);
}
pub fn elemKey(tag: []const u8, key: anytype, attrStruct: anytype) void {
    elemOpenKey(tag, key, attrStruct);
    elemClose(tag);
}

// Attr
//
extern fn uiAttrInt(namePtr: *const u8, nameLen: c_uint, val: c_int) void;
pub fn attrInt(name: []const u8, val: i32) void {
    uiAttrInt(util.cPtr(name), name.len, val);
}

extern fn uiAttrFloat(namePtr: *const u8, nameLen: c_uint, val: f64) void;
pub fn attrFloat(name: []const u8, val: f64) void {
    uiAttrFloat(util.cPtr(name), name.len, val);
}

pub fn attrBool(name: []const u8, val: bool) void {
    if (val) {
        attrStr(name, "");
    }
}

extern fn uiAttrStr(namePtr: *const u8, nameLen: c_uint, valPtr: *const u8, valLen: c_uint) void;
pub fn attrStr(name: []const u8, val: []const u8) void {
    uiAttrStr(util.cPtr(name), name.len, util.cPtr(val), val.len);
}

extern fn uiAttrClass(classPtr: *const u8, classLen: c_uint) void;
pub fn attrClass(class: []const u8) void {
    uiAttrClass(util.cPtr(class), class.len);
}

pub fn attr(name: []const u8, val: anytype) void {
    const ti = @typeInfo(@TypeOf(val));
    switch (ti) {
        .Int => {
            attrInt(name, val);
        },
        .Float => {
            attrFloat(name, val);
        },
        .Bool => {
            attrBool(name, val);
        },
        .Pointer => {
            attrStr(name, val);
        },
        else => {
            @compileError("UI attribute type '" ++ @typeName(@TypeOf(val)) ++ "' not supported");
        },
    }
}

pub fn attrs(attrStruct: anytype) void {
    const ti = @typeInfo(@TypeOf(attrStruct));
    switch (ti) {
        .Struct => {
            inline for (ti.Struct.fields) |field| {
                attr(field.name, @field(attrStruct, field.name));
            }
        },
        else => {
            @compileError("`attrStruct` must have struct type");
        },
    }
}

// Text
//
extern fn uiText(valPtr: *const u8, valLen: c_uint) void;
pub fn text(val: []const u8) void {
    uiText(util.cPtr(val), val.len);
}

// Events
//
extern fn uiEvents(typePtr: *const u8, typeLen: c_uint) c_int;
pub fn events(typ: []const u8) c_int {
    return uiEvents(util.cPtr(typ), typ.len);
}

pub fn event(typ: []const u8) bool {
    return events(typ) > 0;
}

// Value
//
extern fn uiValue(bufPtr: *u8, bufLen: c_uint) c_uint;
pub fn value(buf: []u8) []u8 {
    const written = uiValue(util.cPtr(buf), buf.len);
    return buf[0..written];
}

extern fn uiSetValue(valPtr: *const u8, valLen: c_uint) void;
pub fn setValue(val: []const u8) void {
    uiSetValue(util.cPtr(val), val.len);
}
