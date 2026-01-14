struct GBufferResult {
    worldPos: vec3<f32>,
    worldNormal: vec3<f32>,
    albedo: vec4<f32>,
    depth: f32,
    materialType: f32,
    metallicRoughness: vec2<f32>,
    emissive: vec3<f32>,
}

struct LightParam {
    dir: vec3<f32>,
    color: vec3<f32>,
    attenuation: f32,
    enabled: bool,
}

struct PBRParam {
    NdotL: f32,
    NdotV: f32,
    NdotH: f32,
    LdotH: f32,
    VdotH: f32,
    perceptualRoughness: f32,
    metallic: f32,
    reflectance0_: vec3<f32>,
    reflectance90_: vec3<f32>,
    alphaRoughness: f32,
    diffuseColor: vec3<f32>,
    specularColor: vec3<f32>,
}

struct LightUniformBuffer {
    lightVPMat: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    type_: f32,
    radius: f32,
    intensity: f32,
    angle: f32,
    height: f32,
    mipCount: f32,
    ShadowMapX: f32,
    ShadowMapY: f32,
    useIBL: i32,
    useShadowMap: i32,
    ForceLighting: i32,
    iPad2_: i32,
    dir: vec4<f32>,
    pos: vec4<f32>,
    color: vec4<f32>,
    cameraPos: vec4<f32>,
}

@group(0) @binding(2) 
var gPositionTexture: texture_2d<f32>;
@group(0) @binding(3) 
var gPositionTextureSampler: sampler;
@group(0) @binding(4) 
var gNormalTexture: texture_2d<f32>;
@group(0) @binding(5) 
var gNormalTextureSampler: sampler;
@group(0) @binding(6) 
var gAlbedoTexture: texture_2d<f32>;
@group(0) @binding(7) 
var gAlbedoTextureSampler: sampler;
@group(0) @binding(8) 
var gDepthTexture: texture_2d<f32>;
@group(0) @binding(9) 
var gDepthTextureSampler: sampler;
@group(0) @binding(10) 
var gCustomParam0Texture: texture_2d<f32>;
@group(0) @binding(11) 
var gCustomParam0TextureSampler: sampler;
@group(0) @binding(12) 
var gEmissionTexture: texture_2d<f32>;
@group(0) @binding(13) 
var gEmissionTextureSampler: sampler;
@group(0) @binding(1) 
var<uniform> l_ubo: LightUniformBuffer;
@group(0) @binding(20) 
var shadowmapTexture: texture_2d<f32>;
@group(0) @binding(21) 
var shadowmapTextureSampler: sampler;
@group(0) @binding(18) 
var IBL_GGXLUT_Texture: texture_2d<f32>;
@group(0) @binding(19) 
var IBL_GGXLUT_TextureSampler: sampler;
@group(0) @binding(14) 
var IBL_Diffuse_Texture: texture_2d<f32>;
@group(0) @binding(15) 
var IBL_Diffuse_TextureSampler: sampler;
@group(0) @binding(16) 
var IBL_Specular_Texture: texture_2d<f32>;
@group(0) @binding(17) 
var IBL_Specular_TextureSampler: sampler;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_UV_1: vec2<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn ComputePCF_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> vec2<f32> {
    var moments: vec2<f32>;
    var texelSize: vec2<f32>;

    moments = vec2<f32>(0f, 0f);
    let _e87 = l_ubo.ShadowMapX;
    let _e90 = l_ubo.ShadowMapY;
    texelSize = vec2<f32>((1f / _e87), (1f / _e90));
    let _e93 = (*uv);
    let _e94 = texelSize;
    let _e97 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e93 + (vec2<f32>(-1f, -1f) * _e94)));
    let _e99 = moments;
    moments = (_e99 + _e97.xy);
    let _e101 = (*uv);
    let _e102 = texelSize;
    let _e105 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e101 + (vec2<f32>(-1f, 0f) * _e102)));
    let _e107 = moments;
    moments = (_e107 + _e105.xy);
    let _e109 = (*uv);
    let _e110 = texelSize;
    let _e113 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e109 + (vec2<f32>(-1f, 1f) * _e110)));
    let _e115 = moments;
    moments = (_e115 + _e113.xy);
    let _e117 = (*uv);
    let _e118 = texelSize;
    let _e121 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e117 + (vec2<f32>(0f, -1f) * _e118)));
    let _e123 = moments;
    moments = (_e123 + _e121.xy);
    let _e125 = (*uv);
    let _e126 = texelSize;
    let _e129 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e125 + (vec2<f32>(0f, 0f) * _e126)));
    let _e131 = moments;
    moments = (_e131 + _e129.xy);
    let _e133 = (*uv);
    let _e134 = texelSize;
    let _e137 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e133 + (vec2<f32>(0f, 1f) * _e134)));
    let _e139 = moments;
    moments = (_e139 + _e137.xy);
    let _e141 = (*uv);
    let _e142 = texelSize;
    let _e145 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e141 + (vec2<f32>(1f, -1f) * _e142)));
    let _e147 = moments;
    moments = (_e147 + _e145.xy);
    let _e149 = (*uv);
    let _e150 = texelSize;
    let _e153 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e149 + (vec2<f32>(1f, 0f) * _e150)));
    let _e155 = moments;
    moments = (_e155 + _e153.xy);
    let _e157 = (*uv);
    let _e158 = texelSize;
    let _e161 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e157 + (vec2<f32>(1f, 1f) * _e158)));
    let _e163 = moments;
    moments = (_e163 + _e161.xy);
    let _e165 = moments;
    moments = (_e165 / vec2(9f));
    let _e168 = moments;
    return _e168;
}

