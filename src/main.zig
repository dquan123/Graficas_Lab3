const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;

const rl = @import("raylib");
const Framebuffer = @import("framebuffer.zig").Framebuffer;

const WIDTH: i32 = 800;
const HEIGHT: i32 = 500;

pub fn main() !void {
    const a = Vec3.init(1, 0, 0);
    const b = Vec3.init(0, 1, 0);
    const c = a.cross(b);
    std.debug.print("cross = ({d}, {d}, {d})  dot = {d}\n", .{ c.x, c.y, c.z, a.dot(b) });

    rl.setTraceLogLevel(.warning);

    rl.initWindow(WIDTH, HEIGHT, "Lab 3: Triangulo baricentrico");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var fb = Framebuffer.init(WIDTH, HEIGHT, .black, .white);
    defer fb.deinit();

    // Prueba: tres franjas de colores
    var y: i32 = 100;
    while (y < 400) : (y += 1) {
        var x: i32 = 100;
        while (x < 700) : (x += 1) {
            if (x < 300) {
                fb.set_current_color(.red);
            } else if (x < 500) {
                fb.set_current_color(.green);
            } else {
                fb.set_current_color(.blue);
            }
            try fb.set_pixel(x, y);
        }
    }

    try fb.render_to_file("prueba.png");

    while (!rl.windowShouldClose()) {
        try fb.swap_buffers();
    }
}
