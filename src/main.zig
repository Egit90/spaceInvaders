const rl = @import("raylib");
const Player = @import("entities.zig").Player;
const Bullet = @import("entities.zig").Bullet;
const Invader = @import("entities.zig").Invader;
const EnemyBullet = @import("entities.zig").EnemyBullet;
const Shield = @import("entities.zig").Shield;
const config_module = @import("config.zig");
const GameConfig = config_module.GameConfig;

fn updatePlayer(player: *Player, bullets: []Bullet) void {
    player.update();
    if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        for (bullets) |*bullet| {
            if (!bullet.active) {
                bullet.position_x = player.position_x + player.width / 2 - bullet.width / 2;
                bullet.position_y = player.position_y;
                bullet.active = true;
                break;
            }
        }
    }
}

fn updateBullets(bullets: []Bullet) void {
    for (bullets) |*bullet| {
        bullet.update();
    }
}

fn handleBulletCollisions(bullets: []Bullet, invaders: anytype, shields: []Shield, score: *i32) void {
    for (bullets) |*bullet| {
        if (!bullet.active) continue;

        for (invaders) |*row| {
            for (row) |*invader| {
                if (!invader.alive) continue;
                if (bullet.getRect().intersects(invader.getRect())) {
                    bullet.active = false;
                    invader.alive = false;
                    score.* += 10;
                    break;
                }
            }
        }

        for (shields) |*shield| {
            if (shield.health > 0) {
                if (bullet.getRect().intersects(shield.getRect())) {
                    bullet.active = false;
                    shield.health -= 1;
                    break;
                }
            }
        }
    }
}

fn updateEnemyBullets(enemy_bullets: []EnemyBullet, screenHeight: i32) void {
    for (enemy_bullets) |*bullet| {
        bullet.update(screenHeight);
    }
}

fn handleEnemyShooting(
    invaders: anytype,
    enemy_bullets: []EnemyBullet,
    enemy_shoot_timer: *i32,
    config: GameConfig,
) void {
    enemy_shoot_timer.* += 1;
    if (enemy_shoot_timer.* >= config.enemyShootDelay) {
        enemy_shoot_timer.* = 0;

        for (invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive and rl.getRandomValue(0, 100) < config.enemyShootChance) {
                    for (enemy_bullets) |*bullet| {
                        if (bullet.active) continue;
                        bullet.position_x = invader.position_x + config.invaderWidth / 2 - bullet.width / 2;
                        bullet.position_y = invader.position_y + invader.height;
                        bullet.active = true;
                        break;
                    }
                }
            }
        }
    }
}

