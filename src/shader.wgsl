struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
}

struct CameraUniform {
    pan: vec2<f32>,
    zoom: f32,
    aspect_ratio: f32,
}

@group(0) @binding(0)
var<uniform> camera: CameraUniform;

@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> VertexOutput {
    var out: VertexOutput;
    var pos = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>( 3.0, -1.0),
        vec2<f32>(-1.0,  3.0)
    );
    let xy = pos[in_vertex_index];
    out.position = vec4<f32>(xy, 0.0, 1.0);
    out.uv = xy;
    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let corrected_uv = vec2<f32>(in.uv.x * camera.aspect_ratio, in.uv.y);
    let c = corrected_uv * camera.zoom + camera.pan;

    var z = vec2<f32>(0.0, 0.0);
    let max_iterations = 256u;
    var i = 0u;

    while (i < max_iterations && dot(z, z) < 4.0) {
        let next_x = z.x * z.x - z.y * z.y + c.x;
        let next_y = 2.0 * z.x * z.y + c.y;
        z = vec2<f32>(next_x, next_y);
        i++;
    }

    if (i == max_iterations) {
        return vec4<f32>(0.0, 0.0, 0.0, 1.0);
    }

    let t = f32(i) / f32(max_iterations);
    let transition_speed = 30.0;
    let r: f32 = 0;
    let g: f32 = 0;
    let b = sin(t * transition_speed) * 0.5 + 0.5;

    return vec4<f32>(r, g, b, 1.0);
}