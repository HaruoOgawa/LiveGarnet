#version 450

layout(location = 0) in vec3 f_WorldNormal;
layout(location = 1) in vec2 f_Texcoord;
layout(location = 2) in vec4 f_WorldPos;
layout(location = 3) in vec3 f_WorldTangent;
layout(location = 4) in vec3 f_WorldBioTangent;
layout(location = 5) in vec4 v2f_ProjPos;

layout(location = 0) out vec4 gPosition;
layout(location = 1) out vec4 gNormal;
layout(location = 2) out vec4 gAlbedo;
layout(location = 3) out vec4 gDepth;
layout(location = 4) out vec4 gCustomParam0;
layout(location = 5) out vec4 gEmission;

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

#ifdef USE_OPENGL
layout(binding = 3) uniform sampler2D baseColorTexture;
layout(binding = 5) uniform sampler2D metallicRoughnessTexture;
layout(binding = 7) uniform sampler2D normalTexture;
layout(binding = 9) uniform sampler2D emissiveTexture;
#else
layout(binding = 3) uniform texture2D baseColorTexture;
layout(binding = 4) uniform sampler baseColorTextureSampler;
layout(binding = 5) uniform texture2D metallicRoughnessTexture;
layout(binding = 6) uniform sampler metallicRoughnessTextureSampler;
layout(binding = 7) uniform texture2D normalTexture;
layout(binding = 8) uniform sampler normalTextureSampler;
layout(binding = 9) uniform texture2D emissiveTexture;
layout(binding = 10) uniform sampler emissiveTextureSampler;
#endif

// Lenearは光学に則した色空間(現実の光の仕組み
// sRGBはモニターに使われる色空間で人間の色の知覚に則している
// LinearよりsRGBの方が明るい
// https://www.willgibbons.com/linear-workflow/#:~:text=sRGB%20is%20a%20non%2Dlinear,curve%20applied%20to%20the%20brightness.
// https://lettier.github.io/3d-game-shaders-for-beginners/gamma-correction.html
vec4 SRGBtoLINEAR(vec4 srgbIn)
{
	return vec4(pow(srgbIn.xyz, vec3(2.2)), srgbIn.a);
}

vec4 LINEARtoSRGB(vec4 srgbIn)
{
	return vec4(pow(srgbIn.xyz, vec3(1.0 / 2.2)), srgbIn.a);
}

vec4 GetBaseColor()
{
	vec4 baseColor;
	if(ubo.useBaseColorTexture != 0)
	{
		vec2 st = f_Texcoord * ubo.baseColorTexture_ST.xy + ubo.baseColorTexture_ST.zw;

		#ifdef USE_OPENGL
		baseColor = texture(baseColorTexture, st);
		#else
		baseColor = texture(sampler2D(baseColorTexture, baseColorTextureSampler), st);
		#endif
	}
	else
	{
		baseColor = ubo.baseColorFactor;
	}

	return SRGBtoLINEAR(baseColor);
}

vec3 getNormal()
{
	vec3 nomral = vec3(0.0);

	if(ubo.useNormalTexture != 0)
	{
		vec3 t = normalize(f_WorldTangent.xyz);
		vec3 b = normalize(f_WorldBioTangent.xyz);
		vec3 n = normalize(f_WorldNormal.xyz);

		mat3 tbn = mat3(t, b, n);

		#ifdef USE_OPENGL
		nomral = texture(normalTexture, f_Texcoord).rgb;
		#else
		nomral = texture(sampler2D(normalTexture, normalTextureSampler), f_Texcoord).rgb;
		#endif
		
		nomral = normalize( tbn * (2.0 * nomral - 1.0) );
	}
	else
	{
		nomral = f_WorldNormal;
	}

	return nomral;
}

vec2 GetMetallicRoughness()
{
	float perceptualRoughness = ubo.roughnessFactor;
	float metallic = ubo.metallicFactor;

	if(ubo.useMetallicRoughnessTexture != 0)
	{
		// G Channel: Roughness Map, B Channel: Metallic Map 
		#ifdef USE_OPENGL
		vec4 metallicRoughnessColor = texture(metallicRoughnessTexture, f_Texcoord);
		#else
		vec4 metallicRoughnessColor = texture(sampler2D(metallicRoughnessTexture, metallicRoughnessTextureSampler), f_Texcoord);
		#endif
		
		perceptualRoughness = metallicRoughnessColor.g;
		metallic  = metallicRoughnessColor.b;
	}

	return vec2(metallic, perceptualRoughness);
}

vec3 GetEmissive()
{
	vec3 emissive = ubo.emissiveFactor.rgb * ubo.emissiveStrength;
	if(ubo.useEmissiveTexture != 0)
	{
		#ifdef USE_OPENGL
		emissive *= texture(emissiveTexture, f_Texcoord).rgb;
		#else
		emissive *= texture(sampler2D(emissiveTexture, emissiveTextureSampler), f_Texcoord).rgb;
		#endif
	}

	return emissive;
}

void main(){
	if(ubo.useSpatialCulling == 1)
	{
		if(f_WorldPos.y < ubo.spatialCullPos.y)
		{
			discard;
		}
	}

	vec4 baseColor = GetBaseColor();
	vec3 normal = getNormal();
	// float depth = gl_FragCoord.z;
	float depth = v2f_ProjPos.z / v2f_ProjPos.w;
	depth = depth * 0.5 + 0.5;

	vec2 metallicRoughness = GetMetallicRoughness();

	vec3 emissive = GetEmissive();

	gPosition = f_WorldPos;
	gNormal = vec4(normal, 0.0);
	gAlbedo = baseColor;
	gDepth = vec4(depth);
	gCustomParam0 = vec4(ubo.materialType, metallicRoughness.r, metallicRoughness.g, 0.0);
	gEmission = vec4(emissive, 1.0);
}