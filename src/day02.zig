const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("02", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;
    var lines = std.mem.splitScalar(u8, input, '\n');

    var safeZero: usize = 0;
    var safeOne: usize = 0;
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');

        var ints: [8]i8 = undefined;
        var i: usize = 0;

        while (numbers.next()) |num| {
            ints[i] = @intCast(try std.fmt.parseInt(u8, num, 10));
            i += 1;
        }
        switch (check(ints[0..i])) {
            0 => safeZero += 1,
            1 => safeOne += 1,
            else => {},
        }
    }

    return .{ safeZero, safeZero + safeOne };
}

fn check(ints: []i8) u8 {
    for (0..ints.len + 1) |skipI| {
        const skip = ints.len - skipI;

        var sign: usize = 0;
        var prev = ints[0];
        var start: usize = 1;
        if (skip == 0) {
            // skip first number -> second becomes first, skip one more in iteration
            prev = ints[1];
            start = 2;
        }
        for (ints[start..], start..) |int, i| {
            if (i == skip) continue;

            const inc = int - prev;
            if (inc == 0) break;
            if (inc > 0) {
                if (sign == 1) break;
                sign = 2;
            }
            if (inc < 0) {
                if (sign == 2) break;
                sign = 1;
            }
            if (inc < -3 or inc > 3) break;
            prev = int;
        } else {
            if (skipI == 0) return 0; // didn't skip any
            return 1;
        }
    }
    return 2;
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
    const example_result2: usize = 4;
    try std.testing.expectEqual(example_result2, result[1]);
}
