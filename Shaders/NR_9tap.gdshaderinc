#include "Common.gdshaderinc"

vec3 NR_9tap(vec2 uv,vec2 el,mat4 ipm,sampler2D depth_tex){
	vec3 view_c = viewPosSampler(depth_tex,uv,ipm);
	vec3 view_l = viewPosSampler(depth_tex,uv - vec2(1.0,0.0)*el,ipm);
	vec3 view_r = viewPosSampler(depth_tex,uv + vec2(1.0,0.0)*el,ipm);
	vec3 view_d = viewPosSampler(depth_tex,uv - vec2(0.0,1.0)*el,ipm);
	vec3 view_u = viewPosSampler(depth_tex,uv + vec2(0.0,1.0)*el,ipm);
	
	vec3 l = view_c - view_l;
	vec3 r = view_r - view_c;
	vec3 d = view_c - view_d;
	vec3 u = view_u - view_c;
	
	
	//deside from which direction to sample
	//center depth
	float depth_c = texture(depth_tex,uv).x;
	//early exit if on the end of view distance
	if (depth_c == 1.0){
		float z = fix_void ? 1.0 : 0.5;
		return vec3(0.5,0.5,z);
	}
	//horizontal depths
	vec4 H = vec4(
		texture(depth_tex,uv - vec2(1.0,0.0)*el).x,
		texture(depth_tex,uv - vec2(2.0,0.0)*el).x,
		texture(depth_tex,uv + vec2(1.0,0.0)*el).x,
		texture(depth_tex,uv + vec2(2.0,0.0)*el).x
	);
	//vertical depths
	vec4 V = vec4(
		texture(depth_tex,uv - vec2(0.0,1.0)*el).x,
		texture(depth_tex,uv - vec2(0.0,2.0)*el).x,
		texture(depth_tex,uv + vec2(0.0,1.0)*el).x,
		texture(depth_tex,uv + vec2(0.0,2.0)*el).x
	);
	//find diff of true center and extrapolated one
	vec2 he = abs((2.0*H.xz - H.yw) - depth_c);
	vec2 ve = abs((2.0*V.xz - V.yw) - depth_c);
	
	vec3 h_der = he.x < he.y ? l : r;
	vec3 v_der = ve.x < ve.y ? d : u;
	
	vec3 view_n = normalize(cross(v_der,h_der));
	
	return (view_n+1.0)*0.5;
}