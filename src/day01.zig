const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("01", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;
    _ = input;
    return .{ 0, 0 };
}

test {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;

    const example_result: usize = 11;
    const result = try solve(input);
    try std.testing.expectEqual(example_result, result[0]);
}
