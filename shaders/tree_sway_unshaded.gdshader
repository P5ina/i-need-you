shader_type canvas_item;
render_mode unshaded;

uniform float wind_strength : hint_range(0.0, 1.0) = 0.3;
uniform float wind_speed : hint_range(0.0, 3.0) = 1.0;
uniform float max_angle : hint_range(0.0, 0.5) = 0.2;
uniform float spiral_strength : hint_range(0.0, 3.0) = 1.0;
uniform float sprite_height = 48.0;
uniform float pixel_size = 1.0;
uniform vec2 world_position = vec2(0.0);
uniform float noise_scale : hint_range(0.001, 0.1) = 0.02;
uniform sampler2D wind_noise : repeat_enable;

uniform int h_frames = 1;
uniform int v_frames = 1;
uniform float fps = 8.0;
uniform float time_offset = 0.0;

varying vec4 vertex_modulate;

void vertex() {
    // Сохраняем modulate для fragment шейдера
    vertex_modulate = COLOR;
    
    float height_factor = 1.0 - UV.y;
    float dist_from_base = height_factor * sprite_height;
    
    vec2 noise_uv = world_position * noise_scale + vec2(TIME * wind_speed, 0.0);
    float wind_value = texture(wind_noise, noise_uv).r * 2.0 - 1.0;
    
    float spiral = height_factor * height_factor * spiral_strength * wind_value * wind_strength;
    float total_angle = wind_value * max_angle * wind_strength + spiral;
    
    float sway_x = sin(total_angle) * dist_from_base;
    float sway_y = (1.0 - cos(total_angle)) * dist_from_base;
    
    VERTEX.x += floor(sway_x / pixel_size + 0.5) * pixel_size;
    VERTEX.y -= floor(sway_y / pixel_size + 0.5) * pixel_size;
}

void fragment() {
    int total_frames = h_frames * v_frames;
    int current_frame = int(floor(mod((TIME + time_offset) * fps, float(total_frames))));
    
    vec2 frame_size = vec2(1.0 / float(h_frames), 1.0 / float(v_frames));
    
    int frame_x = current_frame % h_frames;
    int frame_y = current_frame / h_frames;
    
    vec2 frame_offset = vec2(float(frame_x), float(frame_y)) * frame_size;
    vec2 frame_uv = frame_offset + UV * frame_size;
    
    // Применяем modulate к текстуре
    COLOR = texture(TEXTURE, frame_uv) * vertex_modulate;
}