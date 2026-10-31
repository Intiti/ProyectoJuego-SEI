shader_type canvas_item;

uniform vec4 topColor : source_color = vec4(0.05, 0.02, 0.16, 1.0);
uniform vec4 bottomColor : source_color = vec4(0.02, 0.10, 0.20, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec3 color = mix(topColor.rgb, bottomColor.rgb, UV.y);

	float band = sin(UV.y * 9.0 + TIME * 0.25 + sin(UV.x * 3.0 + TIME * 0.15) * 1.5) * 0.5 + 0.5;
	color += vec3(0.05, 0.03, 0.10) * band;

	float shaft = sin(UV.x * 6.0 + TIME * 0.2) * 0.5 + 0.5;
	color += vec3(0.04, 0.02, 0.08) * shaft * (1.0 - UV.y);

	vec2 grid = vec2(48.0, 27.0);
	vec2 cell = floor(UV * grid);
	vec2 local = fract(UV * grid) - 0.5;
	float rnd = hash(cell);
	vec2 jitter = (vec2(hash(cell + 7.0), hash(cell + 13.0)) - 0.5) * 0.5;
	float star = step(0.93, rnd) * smoothstep(0.18, 0.0, length(local - jitter));
	float twinkle = 0.75 + 0.25 * sin(TIME * 0.8 + rnd * 40.0);
	color += vec3(0.8, 0.85, 1.0) * star * twinkle;

	COLOR = vec4(color, 1.0);
}
