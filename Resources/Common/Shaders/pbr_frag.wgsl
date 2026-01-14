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

struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVMat: mat4x4<f32>,
    lightPMat: mat4x4<f32>,
    lightDir: vec4<f32>,
    lightColor: vec4<f32>,
    cameraPos: vec4<f32>,
    baseColorFactor: vec4<f32>,
    emissiveFactor: vec4<f32>,
    spatialCullPos: vec4<f32>,
    ambientColor: vec4<f32>,
    time: f32,
    metallicFactor: f32,
    roughnessFactor: f32,
    normalMapScale: f32,
    occlusionStrength: f32,
    mipCount: f32,
    ShadowMapX: f32,
    ShadowMapY: f32,
    emissiveStrength: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
    useBaseColorTexture: i32,
    useMetallicRoughnessTexture: i32,
    useEmissiveTexture: i32,
    useNormalTexture: i32,
    useOcclusionTexture: i32,
    useCubeMap: i32,
    useShadowMap: i32,
    useIBL: i32,
    useSkinMeshAnimation: i32,
    useDirCubemap: i32,
    pad1_: i32,
    pad2_: i32,
}

@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(8) 
var normalTexture: texture_2d<f32>;
@group(0) @binding(9) 
var normalTextureSampler: sampler;
var<private> f_Texcoord_1: vec2<f32>;
@group(0) @binding(14) 
var shadowmapTexture: texture_2d<f32>;
@group(0) @binding(15) 
var shadowmapTextureSampler: sampler;
@group(0) @binding(12) 
var cubemapTexture: texture_cube<f32>;
@group(0) @binding(13) 
var cubemapTextureSampler: sampler;
@group(0) @binding(22) 
var cubeMap2DTexture: texture_2d<f32>;
@group(0) @binding(23) 
var cubeMap2DTextureSampler: sampler;
@group(0) @binding(20) 
var IBL_GGXLUT_Texture: texture_2d<f32>;
@group(0) @binding(21) 
var IBL_GGXLUT_TextureSampler: sampler;
@group(0) @binding(16) 
var IBL_Diffuse_Texture: texture_2d<f32>;
@group(0) @binding(17) 
var IBL_Diffuse_TextureSampler: sampler;
@group(0) @binding(18) 
var IBL_Specular_Texture: texture_2d<f32>;
@group(0) @binding(19) 
var IBL_Specular_TextureSampler: sampler;
@group(0) @binding(4) 
var metallicRoughnessTexture: texture_2d<f32>;
@group(0) @binding(5) 
var metallicRoughnessTextureSampler: sampler;
@group(0) @binding(2) 
var baseColorTexture: texture_2d<f32>;
@group(0) @binding(3) 
var baseColorTextureSampler: sampler;
var<private> f_WorldPos_1: vec4<f32>;
@group(0) @binding(10) 
var occlusionTexture: texture_2d<f32>;
@group(0) @binding(11) 
var occlusionTextureSampler: sampler;
@group(0) @binding(6) 
var emissiveTexture: texture_2d<f32>;
@group(0) @binding(7) 
var emissiveTextureSampler: sampler;
var<private> f_LightSpacePos_1: vec4<f32>;
var<private> outColor: vec4<f32>;

