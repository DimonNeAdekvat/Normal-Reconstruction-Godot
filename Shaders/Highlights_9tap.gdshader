shader_type spatial;
render_mode unshaded,depth_draw_never;

uniform sampler2D DEPTHS_TEXTURE : hint_depth_texture,filter_nearest;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,filter_nearest;

#include "Common_ED.gdshaderinc"
#include "NR_9tap.gdshaderinc"

void fragment() {
	vec2 e = vec2(1./VIEWPORT_SIZE.xy);
	//	Shadows
	float depth_diff = 0.0;
	float neg_depth_diff = .5;
	if(shadows_enabled){
		float depth = getDepth(SCREEN_UV, DEPTHS_TEXTURE, INV_PROJECTION_MATRIX);
		float du = getDepth(SCREEN_UV+vec2(0., -1.)*e, DEPTHS_TEXTURE, INV_PROJECTION_MATRIX);
		float dr = getDepth(SCREEN_UV+vec2(1., 0.)*e, DEPTHS_TEXTURE, INV_PROJECTION_MATRIX);
		float dd = getDepth(SCREEN_UV+vec2(0., 1.)*e, DEPTHS_TEXTURE, INV_PROJECTION_MATRIX);
		float dl = getDepth(SCREEN_UV+vec2(-1., 0.)*e, DEPTHS_TEXTURE, INV_PROJECTION_MATRIX);
		depth_diff += clamp(du - depth, 0., 1.);
		depth_diff += clamp(dd - depth, 0., 1.);
		depth_diff += clamp(dr - depth, 0., 1.);
		depth_diff += clamp(dl - depth, 0., 1.);
		neg_depth_diff += depth - du;
		neg_depth_diff += depth - dd;
		neg_depth_diff += depth - dr;
		neg_depth_diff += depth - dl;
		neg_depth_diff = clamp(neg_depth_diff, 0., 1.);
		neg_depth_diff = clamp(smoothstep(0.5, 0.5, neg_depth_diff)*10., 0., 1.);
		depth_diff = smoothstep(0.2, 0.3, depth_diff);
	}
	
	//	Highlights
	float normal_diff = 0.;
	if (highlights_enabled) {
		vec3 normal = NR_9tap(SCREEN_UV,e,INV_PROJECTION_MATRIX,DEPTHS_TEXTURE) * 2.0 - 1.0;
		vec3 nu = NR_9tap(SCREEN_UV - vec2(0.0,1.0)*e,e,INV_PROJECTION_MATRIX,DEPTHS_TEXTURE) * 2.0 - 1.0;
		vec3 nr = NR_9tap(SCREEN_UV + vec2(1.0,0.0)*e,e,INV_PROJECTION_MATRIX,DEPTHS_TEXTURE) * 2.0 - 1.0;
		vec3 nd = NR_9tap(SCREEN_UV + vec2(0.0,1.0)*e,e,INV_PROJECTION_MATRIX,DEPTHS_TEXTURE) * 2.0 - 1.0;
		vec3 nl = NR_9tap(SCREEN_UV - vec2(1.0,0.0)*e,e,INV_PROJECTION_MATRIX,DEPTHS_TEXTURE) * 2.0 - 1.0;
		vec3 normal_edge_bias = (vec3(1., 1., 1.));
		normal_diff += normalIndicator(normal_edge_bias, normal, nu, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nr, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nd, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nl, depth_diff);
		normal_diff = smoothstep(0.2, 0.8, normal_diff);
		normal_diff = clamp(normal_diff-neg_depth_diff, 0., 1.);
	}
	
	vec3 original_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 final_highlight_color = mix(original_color, highlight_color, highlight_strength);
	vec3 final_shadow_color = mix(original_color, shadow_color, shadow_strength);
	vec3 final = original_color;
	if (highlights_enabled) {
		final = mix(final, final_highlight_color, normal_diff);
	}
	if (shadows_enabled) {
		final = mix(final, final_shadow_color, depth_diff);
	}
	ALBEDO = final;
//	ALBEDO = texture(NORMAL_TEXTURE,SCREEN_UV).xyz;
	float alpha_mask = depth_diff * float(shadows_enabled) + normal_diff * float(highlights_enabled);
	ALPHA = clamp((alpha_mask) * 5., 0., 1.);
}