fn updateInvaders(
    invaders: anytype,
    invaderDirection: *f32,
    move_timer: *i32,
    config: GameConfig,
) void {
    move_timer.* += 1;
    if (move_timer.* >= config.invaderMoveDelay) {
        move_timer.* = 0;

        var hit_edge = false;

        for (invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive) {
                    const next_x = invader.position_x + (config.invaderSpeed * invaderDirection.*);
                    if (next_x < 0 or next_x + config.invaderWidth > @as(f32, @floatFromInt(config.screenWidth))) {
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
            invaderDirection.* *= -1.0;
            for (invaders) |*row| {
                for (row) |*invader| {
                    invader.update(0, config.invaderDropDistance);
                }
            }
        } else {
            for (invaders) |*row| {
                for (row) |*invader| {
                    invader.update(config.invaderSpeed * invaderDirection.*, 0);
                }
            }
        }
    }
}

fn checkGameState(invaders: anytype, player: *Player, game_over: *bool, game_won: *bool) void {
    // Check if invaders reached player
    for (invaders) |*row| {
        for (row) |*invader| {
            if (invader.alive) {
                if (invader.getRect().intersects(player.getRect())) {
                    game_over.* = true;
                }
            }
        }
    }

    // Check if all invaders are dead
    var all_invaders_dead = true;
    outer: for (invaders) |*row| {
        for (row) |*invader| {
            if (invader.alive) {
                all_invaders_dead = false;
                break :outer;
            }
        }
    }

    if (all_invaders_dead) {
        game_won.* = true;
    }
}

fn handleEnemyBulletCollisions(
    enemy_bullets: []EnemyBullet,
    player: *Player,
    shields: []Shield,
    game_over: *bool,
) void {
    for (enemy_bullets) |*bullet| {
        if (bullet.active) {
            if (bullet.getRect().intersects(player.getRect())) {
                bullet.active = false;
                game_over.* = true;
            }

            for (shields) |*shield| {
                if (shield.health > 0) {
                    if (bullet.getRect().intersects(shield.getRect())) {
                        bullet.active = false;
                        shield.health -= 1;
                        break;
                    }
                }
            }
        }
    }
}

fn drawEntities(
    player: *Player,
    bullets: []Bullet,
    invaders: anytype,
    shields: []Shield,
    enemy_bullets: []EnemyBullet,
) void {
    for (shields) |*shield| {
        shield.draw();
    }

    player.draw();

    for (bullets) |*bullet| {
        bullet.draw();
    }

    for (invaders) |*row| {
        for (row) |*invader| {
            invader.draw();
        }
    }

    for (enemy_bullets) |*bullet| {
        bullet.draw();
    }
}

fn drawUI(score: i32, config: GameConfig, fontSize: i32, showTitle: bool) void {
    const score_text = rl.textFormat("Score: %d", .{score});
    rl.drawText(score_text, 20, config.screenHeight - 20, @divTrunc(fontSize, 2), rl.Color.white);

    if (showTitle) {
        const text = "Zig Invaders";
        const textWidth = rl.measureText(text, fontSize);
        const textHeight = fontSize;
        const centerX = @divTrunc(config.screenWidth, 2);
        const centerY = @divTrunc(config.screenHeight, 2);
        const x = centerX - @divTrunc(textWidth, 2);
        const y = centerY - @divTrunc(textHeight, 2);
        rl.drawText(text, x, y, fontSize, rl.Color.green);
    }
}

pub fn main() !void {
    const config = config_module.defaultConfig;
    const shieldCount = 4;
    const shieldSpacing = 150.0;

    var game_over = false;
    var game_own = false;
    var invaderDirection: f32 = 1.0;
    var move_timer: i32 = 0;
    var score: i32 = 0;
    var enemy_shoot_timer: i32 = 0;

    var player = Player.initFromConfig(config);

    var shields: [shieldCount]Shield = undefined;
    config_module.initShields(&shields, config, shieldSpacing);

    var bullets: [config.maxBullets]Bullet = undefined;
    config_module.initBullets(&bullets, config);

    var enemy_bullets: [config.maxEnemyBullets]EnemyBullet = undefined;
    config_module.initEnemyBullets(&enemy_bullets, config);

    var invaders: [config.invaderRows][config.invaderCols]Invader = undefined;
    config_module.initInvaders(&invaders, config);

    const fontSize: i32 = 40;
    const text = "Zig Invaders";
    const game_over_text = "Press Enter to Play Again";
    const game_own_text = "You Win!";

    rl.initWindow(config.screenWidth, config.screenHeight, "Zig Invaders");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        // Handle game over screen
        if (game_over) {
            const centerX = @divTrunc(config.screenWidth, 2);
            const centerY = @divTrunc(config.screenHeight, 2);
            const textWidth = rl.measureText(text, fontSize);
            const game_over_text_width = rl.measureText(game_over_text, fontSize);
            const x = centerX - @divTrunc(textWidth, 2);
            const y = centerY - @divTrunc(fontSize, 2);
            const game_over_x = centerX - @divTrunc(game_over_text_width, 2);

            rl.drawText("Game Over", x, y, fontSize, rl.Color.green);
            rl.drawText(game_over_text, game_over_x, y + fontSize + 10, fontSize, rl.Color.green);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                config_module.resetGame(&player, &bullets, &enemy_bullets, &shields, &invaders, &invaderDirection, &score, config, shieldSpacing);
                game_over = false;
            }
            continue;
        }

        // Handle win screen
        if (game_own) {
            const centerX = @divTrunc(config.screenWidth, 2);
            const centerY = @divTrunc(config.screenHeight, 2);
            const game_own_text_width = rl.measureText(game_own_text, fontSize);
            const game_own_x = centerX - @divTrunc(game_own_text_width, 2);
            const y = centerY - @divTrunc(fontSize, 2);

            rl.drawText(game_own_text, game_own_x, y + fontSize + 10, fontSize, rl.Color.green);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
                config_module.resetGame(&player, &bullets, &enemy_bullets, &shields, &invaders, &invaderDirection, &score, config, shieldSpacing);
                game_own = false;
            }
            continue;
        }

        // Update game state
        updatePlayer(&player, &bullets);
        updateBullets(&bullets);
        handleBulletCollisions(&bullets, &invaders, &shields, &score);
        updateEnemyBullets(&enemy_bullets, config.screenHeight);
        handleEnemyShooting(&invaders, &enemy_bullets, &enemy_shoot_timer, config);
        updateInvaders(&invaders, &invaderDirection, &move_timer, config);
        checkGameState(&invaders, &player, &game_over, &game_own);
        handleEnemyBulletCollisions(&enemy_bullets, &player, &shields, &game_over);

        // Draw everything
        drawEntities(&player, &bullets, &invaders, &shields, &enemy_bullets);
        drawUI(score, config, fontSize, !game_over);
    }
}
