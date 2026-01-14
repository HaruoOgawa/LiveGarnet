#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inTexcoord;
layout(location = 3) in vec4 inTangent;
layout(location = 4) in uvec4 inJoint0;
layout(location = 5) in vec4 inWeights0;

layout(binding = 0) uniform UniformBufferObject{
    // Vertex
	mat4 model;
    mat4 view;
    mat4 proj;
    mat4 lightVPMat;

    int   useSkinMeshAnimation;
    int   useSpatialCulling;
    int   pad1;
    int   pad2;

    // Fragment
    vec4 baseColorFactor;
	vec4 spatialCullPos;
	vec4 emissiveFactor;
	
    float metallicFactor;
    float roughnessFactor;
	float emissiveStrength;
	float materialType;

    int   useBaseColorTexture;
    int   useMetallicRoughnessTexture;
    int   useNormalTexture;
    int   useEmissiveTexture;

    vec4 baseColorTexture_ST;
} ubo;

layout(binding = 1) uniform SkinMatrixBuffer
{
    mat4 SkinMat[1024];
} r_SkinMatrixBuffer;

layout(location = 0) out vec3 f_WorldNormal;
layout(location = 1) out vec2 f_Texcoord;
layout(location = 2) out vec4 f_WorldPos;
layout(location = 3) out vec3 f_WorldTangent;
layout(location = 4) out vec3 f_WorldBioTangent;
layout(location = 5) out vec4 v2f_ProjPos;

void main(){
    vec3 BioTangent = cross(inNormal, inTangent.xyz);

    vec4 WorldPos;
    vec3 WorldNormal;
    vec3 WorldTangent;
    vec3 WorldBioTangent;

    // スキンメッシュアニメーション
    if(ubo.useSkinMeshAnimation != 0)
    {
        mat4 SkinMat =
            inWeights0.x * r_SkinMatrixBuffer.SkinMat[inJoint0.x] +
            inWeights0.y * r_SkinMatrixBuffer.SkinMat[inJoint0.y] +
            inWeights0.z * r_SkinMatrixBuffer.SkinMat[inJoint0.z] +
            inWeights0.w * r_SkinMatrixBuffer.SkinMat[inJoint0.w ] 
        ;

        // スキンメッシュアニメーションの時はubo.modelは乗算しないように注意
        WorldPos = SkinMat * vec4(inPosition, 1.0);
        WorldNormal = normalize((SkinMat * vec4(inNormal, 0.0)).xyz);
        WorldTangent = normalize((SkinMat * inTangent).xyz);
        WorldBioTangent = normalize((SkinMat * vec4(BioTangent, 0.0)).xyz);
    }
    else
    {
        // 通常の描画
        WorldPos = ubo.model * vec4(inPosition, 1.0);
        WorldNormal = normalize((ubo.model * vec4(inNormal, 0.0)).xyz);
        WorldTangent = normalize((ubo.model * inTangent).xyz);
        WorldBioTangent = normalize((ubo.model * vec4(BioTangent, 0.0)).xyz);
    }

    vec4 ProjPos = ubo.proj * ubo.view * WorldPos;

    gl_Position = ProjPos;
    f_WorldNormal = WorldNormal;
    f_Texcoord = inTexcoord;
    f_WorldPos = WorldPos;
    f_WorldTangent = WorldTangent;
    f_WorldBioTangent = WorldBioTangent;
    v2f_ProjPos = ProjPos;
}