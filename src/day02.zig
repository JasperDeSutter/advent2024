const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("02", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;
    var lines = std.mem.splitScalar(u8, input, '\n');

    var safe: usize = 0;
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');

        var prev = try std.fmt.parseInt(u8, numbers.next().?, 10);
        var sign: u8 = 0;

        while (numbers.next()) |num| {
            const curr = try std.fmt.parseInt(u8, num, 10);
            if (curr == prev) break;
            if (curr > prev) {
                if (sign == 1) break;
                sign = 2;
                if (curr - prev > 3) {
                    break;
                }
            } else {
                if (sign == 2) break;
                sign = 1;
                if (prev - curr > 3) {
                    break;
                }
            }
            prev = curr;
        } else {
            safe += 1;
        }
    }

    return .{ safe, 0 };
}

test {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;

    const example_result: usize = 2;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
