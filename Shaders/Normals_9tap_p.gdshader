shader_type spatial;
render_mode unshaded,depth_draw_never;

uniform sampler2D depth_texture : hint_depth_texture,filter_nearest;

#include "NR_9tap_p.gdshaderinc"

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 el = 1.0/VIEWPORT_SIZE;
	mat4 ipm = INV_PROJECTION_MATRIX;
	vec3 normal = NR_9tap_plus(uv,el,ipm,depth_texture);
	ALBEDO = normal;
}