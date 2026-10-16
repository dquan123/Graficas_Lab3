pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    // a - b: vector que va de b hacia a
    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
    }

    // Producto cruz: vector perpendicular a a y b.
    // Su longitud = área del paralelogramo; su sentido depende del orden (a x b = -(b x a)).
    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    // Producto punto: número. Positivo si apuntan hacia el mismo lado, negativo si no.
    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }
};

pub const Bary = struct { w0: f32, w1: f32, w2: f32 };

// Coordenadas baricéntricas de P respecto al triángulo (v0, v1, v2).
pub fn barycentric(v0: Vec3, v1: Vec3, v2: Vec3, p: Vec3) ?Bary {
    const n = v1.sub(v0).cross(v2.sub(v0)); // normal; |n| = 2 * área total
    const denom = n.dot(n);
    if (denom == 0) return null; // los 3 puntos están en línea: no hay triángulo

    // Arista v0->v1: su sub-triángulo con P está opuesto a v2 -> peso de v2
    const c2 = v1.sub(v0).cross(p.sub(v0));
    // Arista v1->v2: opuesto a v0 -> peso de v0
    const c0 = v2.sub(v1).cross(p.sub(v1));
    // Arista v2->v0: opuesto a v1 -> peso de v1
    const c1 = v0.sub(v2).cross(p.sub(v2));

    return .{
        .w0 = n.dot(c0) / denom,
        .w1 = n.dot(c1) / denom,
        .w2 = n.dot(c2) / denom,
    };
}
