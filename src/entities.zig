const rl = @import("raylib");
const GameConfig = @import("config.zig").GameConfig;

pub const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
        };
    }

    pub fn initFromConfig(config: GameConfig) @This() {
        return Player.init(
            @as(f32, @floatFromInt(config.screenWidth)) / 2.0 - config.playerWidth / 2.0,
            @as(f32, @floatFromInt(config.screenHeight)) - config.playerStartY,
            config.playerWidth,
            config.playerHeight,
        );
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }

        if (self.position_x < 0) {
            self.position_x = 0;
        }

        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

pub const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and // my LEFT is left of their RIGHT
            self.x + self.width > other.x and // my RIGHT is right of their LEFT
            self.y < other.y + other.height and // my TOP is above their BOTTOM
            self.y + self.height > other.y; // my BOTTOM is below their TOP

        // If all four are true, the rectangles must be overlapping
        // there's no gap between them on either axis!
    }
};

pub const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 10.0,
            .active = false,
        };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.position_y -= self.speed;
            if (self.position_y < 0) self.active = false;
        }
    }

    pub fn draw(self: *@This()) void {
        if (!self.active) return;
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.red,
        );
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

pub const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .alive = true,
        };
    }

    pub fn draw(self: @This()) void {
        if (!self.alive) return;
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.green,
        );
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.position_x += dx;
        self.position_y += dy;
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

pub const EnemyBullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.0,
            .active = false,
        };
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn update(self: *@This(), screen_height: i32) void {
        if (!self.active) return;
        self.position_y += self.speed;
        if (self.position_y > @as(f32, @floatFromInt(screen_height))) {
            self.active = false;
        }
    }

    pub fn draw(self: *@This()) void {
        if (!self.active) return;
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.yellow,
        );
    }
};

pub const Shield = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    health: i32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) Shield {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .health = 10,
        };
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.health <= 0) return;
        const alpha = @as(u8, @intCast(@min(255, self.health * 25)));

        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color{
                .r = 0,
                .g = 255,
                .b = 255,
                .a = alpha,
            },
        );
    }
};
