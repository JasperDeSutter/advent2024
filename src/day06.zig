const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("06", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const start = std.mem.indexOfScalar(u8, input, '^').?;

    const visitMap = try alloc.alloc(u8, input.len);
    defer alloc.free(visitMap);

    @memset(visitMap, 0);
    _ = simulate(input, cols, start, visitMap, input.len);
    var visited: usize = 0;
    for (visitMap) |v| {
        if (v != 0) visited += 1;
    }

    var loops: usize = 0;
    for (input, 0..) |c, i| {
        if (c != '.') continue;
        @memset(visitMap, 0);
        const looping = simulate(input, cols, start, visitMap, i);
        if (looping) {
            loops += 1;
        }
    }

    return .{ visited, loops };
}

fn simulate(input: []const u8, cols: usize, start: usize, visitMap: []u8, obstacle: usize) bool {
    const dirs: [4]usize = .{
        1,
        cols,
        std.math.maxInt(usize),
        std.math.maxInt(usize) - cols + 1,
    };
    var dir: u3 = 3;

    var i = start;
    while (i < input.len) : (i +%= dirs[dir]) {
        const c = input[i];
        if (i == obstacle or c == '#') {
            i -%= dirs[dir];
            dir = (dir + 1) % 4;
            continue;
        }
        if (c == '\n') break;

        const bit = @as(u8, 1) << dir;
        if ((visitMap[i] & bit) != 0) return true;
        visitMap[i] |= bit;
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
