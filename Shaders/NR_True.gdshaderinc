#include "Common.gdshaderinc"

vec3 getNormal(sampler2D normal_tex,vec2 uv){
	vec3 normal = texture(normal_tex,uv).rgb;
	vec3 shift = abs(normal - vec3(0.5));
	if (shift.x < 0.25 && shift.y < 0.25 && shift.z < 0.25 && fix_void){
		normal = vec3(0.5,0.5,1.0);
	}
	return normal;
}