const rl = @import("raylib");

pub fn main() !void {
    rl.initWindow(800, 500, "Lab 3: Triangulo baricentrico");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);
        rl.drawText("Lab 3 funcionando", 290, 240, 20, .white);
    }
}
