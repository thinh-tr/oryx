const std = @import("std");
const stdout_writer = std.io.getStdOut().writer();

const Command = enum {
    RUN, // Lệnh khởi chạy file wasm
    HELP, // Menu trợ giúp
    VERSION, // Kiểm tra phiên bản
    DEBUG, // debug file
    VALIDATE, // Kiểm tra tính hợp lệ của file wasm
    COMPILE, // Biên dịch file wat sang wasm

    fn getCommand(command_str: []const u8) ?Command {
        // Trả ra command tương ứng dựa trên command_str
        if (command_map.get(command_str)) |command| {
            return command;
        } else {
            return null; // Không tìm thấy command tương ứng
        }
    }
};

const command_map: std.StaticStringMap(Command) = std.StaticStringMap(Command).initComptime(.{
    .{ "run", .RUN },
    .{ "help", .HELP },
    .{ "version", .VERSION },
    .{ "debug", .DEBUG },
    .{ "validate", .VALIDATE },
    .{ "compile", .COMPILE },
});

pub fn main() !void {
    const args_alloc = std.process.argsAlloc(std.heap.page_allocator) catch unreachable;
    defer std.process.argsFree(std.heap.page_allocator, args_alloc);

    // Kiểm tra danh sách args
    if (args_alloc.len > 1) {
        // Kiểm tra xem lệnh được nhập có nằm trong danh sách command không
        if (Command.getCommand(args_alloc[1])) |command| {
            // Thực thi theo từng command
            switch (command) {
                .RUN => {
                    stdout_writer.writeAll("run command") catch unreachable;
                },
                .HELP => {
                    showHelpMenu();
                },
                .VERSION => {
                    stdout_writer.print("Oryx WASM Runtime version {s}\n", .{"alpha"}) catch unreachable;
                },
                .DEBUG => {
                    stdout_writer.writeAll("run at debug mode") catch unreachable;
                },
                .VALIDATE => {
                    stdout_writer.writeAll("validate wasm file") catch unreachable;
                },
                .COMPILE => {
                    stdout_writer.writeAll("compile wat file to wasm") catch unreachable;
                },
            }
        } else {
            // Không thể nhận diện command đầu vào
            stdout_writer.writeAll("Error: Command is not supported.\n") catch unreachable;
        }
    } else {
        // Trường hợp không có lệnh nào được gọi
        showHelpMenu();
    }
}

fn showHelpMenu() void {
    stdout_writer.writeAll(
        \\Usage: oryx [command] [options]
        \\  run         Run wasm file
        \\  help        Show help menu
        \\  version     Print number version of this runtime
        \\  debug       Run wasm file in debug mode
        \\  validate    Validate wasm file
        \\  compile     Compile wat format to wasm format
        \\
    ) catch unreachable;
}

// Hàm khởi chạy wasm file
fn run() !void {
    const file = try std.fs.openFileAbsolute("/Users/Shared/Projects/Zig/testing_program/language/main.wasm", .{ .mode = .read_only });
    defer file.close();
    const allocator = std.heap.page_allocator;
    const wasm_data = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    parseWasmData(wasm_data);
}

fn parseWasmData(data: []u8) void {
    var index: usize = 0;

    // Đọc Magic Number
    const magic_number = data[index .. index + 4];
    index += 4;
    std.debug.print("Magic Number: {any}\n", .{magic_number});

    // Đọc Version
    const version = data[index .. index + 4];
    index += 4;
    std.debug.print("Version: {any}\n", .{version});

    // Đọc các section
    while (index < data.len) {
        const id = data[index]; // ID của section
        index += 1;

        const payload_len = parseLEB128(data, &index); // Chiều dài payload
        const payload = data[index .. index + payload_len];
        index += payload_len;

        std.debug.print("Section ID: {}, Payload Length: {}, Data: {any}\n", .{ id, payload_len, payload });
    }
}

// Hàm đọc giá trị LEB128 (nén Little-Endian Base 128)
fn parseLEB128(data: []u8, index: *usize) u32 {
    var result: u32 = 0;
    var shift: u3 = 0;

    while (index.* < data.len) {
        const byte = data[index.*];
        index.* += 1;

        result |= (byte & 0x7F) << shift;
        if ((byte & 0x80) == 0) break;
        shift += 7;
    }

    return result;
}

test "run test" {
    try run();
}
