#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

layout(location = 0) out vec4 outColor;

layout(binding = 1) uniform LightUniformBuffer{
	mat4 lightVPMat;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;

    float type; // ライトのタイプ
    float radius; // ライトの有効範囲
    float intensity; // ライトの強さ
    float angle; // ライトの有効範囲

	float height; // ライトの有効範囲
	float mipCount;
	float ShadowMapX;
	float ShadowMapY;

	int useIBL;
	int useShadowMap;
	int ForceLighting;
	int iPad2;

    vec4 dir;
    vec4 pos;
    vec4 color;
    vec4 cameraPos;
} l_ubo;

#ifdef USE_OPENGL
layout(binding = 2) uniform sampler2D gPositionTexture;
layout(binding = 4) uniform sampler2D gNormalTexture;
layout(binding = 6) uniform sampler2D gAlbedoTexture;
layout(binding = 8) uniform sampler2D gDepthTexture;
layout(binding = 10) uniform sampler2D gCustomParam0Texture;
layout(binding = 12) uniform sampler2D gEmissionTexture;
layout(binding = 14) uniform sampler2D IBL_Diffuse_Texture;
layout(binding = 16) uniform sampler2D IBL_Specular_Texture;
layout(binding = 18) uniform sampler2D IBL_GGXLUT_Texture;
layout(binding = 20) uniform sampler2D shadowmapTexture;
#else
layout(binding = 2) uniform texture2D gPositionTexture;
layout(binding = 3) uniform sampler gPositionTextureSampler;
layout(binding = 4) uniform texture2D gNormalTexture;
layout(binding = 5) uniform sampler gNormalTextureSampler;
layout(binding = 6) uniform texture2D gAlbedoTexture;
layout(binding = 7) uniform sampler gAlbedoTextureSampler;
layout(binding = 8) uniform texture2D gDepthTexture;
layout(binding = 9) uniform sampler gDepthTextureSampler;
layout(binding = 10) uniform texture2D gCustomParam0Texture;
layout(binding = 11) uniform sampler gCustomParam0TextureSampler;
layout(binding = 12) uniform texture2D gEmissionTexture;
layout(binding = 13) uniform sampler gEmissionTextureSampler;
layout(binding = 14) uniform texture2D IBL_Diffuse_Texture;
layout(binding = 15) uniform sampler IBL_Diffuse_TextureSampler;
layout(binding = 16) uniform texture2D IBL_Specular_Texture;
layout(binding = 17) uniform sampler IBL_Specular_TextureSampler;
layout(binding = 18) uniform texture2D IBL_GGXLUT_Texture;
layout(binding = 19) uniform sampler IBL_GGXLUT_TextureSampler;
layout(binding = 20) uniform texture2D shadowmapTexture;
layout(binding = 21) uniform sampler shadowmapTextureSampler;
#endif

struct GBufferResult
{
    vec3 worldPos;
    vec3 worldNormal;
    vec4 albedo;
    float depth;
    float materialType;
    vec2 metallicRoughness;
	vec3 emissive;
};

struct LightParam
{
    vec3 dir;
    vec3 color;
    float attenuation; // 減衰(intensityやradiusを使った計算結果)
	bool enabled;
};

vec3 GetWorldPos(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 WorldPos = texture(gPositionTexture, ScreenUV).rgb;
#else
    vec3 WorldPos = texture(sampler2D(gPositionTexture, gPositionTextureSampler), ScreenUV).rgb;
#endif

    return WorldPos;
}

vec3 GetWorldNormal(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec3 WorldNormal = texture(gNormalTexture, ScreenUV).rgb;
#else
    vec3 WorldNormal = texture(sampler2D(gNormalTexture, gNormalTextureSampler), ScreenUV).rgb;
#endif

    return WorldNormal;
}

vec4 GetAlbedo(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec4 Albedo = texture(gAlbedoTexture, ScreenUV);
#else
    vec4 Albedo = texture(sampler2D(gAlbedoTexture, gAlbedoTextureSampler), ScreenUV);
#endif

    return Albedo;
}

