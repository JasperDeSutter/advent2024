const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("06", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var i = std.mem.indexOfScalar(u8, input, '^').?;

    const dirs: [4]usize = .{
        1,
        cols,
        std.math.maxInt(usize),
        std.math.maxInt(usize) - cols + 1,
    };
    var dir: usize = 3;

    var bitset = try std.DynamicBitSet.initEmpty(alloc, input.len);
    defer bitset.deinit();

    bitset.set(i);
    while (i < input.len) : (i +%= dirs[dir]) {
        const c = input[i];
        if (c == '#') {
            i -%= dirs[dir];
            dir = (dir + 1) % 4;
        }
        if (c == '\n') break;
        bitset.set(i);
    }

    return .{ bitset.count(), 0 };
}

test {
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;

    const example_result: usize = 41;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
