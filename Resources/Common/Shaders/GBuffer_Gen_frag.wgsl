struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    useSkinMeshAnimation: i32,
    useSpatialCulling: i32,
    pad1_: i32,
    pad2_: i32,
    baseColorFactor: vec4<f32>,
    spatialCullPos: vec4<f32>,
    emissiveFactor: vec4<f32>,
    metallicFactor: f32,
    roughnessFactor: f32,
    emissiveStrength: f32,
    materialType: f32,
    useBaseColorTexture: i32,
    useMetallicRoughnessTexture: i32,
    useNormalTexture: i32,
    useEmissiveTexture: i32,
    baseColorTexture_ST: vec4<f32>,
}

struct FragmentOutput {
    @location(0) member: vec4<f32>,
    @location(1) member_1: vec4<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec4<f32>,
    @location(4) member_4: vec4<f32>,
    @location(5) member_5: vec4<f32>,
}

@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> f_Texcoord_1: vec2<f32>;
@group(0) @binding(3) 
var baseColorTexture: texture_2d<f32>;
@group(0) @binding(4) 
var baseColorTextureSampler: sampler;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(7) 
var normalTexture: texture_2d<f32>;
@group(0) @binding(8) 
var normalTextureSampler: sampler;
@group(0) @binding(5) 
var metallicRoughnessTexture: texture_2d<f32>;
@group(0) @binding(6) 
var metallicRoughnessTextureSampler: sampler;
@group(0) @binding(9) 
var emissiveTexture: texture_2d<f32>;
@group(0) @binding(10) 
var emissiveTextureSampler: sampler;
var<private> f_WorldPos_1: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> gPosition: vec4<f32>;
var<private> gNormal: vec4<f32>;
var<private> gAlbedo: vec4<f32>;
var<private> gDepth: vec4<f32>;
var<private> gCustomParam0_: vec4<f32>;
var<private> gEmission: vec4<f32>;

fn GetEmissive_u0028_() -> vec3<f32> {
    var emissive: vec3<f32>;

    let _e49 = ubo.emissiveFactor;
    let _e52 = ubo.emissiveStrength;
    emissive = (_e49.xyz * _e52);
    let _e55 = ubo.useEmissiveTexture;
    if (_e55 != 0i) {
        let _e57 = f_Texcoord_1;
        let _e58 = textureSample(emissiveTexture, emissiveTextureSampler, _e57);
        let _e60 = emissive;
        emissive = (_e60 * _e58.xyz);
    }
    let _e62 = emissive;
    return _e62;
}

fn GetMetallicRoughness_u0028_() -> vec2<f32> {
    var perceptualRoughness: f32;
    var metallic: f32;
    var metallicRoughnessColor: vec4<f32>;

    let _e51 = ubo.roughnessFactor;
    perceptualRoughness = _e51;
    let _e53 = ubo.metallicFactor;
    metallic = _e53;
    let _e55 = ubo.useMetallicRoughnessTexture;
    if (_e55 != 0i) {
        let _e57 = f_Texcoord_1;
        let _e58 = textureSample(metallicRoughnessTexture, metallicRoughnessTextureSampler, _e57);
        metallicRoughnessColor = _e58;
        let _e60 = metallicRoughnessColor[1u];
        perceptualRoughness = _e60;
        let _e62 = metallicRoughnessColor[2u];
        metallic = _e62;
    }
    let _e63 = metallic;
    let _e64 = perceptualRoughness;
    return vec2<f32>(_e63, _e64);
}

fn getNormal_u0028_() -> vec3<f32> {
    var nomral: vec3<f32>;
    var t: vec3<f32>;
    var b: vec3<f32>;
    var n: vec3<f32>;
    var tbn: mat3x3<f32>;

    nomral = vec3<f32>(0f, 0f, 0f);
    let _e53 = ubo.useNormalTexture;
    if (_e53 != 0i) {
        let _e55 = f_WorldTangent_1;
        t = normalize(_e55);
        let _e57 = f_WorldBioTangent_1;
        b = normalize(_e57);
        let _e59 = f_WorldNormal_1;
        n = normalize(_e59);
        let _e61 = t;
        let _e62 = b;
        let _e63 = n;
        tbn = mat3x3<f32>(vec3<f32>(_e61.x, _e61.y, _e61.z), vec3<f32>(_e62.x, _e62.y, _e62.z), vec3<f32>(_e63.x, _e63.y, _e63.z));
        let _e77 = f_Texcoord_1;
        let _e78 = textureSample(normalTexture, normalTextureSampler, _e77);
        nomral = _e78.xyz;
        let _e80 = tbn;
        let _e81 = nomral;
        nomral = normalize((_e80 * ((_e81 * 2f) - vec3(1f))));
    } else {
        let _e87 = f_WorldNormal_1;
        nomral = _e87;
    }
    let _e88 = nomral;
    return _e88;
}

