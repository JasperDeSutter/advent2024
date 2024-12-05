const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("05", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var middleSum: usize = 0;
    var correctedMiddleSum: usize = 0;

    var rules = try std.ArrayListUnmanaged([4]u8).initCapacity(alloc, 512);
    defer rules.deinit(alloc);
    {
        var i: usize = 0;
        while (i < input.len) : (i += 6) {
            if (input[i] == '\n') break;
            const r = try rules.addOne(alloc);
            r.* = .{
                input[i],
                input[i + 1],
                input[i + 3],
                input[i + 4],
            };
        }
    }

    std.mem.sortUnstable([4]u8, rules.items, {}, struct {
        fn lessThanFn(_: void, lhs: [4]u8, rhs: [4]u8) bool {
            if (lhs[0] != rhs[0]) return lhs[0] < rhs[0];
            if (lhs[1] != rhs[1]) return lhs[1] < rhs[1];
            if (lhs[2] != rhs[2]) return lhs[2] < rhs[2];
            return lhs[3] < rhs[3];
        }
    }.lessThanFn);

    const updatesI = std.mem.indexOf(u8, input, "\n\n").?;

    var lines = std.mem.splitScalar(u8, input[updatesI + 2 ..], '\n');
    while (lines.next()) |line| {
        // trim the uninteresting numbers, only need up to one after middle if successful
        const trimmed = line[0 .. (((line.len + 1) / 6) + 2) * 3 - 1];
        var failedIdx = getFailIdx(trimmed, rules.items);

        if (failedIdx == 0) {
            middleSum += ((trimmed[trimmed.len - 5] & 0xf) * 10) + (trimmed[trimmed.len - 4] & 0xf);
            continue;
        }

        var lineBuf: [80]u8 = undefined;
        var lineSlice: []u8 = lineBuf[0..line.len];
        @memcpy(lineSlice, line);
        failedIdx = 3;

        while (failedIdx != 0) {
            std.mem.swap(u8, &lineSlice[failedIdx - 3 + 0], &lineSlice[failedIdx - 3 + 3]);
            std.mem.swap(u8, &lineSlice[failedIdx - 3 + 1], &lineSlice[failedIdx - 3 + 4]);

            failedIdx = getFailIdx(lineSlice, rules.items);
        }

        const middle = (line.len) / 2;

        const idx = lineSlice.len - middle;
        correctedMiddleSum += ((lineSlice[idx - 1] & 0xf) * 10) + (lineSlice[idx] & 0xf);
    }

    return .{ middleSum, correctedMiddleSum };
}

fn getFailIdx(line: []const u8, rules: []const [4]u8) usize {
    var i: usize = 3;

    while (i < line.len) : (i += 3) {
        if (std.sort.binarySearch([4]u8, line[i - 3 ..][0..5], rules, {}, compareFn) == null) {
            return i;
        }
    } else {
        return 0;
    }
}

fn compareFn(_: void, key: *const [5]u8, mid_item: [4]u8) std.math.Order {
    // key contains the comma, items do not
    if (key[0] != mid_item[0]) return std.math.order(key[0], mid_item[0]);
    if (key[1] != mid_item[1]) return std.math.order(key[1], mid_item[1]);
    if (key[3] != mid_item[2]) return std.math.order(key[3], mid_item[2]);
    if (key[4] != mid_item[3]) return std.math.order(key[4], mid_item[3]);
    return std.math.Order.eq;
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
