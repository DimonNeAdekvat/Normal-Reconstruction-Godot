#include "Common.gdshaderinc"

vec3 NR_3tap(vec2 uv,vec2 el,mat4 ipm,sampler2D depth_tex){
	float depth_c = texture(depth_tex,uv).x;
	//early exit if on the end of view distance
	if (depth_c == 1.0){
		float z = fix_void ? 1.0 : 0.5;
		return vec3(0.5,0.5,z);
	}
	
	vec3 view_c = viewPosDepth(depth_c,uv,ipm);
	vec3 view_r = viewPosSampler(depth_tex,uv + vec2(1.0,0.0)*el,ipm);
	vec3 view_u = viewPosSampler(depth_tex,uv + vec2(0.0,1.0)*el,ipm);
	
	vec3 h_der = view_r - view_c;
	vec3 v_der = view_u - view_c;
	
	vec3 view_n = normalize(cross(v_der,h_der));
	
	return (view_n+1.0)*0.5;
}