fn ComputePCF_u0028_vf2_u003b(uv: ptr<function, vec2<f32>>) -> vec2<f32> {
    var moments: vec2<f32>;
    var texelSize: vec2<f32>;

    moments = vec2<f32>(0f, 0f);
    let _e98 = ubo.ShadowMapX;
    let _e101 = ubo.ShadowMapY;
    texelSize = vec2<f32>((1f / _e98), (1f / _e101));
    let _e104 = (*uv);
    let _e105 = texelSize;
    let _e108 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e104 + (vec2<f32>(-1f, -1f) * _e105)));
    let _e110 = moments;
    moments = (_e110 + _e108.xy);
    let _e112 = (*uv);
    let _e113 = texelSize;
    let _e116 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e112 + (vec2<f32>(-1f, 0f) * _e113)));
    let _e118 = moments;
    moments = (_e118 + _e116.xy);
    let _e120 = (*uv);
    let _e121 = texelSize;
    let _e124 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e120 + (vec2<f32>(-1f, 1f) * _e121)));
    let _e126 = moments;
    moments = (_e126 + _e124.xy);
    let _e128 = (*uv);
    let _e129 = texelSize;
    let _e132 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e128 + (vec2<f32>(0f, -1f) * _e129)));
    let _e134 = moments;
    moments = (_e134 + _e132.xy);
    let _e136 = (*uv);
    let _e137 = texelSize;
    let _e140 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e136 + (vec2<f32>(0f, 0f) * _e137)));
    let _e142 = moments;
    moments = (_e142 + _e140.xy);
    let _e144 = (*uv);
    let _e145 = texelSize;
    let _e148 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e144 + (vec2<f32>(0f, 1f) * _e145)));
    let _e150 = moments;
    moments = (_e150 + _e148.xy);
    let _e152 = (*uv);
    let _e153 = texelSize;
    let _e156 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e152 + (vec2<f32>(1f, -1f) * _e153)));
    let _e158 = moments;
    moments = (_e158 + _e156.xy);
    let _e160 = (*uv);
    let _e161 = texelSize;
    let _e164 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e160 + (vec2<f32>(1f, 0f) * _e161)));
    let _e166 = moments;
    moments = (_e166 + _e164.xy);
    let _e168 = (*uv);
    let _e169 = texelSize;
    let _e172 = textureSample(shadowmapTexture, shadowmapTextureSampler, (_e168 + (vec2<f32>(1f, 1f) * _e169)));
    let _e174 = moments;
    moments = (_e174 + _e172.xy);
    let _e176 = moments;
    moments = (_e176 / vec2(9f));
    let _e179 = moments;
    return _e179;
}

fn CalcShadow_u0028_vf3_u003b_vf3_u003b_vf3_u003b(lsp: ptr<function, vec3<f32>>, nomral: ptr<function, vec3<f32>>, lightDir: ptr<function, vec3<f32>>) -> f32 {
    var moments_1: vec2<f32>;
    var param: vec2<f32>;
    var ShadowBias: f32;
    var distance: f32;

    let _e101 = (*lsp);
    param = _e101.xy;
    let _e103 = ComputePCF_u0028_vf2_u003b((&param));
    moments_1 = _e103;
    let _e104 = moments_1;
    moments_1 = ((_e104 * 0.5f) + vec2(0.5f));
    let _e108 = (*nomral);
    let _e109 = (*lightDir);
    ShadowBias = max(0f, (0.001f * (1f - dot(_e108, _e109))));
    let _e115 = (*lsp)[2u];
    let _e116 = ShadowBias;
    distance = (_e115 - _e116);
    let _e118 = distance;
    let _e120 = moments_1[0u];
    if (_e118 <= _e120) {
        return 1f;
    }
    return 0.1f;
}

fn SRGBtoLINEAR_u0028_vf4_u003b(srgbIn: ptr<function, vec4<f32>>) -> vec4<f32> {
    let _e95 = (*srgbIn);
    let _e97 = pow(_e95.xyz, vec3<f32>(2.2f, 2.2f, 2.2f));
    let _e99 = (*srgbIn)[3u];
    return vec4<f32>(_e97.x, _e97.y, _e97.z, _e99);
}

fn CastDirToSt_u0028_vf3_u003b(Dir: ptr<function, vec3<f32>>) -> vec2<f32> {
    var pi: f32;
    var theta: f32;
    var phi: f32;
    var st: vec2<f32>;

    pi = 3.1415f;
    let _e100 = (*Dir)[1u];
    theta = acos(_e100);
    let _e103 = (*Dir)[2u];
    let _e105 = (*Dir)[0u];
    phi = atan2(_e103, _e105);
    let _e107 = phi;
    let _e108 = pi;
    let _e111 = theta;
    let _e112 = pi;
    st = vec2<f32>((_e107 / (2f * _e108)), (_e111 / _e112));
    let _e115 = st;
    return _e115;
}

