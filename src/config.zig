const Player = @import("entities.zig").Player;
const Bullet = @import("entities.zig").Bullet;
const Invader = @import("entities.zig").Invader;
const EnemyBullet = @import("entities.zig").EnemyBullet;
const Shield = @import("entities.zig").Shield;

pub fn initShields(shields: []Shield, config: GameConfig, shieldSpacing: f32) void {
    for (shields, 0..) |*shield, index| {
        const x = config.shieldStartX + @as(f32, @floatFromInt(index)) * shieldSpacing;
        shield.* = Shield.init(
            x,
            config.shieldStartY,
            config.shieldWidth,
            config.shieldHeight,
        );
    }
}

pub fn initBullets(bullets: []Bullet, config: GameConfig) void {
    for (bullets) |*bullet| {
        bullet.* = Bullet.init(
            0,
            0,
            config.bulletWidth,
            config.bulletHeight,
        );
    }
}

pub fn initEnemyBullets(enemy_bullets: []EnemyBullet, config: GameConfig) void {
    for (enemy_bullets) |*bullet| {
        bullet.* = EnemyBullet.init(0, 0, config.bulletWidth, config.bulletHeight);
    }
}

pub fn initInvaders(invaders: anytype, config: GameConfig) void {
    for (invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = config.invaderStartX + @as(f32, @floatFromInt(j)) * config.invaderSpacingX;
            const y = config.invaderStartY + @as(f32, @floatFromInt(i)) * config.invaderSpacingY;
            invader.* = Invader.init(
                x,
                y,
                config.invaderWidth,
                config.invaderHeight,
            );
        }
    }
}

pub const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartY: f32,
    playerSpeed: f32,
    maxBullets: i32,
    bulletWidth: f32,
    bulletHeight: f32,
    bulletSpeed: f32,
    shieldStartX: f32,
    shieldStartY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    shieldHealth: i32,
    invaderRows: i32,
    invaderCols: i32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
    invaderSpeed: f32,
    invaderMoveDelay: i32,
    invaderDropDistance: f32,
    maxEnemyBullets: i32,
    enemyBulletSpeed: f32,
    enemyShootDelay: i32,
    enemyShootChance: i32,
};

pub const defaultConfig = GameConfig{
    .screenWidth = 800,
    .screenHeight = 600,
    .playerWidth = 50.0,
    .playerHeight = 30.0,
    .playerStartY = 60.0,
    .playerSpeed = 5.0,
    .maxBullets = 10,
    .bulletWidth = 4.0,
    .bulletHeight = 10.0,
    .bulletSpeed = 10.0,
    .shieldStartX = 100.0,
    .shieldStartY = 450.0,
    .shieldWidth = 80.0,
    .shieldHeight = 60.0,
    .shieldSpacing = 120.0,
    .shieldHealth = 10,
    .invaderRows = 5,
    .invaderCols = 11,
    .invaderStartX = 100.0,
    .invaderStartY = 50.0,
    .invaderWidth = 40.0,
    .invaderHeight = 30.0,
    .invaderSpacingX = 60.0,
    .invaderSpacingY = 40.0,
    .invaderSpeed = 10.0,
    .invaderMoveDelay = 30,
    .invaderDropDistance = 20.0,
    .maxEnemyBullets = 20,
    .enemyBulletSpeed = 5.0,
    .enemyShootDelay = 60,
    .enemyShootChance = 25,
};

pub fn resetGame(
    player: *Player,
    bullets: []Bullet,
    enemyBullets: []EnemyBullet,
    shields: []Shield,
    invaders: anytype,
    invader_direction: *f32,
    score: *i32,
    config: GameConfig,
    shieldSpacing: f32,
) void {
    score.* = 0;
    player.* = Player.initFromConfig(config);

    initBullets(bullets, config);
    initEnemyBullets(enemyBullets, config);
    initShields(shields, config, shieldSpacing);
    initInvaders(invaders, config);

    invader_direction.* = 1.0;
}
