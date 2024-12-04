const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("04", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    const cols = std.mem.indexOfScalar(u8, input, '\n').? + 1;

    _ = alloc;
    // var debug = try alloc.alloc(u8, input.len);
    // defer alloc.free(debug);
    // {
    //     @memset(debug, '.');
    //     var i: usize = 0;
    //     while (i < debug.len - cols + 1) {
    //         i += cols;
    //         debug[i - 1] = '\n';
    //     }
    // }

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
    var found: usize = 0;

    for (0..input.len) |i| {
        for (directions) |d| {
            var j = i;
            for (search) |s| {
                if (j >= input.len or input[j] != s) break;
                j +%= d;
            } else {
                // debug[j -% d] = 'S';
                found += 1;
            }
        }
    }
    // std.debug.print("\n{s}\n\n", .{debug});

    return .{ found, 0 };
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
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
