const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("%%", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;
    _ = input;
    return .{ 0, 0 };
}

test {
    const input =
        \\
    ;

    const example_result: usize = 0;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
