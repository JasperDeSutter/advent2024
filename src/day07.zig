const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("07", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var totalCalibrationResult: usize = 0;

    var operatorStack = std.ArrayListUnmanaged(bool){};
    defer operatorStack.deinit(alloc);
    var numbers = std.ArrayListUnmanaged(u16){};
    defer numbers.deinit(alloc);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var result: usize = 0;
        const start = for (line, 0..) |c, i| {
            if (c == ':') break i + 1;
            result *= 10;
            result += c & 0xF;
        } else 0;

        var parts = std.mem.tokenizeScalar(u8, line[start..], ' ');
        while (parts.next()) |part| {
            try numbers.append(alloc, try std.fmt.parseInt(u16, part, 10));
        }

        var numberI: usize = 1;
        var acc: usize = numbers.items[0];
        while (true) {
            while (numberI < numbers.items.len) : (numberI += 1) {
                const n = numbers.items[numberI];
                if (n * acc <= result) {
                    try operatorStack.append(alloc, true);
                    acc *= n;
                } else if (n + acc <= result) {
                    try operatorStack.append(alloc, false);
                    acc += n;
                } else break;
            }

            if (numbers.items.len == numberI) {
                if (acc == result) {
                    totalCalibrationResult += result;
                    break;
                }
                if (std.mem.allEqual(bool, operatorStack.items, false)) break;
            }
            numberI -= 1;

            // pop up to last mul, change it to add
            var i = operatorStack.items.len - 1;
            while (i < operatorStack.items.len) : (i -%= 1) {
                if (operatorStack.items[i] == true) break;
            }
            operatorStack.items[i] = false;
            operatorStack.items.len = i + 1;

            while (numberI > i + 1) : (numberI -= 1) {
                acc -= numbers.items[numberI];
            }
            acc = acc / numbers.items[numberI] + numbers.items[numberI];
            numberI += 1;
        }

        numbers.items.len = 0;
        operatorStack.items.len = 0;
    }

    return .{ totalCalibrationResult, 0 };
}

test {
    const input =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;
    // const input = "284: 1 56 3 225";

    const example_result: usize = 3749;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 0;
    try std.testing.expectEqual(example_result2, result[1]);
}