fn ComputeReflectionColor_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b_vf3_u003b_vf3_u003b(pbrParam: ptr<function, PBRParam>, v: ptr<function, vec3<f32>>, n: ptr<function, vec3<f32>>) -> vec3<f32> {
    var reflectColor: vec3<f32>;
    var mipCount: f32;
    var lod: f32;
    var param_1: vec4<f32>;
    var st_1: vec2<f32>;
    var param_2: vec3<f32>;
    var mipCount_1: f32;
    var lod_1: f32;
    var param_3: vec4<f32>;

    reflectColor = vec3<f32>(0f, 0f, 0f);
    let _e107 = ubo.useCubeMap;
    if (_e107 != 0i) {
        let _e110 = ubo.mipCount;
        mipCount = _e110;
        let _e111 = mipCount;
        let _e113 = (*pbrParam).perceptualRoughness;
        lod = (_e111 * _e113);
        let _e115 = (*v);
        let _e116 = (*n);
        let _e118 = lod;
        let _e119 = textureSampleLevel(cubemapTexture, cubemapTextureSampler, reflect(_e115, _e116), _e118);
        param_1 = _e119;
        let _e120 = SRGBtoLINEAR_u0028_vf4_u003b((&param_1));
        reflectColor = _e120.xyz;
    } else {
        let _e123 = ubo.useDirCubemap;
        if (_e123 != 0i) {
            let _e125 = (*v);
            let _e126 = (*n);
            param_2 = reflect(_e125, _e126);
            let _e128 = CastDirToSt_u0028_vf3_u003b((&param_2));
            st_1 = _e128;
            let _e130 = ubo.mipCount;
            mipCount_1 = _e130;
            let _e131 = mipCount_1;
            let _e133 = (*pbrParam).perceptualRoughness;
            lod_1 = (_e131 * _e133);
            let _e135 = st_1;
            let _e136 = lod_1;
            let _e137 = textureSampleLevel(cubeMap2DTexture, cubeMap2DTextureSampler, _e135, _e136);
            param_3 = _e137;
            let _e138 = SRGBtoLINEAR_u0028_vf4_u003b((&param_3));
            reflectColor = _e138.xyz;
        }
    }
    let _e140 = reflectColor;
    return _e140;
}

fn GetSphericalTexcoord_u0028_vf3_u003b(Dir_1: ptr<function, vec3<f32>>) -> vec2<f32> {
    var pi_1: f32;
    var theta_1: f32;
    var phi_1: f32;
    var st_2: vec2<f32>;

    pi_1 = 3.1415f;
    let _e100 = (*Dir_1)[1u];
    theta_1 = acos(_e100);
    let _e103 = (*Dir_1)[2u];
    let _e105 = (*Dir_1)[0u];
    phi_1 = atan2(_e103, _e105);
    let _e107 = phi_1;
    let _e108 = pi_1;
    let _e111 = theta_1;
    let _e112 = pi_1;
    st_2 = vec2<f32>((_e107 / (2f * _e108)), (_e111 / _e112));
    let _e115 = st_2;
    return _e115;
}

