const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("04", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;

    const directions: [8]usize = .{
        1,
        cols + 1,
        cols,
        cols - 1,
        std.math.maxInt(usize),
        std.math.maxInt(usize) - cols,
        std.math.maxInt(usize) - cols + 1,
        std.math.maxInt(usize) - cols + 2,
    };

    const search = "XMAS";
    var foundXMAS: usize = 0;

    for (0..input.len) |i| {
        if (input[i] != search[0]) continue;
        for (directions) |d| {
            var j = i;
            for (search) |s| {
                if (j >= input.len or input[j] != s) break;
                j +%= d;
            } else {
                foundXMAS += 1;
            }
        }
    }

    var foundX_MAS: usize = 0;

    const match = 'M' | 'S';
    comptime {
        std.debug.assert('M' | 'A' != match);
        std.debug.assert('S' | 'A' != match);
        std.debug.assert('M' | 'X' != match);
        std.debug.assert('S' | 'X' != match);
    }

    for ((cols + 1)..(input.len - cols - 1)) |i| {
        if (input[i] != 'A') continue;

        const pair1 = input[i - cols - 1] | input[i + cols + 1];
        const pair2 = input[i - cols + 1] | input[i + cols - 1];
        if (pair1 == match and pair2 == match) {
            foundX_MAS += 1;
        }
    }

    return .{ foundXMAS, foundX_MAS };
}

test {
    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const example_result: usize = 18;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 9;
    try std.testing.expectEqual(example_result2, result[1]);
}
