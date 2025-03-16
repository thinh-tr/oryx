// Wasm header
pub const Header = struct {
    magic: [4]u8,   // wasm magic number
    version: u32,   // Phiển bản wasm
};

// Wasm Section
pub const Section = struct {
    id: u8,
    size: u32,
    data: []u8,
};

// Types
pub const Type = enum(u8) {
    i32 = 0x7F,
    i64 = 0x7E,
    f32 = 0x7D,
    f64 = 0x7C,
};

// Function Type
pub const FunctionType = struct {
    param_count: u32,
    param_types: []Type,
    return_count: u32,
    return_type: []Type,
};

// Function
pub const FunctionSection = struct {
    count: u32, //  Số lượng function
    type_indices: []u32,    // Arry index ánh xạ đến type section
};

// Memory
pub const Memory = struct {
    min_pages: u32, // Số page tối thiểu
    max_pages: ?u32,    // Số page tối đa nếu có
};

// Export Section
pub const ExportKind = enum(u8) {
    function = 0x00,
    table = 0x01,
    memory = 0x02,
    global = 0x03,
};

pub const Export = struct {
    name: []const u8, // Tên của export
    kind: ExportKind,   // Loại export (func, memory, table, global)
    index: u32, // index trong module
};

// Code -> Chứa function body
pub const FunctionBody = struct {
    locals: []Type, // Các biến local
    code: []const u8, // bytecode thực thi
};

// Import
pub const ImportKind = enum(u8) {
    function = 0x00,
    table = 0x01,
    memory = 0x02,
    global = 0x03,
};

pub const Import = struct {
    module_name: []const u8,  // Tên module
    name: []const u8, // Tên function/global/Memory
    kind: ImportKind,   // Loại import
    description: union {
        function_index: u32,    // Index của function type
        table: struct {
            element_type: u8, // Kiểu phần tử (0x70 = funcref)
            min_size: u32,
            max_size: ?u32,
        },
        global: struct {
            value_type: Type, // Kiểu dữ liệu
            mutable: bool,  // Có thể thay đổi không
        }
    },
};

// Wasm module
pub const Module = struct {
    header: Header,
    types: ?[]FunctionType,
    functions: FunctionSection,
    memories: ?[]Memory,
    exports: ?[]Export,
    imports: ?[]Import,
    codes: ?[]FunctionBody,
};