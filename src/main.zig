const rl = @import("raylib");
const Player = @import("entities.zig").Player;
const Bullet = @import("entities.zig").Bullet;
const Invader = @import("entities.zig").Invader;

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 600;
    const playerWidth = 50.0;
    const playerHeight = 30.0;
    const maxBullets = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;
    const invaderRows = 5;
    const invaderCols = 11;
    const invaderWidth = 40.0;
    const invaderHeight = 30.0;
    const invaderStartX = 100.0;
    const invaderStartY = 50.0;
    const invaderSpacingX = 60.0;
    const invaderSpacingY = 40.0;
    const invaderSpeed = 10.0;
    const invaderMoverDelay = 30;
    const invaderDropDistance = 20.0;
    var invaderDirection: f32 = 1.0;
    var move_timer: i32 = 0;
    var score: i32 = 0;

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

    var invaders: [invaderRows][invaderCols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invaderStartX + @as(f32, @floatFromInt(j)) * invaderSpacingX;
            const y = invaderStartY + @as(f32, @floatFromInt(i)) * invaderSpacingY;
            invader.* = Invader.init(
                x,
                y,
                invaderWidth,
                invaderHeight,
            );
        }
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

        for (&bullets) |*bullet| {
            if (!bullet.active) continue;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (!invader.alive) continue;
                    if (bullet.getRect().intersects(invader.getRect())) {
                        bullet.active = false;
                        invader.alive = false;
                        score += 10;
                        break;
                    }
                }
            }
        }

        move_timer += 1;
        if (move_timer >= invaderMoverDelay) {
            move_timer = 0;

            var hit_edge = false;

            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const next_x = invader.position_x + (invaderSpeed * invaderDirection);
                        if (next_x < 0 or next_x + invaderWidth > @as(f32, @floatFromInt(screenWidth))) {
                            hit_edge = true;
                            break;
                        }
                    }
                    if (hit_edge) {
                        break;
                    }
                }
            }

            if (hit_edge) {
                invaderDirection *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0, invaderDropDistance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invaderSpeed * invaderDirection, 0);
                    }
                }
            }
        }
        // draw
        player.draw();
        for (&bullets) |*bullet| {
            bullet.draw();
        }

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }

        const score_text = rl.textFormat("Score: %d", .{score});

        rl.drawText(score_text, 20, screenHeight - 20, fontSize / 2, rl.Color.white);
        rl.drawText("Zig Invaders", x, y, fontSize, rl.Color.green);
    }
}
