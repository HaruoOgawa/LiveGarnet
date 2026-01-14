struct FragUniformBuffer {
    baseColorFactor: vec4<f32>,
    metallicFactor: f32,
    roughnessFactor: f32,
    f_pad0_: f32,
    f_pad1_: f32,
    useBaseColorTexture: i32,
    useMetallicRoughnessTexture: i32,
    useNormalTexture: i32,
    materialType: i32,
}

struct FragmentOutput {
    @location(0) member: vec4<f32>,
    @location(1) member_1: vec4<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec4<f32>,
    @location(4) member_4: vec4<f32>,
}

@group(0) @binding(0) 
var<uniform> f_ubo: FragUniformBuffer;
@group(0) @binding(2) 
var baseColorTexture: texture_2d<f32>;
@group(0) @binding(3) 
var baseColorTextureSampler: sampler;
var<private> f_Texcoord_1: vec2<f32>;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(6) 
var normalTexture: texture_2d<f32>;
@group(0) @binding(7) 
var normalTextureSampler: sampler;
@group(0) @binding(4) 
var metallicRoughnessTexture: texture_2d<f32>;
@group(0) @binding(5) 
var metallicRoughnessTextureSampler: sampler;
var<private> gl_FragCoord_1: vec4<f32>;
var<private> gPosition: vec4<f32>;
var<private> f_WorldPos_1: vec4<f32>;
var<private> gNormal: vec4<f32>;
var<private> gAlbedo: vec4<f32>;
var<private> gDepth: vec4<f32>;
var<private> gCustomParam0_: vec4<f32>;

fn GetMetallicRoughness_u0028_() -> vec2<f32> {
    var perceptualRoughness: f32;
    var metallic: f32;
    var metallicRoughnessColor: vec4<f32>;

    let _e36 = f_ubo.roughnessFactor;
    perceptualRoughness = _e36;
    let _e38 = f_ubo.metallicFactor;
    metallic = _e38;
    let _e40 = f_ubo.useMetallicRoughnessTexture;
    if (_e40 != 0i) {
        let _e42 = f_Texcoord_1;
        let _e43 = textureSample(metallicRoughnessTexture, metallicRoughnessTextureSampler, _e42);
        metallicRoughnessColor = _e43;
        let _e45 = metallicRoughnessColor[1u];
        perceptualRoughness = _e45;
        let _e47 = metallicRoughnessColor[2u];
        metallic = _e47;
    }
    let _e48 = metallic;
    let _e49 = perceptualRoughness;
    return vec2<f32>(_e48, _e49);
}

fn getNormal_u0028_() -> vec3<f32> {
    var nomral: vec3<f32>;
    var t: vec3<f32>;
    var b: vec3<f32>;
    var n: vec3<f32>;
    var tbn: mat3x3<f32>;

    nomral = vec3<f32>(0f, 0f, 0f);
    let _e38 = f_ubo.useNormalTexture;
    if (_e38 != 0i) {
        let _e40 = f_WorldTangent_1;
        t = normalize(_e40);
        let _e42 = f_WorldBioTangent_1;
        b = normalize(_e42);
        let _e44 = f_WorldNormal_1;
        n = normalize(_e44);
        let _e46 = t;
        let _e47 = b;
        let _e48 = n;
        tbn = mat3x3<f32>(vec3<f32>(_e46.x, _e46.y, _e46.z), vec3<f32>(_e47.x, _e47.y, _e47.z), vec3<f32>(_e48.x, _e48.y, _e48.z));
        let _e62 = f_Texcoord_1;
        let _e63 = textureSample(normalTexture, normalTextureSampler, _e62);
        nomral = _e63.xyz;
        let _e65 = tbn;
        let _e66 = nomral;
        nomral = normalize((_e65 * ((_e66 * 2f) - vec3(1f))));
    } else {
        let _e72 = f_WorldNormal_1;
        nomral = _e72;
    }
    let _e73 = nomral;
    return _e73;
}

fn GetBaseColor_u0028_() -> vec4<f32> {
    var baseColor: vec4<f32>;

    let _e34 = f_ubo.useBaseColorTexture;
    if (_e34 != 0i) {
        let _e36 = f_Texcoord_1;
        let _e37 = textureSample(baseColorTexture, baseColorTextureSampler, _e36);
        baseColor = _e37;
    } else {
        let _e39 = f_ubo.baseColorFactor;
        baseColor = _e39;
    }
    let _e40 = baseColor;
    return _e40;
}

fn main_1() {
    var baseColor_1: vec4<f32>;
    var normal: vec3<f32>;
    var depth: f32;
    var metallicRoughness: vec2<f32>;

    let _e36 = GetBaseColor_u0028_();
    baseColor_1 = _e36;
    let _e37 = getNormal_u0028_();
    normal = _e37;
    let _e39 = gl_FragCoord_1[2u];
    depth = _e39;
    let _e40 = GetMetallicRoughness_u0028_();
    metallicRoughness = _e40;
    let _e41 = f_WorldPos_1;
    gPosition = _e41;
    let _e42 = normal;
    gNormal = vec4<f32>(_e42.x, _e42.y, _e42.z, 0f);
    let _e47 = baseColor_1;
    gAlbedo = _e47;
    let _e48 = depth;
    gDepth = vec4(_e48);
    let _e51 = f_ubo.materialType;
    let _e54 = metallicRoughness[0u];
    let _e56 = metallicRoughness[1u];
    gCustomParam0_ = vec4<f32>(f32(_e51), _e54, _e56, 0f);
    return;
}

@fragment 
fn main(@location(1) f_Texcoord: vec2<f32>, @location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(0) f_WorldNormal: vec3<f32>, @builtin(position) gl_FragCoord: vec4<f32>, @location(2) f_WorldPos: vec4<f32>) -> FragmentOutput {
    f_Texcoord_1 = f_Texcoord;
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_WorldNormal_1 = f_WorldNormal;
    gl_FragCoord_1 = gl_FragCoord;
    f_WorldPos_1 = f_WorldPos;
    main_1();
    let _e17 = gPosition;
    let _e18 = gNormal;
    let _e19 = gAlbedo;
    let _e20 = gDepth;
    let _e21 = gCustomParam0_;
    return FragmentOutput(_e17, _e18, _e19, _e20, _e21);
}
