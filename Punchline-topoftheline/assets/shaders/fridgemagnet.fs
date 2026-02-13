#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP vec2 fridgemagnet;
extern MY_HIGHP_OR_MEDIUMP number dissolve;
extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv) {
	if (dissolve < 0.001) {
		return vec4(shadow ? vec3(0., 0., 0.) : tex.xyz, shadow ? tex.a * 0.3 : tex.a);
	}

	float adjusted_dissolve = (dissolve * dissolve * (3. - 2. * dissolve)) * 1.02 - 0.01; // Adjusting 0.0-1.0 to fall to -0.1 - 1.1 scale so the mask does
	// not pause at extreme values

	float t = time * 10.0 + 2003.;
	vec2 floored_uv = (floor((uv * texture_details.ba))) / max(texture_details.b, texture_details.a);
	vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);

	vec2 field_part1 = uv_scaled_centered + 50. * vec2(sin(-t / 143.6340), cos(-t / 99.4324));
	vec2 field_part2 = uv_scaled_centered + 50. * vec2(cos(t / 53.1532), cos(t / 61.4532));
	vec2 field_part3 = uv_scaled_centered + 50. * vec2(sin(-t / 87.53218), sin(-t / 49.0000));

	float field =
		(1. + (cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) + cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92)))
		/ 2.;
	vec2 borders = vec2(0.2, 0.8);

	float res = (.5 + .5 * cos((adjusted_dissolve) / 82.612 + (field + -.5) * 3.14))
		- (floored_uv.x > borders.y ? (floored_uv.x - borders.y) * (5. + 5. * dissolve) : 0.) * (dissolve)
		- (floored_uv.y > borders.y ? (floored_uv.y - borders.y) * (5. + 5. * dissolve) : 0.) * (dissolve)
		- (floored_uv.x < borders.x ? (borders.x - floored_uv.x) * (5. + 5. * dissolve) : 0.) * (dissolve)
		- (floored_uv.y < borders.x ? (borders.x - floored_uv.y) * (5. + 5. * dissolve) : 0.) * (dissolve);

	if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8 * (0.5 - abs(adjusted_dissolve - 0.5)) && res > adjusted_dissolve) {
		if (!shadow && res < adjusted_dissolve + 0.5 * (0.5 - abs(adjusted_dissolve - 0.5)) && res > adjusted_dissolve) {
			tex.rgba = burn_colour_1.rgba;
		} else if (burn_colour_2.a > 0.01) {
			tex.rgba = burn_colour_2.rgba;
		}
	}

	return vec4(shadow ? vec3(0., 0., 0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a * 0.3 : tex.a) : .0);
}

#define BASE_COLOR vec3(0.4, 0.45, 0.5)
#define BORDER_COLOR vec3(0.6, 0.65, 0.7)
#define HIGHLIGHT_COLOR vec3(0.8, 0.85, 0.9)
#define SHADOW_COLOR vec3(0.2, 0.25, 0.3)

#define BORDER_WIDTH 0.08
#define INNER_BORDER_WIDTH 0.04
#define BEVEL_STRENGTH 0.6
#define METALLIC_ROUGHNESS 0.3
#define DEPTH_INTENSITY 0.4

#define NOISE_SCALE 15.0
#define NOISE_STRENGTH 0.1
#define SPECULAR_POWER 32.0
#define AMBIENT_STRENGTH 0.3

#define IMAGE_PADDING 0.02
#define IMAGE_BLEND_FACTOR 0.8

// === UTILITY FUNCTIONS ===
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
	vec2 i = floor(st);
	vec2 f = fract(st);

	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float calc_border_dist(vec2 uv) {
	vec2 border_dist = min(uv, 1.0 - uv);

	return min(border_dist.x, border_dist.y);
}

float calc_bevel_factor(float dist) {
	if (dist < BORDER_WIDTH) {
		return smoothstep(0.0, BORDER_WIDTH, dist);
	} else if (dist < BORDER_WIDTH + INNER_BORDER_WIDTH) {
		float inner_progress = (dist - BORDER_WIDTH) / INNER_BORDER_WIDTH;
		return 1.0 - smoothstep(0.0, 1.0, inner_progress) * 0.3;
	}

	return 0.7;
}

