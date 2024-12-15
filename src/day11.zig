const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("11", solve);

const Node = struct {
    value: usize,
    next: usize,
};

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var nodes = std.ArrayList(Node).init(alloc);
    defer nodes.deinit();

    {
        var parts = std.mem.tokenizeScalar(u8, input, ' ');
        while (parts.next()) |part| {
            try nodes.append(Node{ .value = try std.fmt.parseInt(usize, part, 10), .next = nodes.items.len + 1 });
        }
        nodes.items[nodes.items.len - 1].next = std.math.maxInt(usize);
    }

    for (0..25) |_| try simulate(&nodes);

    const res1 = nodes.items.len;

    for (0..50) |_| try simulate(&nodes);

    return .{ res1, nodes.items.len };
}

fn simulate(nodes: *std.ArrayList(Node)) !void {
    var node: usize = 0;
    while (node < nodes.items.len) {
        const stone = &nodes.items[node];
        const nodeCpy = node;
        node = stone.next;
        if (stone.value == 0) {
            stone.value = 1;
            continue;
        }
        var digits: usize = 0;
        var n = stone.value;
        while (n > 0) : (digits += 1)
            n /= 10;

        if (digits & 1 == 1) {
            stone.value = stone.value * 2024;
            continue;
        }
        digits /= 2;
        var dec: usize = 1;
        while (digits > 0) : (digits -= 1)
            dec *= 10;
        const left = stone.value / dec;

        try nodes.append(Node{ .value = stone.value - (left * dec), .next = stone.next }); // invalidates stone ptr

        {
            const stone2 = &nodes.items[nodeCpy];
            stone2.value = left;
            stone2.next = nodes.items.len - 1;
        }
    }
}

test {
    const input =
        \\125 17
    ;

    const example_result: usize = 55312;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
