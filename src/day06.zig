const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("06", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, input, '^').?;

    var bitset = try std.DynamicBitSet.initEmpty(alloc, input.len);
    defer bitset.deinit();

    const dirs: [4]usize = .{
        1,
        cols,
        std.math.maxInt(usize),
        std.math.maxInt(usize) - cols + 1,
    };
    simulate1(input, &dirs, start, &bitset);

    const visitMap2 = try alloc.alloc(u8, input.len);
    defer alloc.free(visitMap2);

    var visited: usize = 0;
    var loops: usize = 0;
    for (0..input.len) |i| {
        if (!bitset.isSet(i)) continue;
        visited += 1;

        @memset(visitMap2, 0);
        const looping = simulate2(input, &dirs, start, visitMap2, i);
        if (looping) {
            loops += 1;
        }
    }

    return .{ visited, loops };
}

fn simulate1(input: []const u8, dirs: *const [4]usize, start: usize, bitset: *std.DynamicBitSet) void {
    var dir: u3 = 3;

    var i = start;
    while (i < input.len) : (i +%= dirs[dir]) {
        const c = input[i];
        if (c == '#') {
            i -%= dirs[dir];
            dir = (dir + 1) % 4;
        }
        if (c == '\n') break;
        bitset.set(i);
    }
}

fn simulate2(input: []const u8, dirs: *const [4]usize, start: usize, visitMap: []u8, obstacle: usize) bool {
    var dir: u3 = 3;

    var i = start;
    while (i < input.len) : (i +%= dirs[dir]) {
        const c = input[i];
        if (i == obstacle or c == '#') {
            i -%= dirs[dir];
            dir = (dir + 1) % 4;

            const bit = @as(u8, 1) << dir;
            if ((visitMap[i] & bit) != 0) return true;
            visitMap[i] |= bit;
        }
        if (c == '\n') break;
    }

    return false;
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
    const example_result2: usize = 6;
    try std.testing.expectEqual(example_result2, result[1]);
}
