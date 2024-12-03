const std = @import("std");
const runner = @import("runner.zig");

pub const main = runner.run("01", solve);

fn solve(alloc: std.mem.Allocator, input: []const u8) anyerror![2]usize {
    _ = alloc;

    var sum: usize = 0;
    var enabledSum: usize = 0;

    var enabled: bool = true;
    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        if (input[i] != 'm') {
            if (input[i] != 'd') continue;
            const do = "o()";
            i += 1;
            if (input.len < i + do.len) continue;
            if (std.mem.eql(u8, input[i .. i + do.len], do)) {
                enabled = true;
                i += do.len;
            }
            const dont = "on't()";
            if (input.len < i + dont.len) continue;
            if (std.mem.eql(u8, input[i .. i + dont.len], dont)) {
                enabled = false;
                i += dont.len;
            }
        }
        if (input[i + 1] != 'u') continue;
        if (input[i + 2] != 'l') continue;
        if (input[i + 3] != '(') continue;
        i += 4;

        var part = input[i..@min(i + 8, input.len)];
        {
            var j: usize = 0;
            while (j < part.len) : (j += 1) {
                if (part[j] == ')') break;
            }
            part = part[0..j];
        }

        var numbers = std.mem.tokenizeScalar(u8, part, ',');
        const left = numbers.next() orelse continue;
        const right = numbers.next() orelse continue;

        const l = std.fmt.parseInt(i32, left, 10) catch continue;
        const r = std.fmt.parseInt(i32, right, 10) catch continue;

        sum += @intCast(l * r);
        if (enabled) {
            enabledSum += @intCast(l * r);
        }
    }

    return .{ sum, enabledSum };
}

test {
    const input =
        \\xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    ;

    const example_result: usize = 161;
    const result = try solve(std.testing.allocator, input);
    try std.testing.expectEqual(example_result, result[0]);

    const input2 =
        \\xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    ;
    const result2 = try solve(std.testing.allocator, input2);
    const example_result2: usize = 48;
    try std.testing.expectEqual(example_result2, result2[1]);
}