fn CalcShadow_u0028_vf3_u003b_vf3_u003b_vf3_u003b(lsp: ptr<function, vec3<f32>>, nomral: ptr<function, vec3<f32>>, lightDir: ptr<function, vec3<f32>>) -> f32 {
    var moments_1: vec2<f32>;
    var param: vec2<f32>;
    var ShadowBias: f32;
    var distance: f32;

    let _e90 = (*lsp);
    param = _e90.xy;
    let _e92 = ComputePCF_u0028_vf2_u003b((&param));
    moments_1 = _e92;
    let _e93 = moments_1;
    moments_1 = ((_e93 * 0.5f) + vec2(0.5f));
    let _e97 = (*nomral);
    let _e98 = (*lightDir);
    ShadowBias = max(0f, (0.001f * (1f - dot(_e97, _e98))));
    let _e104 = (*lsp)[2u];
    let _e105 = ShadowBias;
    distance = (_e104 - _e105);
    let _e107 = distance;
    let _e109 = moments_1[0u];
    if (_e107 <= _e109) {
        return 1f;
    }
    return 0.1f;
}

fn GetSphericalTexcoord_u0028_vf3_u003b(Dir: ptr<function, vec3<f32>>) -> vec2<f32> {
    var pi: f32;
    var theta: f32;
    var phi: f32;
    var st: vec2<f32>;

    pi = 3.1415f;
    let _e89 = (*Dir)[1u];
    theta = acos(_e89);
    let _e92 = (*Dir)[2u];
    let _e94 = (*Dir)[0u];
    phi = atan2(_e92, _e94);
    let _e96 = phi;
    let _e97 = pi;
    let _e100 = theta;
    let _e101 = pi;
    st = vec2<f32>((_e96 / (2f * _e97)), (_e100 / _e101));
    let _e104 = st;
    return _e104;
}

fn SRGBtoLINEAR_u0028_vf4_u003b(srgbIn: ptr<function, vec4<f32>>) -> vec4<f32> {
    let _e84 = (*srgbIn);
    let _e86 = pow(_e84.xyz, vec3<f32>(2.2f, 2.2f, 2.2f));
    let _e88 = (*srgbIn)[3u];
    return vec4<f32>(_e86.x, _e86.y, _e86.z, _e88);
}