fn SRGBtoLINEAR_u0028_vf4_u003b(srgbIn: ptr<function, vec4<f32>>) -> vec4<f32> {
    let _e48 = (*srgbIn);
    let _e50 = pow(_e48.xyz, vec3<f32>(2.2f, 2.2f, 2.2f));
    let _e52 = (*srgbIn)[3u];
    return vec4<f32>(_e50.x, _e50.y, _e50.z, _e52);
}

fn GetBaseColor_u0028_() -> vec4<f32> {
    var st: vec2<f32>;
    var baseColor: vec4<f32>;
    var param: vec4<f32>;

    let _e51 = ubo.useBaseColorTexture;
    if (_e51 != 0i) {
        let _e53 = f_Texcoord_1;
        let _e55 = ubo.baseColorTexture_ST;
        let _e59 = ubo.baseColorTexture_ST;
        st = ((_e53 * _e55.xy) + _e59.zw);
        let _e62 = st;
        let _e63 = textureSample(baseColorTexture, baseColorTextureSampler, _e62);
        baseColor = _e63;
    } else {
        let _e65 = ubo.baseColorFactor;
        baseColor = _e65;
    }
    let _e66 = baseColor;
    param = _e66;
    let _e67 = SRGBtoLINEAR_u0028_vf4_u003b((&param));
    return _e67;
}

fn main_1() {
    var baseColor_1: vec4<f32>;
    var normal: vec3<f32>;
    var depth: f32;
    var metallicRoughness: vec2<f32>;
    var emissive_1: vec3<f32>;

    let _e53 = ubo.useSpatialCulling;
    if (_e53 == 1i) {
        let _e56 = f_WorldPos_1[1u];
        let _e59 = ubo.spatialCullPos[1u];
        if (_e56 < _e59) {
            discard;
        }
    }
    let _e61 = GetBaseColor_u0028_();
    baseColor_1 = _e61;
    let _e62 = getNormal_u0028_();
    normal = _e62;
    let _e64 = v2f_ProjPos_1[2u];
    let _e66 = v2f_ProjPos_1[3u];
    depth = (_e64 / _e66);
    let _e68 = depth;
    depth = ((_e68 * 0.5f) + 0.5f);
    let _e71 = GetMetallicRoughness_u0028_();
    metallicRoughness = _e71;
    let _e72 = GetEmissive_u0028_();
    emissive_1 = _e72;
    let _e73 = f_WorldPos_1;
    gPosition = _e73;
    let _e74 = normal;
    gNormal = vec4<f32>(_e74.x, _e74.y, _e74.z, 0f);
    let _e79 = baseColor_1;
    gAlbedo = _e79;
    let _e80 = depth;
    gDepth = vec4(_e80);
    let _e83 = ubo.materialType;
    let _e85 = metallicRoughness[0u];
    let _e87 = metallicRoughness[1u];
    gCustomParam0_ = vec4<f32>(_e83, _e85, _e87, 0f);
    let _e89 = emissive_1;
    gEmission = vec4<f32>(_e89.x, _e89.y, _e89.z, 1f);
    return;
}

@fragment 
fn main(@location(1) f_Texcoord: vec2<f32>, @location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(0) f_WorldNormal: vec3<f32>, @location(2) f_WorldPos: vec4<f32>, @location(5) v2f_ProjPos: vec4<f32>) -> FragmentOutput {
    f_Texcoord_1 = f_Texcoord;
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_WorldNormal_1 = f_WorldNormal;
    f_WorldPos_1 = f_WorldPos;
    v2f_ProjPos_1 = v2f_ProjPos;
    main_1();
    let _e18 = gPosition;
    let _e19 = gNormal;
    let _e20 = gAlbedo;
    let _e21 = gDepth;
    let _e22 = gCustomParam0_;
    let _e23 = gEmission;
    return FragmentOutput(_e18, _e19, _e20, _e21, _e22, _e23);
}
