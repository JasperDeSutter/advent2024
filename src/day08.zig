const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("08", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var antennas = std.AutoHashMapUnmanaged(u8, std.ArrayListUnmanaged(usize)){};
    defer {
        var values = antennas.valueIterator();
        while (values.next()) |value| {
            value.deinit(alloc);
        }
        antennas.deinit(alloc);
    }

    var cols: usize = 0;
    {
        var i: usize = 0;
        while (i < input.len) : (i += 1) {
            if (input[i] == '\n') {
                if (cols == 0) cols = i + 1;
                continue;
            }
            if (input[i] != '.') {
                var entry = try antennas.getOrPut(alloc, input[i]);
                if (!entry.found_existing) {
                    entry.value_ptr.* = .{};
                }
                try entry.value_ptr.append(alloc, i);
            }
        }
    }

    var antinodes = try std.DynamicBitSetUnmanaged.initEmpty(alloc, input.len);
    defer antinodes.deinit(alloc);

    var antinodes2 = try std.DynamicBitSetUnmanaged.initEmpty(alloc, input.len);
    defer antinodes2.deinit(alloc);

    {
        var values = antennas.valueIterator();
        while (values.next()) |al| {
            const list = al.items;
            for (list[0 .. list.len - 1], 0..) |pos1, i| {
                const x1 = pos1 % cols;
                for (list[i + 1 ..]) |pos2| {
                    const x2 = pos2 % cols;
                    const delta = pos2 - pos1;
                    const dx = x2 -% x1;

                    const antiA = pos1 -% delta;
                    const xA = x1 -% dx;
                    if (antiA < input.len and xA < cols - 1) {
                        antinodes.set(antiA);
                    }

                    const antiB = pos2 + delta;
                    const xB = x2 +% dx;
                    if (antiB < input.len and xB < cols - 1) {
                        antinodes.set(antiB);
                    }

                    var j = pos1;
                    var k = x1;
                    while (j < input.len) : (j -%= delta) {
                        // iterate to top left
                        k -%= dx;
                    }
                    j +%= delta;

                    while (j < input.len) : (j += delta) {
                        k +%= dx;
                        if (k < cols - 1) {
                            antinodes2.set(j);
                        }
                    }
                }
            }
        }
    }

    return .{ antinodes.count(), antinodes2.count() };
}

test {
    const input =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    ;

    const example_result: usize = 14;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 34;
    try std.testing.expectEqual(example_result2, result[1]);
}