fn ComputeIBL_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b_vf3_u003b_vf3_u003b(pbrParam: ptr<function, PBRParam>, v: ptr<function, vec3<f32>>, n: ptr<function, vec3<f32>>) -> vec3<f32> {
    var mipCount: f32;
    var lod: f32;
    var brdf: vec3<f32>;
    var param_1: vec4<f32>;
    var diffuseLight: vec3<f32>;
    var param_2: vec3<f32>;
    var param_3: vec4<f32>;
    var specularLight: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec4<f32>;
    var diffuse: vec3<f32>;
    var specular: vec3<f32>;

    let _e99 = l_ubo.mipCount;
    mipCount = _e99;
    let _e100 = mipCount;
    let _e102 = (*pbrParam).perceptualRoughness;
    lod = (_e100 * _e102);
    let _e105 = (*pbrParam).NdotV;
    let _e107 = (*pbrParam).perceptualRoughness;
    let _e110 = textureSample(IBL_GGXLUT_Texture, IBL_GGXLUT_TextureSampler, vec2<f32>(_e105, (1f - _e107)));
    param_1 = _e110;
    let _e111 = SRGBtoLINEAR_u0028_vf4_u003b((&param_1));
    brdf = _e111.xyz;
    let _e113 = (*n);
    param_2 = _e113;
    let _e114 = GetSphericalTexcoord_u0028_vf3_u003b((&param_2));
    let _e115 = textureSample(IBL_Diffuse_Texture, IBL_Diffuse_TextureSampler, _e114);
    param_3 = _e115;
    let _e116 = SRGBtoLINEAR_u0028_vf4_u003b((&param_3));
    diffuseLight = _e116.xyz;
    let _e118 = (*v);
    let _e119 = (*n);
    param_4 = reflect(_e118, _e119);
    let _e121 = GetSphericalTexcoord_u0028_vf3_u003b((&param_4));
    let _e122 = lod;
    let _e123 = textureSampleLevel(IBL_Specular_Texture, IBL_Specular_TextureSampler, _e121, _e122);
    param_5 = _e123;
    let _e124 = SRGBtoLINEAR_u0028_vf4_u003b((&param_5));
    specularLight = _e124.xyz;
    let _e126 = diffuseLight;
    let _e128 = (*pbrParam).diffuseColor;
    diffuse = (_e126 * _e128);
    let _e130 = specularLight;
    let _e132 = (*pbrParam).specularColor;
    let _e134 = brdf[0u];
    let _e137 = brdf[1u];
    specular = (_e130 * ((_e132 * _e134) + vec3(_e137)));
    let _e141 = specular;
    return _e141;
}

fn CalcDiffuseBRDF_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_6: ptr<function, PBRParam>) -> vec3<f32> {
    var oneminus: f32;

    let _e86 = (*param_6).metallic;
    oneminus = (0.96f - (_e86 * 0.96f));
    let _e90 = (*param_6).diffuseColor;
    let _e91 = oneminus;
    return (_e90 * _e91);
}

fn CalcFrenelReflection_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_7: ptr<function, PBRParam>) -> vec3<f32> {
    let _e85 = (*param_7).reflectance0_;
    let _e87 = (*param_7).reflectance90_;
    let _e89 = (*param_7).reflectance0_;
    let _e92 = (*param_7).VdotH;
    return (_e85 + ((_e87 - _e89) * pow(clamp((1f - _e92), 0f, 1f), 5f)));
}

fn CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_8: ptr<function, PBRParam>) -> f32 {
    var NdotL: f32;
    var NdotV: f32;
    var r: f32;
    var attenuationL: f32;
    var attenuationV: f32;

    let _e90 = (*param_8).NdotL;
    NdotL = _e90;
    let _e92 = (*param_8).NdotV;
    NdotV = _e92;
    let _e94 = (*param_8).alphaRoughness;
    r = _e94;
    let _e95 = NdotL;
    let _e97 = NdotL;
    let _e98 = r;
    let _e99 = r;
    let _e101 = r;
    let _e102 = r;
    let _e105 = NdotL;
    let _e106 = NdotL;
    attenuationL = ((2f * _e95) / (_e97 + sqrt(((_e98 * _e99) + ((1f - (_e101 * _e102)) * (_e105 * _e106))))));
    let _e113 = NdotV;
    let _e115 = NdotV;
    let _e116 = r;
    let _e117 = r;
    let _e119 = r;
    let _e120 = r;
    let _e123 = NdotV;
    let _e124 = NdotV;
    attenuationV = ((2f * _e113) / (_e115 + sqrt(((_e116 * _e117) + ((1f - (_e119 * _e120)) * (_e123 * _e124))))));
    let _e131 = attenuationL;
    let _e132 = attenuationV;
    return (_e131 * _e132);
}