float GetDepth(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    float Depth = texture(gDepthTexture, ScreenUV).r;
#else
    float Depth = texture(sampler2D(gDepthTexture, gDepthTextureSampler), ScreenUV).r;
#endif

    return Depth;
}

vec4 GetCustomParam0(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec4 CustomParam0 = texture(gCustomParam0Texture, ScreenUV);
#else
    vec4 CustomParam0 = texture(sampler2D(gCustomParam0Texture, gCustomParam0TextureSampler), ScreenUV);
#endif

    return CustomParam0;
}

vec4 GetEmission(vec2 ScreenUV)
{
#ifdef USE_OPENGL
    vec4 Emission = texture(gEmissionTexture, ScreenUV);
#else
    vec4 Emission = texture(sampler2D(gEmissionTexture, gEmissionTextureSampler), ScreenUV);
#endif

    return Emission;
}

GBufferResult GetGBuffer(vec2 ScreenUV)
{
    GBufferResult gResult;

    gResult.worldPos = GetWorldPos(ScreenUV);
    gResult.worldNormal = GetWorldNormal(ScreenUV);
    gResult.albedo = GetAlbedo(ScreenUV);
    gResult.depth = GetDepth(ScreenUV);

    vec4 CustomParam0 = GetCustomParam0(ScreenUV);
    gResult.materialType = CustomParam0.r;
    gResult.metallicRoughness = CustomParam0.gb;

	gResult.emissive = GetEmission(ScreenUV).rgb;

    return gResult;
}

LightParam GetLightParam(GBufferResult gResult)
{
    LightParam light;

    if(l_ubo.type == 1.0)
    {
        // Directional Light
        light.dir = normalize(l_ubo.dir.xyz);
        light.color = l_ubo.color.rgb;
        light.attenuation = l_ubo.intensity;
		light.enabled = true;
    }
    else if(l_ubo.type == 2.0)
    {
        // Point Light
		vec3 l2v = gResult.worldPos.xyz - l_ubo.pos.xyz;
        light.dir = normalize(l2v);
        light.color = l_ubo.color.rgb;

		float len = length(l2v);

		// https://github.com/KhronosGroup/glTF/blob/main/extensions/2.0/Khronos/KHR_lights_punctual/README.md#range-property
        light.attenuation = l_ubo.intensity * max( min(1.0 - pow((len / l_ubo.radius), 4.0), 1.0), 0.0 ) / pow(len, 2.0);
        // light.attenuation = l_ubo.intensity * (1.0 - len / l_ubo.radius);

		// ライト球の範囲外なら描画しない
		light.enabled = (len <= l_ubo.radius); 
    }
	else if(l_ubo.type == 3.0)
	{
		// Spot Light
		vec3 baseDir = normalize(l_ubo.dir.xyz);
		vec3 l2g = gResult.worldPos.xyz - l_ubo.pos.xyz;
		vec3 l2g_norm = normalize(l2g);

		// スポットライトの範囲内であれば描画可能
		// 角度チェック
		float coneAngle = radians(l_ubo.angle);
		float l2g_angle = acos(dot(baseDir, l2g_norm));
		bool ValidAngle = (l2g_angle >= 0.0 && l2g_angle <= coneAngle);

		// 高さ(長さ)チェック
		// l2gをbaseDirに射影してその長さがHeight以下なら範囲内である
		float height = l_ubo.height;
		float prjlen = length(l2g) * cos(l2g_angle);
		bool ValidHeight = (prjlen >= 0 && prjlen < height);

		// 半径チェック
		// スポットライト底面の半径
		float sinFactor = sin(coneAngle) / sin(3.1415 * 0.5 - coneAngle);
		// float spotR = sinFactor * height;
		float spotR = sinFactor * prjlen;
		// l2gからその射影ベクトルに垂直なベクトルの長さ
		vec3 l2g_perp = l2g - (prjlen * baseDir);
		float l2gR = length(l2g_perp);
		// l2gRが半径内であれば描画(角度付きのコーンではなく、上端と下端を底面の半径にした円柱で描画判定)
		bool ValidRadius = (l2gR <= spotR);

		// 現在のl2g射影ベクトルの高さにおける半径
		// float cH_spotR = sinFactor * prjlen;

		// 減衰
		// float attenuation = max( min(1.0 - pow((l2gR / spotR), 4.0), 1.0), 0.0 ) / pow(l2gR, 2.0);
		// attenuation = clamp(attenuation, 0.0, 1.0);
		// float attenuation = smoothstep(1.0, 0.5, l2gR / spotR);
		// float attenuation = smoothstep(1.0, 0.0, l2gR / spotR);
		float attenuation = 1.0;

		//
		light.dir = l2g_norm;
        light.color = l_ubo.color.rgb;
        light.attenuation = l_ubo.intensity * attenuation * l_ubo.color.a;
		// light.enabled = (ValidAngle && ValidRadius && ValidHeight);
		light.enabled = (ValidAngle && ValidRadius);
	}

    return light;
}

