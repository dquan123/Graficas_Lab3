const std = @import("std");
const rl = @import("raylib");
const Framebuffer = @import("framebuffer.zig").Framebuffer;
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;

const WIDTH: i32 = 800;
const HEIGHT: i32 = 500;

// Mezcla un canal (R, G o B) de los 3 vértices con los pesos baricéntricos.
fn mezclar(a: u8, b: u8, c: u8, w0: f32, w1: f32, w2: f32) u8 {
    const v = w0 * @as(f32, @floatFromInt(a)) +
        w1 * @as(f32, @floatFromInt(b)) +
        w2 * @as(f32, @floatFromInt(c));
    // Por errores de redondeo v puede salir 255.0001 o -0.0001: lo limitamos.
    return @intFromFloat(@max(0.0, @min(255.0, v)));
}

fn draw_triangle(
    fb: *Framebuffer,
    v0: Vec3,
    v1: Vec3,
    v2: Vec3,
    c0: rl.Color,
    c1: rl.Color,
    c2: rl.Color,
) !void {
    const fw: f32 = @floatFromInt(fb.width);
    const fh: f32 = @floatFromInt(fb.height);

    // Caja contenedora del triángulo, limitada a la pantalla.
    const min_x: i32 = @intFromFloat(@max(0.0, @floor(@min(v0.x, @min(v1.x, v2.x)))));
    const max_x: i32 = @intFromFloat(@min(fw - 1, @ceil(@max(v0.x, @max(v1.x, v2.x)))));
    const min_y: i32 = @intFromFloat(@max(0.0, @floor(@min(v0.y, @min(v1.y, v2.y)))));
    const max_y: i32 = @intFromFloat(@min(fh - 1, @ceil(@max(v0.y, @max(v1.y, v2.y)))));

    var y = min_y;
    while (y <= max_y) : (y += 1) {
        var x = min_x;
        while (x <= max_x) : (x += 1) {
            // Centro del píxel
            const p = Vec3.init(
                @as(f32, @floatFromInt(x)) + 0.5,
                @as(f32, @floatFromInt(y)) + 0.5,
                0,
            );

            // Si el triángulo es degenerado (área 0) no se dibuja nada.
            const w = vec3.barycentric(v0, v1, v2, p) orelse return;

            // Fuera del triángulo si algún peso es negativo.
            if (w.w0 < 0 or w.w1 < 0 or w.w2 < 0) continue;

            fb.set_current_color(.{
                .r = mezclar(c0.r, c1.r, c2.r, w.w0, w.w1, w.w2),
                .g = mezclar(c0.g, c1.g, c2.g, w.w0, w.w1, w.w2),
                .b = mezclar(c0.b, c1.b, c2.b, w.w0, w.w1, w.w2),
                .a = 255,
            });
            try fb.set_pixel(x, y);
        }
    }
}

const rojo = rl.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };
const verde = rl.Color{ .r = 0, .g = 255, .b = 0, .a = 255 };
const azul = rl.Color{ .r = 0, .g = 0, .b = 255, .a = 255 };

const Triangulo = struct { v0: Vec3, v1: Vec3, v2: Vec3 };

const triangulos = [_]Triangulo{
    // 1: casi equilátero
    .{ .v0 = Vec3.init(220, 400, 0), .v1 = Vec3.init(400, 88, 0), .v2 = Vec3.init(580, 400, 0) },
    // 2: irregular
    .{ .v0 = Vec3.init(120, 430, 0), .v1 = Vec3.init(330, 60, 0), .v2 = Vec3.init(700, 340, 0) },
    // 3: delgado
    .{ .v0 = Vec3.init(300, 440, 0), .v1 = Vec3.init(520, 60, 0), .v2 = Vec3.init(350, 440, 0) },
};

const nombres = [_][]const u8{ "triangulo1.png", "triangulo2.png", "triangulo3.png" };

fn render_caso(fb: *Framebuffer, t: Triangulo) !void {
    fb.clear();
    try draw_triangle(fb, t.v0, t.v1, t.v2, rojo, verde, azul);
}

pub fn main() !void {
    rl.setTraceLogLevel(.warning);
    rl.initWindow(WIDTH, HEIGHT, "Lab 3: Triangulo baricentrico");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var fb = Framebuffer.init(WIDTH, HEIGHT, .black, .white);
    defer fb.deinit();

    // Exporta las 3 imágenes de entrega
    for (triangulos, 0..) |t, i| {
        try render_caso(&fb, t);
        try fb.render_to_file(nombres[i]);
    }

    // Muestra el primero; ESPACIO cambia al siguiente
    var actual: usize = 0;
    try render_caso(&fb, triangulos[actual]);

    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.space)) {
            actual = (actual + 1) % triangulos.len;
            try render_caso(&fb, triangulos[actual]);
        }
        try fb.swap_buffers();
    }
}
