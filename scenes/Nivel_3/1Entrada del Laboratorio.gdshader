
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float desenfoque : hint_range(0.0, 5.0) = 2.0;
uniform float oscuridad : hint_range(0.0, 1.0) = 0.55;

void fragment() {
    vec4 fondo = textureLod(
        screen_texture,
        SCREEN_UV,
        desenfoque
    );

    fondo.rgb = mix(
        fondo.rgb,
        vec3(0.02, 0.04, 0.09),
        oscuridad
    );

    COLOR = vec4(fondo.rgb, 1.0);
}