fn ComputeIBL_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b_vf3_u003b_vf3_u003b(pbrParam_1: ptr<function, PBRParam>, v_1: ptr<function, vec3<f32>>, n_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var mipCount_2: f32;
    var lod_2: f32;
    var brdf: vec3<f32>;
    var param_4: vec4<f32>;
    var diffuseLight: vec3<f32>;
    var param_5: vec3<f32>;
    var param_6: vec4<f32>;
    var specularLight: vec3<f32>;
    var param_7: vec3<f32>;
    var param_8: vec4<f32>;
    var diffuse: vec3<f32>;
    var specular: vec3<f32>;

    let _e110 = ubo.mipCount;
    mipCount_2 = _e110;
    let _e111 = mipCount_2;
    let _e113 = (*pbrParam_1).perceptualRoughness;
    lod_2 = (_e111 * _e113);
    let _e116 = (*pbrParam_1).NdotV;
    let _e118 = (*pbrParam_1).perceptualRoughness;
    let _e121 = textureSample(IBL_GGXLUT_Texture, IBL_GGXLUT_TextureSampler, vec2<f32>(_e116, (1f - _e118)));
    param_4 = _e121;
    let _e122 = SRGBtoLINEAR_u0028_vf4_u003b((&param_4));
    brdf = _e122.xyz;
    let _e124 = (*n_1);
    param_5 = _e124;
    let _e125 = GetSphericalTexcoord_u0028_vf3_u003b((&param_5));
    let _e126 = textureSample(IBL_Diffuse_Texture, IBL_Diffuse_TextureSampler, _e125);
    param_6 = _e126;
    let _e127 = SRGBtoLINEAR_u0028_vf4_u003b((&param_6));
    diffuseLight = _e127.xyz;
    let _e129 = (*v_1);
    let _e130 = (*n_1);
    param_7 = reflect(_e129, _e130);
    let _e132 = GetSphericalTexcoord_u0028_vf3_u003b((&param_7));
    let _e133 = lod_2;
    let _e134 = textureSampleLevel(IBL_Specular_Texture, IBL_Specular_TextureSampler, _e132, _e133);
    param_8 = _e134;
    let _e135 = SRGBtoLINEAR_u0028_vf4_u003b((&param_8));
    specularLight = _e135.xyz;
    let _e137 = diffuseLight;
    let _e139 = (*pbrParam_1).diffuseColor;
    diffuse = (_e137 * _e139);
    let _e141 = specularLight;
    let _e143 = (*pbrParam_1).specularColor;
    let _e145 = brdf[0u];
    let _e148 = brdf[1u];
    specular = (_e141 * ((_e143 * _e145) + vec3(_e148)));
    let _e152 = specular;
    return _e152;
}

fn CalcDiffuseBRDF_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_9: ptr<function, PBRParam>) -> vec3<f32> {
    var oneminus: f32;

    let _e97 = (*param_9).metallic;
    oneminus = (0.96f - (_e97 * 0.96f));
    let _e101 = (*param_9).diffuseColor;
    let _e102 = oneminus;
    return (_e101 * _e102);
}

fn CalcFrenelReflection_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_10: ptr<function, PBRParam>) -> vec3<f32> {
    let _e96 = (*param_10).reflectance0_;
    let _e98 = (*param_10).reflectance90_;
    let _e100 = (*param_10).reflectance0_;
    let _e103 = (*param_10).VdotH;
    return (_e96 + ((_e98 - _e100) * pow(clamp((1f - _e103), 0f, 1f), 5f)));
}

fn CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_11: ptr<function, PBRParam>) -> f32 {
    var NdotL: f32;
    var NdotV: f32;
    var r: f32;
    var attenuationL: f32;
    var attenuationV: f32;

    let _e101 = (*param_11).NdotL;
    NdotL = _e101;
    let _e103 = (*param_11).NdotV;
    NdotV = _e103;
    let _e105 = (*param_11).alphaRoughness;
    r = _e105;
    let _e106 = NdotL;
    let _e108 = NdotL;
    let _e109 = r;
    let _e110 = r;
    let _e112 = r;
    let _e113 = r;
    let _e116 = NdotL;
    let _e117 = NdotL;
    attenuationL = ((2f * _e106) / (_e108 + sqrt(((_e109 * _e110) + ((1f - (_e112 * _e113)) * (_e116 * _e117))))));
    let _e124 = NdotV;
    let _e126 = NdotV;
    let _e127 = r;
    let _e128 = r;
    let _e130 = r;
    let _e131 = r;
    let _e134 = NdotV;
    let _e135 = NdotV;
    attenuationV = ((2f * _e124) / (_e126 + sqrt(((_e127 * _e128) + ((1f - (_e130 * _e131)) * (_e134 * _e135))))));
    let _e142 = attenuationL;
    let _e143 = attenuationV;
    return (_e142 * _e143);
}