fn CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_9: ptr<function, PBRParam>) -> f32 {
    var roughness2_: f32;
    var f: f32;

    let _e87 = (*param_9).alphaRoughness;
    let _e89 = (*param_9).alphaRoughness;
    roughness2_ = (_e87 * _e89);
    let _e92 = (*param_9).NdotH;
    let _e93 = roughness2_;
    let _e96 = (*param_9).NdotH;
    let _e99 = (*param_9).NdotH;
    f = ((((_e92 * _e93) - _e96) * _e99) + 1f);
    let _e102 = roughness2_;
    let _e103 = f;
    let _e105 = f;
    return (_e102 / ((3.1415927f * _e103) * _e105));
}

fn ComputeLight_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_struct_u002d_LightParam_u002d_vf3_u002d_vf3_u002d_f1_u002d_b11_u003b(gResult: ptr<function, GBufferResult>, light: ptr<function, LightParam>) -> vec3<f32> {
    var col: vec3<f32>;
    var perceptualRoughness: f32;
    var metallic: f32;
    var alphaRoughness: f32;
    var baseColor: vec4<f32>;
    var f0_: vec3<f32>;
    var diffuseColor: vec3<f32>;
    var specularColor: vec3<f32>;
    var reflectance: f32;
    var reflectance90_: f32;
    var specularEnvironmentR0_: vec3<f32>;
    var specularEnvironmentR90_: vec3<f32>;
    var n_1: vec3<f32>;
    var v_1: vec3<f32>;
    var l: vec3<f32>;
    var h: vec3<f32>;
    var reflection: vec3<f32>;
    var NdotL_1: f32;
    var NdotV_1: f32;
    var NdotH: f32;
    var LdotH: f32;
    var VdotH: f32;
    var pbrParam_1: PBRParam;
    var specular_1: vec3<f32>;
    var diffuse_1: vec3<f32>;
    var D: f32;
    var param_10: PBRParam;
    var G: f32;
    var param_11: PBRParam;
    var F: vec3<f32>;
    var param_12: PBRParam;
    var param_13: PBRParam;
    var param_14: PBRParam;
    var param_15: vec3<f32>;
    var param_16: vec3<f32>;
    var lSpaceProjPos: vec4<f32>;
    var lsp_1: vec3<f32>;
    var shadowCol: f32;
    var outSide: bool;
    var param_17: vec3<f32>;
    var param_18: vec3<f32>;
    var param_19: vec3<f32>;
    var phi_965_: bool;
    var phi_1020_: bool;
    var phi_1027_: bool;
    var phi_1040_: bool;
    var phi_1047_: bool;
    var phi_1048_: bool;

    col = vec3<f32>(0f, 0f, 0f);
    let _e129 = (*gResult).metallicRoughness[1u];
    perceptualRoughness = _e129;
    let _e132 = (*gResult).metallicRoughness[0u];
    metallic = _e132;
    let _e133 = perceptualRoughness;
    perceptualRoughness = clamp(_e133, 0.04f, 1f);
    let _e135 = metallic;
    metallic = clamp(_e135, 0f, 1f);
    let _e137 = perceptualRoughness;
    let _e138 = perceptualRoughness;
    alphaRoughness = (_e137 * _e138);
    let _e141 = (*gResult).albedo;
    baseColor = _e141;
    f0_ = vec3<f32>(0.04f, 0.04f, 0.04f);
    let _e142 = baseColor;
    let _e144 = f0_;
    diffuseColor = (_e142.xyz * (vec3<f32>(1f, 1f, 1f) - _e144));
    let _e147 = f0_;
    let _e148 = baseColor;
    let _e150 = metallic;
    specularColor = mix(_e147, _e148.xyz, vec3(_e150));
    let _e154 = specularColor[0u];
    let _e156 = specularColor[1u];
    let _e159 = specularColor[2u];
    reflectance = max(max(_e154, _e156), _e159);
    let _e161 = reflectance;
    reflectance90_ = clamp((_e161 * 25f), 0f, 1f);
    let _e164 = specularColor;
    specularEnvironmentR0_ = _e164;
    let _e165 = reflectance90_;
    specularEnvironmentR90_ = (vec3<f32>(1f, 1f, 1f) * _e165);
    let _e168 = (*gResult).worldNormal;
    n_1 = _e168;
    let _e170 = (*gResult).worldPos;
    let _e172 = l_ubo.cameraPos;
    v_1 = (normalize((_e170 - _e172.xyz)) * -1f);
    let _e178 = (*light).dir;
    l = (_e178 * -1f);
    let _e180 = v_1;
    let _e181 = l;
    h = normalize((_e180 + _e181));
    let _e184 = v_1;
    let _e185 = n_1;
    reflection = normalize(reflect(_e184, _e185));
    let _e188 = n_1;
    let _e189 = l;
    NdotL_1 = clamp(dot(_e188, _e189), 0f, 1f);
    let _e192 = n_1;
    let _e193 = v_1;
    NdotV_1 = clamp(abs(dot(_e192, _e193)), 0f, 1f);
    let _e197 = n_1;
    let _e198 = h;
    NdotH = clamp(dot(_e197, _e198), 0f, 1f);
    let _e201 = l;
    let _e202 = h;
    LdotH = clamp(dot(_e201, _e202), 0f, 1f);
    let _e205 = v_1;
    let _e206 = h;
    VdotH = clamp(dot(_e205, _e206), 0f, 1f);
    let _e209 = NdotL_1;
    let _e210 = NdotV_1;
    let _e211 = NdotH;
    let _e212 = LdotH;
    let _e213 = VdotH;
    let _e214 = perceptualRoughness;
    let _e215 = metallic;
    let _e216 = specularEnvironmentR0_;
    let _e217 = specularEnvironmentR90_;
    let _e218 = alphaRoughness;
    let _e219 = diffuseColor;
    let _e220 = specularColor;
    pbrParam_1 = PBRParam(_e209, _e210, _e211, _e212, _e213, _e214, _e215, _e216, _e217, _e218, _e219, _e220);
    specular_1 = vec3<f32>(0f, 0f, 0f);
    diffuse_1 = vec3<f32>(0f, 0f, 0f);
    let _e222 = pbrParam_1;
    param_10 = _e222;
    let _e223 = CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_10));
    D = _e223;
    let _e224 = pbrParam_1;
    param_11 = _e224;
    let _e225 = CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_11));
    G = _e225;
    let _e226 = pbrParam_1;
    param_12 = _e226;
    let _e227 = CalcFrenelReflection_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_12));
    F = _e227;
    let _e228 = NdotL_1;
    let _e230 = NdotV_1;
    if ((_e228 > 0f) || (_e230 > 0f)) {
        let _e233 = D;
        let _e234 = G;
        let _e236 = F;
        let _e238 = NdotL_1;
        let _e240 = NdotV_1;
        let _e244 = specular_1;
        specular_1 = (_e244 + ((_e236 * (_e233 * _e234)) / vec3(((4f * _e238) * _e240))));
        let _e246 = specular_1;
        specular_1 = max(_e246, vec3<f32>(0f, 0f, 0f));
        let _e248 = F;
        let _e251 = pbrParam_1;
        param_13 = _e251;
        let _e252 = CalcDiffuseBRDF_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_13));
        let _e254 = diffuse_1;
        diffuse_1 = (_e254 + ((vec3(1f) - _e248) * _e252));
        let _e256 = NdotL_1;
        let _e257 = specular_1;
        let _e258 = diffuse_1;
        let _e262 = (*light).color;
        col = (((_e257 + _e258) * _e256) * _e262);
    }
    let _e265 = (*light).attenuation;
    let _e266 = col;
    col = (_e266 * _e265);
    let _e269 = l_ubo.type_;
    let _e270 = (_e269 == 1f);
    phi_965_ = _e270;
    if _e270 {
        let _e272 = l_ubo.useIBL;
        phi_965_ = (_e272 != 0i);
    }
    let _e275 = phi_965_;
    if _e275 {
        let _e276 = pbrParam_1;
        param_14 = _e276;
        let _e277 = v_1;
        param_15 = _e277;
        let _e278 = n_1;
        param_16 = _e278;
        let _e279 = ComputeIBL_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b_vf3_u003b_vf3_u003b((&param_14), (&param_15), (&param_16));
        let _e280 = col;
        col = (_e280 + _e279);
    }
    let _e282 = col;
    col = pow(_e282, vec3<f32>(0.45454547f, 0.45454547f, 0.45454547f));
    let _e285 = l_ubo.useShadowMap;
    if (_e285 != 0i) {
        let _e288 = l_ubo.lightVPMat;
        let _e290 = (*gResult).worldPos;
        lSpaceProjPos = (_e288 * vec4<f32>(_e290.x, _e290.y, _e290.z, 1f));
        let _e296 = lSpaceProjPos;
        let _e299 = lSpaceProjPos[3u];
        lsp_1 = (_e296.xyz / vec3(_e299));
        let _e302 = lsp_1;
        lsp_1 = ((_e302 * 0.5f) + vec3(0.5f));
        shadowCol = 1f;
        let _e307 = lsp_1[0u];
        let _e308 = (_e307 < 0f);
        phi_1020_ = _e308;
        if !(_e308) {
            let _e311 = lsp_1[1u];
            phi_1020_ = (_e311 < 0f);
        }
        let _e314 = phi_1020_;
        phi_1027_ = _e314;
        if !(_e314) {
            let _e317 = lsp_1[2u];
            phi_1027_ = (_e317 < 0f);
        }
        let _e320 = phi_1027_;
        phi_1048_ = _e320;
        if !(_e320) {
            let _e323 = lsp_1[0u];
            let _e324 = (_e323 > 1f);
            phi_1040_ = _e324;
            if !(_e324) {
                let _e327 = lsp_1[1u];
                phi_1040_ = (_e327 > 1f);
            }
            let _e330 = phi_1040_;
            phi_1047_ = _e330;
            if !(_e330) {
                let _e333 = lsp_1[2u];
                phi_1047_ = (_e333 > 1f);
            }
            let _e336 = phi_1047_;
            phi_1048_ = _e336;
        }
        let _e338 = phi_1048_;
        outSide = _e338;
        let _e339 = outSide;
        if !(_e339) {
            let _e341 = lsp_1;
            param_17 = _e341;
            let _e342 = n_1;
            param_18 = _e342;
            let _e343 = l;
            param_19 = _e343;
            let _e344 = CalcShadow_u0028_vf3_u003b_vf3_u003b_vf3_u003b((&param_17), (&param_18), (&param_19));
            shadowCol = _e344;
        }
        let _e345 = shadowCol;
        let _e346 = col;
        col = (_e346 * _e345);
    }
    let _e349 = (*gResult).emissive;
    let _e350 = col;
    col = (_e350 + _e349);
    let _e352 = col;
    return _e352;
}