// PBR ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const float MIN_ROUGHNESS = 0.04;
const float PI = 3.14159265;

struct PBRParam
{
	float NdotL;
	float NdotV;
	float NdotH;
	float LdotH;
	float VdotH;
	float perceptualRoughness;
	float metallic;
	vec3 reflectance0;
	vec3 reflectance90;
	float alphaRoughness;
	vec3 diffuseColor;
	vec3 specularColor;
};

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

float linstep(float min, float max, float v)
{
	return clamp((v - min) / (max - min), 0.0, 1.0);
}

float ReduceLightBleeding(float p_max, float Amount)
{
	return linstep(Amount, 1.0, p_max);
}

vec2 ComputePCF(vec2 uv)
{
	vec2 moments = vec2(0.0);

	vec2 texelSize = vec2(1.0 / l_ubo.ShadowMapX, 1.0 / l_ubo.ShadowMapY);

	/*for(float x = -1.0; x <= 1.0; x++)
	{
		for(float y = -1.0; y <= 1.0; y++)
		{
			#ifdef USE_OPENGL
			moments += texture(shadowmapTexture, uv + vec2(x, y) * texelSize).rg;
			#else
			moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(x, y) * texelSize).rg;
			#endif
		}
	}*/

	#ifdef USE_OPENGL
	moments += texture(shadowmapTexture, uv + vec2(-1.0, -1.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(-1.0, 0.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(-1.0, 1.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(0.0, -1.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(0.0, 0.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(0.0, 1.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(1.0, -1.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(1.0, 0.0) * texelSize).rg;
	moments += texture(shadowmapTexture, uv + vec2(1.0, 1.0) * texelSize).rg;
	#else
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(-1.0, -1.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(-1.0, 0.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(-1.0, 1.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(0.0, -1.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(0.0, 0.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(0.0, 1.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(1.0, -1.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(1.0, 0.0) * texelSize).rg;
	moments += texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv + vec2(1.0, 1.0) * texelSize).rg;
	#endif

	moments /= 9.0;

	#ifdef USE_OPENGL
	//moments = texture(shadowmapTexture, uv).rg;
	#else
	//moments = texture(sampler2D(shadowmapTexture, shadowmapTextureSampler), uv ).rg;
	#endif

	return moments;
}

float CalcShadow(vec3 lsp, vec3 nomral, vec3 lightDir)
{
	vec2 moments = ComputePCF(lsp.xy);

	#ifndef USE_OPENGL
	// Vulkan・WebGPUではDepthBufferの値が-1.0 ~ 1.0になっているので0.0 ~ 1.0に補正する
	moments = moments * 0.5 + 0.5;
	#endif

	// マッハバンド対策のShadow Bias
	// ShadowBiasとは深度のオフセットのこと
	// マッハバンドはShawMapの解像度により発生する。複数のフラグメントが光源から比較的離れている場合、深度マップから同じ値をサンプリングする可能性がある。
	// 光の入射角がオクルーダーの法線に対して斜めなとき、上記の理由から例えば少し深度が大きい隣の表面の深度をサンプリングしてしまい、結果ShadowMapの元の深度より大ききなってしまうことで縞々になる(大きいということは影になる, 黒色)
	// その対策でオクルーダーをほんの少しだけ手前にする。手前にすることでShadowmapよりも深度が小さくなるため影になりにくくなる
	// https://drive.google.com/file/d/1tyDT7xQVSYzKnZXt6vvDwt-rlWEjVGDP/view?usp=sharing
	// 床の法線とライト方向の成す角度が垂直になるほど、Biasを強くする
	// https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
	float ShadowBias = max(0.0, 0.001 * (1.0 - dot(nomral, lightDir)) );

	float distance = lsp.z - ShadowBias;

	// ShadowMapの深度よりも手前なので普通に描画する
	if(distance <= moments.x)
	{
		return 1.0;
	}
	
	return 0.1;

	/*// 後ろなので影にする
	// バリアンスの計算
	float variance = moments.y - (moments.x * moments.x);
	variance = max(0.005, variance);

	float d = distance - moments.x;
	float p_max = variance / (variance + d * d);

	// 本来影になるところに光がにじんでいるようなアーティファクトが出ることがあるのでその対策
	//p_max = ReduceLightBleeding(0.1, p_max);

	return p_max;*/
}

vec2 GetSphericalTexcoord(vec3 Dir)
{
	float pi = 3.1415;

	float theta = acos(Dir.y);
	float phi = atan(Dir.z, Dir.x);

	vec2 st = vec2(phi / (2.0 * pi), theta / pi);

	return st;
}

// マイクロファセット(微小面法線分布関数)(Microfacet Distribution). Distributionは分布に意味
// 分布関数なので統計学的に求められた数式
// マイクロファセットの面積を返す
// 面積が小さいほどマイクロファセットが散らばっていて荒いということかな？ → 大きいほど凸凹のない一つの平面に近づく
// https://learnopengl.com/PBR/Theory#:~:text=GGX%20for%20G.-,Normal%20distribution%20function,-The%20normal%20distribution
float CalcMicrofacet(PBRParam param)
{
	float roughness2 = param.alphaRoughness * param.alphaRoughness; // グラフの勾配を高くする
	
	//
	float f = (param.NdotH * roughness2 - param.NdotH) * param.NdotH + 1.0;
	// = ( param.NdotH * (roughness2 - 1.0) ) * param.NdotH + 1.0
	// = pow(param.NdotH, 2.0) * (roughness2 - 1.0) + 1.0
	// 数式と同じ形になる. (n・h)^2 * (a^2 - 1) + 1
	
	//
	return roughness2 / (PI * f * f);
}

// 幾何減衰項(Geometric Occlusion)
// マイクロファセットの微小平面が光の経路を遮断することにより失われてしまう光の減衰量を計算する関数
float CalcGeometricOcculusion(PBRParam param)
{
	float NdotL = param.NdotL;
	float NdotV = param.NdotV;
	// 表面が荒いほど、微小平面が増えて光が隠蔽されやすくなる
	float r = param.alphaRoughness;

	// 詳しい数式(https://google.github.io/filament/Filament.md.html#materialsystem/specularbrdf/geometricshadowing(specularg))
	// シャドウイングの項を計算(入射光が他の微小平面に遮られて影になり光が減衰する分)
	float attenuationL = 2.0 * NdotL / ( NdotL + sqrt(r * r + (1.0 - r * r) * (NdotL * NdotL)) );
	// = 2.0 * NdotL / ( NdotL * () )
	// マスキングの項を計算(反射光が他の微小平面に遮られてその光が目に届かないことで減衰する分)
	float attenuationV = 2.0 * NdotV / ( NdotV + sqrt(r * r + (1.0 - r * r) * (NdotV * NdotV)) );

	// 幾何減衰項は上記の乗算結果
	return attenuationL * attenuationV;
}

// フレネル反射(フレネル項). 
// フレネル反射とはView方向に応じて反射率が変化する物理現象のことである 
// ここでのGGX項でのフレネル反射はオブジェクトの端であるほど反射率が高い(反射色が明るい)ことを示している
// https://marmoset.co/posts/basic-theory-of-physically-based-rendering/
// この画像がわかりやすい --> https://marmoset.co/wp-content/uploads/2016/11/pbr_theory_fresnel.png
// GGXのフレネル項の式は、よく光学の分野で見聞きするようなフレネルの式の近似式である(https://ja.wikipedia.org/wiki/%E3%83%95%E3%83%AC%E3%83%8D%E3%83%AB%E3%81%AE%E5%BC%8F)
// https://learnopengl.com/PBR/Theory#:~:text=return%20ggx1%20*%20ggx2%3B%0A%7D-,Fresnel%20equation,-The%20Fresnel%20equation
vec3 CalcFrenelReflection(PBRParam param)
{
	// 基本の反射率: reflectance0
	// それに対して視野方向による反射率の変化分を加算している
	// 割と数式だとreflectance90は1.0なので今はあんまり深く考えなくてもいいかも？
	// もしかしてreflectance90は媒質の屈折率に関係している？真空だと1.0なので、他の数式とかだとひとます真空と仮定している？
	return param.reflectance0 + (param.reflectance90 - param.reflectance0) * pow(clamp(1.0 - param.VdotH, 0.0, 1.0), 5.0);
}

// ディフューズのBRDFを計算
// https://google.github.io/filament/Filament.md.html#materialsystem/diffusebrdf
// この記事によると拡散色のBRDFは近似的に『1.0 / PI』と定まるとのこと
vec3 CalcDiffuseBRDF(PBRParam param)
{
	float oneminus = (1.0 - 0.04) - param.metallic * (1.0 - 0.04);

	return param.diffuseColor * oneminus;
	// return param.diffuseColor / PI;
}

// IBL
vec3 ComputeIBL(PBRParam pbrParam, vec3 v, vec3 n) 
{
	float mipCount = l_ubo.mipCount;
	float lod = mipCount * pbrParam.perceptualRoughness;

	#ifdef USE_OPENGL
	vec3 brdf = SRGBtoLINEAR(texture(IBL_GGXLUT_Texture, vec2(pbrParam.NdotV, 1.0 - pbrParam.perceptualRoughness))).rgb;
	vec3 diffuseLight = SRGBtoLINEAR(texture(IBL_Diffuse_Texture, GetSphericalTexcoord(n))).rgb;
	vec3 specularLight = SRGBtoLINEAR(textureLod(IBL_Specular_Texture, GetSphericalTexcoord(reflect(v, n)), lod)).rgb;
	#else
	vec3 brdf = SRGBtoLINEAR(texture(sampler2D(IBL_GGXLUT_Texture, IBL_GGXLUT_TextureSampler), vec2(pbrParam.NdotV, 1.0 - pbrParam.perceptualRoughness))).rgb;
	vec3 diffuseLight = SRGBtoLINEAR(texture(sampler2D(IBL_Diffuse_Texture, IBL_Diffuse_TextureSampler), GetSphericalTexcoord(n))).rgb;
	vec3 specularLight = SRGBtoLINEAR(textureLod(sampler2D(IBL_Specular_Texture, IBL_Specular_TextureSampler), GetSphericalTexcoord(reflect(v, n)), lod)).rgb;
	#endif

	// 
	vec3 diffuse = diffuseLight * pbrParam.diffuseColor;
	vec3 specular = specularLight * (pbrParam.specularColor * brdf.x + brdf.y);

	return specular;
}

vec3 ComputeLight(GBufferResult gResult, LightParam light)
{
    vec3 col = vec3(0.0);

    // ラフネスとメタリックを取得。テクスチャにパッキングされていることもある
	float perceptualRoughness = gResult.metallicRoughness.g;
	float metallic = gResult.metallicRoughness.r;
	perceptualRoughness = clamp(perceptualRoughness, MIN_ROUGHNESS, 1.0);
	metallic  = clamp(metallic, 0.0, 1.0);

	// 実際に計算に使用するラフネスかな
	float alphaRoughness = perceptualRoughness * perceptualRoughness;

	// ベースカラーの取得. ベースカラーは単純な表面色
	vec4 baseColor = gResult.albedo;
	
	// 
	vec3 f0 = vec3(0.04);
	// diffuseColor. 訳すと拡散色. ライトで照らされたときにその物体が反射する色. 光学的には反射して目に入る色
    // 物体に衝突すると内部で乱反射してランダムないろんな方向に出ていく光。なのでどこから見ても同じような色が見える
	// https://help.autodesk.com/view/3DSMAX/2023/ENU/?guid=GUID-3CEBFC6A-7A8F-4E78-9CF2-F78BA9CFCDC3
	// たぶんこの0.04という数値は経験から得られた値で物理学者がいい感じにチューニングして得た綺麗な描画結果を出すのにちょうどいい値ということだと思う
	// → さらに調べてみるとこの0.04は入射反射率4%という意味らし。たぶんどんな物体でも最低でも4%は光を吸収するということかな
	vec3 diffuseColor = baseColor.rgb * (vec3(1.0) - f0); // 0.04だけ減衰させる. たぶん光エネルギーが色以外のとこで減衰した分を考慮している(?)
	//diffuseColor *= (1.0 - metallic); // metallicが1.0ならdiffuseColorは0になる。完全な金属の表面色は周りの映り込み色だけになることを表している
	// specularColor. 意味は鏡面色. サーフェイス上のハイライトの色らしい.
    // 鏡面反射(面の法線で対称に反射)による光。見え方が場所に依存する
	// https://help.autodesk.com/view/3DSMAX/2023/ENU/?guid=GUID-90065A74-C223-474C-8D85-7596D70E5004
	// 金属であるほどハイライト色がベースカラーに近づく.
	// とはいえ確かに金属はきらっとしてて逆にマットなオブジェクトは全く光ってないようなイメージがある
	// metallic : 0.0(マット) <--> 1.0(金属) って意味だと思う
	vec3 specularColor = mix(f0, baseColor.rgb, metallic); // specularColor

	// 反射率(reflectance)の計算
	// ハイライトカラーはRGBが一番大きいやつの色になるので、どれくらい反射するかもその値(色)を基準にするはずである
	float reflectance = max(max(specularColor.r, specularColor.g), specularColor.b);

	// フレネル項で必要なパラメーター
	// reflectanceに対して0.04(4%) * 25.0 = 1.0(100%)といった計算を行い、0.04(4%)以上は強制的に1.0(100%)に、それより下の値で0.0 ~ 1.0の分布を作っている。つまりグラフを急勾配にしている
	float reflectance90 = clamp(reflectance * 25.0, 0.0, 1.0);
	vec3 specularEnvironmentR0 = specularColor.rgb; // 通常の反射率
	vec3 specularEnvironmentR90 = vec3(1.0, 1.0, 1.0) * reflectance90; // 急勾配ば反射率

	// PBRに使うベクトル系のパラメーターを計算する
	vec3 n = gResult.worldNormal;
	vec3 v = (-1.0f) * normalize(gResult.worldPos.xyz - l_ubo.cameraPos.xyz);
	
	// 計算に使用するのでライト方向は反転させておく
	// 図を書くとわかるがそのままのベクトルを使うと180度回転した分の結果になってしまう
	// 法線方向を基準に考える
	vec3 l = (-1.0f) * light.dir;
	
	// ハーフベクトルはvとlの中間に位置するベクトルのこと
	// 光源の方向ベクトルはCGの慣例として光源方向に向けた方がいいのかも？
	// https://qiita.com/emadurandal/items/76348ad118c36317ec5c#:~:text=%E3%81%97%E3%81%A6%E3%81%84%E3%81%BE%E3%81%99%E3%80%82-,h,%E3%81%AF%E3%83%8F%E3%83%BC%E3%83%95%E3%83%99%E3%82%AF%E3%83%88%E3%83%AB%E3%81%A8%E3%81%84%E3%81%84,-%E3%80%81%E3%83%A9%E3%82%A4%E3%83%88%E3%83%99%E3%82%AF%E3%83%88%E3%83%AB%E3%81%A8
	vec3 h = normalize(v + l);
	vec3 reflection = normalize(reflect(v, n));

	// 考え方としては内積は二つのベクトルの角度がどれだけ水平・垂直に近いかを示す値としてみることができる
	float NdotL = clamp(dot(n, l), 0.0, 1.0);
	float NdotV = clamp(abs(dot(n, v)), 0.0, 1.0);
	float NdotH = clamp(dot(n, h), 0.0, 1.0);
	float LdotH = clamp(dot(l, h), 0.0, 1.0);
	float VdotH = clamp(dot(v, h), 0.0, 1.0);

	//
	PBRParam pbrParam = PBRParam(
		NdotL,
		NdotV,
		NdotH,
		LdotH,
		VdotH,
		perceptualRoughness,
		metallic,
		specularEnvironmentR0,
		specularEnvironmentR90,
		alphaRoughness,
		diffuseColor,
		specularColor
	);

	//
	vec3 specular = vec3(0.0);
	vec3 diffuse = vec3(0.0);

	// クックトランスモデルによるスペキュラーのGGXを計算する
	float D = CalcMicrofacet(pbrParam); // マイクロファセット(微小面法線分布関数)
	float G = CalcGeometricOcculusion(pbrParam); // 幾何減衰項
	vec3 F = CalcFrenelReflection(pbrParam); // フレネル項

	if(NdotL > 0.0 || NdotV > 0.0)
	{
		// スペキュラーBRDFを構築
		// スペキュラーは鏡面反射: 鏡面反射とは入射角と出射角が等しい反射
		// https://ja.wikipedia.org/wiki/%E9%8F%A1%E9%9D%A2%E5%8F%8D%E5%B0%84
		specular += D * G * F / (4.0 * NdotL * NdotV);

		specular = max(specular, vec3(0.0));

		// ディフューズBRDFを計算
		// Diffuseは拡散反射 : 拡散反射とは鏡面反射に比べて反射角に依存せず、多様な方向に同程度の光度を放つ反射のこと
		// https://ja.wikipedia.org/wiki/%E6%8B%A1%E6%95%A3%E5%8F%8D%E5%B0%84
		diffuse += (1.0 - F) * CalcDiffuseBRDF(pbrParam);

		// レンダリング方程式を構築
		col.rgb = NdotL * (specular + diffuse) * light.color;
	}

    col *= light.attenuation;

	if(l_ubo.type == 1.0 && l_ubo.useIBL != 0)
	{
		// IBL
		col.rgb += ComputeIBL(pbrParam, v, n);
	}

	// カラースペースをリニアにする
	col = pow(col, vec3(1.0/2.2));

	// Shadow
	// LightSpaceScreenPos
	if(l_ubo.useShadowMap != 0)
	{
		// https://qiita.com/Haru86_/items/d563ce1f65cf55e547a3
		// 正規化デバイス座標(NDC)に変換する
		vec4 lSpaceProjPos = l_ubo.lightVPMat * vec4(gResult.worldPos.xyz, 1.0);
		vec3 lsp = lSpaceProjPos.xyz / lSpaceProjPos.w;
		// スクリーンUVとデプスを取り出す
		lsp = lsp * 0.5 + 0.5;
		
		float shadowCol = 1.0;

		bool outSide = (lsp.x < 0.0 || lsp.y < 0.0 || lsp.z < 0.0) || (lsp.x > 1.0 || lsp.y > 1.0 || lsp.z > 1.0);

		if(!outSide)
		{
			shadowCol = CalcShadow(lsp, n, l);
		}

		col.rgb *= shadowCol;
	}

	col.rgb += gResult.emissive;

    return col;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void main()
{
    vec2 ScreenUV = v2f_ProjPos.xy / v2f_ProjPos.w;
    ScreenUV = ScreenUV * 0.5 + 0.5;

    // Get Param
    GBufferResult gResult = GetGBuffer(ScreenUV);
    LightParam light = GetLightParam(gResult);
	
	// スポットライトでかつForceLightingがtrueならベースカラーを白にする
	// これが黒になっているといくらライティングしても黒のままなのでライトの影響を受けない
	if(l_ubo.ForceLighting == 1 && l_ubo.type == 3.0)
	{
		gResult.albedo = vec4(1.0);
	}

    // Compute Color
    vec3 col = vec3(0.0);
    if(gResult.materialType == 1.0 && light.enabled)
    {
        // PBR
        col = ComputeLight(gResult, light);
    }
    else
    {
        // 何も描画しない
        // ライトは加算描画なので黒でいい
        col = vec3(0.0, 0.0, 0.0);
    }

    outColor = vec4(col, 1.0);
}