vec3 calc_normal(vec2 uv, float height) {
	float eps = 1.0 / 420.0;

	float hx = calc_bevel_factor(calc_border_dist(uv + vec2(eps, 0.0)));
	float hy = calc_bevel_factor(calc_border_dist(uv + vec2(0.0, eps)));

	vec3 normal = normalize(vec3((height - hx) / eps, (height - hy) / eps, 1.0));

	return normal;
}

vec3 apply_lighting(vec3 base_color, vec3 normal, vec2 uv) {
	vec3 light_dir = normalize(vec3(0.5, 0.5, 1.0));
	vec3 view_dir = vec3(0.0, 0.0, 1.0);
	vec3 reflect_dir = reflect(-light_dir, normal);

	float diffuse = max(dot(normal, light_dir), 0.0);
	float specular = pow(max(dot(view_dir, reflect_dir), 0.0), SPECULAR_POWER);

	vec3 ambient = base_color * AMBIENT_STRENGTH;
	vec3 result = ambient + base_color * diffuse + HIGHLIGHT_COLOR * specular + METALLIC_ROUGHNESS;

	return result;
}

const float image_aspect_ratio = 71.0 / 95.0;

vec2 calculate_image_uv(vec2 uv) {
	// Define the content area (inside borders + padding)
	float content_border = BORDER_WIDTH + INNER_BORDER_WIDTH + IMAGE_PADDING;

	// Check if we're inside the content area
	if (uv.x < content_border || uv.x > (1.0 - content_border) || uv.y < content_border || uv.y > (1.0 - content_border)) {
		return vec2(-1.0); // Outside content area
	}

	// Map UV to content area
	vec2 content_size = vec2(1.0 - 2.0 * content_border);
	vec2 content_uv = (uv - content_border) / content_size;

	// Calculate content area aspect ratio
	float content_aspect = content_size.x / content_size.y;

	// Scale to fit while maintaining aspect ratio
	vec2 scale;
	if (image_aspect_ratio > content_aspect) {
		// Image is wider - fit to width
		scale = vec2(1.0, content_aspect / image_aspect_ratio);
	} else {
		// Image is taller - fit to height
		scale = vec2(image_aspect_ratio / content_aspect, 1.0);
	}

	// Center the scaled image
	vec2 offset = (vec2(1.0) - scale) * 0.5;
	vec2 final_uv = content_uv * scale + offset;

	// Check bounds
	if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
		return vec2(-1.0); // Outside image bounds
	}

	return final_uv;
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 tex = Texel(texture, texture_coords);
	vec2 uv = (((texture_coords) * (image_details)) - texture_details.xy * texture_details.ba) / texture_details.ba;

	float border_dist = calc_border_dist(uv);
	float bevel_factor = calc_bevel_factor(border_dist);
	float surface_noise = noise(uv * NOISE_SCALE) * NOISE_STRENGTH;

	vec3 curr_col;

	if (border_dist < BORDER_WIDTH) {
		float border_progress = border_dist / BORDER_WIDTH;

		curr_col = mix(BORDER_COLOR, BASE_COLOR, border_progress);
	} else if (border_dist < BORDER_WIDTH + INNER_BORDER_WIDTH) {
		float inner_progress = (border_dist - BORDER_WIDTH) / INNER_BORDER_WIDTH;

		curr_col = mix(BASE_COLOR, BASE_COLOR * 0.9, inner_progress);
	} else {
		curr_col = BASE_COLOR * 0.85;
	}

	curr_col += surface_noise;

	vec3 surface_normal = calc_normal(uv, bevel_factor);
	vec3 lit_color = apply_lighting(curr_col, surface_normal, uv);

	float depth_shadow = 1.0 - (1.0 - bevel_factor) * DEPTH_INTENSITY;

	lit_color *= depth_shadow;
	lit_color = clamp(lit_color, 0.0, 1.0);

	vec4 final_color = vec4(lit_color, clamp(fridgemagnet.x, 1.0, 1.0));

	return dissolve_mask(tex * final_color, texture_coords, uv);
}

extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
	if (hovering <= 0.) {
		return transform_projection * vertex_position;
	}
	float mid_dist = length(vertex_position.xy - 0.5 * love_ScreenSize.xy) / length(love_ScreenSize.xy);
	vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy) / screen_scale;
	float scale = 0.2 * (-0.03 - 0.3 * max(0., 0.3 - mid_dist)) * hovering * (length(mouse_offset) * length(mouse_offset)) / (2. - mid_dist);

	return transform_projection * vertex_position + vec4(0, 0, 0, scale);
}
#endif