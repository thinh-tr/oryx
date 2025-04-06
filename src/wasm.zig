const types = @import("types.zig");

// Wasm Header info
pub const Header = struct {
    magic: u32,
    version: u32,

    const Self = @This();

    pub fn isValidMagic(self: *Self) bool {
        return self.*.magic == 0x6D736100;  // magic = "\0asm"
    }
};

// Wasm Section
pub const Section = struct {
    id: u8,
    payload_len: u32,
    payload: ?[]u8,
};

// Wasm Module
pub const Module = struct {
    header: Header,
    sections: []const Section,
};