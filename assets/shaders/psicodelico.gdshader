shader_type canvas_item;

uniform sampler2D screenTexture : hint_screen_texture, filter_linear, repeat_disable;
uniform float intensity : hint_range(0.0, 2.0) = 0.0;
uniform float swirl : hint_range(0.0, 12.0) = 0.0;
uniform float fade : hint_range(0.0, 1.0) = 0.0;
uniform float colorAmount : hint_range(0.0, 1.0) = 1.0;
uniform vec2 center = vec2(0.5, 0.5);
uniform float aspect = 1.7778;

vec3 hueShift(vec3 color, float shift) {
	const vec3 k = vec3(0.57735);
	float c = cos(shift);
	float s = sin(shift);
	return color * c + cross(k, color) * s + k * dot(k, color) * (1.0 - c);
}

void fragment() {
	vec2 delta = SCREEN_UV - center;
	delta.x *= aspect;
	float dist = length(delta);
	vec2 direction = delta / (dist + 0.0001);
	vec2 uvDirection = vec2(direction.x / aspect, direction.y);

	float twist = swirl * exp(-dist * 2.2);
	float ca = cos(twist);
	float sa = sin(twist);
	vec2 twisted = vec2(delta.x * ca - delta.y * sa, delta.x * sa + delta.y * ca);

	float falloff = exp(-dist * 1.6);
	float ripple = sin(dist * 28.0 - TIME * 2.4) * intensity * 0.006 * falloff;
	vec2 uv = center + vec2(twisted.x / aspect, twisted.y) + uvDirection * ripple;
	uv.x += sin(SCREEN_UV.y * 16.0 + TIME * 1.3) * intensity * 0.003;

	vec2 split = uvDirection * intensity * 0.004;
	float r = texture(screenTexture, uv + split).r;
	float g = texture(screenTexture, uv).g;
	float b = texture(screenTexture, uv - split).b;
	vec3 color = vec3(r, g, b);

	float shift = intensity * (TIME * 0.25 + dist * 2.0);
	color = mix(color, hueShift(color, shift), clamp(intensity, 0.0, 1.0) * 0.6);

	float luma = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(luma), color, 1.0 + intensity * 0.3);

	vec3 aura = hueShift(vec3(0.45, 0.2, 0.7), TIME * 0.3);
	color += aura * exp(-dist * 6.0) * intensity * 0.22 * colorAmount;

	color *= 1.0 - smoothstep(0.35, 0.95, dist) * 0.4 * clamp(intensity, 0.0, 1.0);

	float finalLuma = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(vec3(finalLuma), color, colorAmount);
	color = mix(color, vec3(0.0), fade);

	COLOR = vec4(color, 1.0);
}
