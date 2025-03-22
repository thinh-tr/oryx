const types = @import("types.zig");

// Wasm Header info
pub const Header = struct {
    magic: u32,
    version: u32,
};

// Wasm Section
pub const Section = struct {
    id: u8,
    payload_len: u32,
    payload: []u8,
};

// Wasm Module
pub const Module = struct {
    header: Header,
    sections: []const Section,
};