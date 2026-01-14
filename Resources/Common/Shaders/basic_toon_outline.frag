#version 450

layout(location = 0) in vec3 f_WorldNormal;
layout(location = 1) in vec2 f_Texcoord;
layout(location = 2) in vec4 f_WorldPos;
layout(location = 3) in vec3 f_WorldTangent;
layout(location = 4) in vec3 f_WorldBioTangent;
layout(location = 5) in vec4 f_LightSpacePos;
layout(location = 6) in vec2 f_SphereUV;

layout(location = 0) out vec4 outColor;

layout(binding = 2) uniform FragUniformBufferObject{
	vec4 edgeColor;

	mat4 mPad0;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;
} fragUbo;

void main(){
	vec3 col = vec3(1.0);
	float alpha = 1.0;

	col.rgb = fragUbo.edgeColor.rgb;
	
	outColor = vec4(col, alpha);
}