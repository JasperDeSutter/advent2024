const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("11", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var stones = std.ArrayListUnmanaged(usize){};
    defer stones.deinit(alloc);

    {
        var parts = std.mem.tokenizeScalar(u8, input, ' ');
        while (parts.next()) |part| {
            try stones.append(alloc, try std.fmt.parseInt(usize, part, 10));
        }
    }

    for (0..25) |_| {
        var i = stones.items.len - 1;
        while (i < stones.items.len) : (i -%= 1) {
            const stone = stones.items[i];
            if (stone == 0) {
                stones.items[i] = 1;
                continue;
            }
            var digits: usize = 0;
            var n = stone;
            while (n > 0) : (digits += 1)
                n /= 10;

            if (digits & 1 == 1) {
                stones.items[i] = stone * 2024;
            } else {
                digits /= 2;
                var dec: usize = 1;
                while (digits > 0) : (digits -= 1)
                    dec *= 10;
                const left = stone / dec;
                stones.items[i] = stone - (left * dec);
                try stones.insert(alloc, i, left);
            }
        }
    }

    return .{ stones.items.len, 0 };
}

test {
    const input =
        \\125 17
    ;

    const example_result: usize = 55312;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