fn CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b(param_12: ptr<function, PBRParam>) -> f32 {
    var roughness2_: f32;
    var f: f32;

    let _e98 = (*param_12).alphaRoughness;
    let _e100 = (*param_12).alphaRoughness;
    roughness2_ = (_e98 * _e100);
    let _e103 = (*param_12).NdotH;
    let _e104 = roughness2_;
    let _e107 = (*param_12).NdotH;
    let _e110 = (*param_12).NdotH;
    f = ((((_e103 * _e104) - _e107) * _e110) + 1f);
    let _e113 = roughness2_;
    let _e114 = f;
    let _e116 = f;
    return (_e113 / ((3.1415927f * _e114) * _e116));
}

fn getNormal_u0028_() -> vec3<f32> {
    var nomral_1: vec3<f32>;
    var t: vec3<f32>;
    var b: vec3<f32>;
    var n_2: vec3<f32>;
    var tbn: mat3x3<f32>;

    nomral_1 = vec3<f32>(0f, 0f, 0f);
    let _e100 = ubo.useNormalTexture;
    if (_e100 != 0i) {
        let _e102 = f_WorldTangent_1;
        t = normalize(_e102);
        let _e104 = f_WorldBioTangent_1;
        b = normalize(_e104);
        let _e106 = f_WorldNormal_1;
        n_2 = normalize(_e106);
        let _e108 = t;
        let _e109 = b;
        let _e110 = n_2;
        tbn = mat3x3<f32>(vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e109.x, _e109.y, _e109.z), vec3<f32>(_e110.x, _e110.y, _e110.z));
        let _e124 = f_Texcoord_1;
        let _e125 = textureSample(normalTexture, normalTextureSampler, _e124);
        nomral_1 = _e125.xyz;
        let _e127 = tbn;
        let _e128 = nomral_1;
        let _e133 = ubo.normalMapScale;
        let _e135 = ubo.normalMapScale;
        nomral_1 = normalize((_e127 * (((_e128 * 2f) - vec3(1f)) * vec3<f32>(_e133, _e135, 1f))));
    } else {
        let _e140 = f_WorldNormal_1;
        nomral_1 = _e140;
    }
    let _e141 = nomral_1;
    return _e141;
}

