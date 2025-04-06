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

fn parseHeader(self: *Self) ParserError!wasm.Header {
    if (self.*.wasm_data.len < 8) return ParserError.InvalidWasmFile;

    const magic_number: []u8 = bytesToASCII(self.*.wasm_data[0..4]);
    const version: u32 = bytesToU32(self.*.wasm_data[4..8]) catch |err| {
        return err;
    };
    const header: wasm.Header = wasm.Header{
        .magic = magic_number,
        .version = version,
    };
    return header;
}

// Chuyển bytes sang kiểu u32
fn bytesToU32(bytes: []const u8) ParserError!u32 {
    if (bytes.len < 4) return ParserError.InvalidByteLenght;
    return (@as(u32, bytes[0]) << 0) | (@as(u32, bytes[1]) << 8) | (@as(u32, bytes[2]) << 16) | (@as(u32, bytes[3]) << 24);
}

// Chuyển bytes sang ASCII
fn bytesToASCII(bytes: []const u8) []u8 {
    var ascii_str: ArrayList(u8) = ArrayList(u8).init(std.heap.page_allocator);
    for (bytes) |byte| {
        if (byte == 0x00) {
            ascii_str.append('\\') catch unreachable;
            ascii_str.append('0') catch unreachable;
        } else if (byte >= 0x20 and byte <= 0x7E) {
            ascii_str.append(byte) catch unreachable;
        } else {
            ascii_str.append('.') catch unreachable;
        }
    }

    return ascii_str.items;
}

pub const ParserError = error {
    InvalidWasmFile,
    InvalidByteLenght,
};

test "parse header" {
    var alloc = std.heap.page_allocator;
    var parser = Self.init(&[_]u8{0, 97, 115, 109, 1, 0, 0, 0}, &alloc);
    const header = try parser.parseHeader();
    std.debug.print("magic: {s} \nversion: {}\n", .{header.magic, header.version});
}