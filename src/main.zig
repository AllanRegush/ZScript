const std = @import("std");
const ArrayList = std.ArrayList;

const TokenKind = enum { LEFT_PAREN, RIGHT_PAREN };

const Contents = union {
    val: u64,
    string: []const u8,
};

const Token = struct {
    kind: TokenKind,
    contents: Contents,
};

const Scanner = struct {
    const Self = @This();
    src: []const u8,
    tokens: ArrayList(Token),
    start: u64,
    current: u64,
    pub fn init(
        src: []const u8,
    ) Scanner {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        //defer arena.deinit();
        var allocator = &arena.allocator;
        return Scanner{
            .src = src,
            .tokens = ArrayList(Token).init(allocator),
            .start = 0,
            .current = 0,
        };
    }

    fn add_token(self: *Self, kind: TokenKind) !void {
        switch (kind) {
            TokenKind.LEFT_PAREN, TokenKind.RIGHT_PAREN => {
                try self.tokens.append(.{ .kind = kind, .contents = Contents{
                    .string = self.src[self.start..self.current],
                } });
            },
        }
    }

    fn scan_token(self: *Self) !void {
        const char: u8 = self.advance();
        switch (char) {
            '(' => {
                //std.debug.print("{c}\n", .{char});
                try self.add_token(TokenKind.LEFT_PAREN);
            },
            ')' => {
                //std.debug.print("{c}\n", .{char});
                try self.add_token(TokenKind.RIGHT_PAREN);
            },
            else => {
                std.debug.print("{c}\n", .{char});
            },
        }
    }

    pub fn scan_tokens(self: *Self) !ArrayList(Token) {
        while (self.current < self.src.len) {
            self.start = self.current;
            try self.scan_token();
        }
        return self.tokens;
    }

    fn advance(self: *Self) u8 {
        const char: u8 = self.src[self.current];
        self.current += 1;
        return char;
    }
};

pub fn run(line: []const u8) !void {
    var scanner = Scanner.init(line);
    const Tokens = try scanner.scan_tokens();

    for (Tokens.items) |token| {
        std.debug.print("{}, Contents: {s} len: {}\n", .{ token, token.contents.string, token.contents.string.len });
    }
}

pub fn main() anyerror!void {
    const stdin = std.io.getStdIn().reader();
    while (true) {
        std.debug.print("> ", .{});
        var buf: [10]u8 = undefined;

        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
            try run(line[0 .. line.len - 1]);
        }
    }
}
