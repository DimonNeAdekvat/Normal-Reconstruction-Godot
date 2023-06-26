shader_type spatial;
render_mode unshaded,depth_draw_never;

uniform sampler2D normals : hint_normal_roughness_texture;

#include "NR_True.gdshaderinc"

void fragment() {
	ALBEDO = getNormal(normals,SCREEN_UV);
}
