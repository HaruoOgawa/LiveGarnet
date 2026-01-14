struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    edgeSize: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
    useSkinMeshAnimation: i32,
    pad0_: i32,
    pad1_: i32,
    pad2_: i32,
}

struct SkinMatrixBuffer {
    SkinMat: array<mat4x4<f32>, 1024>,
}

struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32, 1>,
    gl_CullDistance: array<f32, 1>,
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec3<f32>,
    @location(1) member_1: vec2<f32>,
    @location(2) member_2: vec4<f32>,
    @location(3) member_3: vec3<f32>,
    @location(4) member_4: vec3<f32>,
    @location(5) member_5: vec4<f32>,
    @location(6) member_6: vec2<f32>,
}

var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inPosition_1: vec3<f32>;
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> inWeights0_1: vec4<f32>;
@group(0) @binding(1) 
var<uniform> r_SkinMatrixBuffer: SkinMatrixBuffer;
var<private> inBone0_1: vec4<u32>;
var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
var<private> f_WorldNormal: vec3<f32>;
var<private> f_Texcoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> f_WorldPos: vec4<f32>;
var<private> f_WorldTangent: vec3<f32>;
var<private> f_WorldBioTangent: vec3<f32>;
var<private> f_LightSpacePos: vec4<f32>;
var<private> f_SphereUV: vec2<f32>;

fn main_1() {
    var BioTangent: vec3<f32>;
    var LocalPos: vec3<f32>;
    var SkinMat: mat4x4<f32>;
    var WorldPos: vec4<f32>;
    var WorldNormal: vec3<f32>;
    var WorldTangent: vec3<f32>;
    var WorldBioTangent: vec3<f32>;
    var VNormal: vec4<f32>;
    var SphereUV: vec2<f32>;

    let _e38 = inNormal_1;
    let _e39 = inTangent_1;
    BioTangent = cross(_e38, _e39.xyz);
    let _e42 = inPosition_1;
    LocalPos = _e42;
    let _e44 = ubo.useSkinMeshAnimation;
    if (_e44 != 0i) {
        let _e47 = inWeights0_1[0u];
        let _e49 = inBone0_1[0u];
        let _e52 = r_SkinMatrixBuffer.SkinMat[_e49];
        let _e53 = (_e52 * _e47);
        let _e55 = inWeights0_1[1u];
        let _e57 = inBone0_1[1u];
        let _e60 = r_SkinMatrixBuffer.SkinMat[_e57];
        let _e61 = (_e60 * _e55);
        let _e74 = mat4x4<f32>((_e53[0] + _e61[0]), (_e53[1] + _e61[1]), (_e53[2] + _e61[2]), (_e53[3] + _e61[3]));
        let _e76 = inWeights0_1[2u];
        let _e78 = inBone0_1[2u];
        let _e81 = r_SkinMatrixBuffer.SkinMat[_e78];
        let _e82 = (_e81 * _e76);
        let _e95 = mat4x4<f32>((_e74[0] + _e82[0]), (_e74[1] + _e82[1]), (_e74[2] + _e82[2]), (_e74[3] + _e82[3]));
        let _e97 = inWeights0_1[3u];
        let _e99 = inBone0_1[3u];
        let _e102 = r_SkinMatrixBuffer.SkinMat[_e99];
        let _e103 = (_e102 * _e97);
        SkinMat = mat4x4<f32>((_e95[0] + _e103[0]), (_e95[1] + _e103[1]), (_e95[2] + _e103[2]), (_e95[3] + _e103[3]));
        let _e117 = SkinMat;
        let _e118 = LocalPos;
        WorldPos = (_e117 * vec4<f32>(_e118.x, _e118.y, _e118.z, 1f));
        let _e124 = SkinMat;
        let _e125 = inNormal_1;
        WorldNormal = normalize((_e124 * vec4<f32>(_e125.x, _e125.y, _e125.z, 0f)).xyz);
        let _e133 = SkinMat;
        let _e134 = inTangent_1;
        WorldTangent = normalize((_e133 * _e134).xyz);
        let _e138 = SkinMat;
        let _e139 = BioTangent;
        WorldBioTangent = normalize((_e138 * vec4<f32>(_e139.x, _e139.y, _e139.z, 0f)).xyz);
    } else {
        let _e148 = ubo.model;
        let _e149 = LocalPos;
        WorldPos = (_e148 * vec4<f32>(_e149.x, _e149.y, _e149.z, 1f));
        let _e156 = ubo.model;
        let _e157 = inNormal_1;
        WorldNormal = normalize((_e156 * vec4<f32>(_e157.x, _e157.y, _e157.z, 0f)).xyz);
        let _e166 = ubo.model;
        let _e167 = inTangent_1;
        WorldTangent = normalize((_e166 * _e167).xyz);
        let _e172 = ubo.model;
        let _e173 = BioTangent;
        WorldBioTangent = normalize((_e172 * vec4<f32>(_e173.x, _e173.y, _e173.z, 0f)).xyz);
    }
    let _e182 = ubo.view;
    let _e183 = WorldNormal;
    VNormal = (_e182 * vec4<f32>(_e183.x, _e183.y, _e183.z, 0f));
    let _e189 = VNormal;
    SphereUV = ((_e189.xy * 0.5f) + vec2(0.5f));
    let _e195 = ubo.proj;
    let _e197 = ubo.view;
    let _e199 = WorldPos;
    unnamed.gl_Position = ((_e195 * _e197) * _e199);
    let _e202 = WorldNormal;
    f_WorldNormal = _e202;
    let _e203 = inTexcoord_1;
    f_Texcoord = _e203;
    let _e204 = WorldPos;
    f_WorldPos = _e204;
    let _e205 = WorldTangent;
    f_WorldTangent = _e205;
    let _e206 = WorldBioTangent;
    f_WorldBioTangent = _e206;
    let _e208 = ubo.lightVPMat;
    let _e209 = WorldPos;
    f_LightSpacePos = (_e208 * _e209);
    let _e211 = SphereUV;
    f_SphereUV = _e211;
    return;
}

@vertex 
fn main(@location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(0) inPosition: vec3<f32>, @location(5) inWeights0_: vec4<f32>, @location(4) inBone0_: vec4<u32>, @location(2) inTexcoord: vec2<f32>) -> VertexOutput {
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inPosition_1 = inPosition;
    inWeights0_1 = inWeights0_;
    inBone0_1 = inBone0_;
    inTexcoord_1 = inTexcoord;
    main_1();
    let _e22 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e22);
    let _e24 = unnamed.gl_Position;
    let _e25 = f_WorldNormal;
    let _e26 = f_Texcoord;
    let _e27 = f_WorldPos;
    let _e28 = f_WorldTangent;
    let _e29 = f_WorldBioTangent;
    let _e30 = f_LightSpacePos;
    let _e31 = f_SphereUV;
    return VertexOutput(_e24, _e25, _e26, _e27, _e28, _e29, _e30, _e31);
}
