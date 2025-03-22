// Number types
pub const NumberType = enum(u8) {
    int32 = 0x7F,
    int64 = 0x7E,
    float32 = 0x7D,
    float64 = 0x7C,
};

// Vector type
pub const VectorType = enum(u8) {
    v128 = 0x7B,
};

// Reference type
pub const ReferenceType = enum(u8) {
    funcref = 0x70,
    externref = 0x6F,
};

// Value type
pub const ValueType = union(enum) {
    number: NumberType,
    reference: ReferenceType,
    vector: VectorType,
};

// Result type
pub const ResultType = []const ValueType;

// Function type
pub const FunctionType = struct {
    params: ResultType,
    results: ResultType,
};

// Limit
pub const Limits = struct {
    min: u32,
    max: ?u32,
};

// Memory type
pub const MemoryType = Limits;

// Table type
pub const TableType = struct {
    limits: Limits,
    element_type: ReferenceType,
};

// Gloabl type
pub const GlobalType = struct {
    value_type: ValueType,
    is_mutable: bool,
};