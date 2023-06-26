#include "Common.gdshaderinc"

float getDepth(vec2 uv,sampler2D depth_texture,mat4 ipm){
	float depth = texture(depth_texture,uv).x;
	return -viewPosDepth(depth,uv,ipm).z;
}

float normalIndicator(vec3 normalEdgeBias, vec3 baseNormal, vec3 newNormal, float depth_diff){
	// Credit: https://threejs.org/examples/webgl_postprocessing_pixel.html
	float normalDiff = dot(baseNormal - newNormal, normalEdgeBias);
	float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);
	float depthIndicator = clamp(sign(depth_diff * .25 + .0025), 0.0, 1.0);
	return (1.0 - dot(baseNormal, newNormal)) * depthIndicator * normalIndicator;
}

uniform bool shadows_enabled = true;
uniform bool highlights_enabled = true;
global uniform float shadow_strength : hint_range(0.0, 1.0, 0.01);
global uniform float highlight_strength : hint_range(0.0, 1.0, 0.01);
global uniform vec3 highlight_color : source_color;
global uniform vec3 shadow_color : source_color;