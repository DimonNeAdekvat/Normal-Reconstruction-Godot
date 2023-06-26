#include "Common.gdshaderinc"

vec3 NR_9tap_plus(vec2 uv,vec2 el,mat4 ipm,sampler2D depth_tex){
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
	//from which direction to sample
	float h_sign = he.x < he.y ? -1.0 : 1.0;
	float v_sign = ve.x < ve.y ? -1.0 : 1.0;
	
	vec3 view_h = viewPosDepth(H[1 + int(h_sign)],uv + vec2(h_sign,0.0)*el,ipm);
	vec3 view_v = viewPosDepth(V[1 + int(v_sign)],uv + vec2(0.0,v_sign)*el,ipm);
	
	vec3 view_c = viewPosDepth(depth_c,uv,ipm);
	
	vec3 h_der = h_sign*(view_h - view_c);
	vec3 v_der = v_sign*(view_v - view_c);
	
	vec3 view_n = normalize(cross(v_der,h_der));
	
	return (view_n+1.0)*0.5;
}