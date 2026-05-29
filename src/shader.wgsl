struct VertexOutput { // Dit zijn de posities van de vertecies die we bewerken in de vertex shader
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
}

struct CameraUniform { // Dit is de data die wij krijgen vanaf de cpu
    pan: vec2<f32>,
    zoom: f32,
    aspect_ratio: f32,
}

@group(0) @binding(0)
var<uniform> camera: CameraUniform;

@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> VertexOutput {   // Dit is de vertex shader
    var out: VertexOutput;                                                  // Dit stuk code zorgt ervoor dat het hele
    var pos = array<vec2<f32>, 3>(                                          // scherm is gevuld met de shader
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
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {                // Dit is de fragment shader, hierover lees je meer in het word document
    let aspect_ratio_corrected_uv = vec2<f32>(in.uv.x * camera.aspect_ratio, in.uv.y);
    let c = aspect_ratio_corrected_uv * camera.zoom + camera.pan;

    var z = vec2<f32>(0.0, 0.0);
    let max_iterations = 256u;
    var i = 0u;
    let z_size_limit = 4.0; // 2.0^2 = 4.0

    while (i < max_iterations && dot(z, z) < z_size_limit) {
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
    let offset: f32 = 1; //offset so the fractal starts with a dark colour black
    let r: f32 = 0;
    let g: f32 = 0;
    let b = sin((t + offset) * transition_speed) * 0.5 + 0.5;

    return vec4<f32>(r, g, b, 1.0);
}