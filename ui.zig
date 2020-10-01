// Elem
//
extern fn uiElemOpenStart(tagPtr: *const u8, tagLen: c_uint) void;
pub fn elemOpenStart(tag: []const u8) void {
    uiElemOpenStart(&tag[0], tag.len);
}

extern fn uiElemOpenStartKeyInt(tagPtr: *const u8, tagLen: c_uint, key: c_int) void;
extern fn uiElemOpenStartKeyStr(tagPtr: *const u8, tagLen: c_uint, keyPtr: *const u8, keyLen: c_uint) void;
pub fn elemOpenStartKey(tag: []const u8, key: anytype) void {
    const ti = @typeInfo(@TypeOf(key));
    switch (ti) {
        .Int => {
            uiElemOpenStartKeyInt(&tag[0], tag.len, key);
        },
        .Pointer => {
            uiElemOpenStartKeyStr(&tag[0], tag.len, &key[0], key.len);
        },
        else => {
            @compileError("UI key type '" ++ @typeName(@TypeOf(value)) ++ "' not supported");
        },
    }
}

extern fn uiElemOpenEnd() void;
pub const elemOpenEnd = uiElemOpenEnd;

extern fn uiElemClose(tagPtr: *const u8, tagLen: c_uint) void;
pub fn elemClose(tag: []const u8) void {
    uiElemClose(&tag[0], tag.len);
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
extern fn uiAttrInt(namePtr: *const u8, nameLen: c_uint, value: c_int) void;
pub fn attrInt(name: []const u8, value: i32) void {
    uiAttrInt(&name[0], name.len, value);
}

extern fn uiAttrFloat(namePtr: *const u8, nameLen: c_uint, value: f64) void;
pub fn attrFloat(name: []const u8, value: f64) void {
    uiAttrFloat(&name[0], name.len, value);
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

pub fn attr(name: []const u8, value: anytype) void {
    const ti = @typeInfo(@TypeOf(value));
    switch (ti) {
        .Int => {
            attrInt(name, value);
        },
        .Float => {
            attrFloat(name, value);
        },
        .Bool => {
            attrBool(name, value);
        },
        .Pointer => {
            attrStr(name, value);
        },
        else => {
            @compileError("UI attribute type '" ++ @typeName(@TypeOf(value)) ++ "' not supported");
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
extern fn uiText(valuePtr: *const u8, valueLen: c_uint) void;
pub fn text(value: []const u8) void {
    uiText(&value[0], value.len);
}

// Events
//
extern fn uiEvents(typePtr: *const u8, typeLen: c_uint) c_int;
pub fn events(typ: []const u8) c_int {
    return uiEvents(&typ[0], typ.len);
}
