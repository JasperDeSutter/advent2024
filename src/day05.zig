const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("05", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;

    var middleSum: usize = 0;
    var correctedMiddleSum: usize = 0;

    const updatesI = std.mem.indexOf(u8, input, "\n\n").?;
    const rules = input[0..updatesI];

    var lines = std.mem.splitScalar(u8, input[updatesI + 2 ..], '\n');
    while (lines.next()) |line| {
        // trim the uninteresting numbers, only need up to one after middle if successful
        const trimmed = line[0 .. (((line.len + 1) / 6) + 2) * 3 - 1];
        var failedIdx = getFailIdx(trimmed, rules);

        if (failedIdx == trimmed.len) {
            middleSum += ((trimmed[trimmed.len - 5] - '0') * 10) + trimmed[trimmed.len - 4] - '0';
            continue;
        }

        var lineBuf: [80]u8 = undefined;
        var lineSlice: []u8 = lineBuf[0..line.len];
        @memcpy(lineSlice, line);
        failedIdx = 3;

        while (failedIdx != lineSlice.len) {
            std.mem.swap(u8, &lineSlice[failedIdx - 3 + 0], &lineSlice[failedIdx - 3 + 3]);
            std.mem.swap(u8, &lineSlice[failedIdx - 3 + 1], &lineSlice[failedIdx - 3 + 4]);

            failedIdx = getFailIdx(lineSlice, rules);
        }

        const middle = (line.len) / 2;

        const idx = lineSlice.len - middle;
        correctedMiddleSum += ((lineSlice[idx - 1] - '0') * 10) + lineSlice[idx] - '0';
    }

    return .{ middleSum, correctedMiddleSum };
}

fn getFailIdx(line: []const u8, rules: []const u8) usize {
    var i: usize = 3;
    var last: [2]u8 = .{ line[0], line[1] };

    while (i < line.len) : (i += 3) {
        const now: [2]u8 = .{ line[i], line[i + 1] };

        const good: [5]u8 = .{ last[0], last[1], '|', now[0], now[1] };
        const bad: [5]u8 = .{ now[0], now[1], '|', last[0], last[1] };

        var j: usize = 0;
        while (j < rules.len) : (j += 6) {
            const rule = rules[j .. j + 5];

            if (std.mem.eql(u8, &good, rule)) break;
            if (std.mem.eql(u8, &bad, rule)) return i;
        }

        last = now;
    } else {
        return line.len;
    }
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
    const example_result2: usize = 123;
    try std.testing.expectEqual(example_result2, result[1]);
}
