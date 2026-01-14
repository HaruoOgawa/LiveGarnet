#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inTexcoord;
layout(location = 3) in vec4 inTangent;
layout(location = 4) in uvec4 inBone0;
layout(location = 5) in vec4 inWeights0;

layout(location = 0) out vec2 v2f_UV;
layout(location = 1) out vec4 v2f_ProjPos;
layout(location = 2) out vec4 v2f_WorldPos;

layout(binding = 0) uniform VertUniformBuffer{
	mat4 model;
    mat4 view;
    mat4 proj;
    mat4 lightVPMat;
} v_ubo;

void main()
{
	vec4 ProjPos = v_ubo.proj * v_ubo.view * v_ubo.model * vec4(inPosition, 1.0);

	gl_Position = ProjPos;
	v2f_UV = inTexcoord;
	v2f_ProjPos = ProjPos;
	v2f_WorldPos = v_ubo.model * vec4(inPosition, 1.0);
}