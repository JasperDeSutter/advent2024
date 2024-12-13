const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("10", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    const reachableFrom = try alloc.alloc(std.bit_set.ArrayBitSet(usize, 64 * 5), input.len);
    defer alloc.free(reachableFrom);

    @memset(reachableFrom, std.bit_set.ArrayBitSet(usize, 64 * 5).initEmpty());

    var bit: usize = 0;
    var cols: usize = 0;
    for (input, 0..) |c, i| {
        if (c == '\n' and cols == 0) {
            cols = i + 1;
        } else if (c == '0') {
            reachableFrom[i].set(bit);
            bit += 1;
        }
    }

    var total: usize = 0;

    for (1..10) |step| {
        for (input, 0..) |c, i| {
            if (c != step + '0') continue;
            const bitset = &reachableFrom[i];

            if (i >= 1 and input[i - 1] == c - 1) bitset.setUnion(reachableFrom[i - 1]);
            if (i < input.len - 1 and input[i + 1] == c - 1) bitset.setUnion(reachableFrom[i + 1]);
            if (i >= cols and input[i - cols] == c - 1) bitset.setUnion(reachableFrom[i - cols]);
            if (i < input.len - cols and input[i + cols] == c - 1) bitset.setUnion(reachableFrom[i + cols]);

            if (step == 9) {
                total += bitset.count();
            }
        }
    }

    return .{ total, 0 };
}

test {
    const input =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
    ;

    const example_result: usize = 36;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
