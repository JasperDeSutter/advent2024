const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("09", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var filesystem = std.ArrayList(u16).init(alloc);
    defer filesystem.deinit();

    const gaps = try alloc.alloc(u16, 10); // remember first gap encountered for each size
    defer alloc.free(gaps);
    @memset(gaps, 0);

    {
        var isFile = true;
        var fileId: u16 = 0;
        for (input) |c| {
            const size = c & 0xf;
            const preSize = filesystem.items.len;
            if (size > 0) {
                const slice = try filesystem.addManyAsSlice(size);
                if (isFile) {
                    @memset(slice, fileId);
                    fileId += 1;
                } else {
                    @memset(slice, std.math.maxInt(u16));
                    if (gaps[size] == 0) {
                        gaps[size] = @intCast(preSize);
                    }
                }
            }
            isFile = !isFile;
        }
    }

    var clone = try filesystem.clone();
    defer clone.deinit();

    {
        var i: usize = 0;
        while (i < filesystem.items.len) : (i += 1) {
            if (filesystem.items[i] != std.math.maxInt(u16)) continue;
            while (filesystem.items[filesystem.items.len - 1] == std.math.maxInt(u16)) {
                filesystem.items.len -= 1;
            }
            filesystem.items[i] = filesystem.items[filesystem.items.len - 1];
            filesystem.items.len -= 1;
        }
    }

    {
        // part 2
        var i = clone.items.len - 1;
        while (i > 0) {
            const end = i;
            const c = clone.items[i];
            i -= 1;
            while (i < clone.items.len and clone.items[i] == c) : (i -%= 1) {}
            if (end < i) break;

            const len = end - i;
            var lowest: u16 = std.math.maxInt(u16);
            var lowestI: usize = gaps.len;
            var j = len;
            while (j < gaps.len) : (j += 1) {
                // find the first gap that is big enough to fit file
                if (gaps[j] != 0 and gaps[j] < lowest) {
                    lowest = gaps[j];
                    lowestI = j;
                }
            }
            j = lowestI;

            if (j < gaps.len and gaps[j] < i) {
                @memset(clone.items[gaps[j]..][0..len], c);
                @memset(clone.items[i + 1 ..][0..len], std.math.maxInt(u16));

                if (gaps[j - len] > gaps[j] + len) {
                    // gap was bigger than required, remaining space can be new gap
                    gaps[j - len] = @intCast(gaps[j] + len);
                }

                // find next gap of this size
                var last = gaps[j] + j;
                while (clone.items[last] != std.math.maxInt(u16)) : (last += 1) {}

                var k = last;
                while (k < clone.items.len) : (k += 1) {
                    if (clone.items[k - 1] != std.math.maxInt(u16) and clone.items[k] == std.math.maxInt(u16)) {
                        last = k;
                    }
                    if (clone.items[k - 1] == std.math.maxInt(u16) and clone.items[k] != std.math.maxInt(u16)) {
                        if (k - last == j) {
                            gaps[j] = @intCast(last);
                            break;
                        }
                        last = k - 1;
                    }
                } else {
                    gaps[j] = 0;
                }
            }

            while (clone.items[i] == std.math.maxInt(u16)) {
                i -= 1;
            }
        }
    }

    return .{ checksum(filesystem.items), checksum(clone.items) };
}

fn checksum(items: []const u16) usize {
    var sum: usize = 0;
    for (items, 0..) |id, pos| {
        if (id != std.math.maxInt(u16))
            sum += id * pos;
    }
    return sum;
}

test {
    const input =
        \\2333133121414131402
    ;

    const example_result: usize = 1928;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 2858;
    try std.testing.expectEqual(example_result2, result[1]);
}