fn CalcSurface_u0028_() -> vec4<f32> {
    var col: vec3<f32>;
    var perceptualRoughness: f32;
    var metallic: f32;
    var metallicRoughnessColor: vec4<f32>;
    var alphaRoughness: f32;
    var baseColor: vec4<f32>;
    var f0_: vec3<f32>;
    var diffuseColor: vec3<f32>;
    var specularColor: vec3<f32>;
    var reflectance: f32;
    var reflectance90_: f32;
    var specularEnvironmentR0_: vec3<f32>;
    var specularEnvironmentR90_: vec3<f32>;
    var n_3: vec3<f32>;
    var v_2: vec3<f32>;
    var l: vec3<f32>;
    var h: vec3<f32>;
    var reflection: vec3<f32>;
    var NdotL_1: f32;
    var NdotV_1: f32;
    var NdotH: f32;
    var LdotH: f32;
    var VdotH: f32;
    var pbrParam_2: PBRParam;
    var specular_1: vec3<f32>;
    var diffuse_1: vec3<f32>;
    var D: f32;
    var param_13: PBRParam;
    var G: f32;
    var param_14: PBRParam;
    var F: vec3<f32>;
    var param_15: PBRParam;
    var param_16: PBRParam;
    var param_17: PBRParam;
    var param_18: vec3<f32>;
    var param_19: vec3<f32>;
    var param_20: PBRParam;
    var param_21: vec3<f32>;
    var param_22: vec3<f32>;
    var gi_diffuse: vec3<f32>;
    var ao: f32;
    var emissive: vec3<f32>;
    var param_23: vec4<f32>;
    var lsp_1: vec3<f32>;
    var shadowCol: f32;
    var outSide: bool;
    var param_24: vec3<f32>;
    var param_25: vec3<f32>;
    var param_26: vec3<f32>;
    var alpha: f32;
    var result: vec4<f32>;
    var phi_877_: bool;
    var phi_983_: bool;
    var phi_990_: bool;
    var phi_1003_: bool;
    var phi_1010_: bool;
    var phi_1011_: bool;

    col = vec3<f32>(0f, 0f, 0f);
    let _e146 = ubo.roughnessFactor;
    perceptualRoughness = _e146;
    let _e148 = ubo.metallicFactor;
    metallic = _e148;
    let _e150 = ubo.useMetallicRoughnessTexture;
    if (_e150 != 0i) {
        let _e152 = f_Texcoord_1;
        let _e153 = textureSample(metallicRoughnessTexture, metallicRoughnessTextureSampler, _e152);
        metallicRoughnessColor = _e153;
        let _e154 = perceptualRoughness;
        let _e156 = metallicRoughnessColor[1u];
        perceptualRoughness = (_e154 * _e156);
        let _e158 = metallic;
        let _e160 = metallicRoughnessColor[2u];
        metallic = (_e158 * _e160);
    }
    let _e162 = perceptualRoughness;
    perceptualRoughness = clamp(_e162, 0.04f, 1f);
    let _e164 = metallic;
    metallic = clamp(_e164, 0f, 1f);
    let _e166 = perceptualRoughness;
    let _e167 = perceptualRoughness;
    alphaRoughness = (_e166 * _e167);
    let _e170 = ubo.useBaseColorTexture;
    if (_e170 != 0i) {
        let _e172 = f_Texcoord_1;
        let _e173 = textureSample(baseColorTexture, baseColorTextureSampler, _e172);
        baseColor = _e173;
    } else {
        let _e175 = ubo.baseColorFactor;
        baseColor = _e175;
    }
    f0_ = vec3<f32>(0.04f, 0.04f, 0.04f);
    let _e176 = baseColor;
    let _e178 = f0_;
    diffuseColor = (_e176.xyz * (vec3<f32>(1f, 1f, 1f) - _e178));
    let _e181 = f0_;
    let _e182 = baseColor;
    let _e184 = metallic;
    specularColor = mix(_e181, _e182.xyz, vec3(_e184));
    let _e188 = specularColor[0u];
    let _e190 = specularColor[1u];
    let _e193 = specularColor[2u];
    reflectance = max(max(_e188, _e190), _e193);
    let _e195 = reflectance;
    reflectance90_ = clamp((_e195 * 25f), 0f, 1f);
    let _e198 = specularColor;
    specularEnvironmentR0_ = _e198;
    let _e199 = reflectance90_;
    specularEnvironmentR90_ = (vec3<f32>(1f, 1f, 1f) * _e199);
    let _e201 = getNormal_u0028_();
    n_3 = _e201;
    let _e202 = f_WorldPos_1;
    let _e205 = ubo.cameraPos;
    v_2 = (normalize((_e202.xyz - _e205.xyz)) * -1f);
    let _e211 = ubo.lightDir;
    l = (normalize(_e211.xyz) * -1f);
    let _e215 = v_2;
    let _e216 = l;
    h = normalize((_e215 + _e216));
    let _e219 = v_2;
    let _e220 = n_3;
    reflection = normalize(reflect(_e219, _e220));
    let _e223 = n_3;
    let _e224 = l;
    NdotL_1 = clamp(dot(_e223, _e224), 0f, 1f);
    let _e227 = n_3;
    let _e228 = v_2;
    NdotV_1 = clamp(abs(dot(_e227, _e228)), 0f, 1f);
    let _e232 = n_3;
    let _e233 = h;
    NdotH = clamp(dot(_e232, _e233), 0f, 1f);
    let _e236 = l;
    let _e237 = h;
    LdotH = clamp(dot(_e236, _e237), 0f, 1f);
    let _e240 = v_2;
    let _e241 = h;
    VdotH = clamp(dot(_e240, _e241), 0f, 1f);
    let _e244 = NdotL_1;
    let _e245 = NdotV_1;
    let _e246 = NdotH;
    let _e247 = LdotH;
    let _e248 = VdotH;
    let _e249 = perceptualRoughness;
    let _e250 = metallic;
    let _e251 = specularEnvironmentR0_;
    let _e252 = specularEnvironmentR90_;
    let _e253 = alphaRoughness;
    let _e254 = diffuseColor;
    let _e255 = specularColor;
    pbrParam_2 = PBRParam(_e244, _e245, _e246, _e247, _e248, _e249, _e250, _e251, _e252, _e253, _e254, _e255);
    specular_1 = vec3<f32>(0f, 0f, 0f);
    diffuse_1 = vec3<f32>(0f, 0f, 0f);
    let _e257 = pbrParam_2;
    param_13 = _e257;
    let _e258 = CalcMicrofacet_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_13));
    D = _e258;
    let _e259 = pbrParam_2;
    param_14 = _e259;
    let _e260 = CalcGeometricOcculusion_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_14));
    G = _e260;
    let _e261 = pbrParam_2;
    param_15 = _e261;
    let _e262 = CalcFrenelReflection_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_15));
    F = _e262;
    let _e263 = NdotL_1;
    let _e265 = NdotV_1;
    if ((_e263 > 0f) || (_e265 > 0f)) {
        let _e268 = D;
        let _e269 = G;
        let _e271 = F;
        let _e273 = NdotL_1;
        let _e275 = NdotV_1;
        let _e279 = specular_1;
        specular_1 = (_e279 + ((_e271 * (_e268 * _e269)) / vec3(((4f * _e273) * _e275))));
        let _e281 = specular_1;
        specular_1 = max(_e281, vec3<f32>(0f, 0f, 0f));
        let _e283 = F;
        let _e286 = pbrParam_2;
        param_16 = _e286;
        let _e287 = CalcDiffuseBRDF_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b((&param_16));
        let _e289 = diffuse_1;
        diffuse_1 = (_e289 + ((vec3(1f) - _e283) * _e287));
        let _e291 = NdotL_1;
        let _e292 = specular_1;
        let _e293 = diffuse_1;
        col = ((_e292 + _e293) * _e291);
    }
    let _e297 = ubo.useIBL;
    if (_e297 != 0i) {
        let _e299 = pbrParam_2;
        param_17 = _e299;
        let _e300 = v_2;
        param_18 = _e300;
        let _e301 = n_3;
        param_19 = _e301;
        let _e302 = ComputeIBL_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b_vf3_u003b_vf3_u003b((&param_17), (&param_18), (&param_19));
        let _e303 = col;
        col = (_e303 + _e302);
    } else {
        let _e306 = ubo.useCubeMap;
        let _e307 = (_e306 != 0i);
        phi_877_ = _e307;
        if !(_e307) {
            let _e310 = ubo.useDirCubemap;
            phi_877_ = (_e310 != 0i);
        }
        let _e313 = phi_877_;
        if _e313 {
            let _e314 = pbrParam_2;
            param_20 = _e314;
            let _e315 = v_2;
            param_21 = _e315;
            let _e316 = n_3;
            param_22 = _e316;
            let _e317 = ComputeReflectionColor_u0028_struct_u002d_PBRParam_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_f1_u002d_vf3_u002d_vf3_u002d_f1_u002d_vf3_u002d_vf31_u003b_vf3_u003b_vf3_u003b((&param_20), (&param_21), (&param_22));
            let _e318 = F;
            let _e320 = col;
            col = (_e320 + (_e317 * _e318));
        } else {
            let _e323 = ubo.ambientColor;
            gi_diffuse = _e323.xyz;
            let _e325 = gi_diffuse;
            let _e326 = col;
            col = (_e326 + _e325);
        }
    }
    let _e329 = ubo.useOcclusionTexture;
    if (_e329 != 0i) {
        let _e331 = f_Texcoord_1;
        let _e332 = textureSample(occlusionTexture, occlusionTextureSampler, _e331);
        ao = _e332.x;
        let _e334 = col;
        let _e335 = col;
        let _e336 = ao;
        let _e339 = ubo.occlusionStrength;
        col = mix(_e334, (_e335 * _e336), vec3(_e339));
    }
    let _e343 = ubo.emissiveFactor;
    let _e346 = ubo.emissiveStrength;
    emissive = (_e343.xyz * _e346);
    let _e349 = ubo.useEmissiveTexture;
    if (_e349 != 0i) {
        let _e351 = f_Texcoord_1;
        let _e352 = textureSample(emissiveTexture, emissiveTextureSampler, _e351);
        param_23 = _e352;
        let _e353 = SRGBtoLINEAR_u0028_vf4_u003b((&param_23));
        let _e355 = emissive;
        emissive = (_e355 * _e353.xyz);
    }
    let _e357 = emissive;
    let _e358 = col;
    col = (_e358 + _e357);
    let _e361 = ubo.useShadowMap;
    if (_e361 != 0i) {
        let _e363 = f_LightSpacePos_1;
        let _e366 = f_LightSpacePos_1[3u];
        lsp_1 = (_e363.xyz / vec3(_e366));
        let _e369 = lsp_1;
        lsp_1 = ((_e369 * 0.5f) + vec3(0.5f));
        shadowCol = 1f;
        let _e374 = lsp_1[0u];
        let _e375 = (_e374 < 0f);
        phi_983_ = _e375;
        if !(_e375) {
            let _e378 = lsp_1[1u];
            phi_983_ = (_e378 < 0f);
        }
        let _e381 = phi_983_;
        phi_990_ = _e381;
        if !(_e381) {
            let _e384 = lsp_1[2u];
            phi_990_ = (_e384 < 0f);
        }
        let _e387 = phi_990_;
        phi_1011_ = _e387;
        if !(_e387) {
            let _e390 = lsp_1[0u];
            let _e391 = (_e390 > 1f);
            phi_1003_ = _e391;
            if !(_e391) {
                let _e394 = lsp_1[1u];
                phi_1003_ = (_e394 > 1f);
            }
            let _e397 = phi_1003_;
            phi_1010_ = _e397;
            if !(_e397) {
                let _e400 = lsp_1[2u];
                phi_1010_ = (_e400 > 1f);
            }
            let _e403 = phi_1010_;
            phi_1011_ = _e403;
        }
        let _e405 = phi_1011_;
        outSide = _e405;
        let _e406 = outSide;
        if !(_e406) {
            let _e408 = lsp_1;
            param_24 = _e408;
            let _e409 = n_3;
            param_25 = _e409;
            let _e410 = l;
            param_26 = _e410;
            let _e411 = CalcShadow_u0028_vf3_u003b_vf3_u003b_vf3_u003b((&param_24), (&param_25), (&param_26));
            shadowCol = _e411;
        }
        let _e412 = shadowCol;
        let _e413 = col;
        col = (_e413 * _e412);
    }
    let _e415 = col;
    col = pow(_e415, vec3<f32>(0.45454547f, 0.45454547f, 0.45454547f));
    let _e418 = baseColor[3u];
    alpha = _e418;
    let _e419 = col;
    let _e420 = alpha;
    result = vec4<f32>(_e419.x, _e419.y, _e419.z, _e420);
    let _e425 = result;
    return _e425;
}

fn main_1() {
    var result_1: vec4<f32>;

    result_1 = vec4<f32>(0f, 0f, 0f, 0f);
    let _e95 = CalcSurface_u0028_();
    result_1 = _e95;
    let _e96 = result_1;
    outColor = _e96;
    return;
}

@fragment 
fn main(@location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(0) f_WorldNormal: vec3<f32>, @location(1) f_Texcoord: vec2<f32>, @location(2) f_WorldPos: vec4<f32>, @location(5) f_LightSpacePos: vec4<f32>) -> @location(0) vec4<f32> {
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_WorldNormal_1 = f_WorldNormal;
    f_Texcoord_1 = f_Texcoord;
    f_WorldPos_1 = f_WorldPos;
    f_LightSpacePos_1 = f_LightSpacePos;
    main_1();
    let _e13 = outColor;
    return _e13;
}
