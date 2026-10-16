const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;

const rl = @import("raylib");
const Framebuffer = @import("framebuffer.zig").Framebuffer;

const bary = @import("vec3.zig").barycentric;

const WIDTH: i32 = 800;
const HEIGHT: i32 = 500;

pub fn main() !void {
    const a = Vec3.init(1, 0, 0);
    const b = Vec3.init(0, 1, 0);
    const c = a.cross(b);
    std.debug.print("cross = ({d}, {d}, {d})  dot = {d}\n", .{ c.x, c.y, c.z, a.dot(b) });

    const t0 = Vec3.init(0, 0, 0);
    const t1 = Vec3.init(4, 0, 0);
    const t2 = Vec3.init(0, 4, 0);

    const centro = bary(t0, t1, t2, Vec3.init(4.0 / 3.0, 4.0 / 3.0, 0)).?;
    std.debug.print("centro = ({d:.3}, {d:.3}, {d:.3})\n", .{ centro.w0, centro.w1, centro.w2 });

    const en_v1 = bary(t0, t1, t2, t1).?;
    std.debug.print("en v1  = ({d:.3}, {d:.3}, {d:.3})\n", .{ en_v1.w0, en_v1.w1, en_v1.w2 });

    const fuera = bary(t0, t1, t2, Vec3.init(5, 5, 0)).?;
    std.debug.print("fuera  = ({d:.3}, {d:.3}, {d:.3})\n", .{ fuera.w0, fuera.w1, fuera.w2 });

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
