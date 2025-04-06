const std = @import("std");
const Allocator = std.mem.Allocator;
const wasm = @import("wasm.zig");
const ArrayList = std.ArrayList;

wasm_data: []const u8, // Wasm data đầu vào của parser
allocator: *Allocator, // Allocator

const Self = @This();

// Khởi tạo Paser
pub fn init(wasm_data: []const u8, allocator: *Allocator) Self {
    return Self{
        .wasm_data = wasm_data,
        .allocator = allocator,
    };
}

fn parseHeader(self: *Self) ParseError!wasm.Header {
    if (self.*.wasm_data.len < 8) return ParseError.InvalidWasmFile;

    const magic: u32 = bytesToU32(self.*.wasm_data[0..4]) catch |err| {
        return err;
    };
    const version: u32 = bytesToU32(self.*.wasm_data[4..8]) catch |err| {
        return err;
    };
    var header: wasm.Header = wasm.Header{
        .magic = magic,
        .version = version,
    };

    if (header.isValidMagic()) {
        return header;
    } else {
        return ParseError.InvalidWasmFile;
    }
}

// Chuyển bytes sang kiểu u32
fn bytesToU32(bytes: []const u8) ParseError!u32 {
    if (bytes.len < 4) return ParseError.InvalidByteLenght;
    return (@as(u32, bytes[0]) << 0) | (@as(u32, bytes[1]) << 8) | (@as(u32, bytes[2]) << 16) | (@as(u32, bytes[3]) << 24);
}

pub const ParseError = error {
    InvalidWasmFile,
    InvalidByteLenght,
};

test "parse header" {
    var alloc = std.heap.page_allocator;
    var parser = Self.init(&[_]u8{0, 97, 115, 109, 1, 0, 0, 0}, &alloc);
    const header = try parser.parseHeader();
    std.debug.print("magic: {} \nversion: {}\n", .{header.magic, header.version});
}