const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("07", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    var totalCalibrationResult: usize = 0;
    var totalCalibrationResult2: usize = 0;

    var operatorStack = std.ArrayListUnmanaged(u8){};
    defer operatorStack.deinit(alloc);
    var numbers = std.ArrayListUnmanaged(u16){};
    defer numbers.deinit(alloc);
    var history = std.ArrayListUnmanaged(usize){};
    defer history.deinit(alloc);

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

        if (try inner(numbers.items, result, &operatorStack, alloc, &history, false)) {
            totalCalibrationResult += result;
        } else {
            operatorStack.items.len = 0;
            history.items.len = 0;
            if (try inner(numbers.items, result, &operatorStack, alloc, &history, true)) {
                totalCalibrationResult2 += result;
            }
        }
        operatorStack.items.len = 0;
        history.items.len = 0;
        numbers.items.len = 0;
    }

    return .{ totalCalibrationResult, totalCalibrationResult + totalCalibrationResult2 };
}

fn inner(numbers: []u16, result: usize, operatorStack: *std.ArrayListUnmanaged(u8), alloc: std.mem.Allocator, history: *std.ArrayListUnmanaged(usize), concatEnabled: bool) !bool {
    var numberI: usize = 1;
    var acc: usize = numbers[0];
    try history.append(alloc, acc);
    while (true) {
        while (numberI < numbers.len) : (numberI += 1) {
            const n = numbers[numberI];

            const mul: usize = if (n >= 100)
                1000
            else if (n >= 10)
                100
            else
                10;

            const concat = acc * mul + n;

            var operator: u8 = 0;
            if (concatEnabled and concat <= result) {
                operator = 2;
                acc = concat;
            } else if (n * acc <= result) {
                operator = 1;
                acc *= n;
            } else if (n + acc <= result) {
                operator = 0;
                acc += n;
            } else break;
            try operatorStack.append(alloc, operator);
            try history.append(alloc, acc);
        }

        if (numbers.len == numberI) {
            if (acc == result) return true;
        }
        if (std.mem.allEqual(u8, operatorStack.items, 0)) return false;

        // pop up to last non-add
        var i = operatorStack.items.len - 1;
        while (i < operatorStack.items.len) : (i -%= 1) {
            if (operatorStack.items[i] != 0) break;
        }
        numberI = i + 1;
        operatorStack.items.len = numberI;
        history.items.len = numberI + 1;

        if (operatorStack.items[i] == 1) {
            operatorStack.items[i] = 0;
            acc = history.items[i] + numbers[numberI];
        } else {
            operatorStack.items[i] = 1;
            acc = history.items[i] * numbers[numberI];
        }
        history.items[numberI] = acc;
        numberI += 1;
    }

    return false;
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

    const example_result: usize = 3749;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);
    const example_result2: usize = 11387;
    try std.testing.expectEqual(example_result2, result[1]);
}
