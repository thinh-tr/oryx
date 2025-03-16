const std = @import("std");
const stdout_writer = std.io.getStdOut().writer();

const Command = enum {
    RUN,    // Lệnh khởi chạy file wasm
    HELP,   // Menu trợ giúp
    VERSION,    // Kiểm tra phiên bản
    DEBUG,  // debug file
    VALIDATE,   // Kiểm tra tính hợp lệ của file wasm
    COMPILE, // Biên dịch file wat sang wasm

    fn getCommand(command_str: []const u8) ?Command {
        // Trả ra command tương ứng dựa trên command_str
        if (command_map.get(command_str)) |command| {
            return command;
        } else {
            return null;    // Không tìm thấy command tương ứng
        }
    }
};

const command_map: std.StaticStringMap(Command) = std.StaticStringMap(Command).initComptime(.{
    .{"run", .RUN},
    .{"help", .HELP},
    .{"version", .VERSION},
    .{"debug", .DEBUG},
    .{"validate", .VALIDATE},
    .{"compile", .COMPILE},
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