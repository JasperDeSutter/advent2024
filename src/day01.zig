const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("01", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var leftsAL = try std.ArrayListUnmanaged(u32).initCapacity(alloc, 1000);
    var rightsAL = try std.ArrayListUnmanaged(u32).initCapacity(alloc, 1000);
    defer leftsAL.deinit(alloc);
    defer rightsAL.deinit(alloc);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        const left = try std.fmt.parseInt(u32, numbers.next().?, 10);
        const right = try std.fmt.parseInt(u32, numbers.next().?, 10);
        try leftsAL.append(alloc, left);
        try rightsAL.append(alloc, right);
    }

    const lefts = leftsAL.items;
    const rights = rightsAL.items;
    std.mem.sort(u32, lefts, {}, std.sort.asc(u32));
    std.mem.sort(u32, rights, {}, std.sort.asc(u32));

    var sum: usize = 0;
    for (lefts, rights) |left, right| {
        if (left > right) {
            sum += left - right;
        } else {
            sum += right - left;
        }
    }

    var similarity: usize = 0;
    var l: usize = 0;
    var r: usize = 0;

    outer: while (l < lefts.len and r < rights.len) {
        while (lefts[l] > rights[r]) {
            r += 1;
            if (r == rights.len) {
                break :outer;
            }
        }
        while (lefts[l] < rights[r]) {
            l += 1;
            if (l == lefts.len) {
                break :outer;
            }
        }

        const preR = r;
        const preL = l;
        while (r < rights.len and lefts[preL] == rights[r]) {
            r += 1;
        }
        while (l < lefts.len and lefts[l] == rights[preR]) {
            l += 1;
        }

        similarity += lefts[preL] * (r - preR) * (l - preL);
    }

    return .{ sum, similarity };
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
    const example_result2: usize = 31;
    try std.testing.expectEqual(example_result2, result[1]);
}