fn GetLightParam_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b(gResult_1: ptr<function, GBufferResult>) -> LightParam {
    var light_1: LightParam;
    var l2v: vec3<f32>;
    var len: f32;
    var baseDir: vec3<f32>;
    var l2g: vec3<f32>;
    var l2g_norm: vec3<f32>;
    var coneAngle: f32;
    var l2g_angle: f32;
    var ValidAngle: bool;
    var height: f32;
    var prjlen: f32;
    var ValidHeight: bool;
    var sinFactor: f32;
    var spotR: f32;
    var l2g_perp: vec3<f32>;
    var l2gR: f32;
    var ValidRadius: bool;
    var attenuation: f32;

    let _e103 = l_ubo.type_;
    if (_e103 == 1f) {
        let _e106 = l_ubo.dir;
        light_1.dir = normalize(_e106.xyz);
        let _e111 = l_ubo.color;
        light_1.color = _e111.xyz;
        let _e115 = l_ubo.intensity;
        light_1.attenuation = _e115;
        light_1.enabled = true;
    } else {
        let _e119 = l_ubo.type_;
        if (_e119 == 2f) {
            let _e122 = (*gResult_1).worldPos;
            let _e124 = l_ubo.pos;
            l2v = (_e122 - _e124.xyz);
            let _e127 = l2v;
            light_1.dir = normalize(_e127);
            let _e131 = l_ubo.color;
            light_1.color = _e131.xyz;
            let _e134 = l2v;
            len = length(_e134);
            let _e137 = l_ubo.intensity;
            let _e138 = len;
            let _e140 = l_ubo.radius;
            let _e147 = len;
            light_1.attenuation = ((_e137 * max(min((1f - pow((_e138 / _e140), 4f)), 1f), 0f)) / pow(_e147, 2f));
            let _e151 = len;
            let _e153 = l_ubo.radius;
            light_1.enabled = (_e151 <= _e153);
        } else {
            let _e157 = l_ubo.type_;
            if (_e157 == 3f) {
                let _e160 = l_ubo.dir;
                baseDir = normalize(_e160.xyz);
                let _e164 = (*gResult_1).worldPos;
                let _e166 = l_ubo.pos;
                l2g = (_e164 - _e166.xyz);
                let _e169 = l2g;
                l2g_norm = normalize(_e169);
                let _e172 = l_ubo.angle;
                coneAngle = radians(_e172);
                let _e174 = baseDir;
                let _e175 = l2g_norm;
                l2g_angle = acos(dot(_e174, _e175));
                let _e178 = l2g_angle;
                let _e180 = l2g_angle;
                let _e181 = coneAngle;
                ValidAngle = ((_e178 >= 0f) && (_e180 <= _e181));
                let _e185 = l_ubo.height;
                height = _e185;
                let _e186 = l2g;
                let _e188 = l2g_angle;
                prjlen = (length(_e186) * cos(_e188));
                let _e191 = prjlen;
                let _e193 = prjlen;
                let _e194 = height;
                ValidHeight = ((_e191 >= 0f) && (_e193 < _e194));
                let _e197 = coneAngle;
                let _e199 = coneAngle;
                sinFactor = (sin(_e197) / sin((1.57075f - _e199)));
                let _e203 = sinFactor;
                let _e204 = prjlen;
                spotR = (_e203 * _e204);
                let _e206 = l2g;
                let _e207 = prjlen;
                let _e208 = baseDir;
                l2g_perp = (_e206 - (_e208 * _e207));
                let _e211 = l2g_perp;
                l2gR = length(_e211);
                let _e213 = l2gR;
                let _e214 = spotR;
                ValidRadius = (_e213 <= _e214);
                attenuation = 1f;
                let _e216 = l2g_norm;
                light_1.dir = _e216;
                let _e219 = l_ubo.color;
                light_1.color = _e219.xyz;
                let _e223 = l_ubo.intensity;
                let _e224 = attenuation;
                let _e228 = l_ubo.color[3u];
                light_1.attenuation = ((_e223 * _e224) * _e228);
                let _e231 = ValidAngle;
                let _e232 = ValidRadius;
                light_1.enabled = (_e231 && _e232);
            }
        }
    }
    let _e235 = light_1;
    return _e235;
}

