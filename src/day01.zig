const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("01", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var lefts = std.ArrayListUnmanaged(u32){};
    var rights = std.ArrayListUnmanaged(u32){};
    defer lefts.deinit(alloc);
    defer rights.deinit(alloc);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        const left = try std.fmt.parseInt(u32, numbers.next().?, 10);
        const right = try std.fmt.parseInt(u32, numbers.next().?, 10);
        try lefts.append(alloc, left);
        try rights.append(alloc, right);
    }

    std.mem.sort(u32, lefts.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, rights.items, {}, std.sort.asc(u32));

    var sum: usize = 0;
    for (lefts.items, rights.items) |left, right| {
        if (left > right) {
            sum += left - right;
        } else {
            sum += right - left;
        }
    }

    return .{ sum, 0 };
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
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
}
