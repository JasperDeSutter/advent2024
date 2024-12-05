const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("05", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;

    var middleSum: usize = 0;

    const updatesI = std.mem.indexOf(u8, input, "\n\n").?;
    const rules = input[0..updatesI];
    std.debug.print("rules: {s}|\n", .{rules});

    var lines = std.mem.splitScalar(u8, input[updatesI + 2 ..], '\n');
    while (lines.next()) |line| {
        const count = (line.len + 1) / 3;
        var i: usize = 1;
        var last: [2]u8 = .{ line[0], line[1] };

        matcher: while (i < count) : (i += 1) {
            const now: [2]u8 = .{ line[i * 3], line[i * 3 + 1] };

            const good: [5]u8 = .{ last[0], last[1], '|', now[0], now[1] };
            const bad: [5]u8 = .{ now[0], now[1], '|', last[0], last[1] };

            var j: usize = 0;
            while (j < rules.len) : (j += 6) {
                const rule = rules[j .. j + 5];

                if (std.mem.eql(u8, &good, rule)) break;
                if (std.mem.eql(u8, &bad, rule)) break :matcher;
            }

            last = now;
        } else {
            const middle = (count - 1) / 2;
            middleSum += ((line[middle * 3] - '0') * 10) + line[middle * 3 + 1] - '0';
        }
    }

    return .{ middleSum, 0 };
}

test {
    const input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    const example_result: usize = 143;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