fn GetEmission_u0028_vf2_u003b(ScreenUV: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Emission: vec4<f32>;

    let _e85 = (*ScreenUV);
    let _e86 = textureSample(gEmissionTexture, gEmissionTextureSampler, _e85);
    Emission = _e86;
    let _e87 = Emission;
    return _e87;
}

fn GetCustomParam0_u0028_vf2_u003b(ScreenUV_1: ptr<function, vec2<f32>>) -> vec4<f32> {
    var CustomParam0_: vec4<f32>;

    let _e85 = (*ScreenUV_1);
    let _e86 = textureSample(gCustomParam0Texture, gCustomParam0TextureSampler, _e85);
    CustomParam0_ = _e86;
    let _e87 = CustomParam0_;
    return _e87;
}

fn GetDepth_u0028_vf2_u003b(ScreenUV_2: ptr<function, vec2<f32>>) -> f32 {
    var Depth: f32;

    let _e85 = (*ScreenUV_2);
    let _e86 = textureSample(gDepthTexture, gDepthTextureSampler, _e85);
    Depth = _e86.x;
    let _e88 = Depth;
    return _e88;
}

fn GetAlbedo_u0028_vf2_u003b(ScreenUV_3: ptr<function, vec2<f32>>) -> vec4<f32> {
    var Albedo: vec4<f32>;

    let _e85 = (*ScreenUV_3);
    let _e86 = textureSample(gAlbedoTexture, gAlbedoTextureSampler, _e85);
    Albedo = _e86;
    let _e87 = Albedo;
    return _e87;
}

