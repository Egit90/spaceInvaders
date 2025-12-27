const rl = @import("raylib");
const Player = @import("entities.zig").Player;
const Bullet = @import("entities.zig").Bullet;

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 600;
    const playerWidth = 50.0;
    const playerHeight = 30.0;
    const maxBullets = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;

    var player = Player.init(
        @as(f32, @floatFromInt(screenWidth)) / 2 - playerWidth / 2,
        @as(f32, @floatFromInt(screenHeight)) - 60,
        playerWidth,
        playerHeight,
    );

    var bullets: [maxBullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(
            0,
            0,
            bulletWidth,
            bulletHeight,
        );
    }

    const fontSize: i32 = 40;
    const text = "Zig Invaders";

    rl.initWindow(screenWidth, screenHeight, "Zig Invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        const centerX = screenWidth / 2;
        const centerY = screenHeight / 2;

        const textWidth = rl.measureText(text, fontSize);
        const textHeight = fontSize;

        const x = centerX - @divTrunc(textWidth, 2);
        const y = centerY - @divTrunc(textHeight, 2);

        // update
        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + player.width / 2 - bullet.width / 2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        // draw
        player.draw();
        for (&bullets) |*bullet| {
            bullet.draw();
        }

        rl.drawText("Zig Invaders", x, y, fontSize, rl.Color.green);
    }
}
