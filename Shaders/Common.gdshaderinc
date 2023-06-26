global uniform bool compatibility;
global uniform bool fix_void;

void vertex(){
	float z = compatibility ? -1.0 : 0.0;
	POSITION = vec4(VERTEX.xy,z,1.0);
}

vec3 viewPosDepth(float depth,vec2 uv,mat4 ipm){
	float z = compatibility ? depth * 2.0 -1.0 : depth;
	vec3 ndc = vec3(uv*2.0 - 1.0,z);
	vec4 view = ipm * vec4(ndc,1.0);
	view.xyz /= view.w;
	return view.xyz;
}

vec3 viewPosSampler(sampler2D depth_tex,vec2 uv,mat4 ipm){
	float depth = texture(depth_tex,uv).x;
	return viewPosDepth(depth,uv,ipm);
}