fn GetWorldNormal_u0028_vf2_u003b(ScreenUV_4: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldNormal: vec3<f32>;

    let _e85 = (*ScreenUV_4);
    let _e86 = textureSample(gNormalTexture, gNormalTextureSampler, _e85);
    WorldNormal = _e86.xyz;
    let _e88 = WorldNormal;
    return _e88;
}

fn GetWorldPos_u0028_vf2_u003b(ScreenUV_5: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e85 = (*ScreenUV_5);
    let _e86 = textureSample(gPositionTexture, gPositionTextureSampler, _e85);
    WorldPos = _e86.xyz;
    let _e88 = WorldPos;
    return _e88;
}

fn GetGBuffer_u0028_vf2_u003b(ScreenUV_6: ptr<function, vec2<f32>>) -> GBufferResult {
    var gResult_2: GBufferResult;
    var param_20: vec2<f32>;
    var param_21: vec2<f32>;
    var param_22: vec2<f32>;
    var param_23: vec2<f32>;
    var CustomParam0_1: vec4<f32>;
    var param_24: vec2<f32>;
    var param_25: vec2<f32>;

    let _e92 = (*ScreenUV_6);
    param_20 = _e92;
    let _e93 = GetWorldPos_u0028_vf2_u003b((&param_20));
    gResult_2.worldPos = _e93;
    let _e95 = (*ScreenUV_6);
    param_21 = _e95;
    let _e96 = GetWorldNormal_u0028_vf2_u003b((&param_21));
    gResult_2.worldNormal = _e96;
    let _e98 = (*ScreenUV_6);
    param_22 = _e98;
    let _e99 = GetAlbedo_u0028_vf2_u003b((&param_22));
    gResult_2.albedo = _e99;
    let _e101 = (*ScreenUV_6);
    param_23 = _e101;
    let _e102 = GetDepth_u0028_vf2_u003b((&param_23));
    gResult_2.depth = _e102;
    let _e104 = (*ScreenUV_6);
    param_24 = _e104;
    let _e105 = GetCustomParam0_u0028_vf2_u003b((&param_24));
    CustomParam0_1 = _e105;
    let _e107 = CustomParam0_1[0u];
    gResult_2.materialType = _e107;
    let _e109 = CustomParam0_1;
    gResult_2.metallicRoughness = _e109.yz;
    let _e112 = (*ScreenUV_6);
    param_25 = _e112;
    let _e113 = GetEmission_u0028_vf2_u003b((&param_25));
    gResult_2.emissive = _e113.xyz;
    let _e116 = gResult_2;
    return _e116;
}

