const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("09", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var filesystem = std.ArrayList(u16).init(alloc);
    defer filesystem.deinit();
    {
        var isFile = true;
        var fileId: u16 = 0;
        for (input) |c| {
            const slice = try filesystem.addManyAsSlice(c & 0xf);
            if (isFile) {
                @memset(slice, fileId);
                fileId += 1;
            } else {
                @memset(slice, std.math.maxInt(u16));
            }
            isFile = !isFile;
        }
    }

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

    var checksum: usize = 0;
    for (filesystem.items, 0..) |id, pos| {
        checksum += id * pos;
    }

    return .{ checksum, 0 };
}

test {
    const input =
        \\2333133121414131402
    ;

    const example_result: usize = 1928;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