fn main_1() {
    var ScreenUV_7: vec2<f32>;
    var gResult_3: GBufferResult;
    var param_26: vec2<f32>;
    var light_2: LightParam;
    var param_27: GBufferResult;
    var col_1: vec3<f32>;
    var param_28: GBufferResult;
    var param_29: LightParam;
    var phi_1101_: bool;

    let _e91 = v2f_ProjPos_1;
    let _e94 = v2f_ProjPos_1[3u];
    ScreenUV_7 = (_e91.xy / vec2(_e94));
    let _e97 = ScreenUV_7;
    ScreenUV_7 = ((_e97 * 0.5f) + vec2(0.5f));
    let _e101 = ScreenUV_7;
    param_26 = _e101;
    let _e102 = GetGBuffer_u0028_vf2_u003b((&param_26));
    gResult_3 = _e102;
    let _e103 = gResult_3;
    param_27 = _e103;
    let _e104 = GetLightParam_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b((&param_27));
    light_2 = _e104;
    let _e106 = l_ubo.ForceLighting;
    let _e107 = (_e106 == 1i);
    phi_1101_ = _e107;
    if _e107 {
        let _e109 = l_ubo.type_;
        phi_1101_ = (_e109 == 3f);
    }
    let _e112 = phi_1101_;
    if _e112 {
        gResult_3.albedo = vec4<f32>(1f, 1f, 1f, 1f);
    }
    col_1 = vec3<f32>(0f, 0f, 0f);
    let _e115 = gResult_3.materialType;
    let _e118 = light_2.enabled;
    if ((_e115 == 1f) && _e118) {
        let _e120 = gResult_3;
        param_28 = _e120;
        let _e121 = light_2;
        param_29 = _e121;
        let _e122 = ComputeLight_u0028_struct_u002d_GBufferResult_u002d_vf3_u002d_vf3_u002d_vf4_u002d_f1_u002d_f1_u002d_vf2_u002d_vf31_u003b_struct_u002d_LightParam_u002d_vf3_u002d_vf3_u002d_f1_u002d_b11_u003b((&param_28), (&param_29));
        col_1 = _e122;
    } else {
        col_1 = vec3<f32>(0f, 0f, 0f);
    }
    let _e123 = col_1;
    outColor = vec4<f32>(_e123.x, _e123.y, _e123.z, 1f);
    return;
}

@fragment 
fn main(@location(1) v2f_ProjPos: vec4<f32>, @location(0) v2f_UV: vec2<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_UV_1 = v2f_UV;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
