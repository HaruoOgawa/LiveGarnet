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
    var ViewSpaceOutline: bool;
    var CameraPos: vec4<f32>;
    var CameraNormal: vec3<f32>;

    let _e44 = inNormal_1;
    let _e45 = inTangent_1;
    BioTangent = cross(_e44, _e45.xyz);
    let _e48 = inPosition_1;
    LocalPos = _e48;
    let _e50 = ubo.useSkinMeshAnimation;
    if (_e50 != 0i) {
        let _e53 = inWeights0_1[0u];
        let _e55 = inBone0_1[0u];
        let _e58 = r_SkinMatrixBuffer.SkinMat[_e55];
        let _e59 = (_e58 * _e53);
        let _e61 = inWeights0_1[1u];
        let _e63 = inBone0_1[1u];
        let _e66 = r_SkinMatrixBuffer.SkinMat[_e63];
        let _e67 = (_e66 * _e61);
        let _e80 = mat4x4<f32>((_e59[0] + _e67[0]), (_e59[1] + _e67[1]), (_e59[2] + _e67[2]), (_e59[3] + _e67[3]));
        let _e82 = inWeights0_1[2u];
        let _e84 = inBone0_1[2u];
        let _e87 = r_SkinMatrixBuffer.SkinMat[_e84];
        let _e88 = (_e87 * _e82);
        let _e101 = mat4x4<f32>((_e80[0] + _e88[0]), (_e80[1] + _e88[1]), (_e80[2] + _e88[2]), (_e80[3] + _e88[3]));
        let _e103 = inWeights0_1[3u];
        let _e105 = inBone0_1[3u];
        let _e108 = r_SkinMatrixBuffer.SkinMat[_e105];
        let _e109 = (_e108 * _e103);
        SkinMat = mat4x4<f32>((_e101[0] + _e109[0]), (_e101[1] + _e109[1]), (_e101[2] + _e109[2]), (_e101[3] + _e109[3]));
        let _e123 = SkinMat;
        let _e124 = LocalPos;
        WorldPos = (_e123 * vec4<f32>(_e124.x, _e124.y, _e124.z, 1f));
        let _e130 = SkinMat;
        let _e131 = inNormal_1;
        WorldNormal = normalize((_e130 * vec4<f32>(_e131.x, _e131.y, _e131.z, 0f)).xyz);
        let _e139 = SkinMat;
        let _e140 = inTangent_1;
        WorldTangent = normalize((_e139 * _e140).xyz);
        let _e144 = SkinMat;
        let _e145 = BioTangent;
        WorldBioTangent = normalize((_e144 * vec4<f32>(_e145.x, _e145.y, _e145.z, 0f)).xyz);
    } else {
        let _e154 = ubo.model;
        let _e155 = LocalPos;
        WorldPos = (_e154 * vec4<f32>(_e155.x, _e155.y, _e155.z, 1f));
        let _e162 = ubo.model;
        let _e163 = inNormal_1;
        WorldNormal = normalize((_e162 * vec4<f32>(_e163.x, _e163.y, _e163.z, 0f)).xyz);
        let _e172 = ubo.model;
        let _e173 = inTangent_1;
        WorldTangent = normalize((_e172 * _e173).xyz);
        let _e178 = ubo.model;
        let _e179 = BioTangent;
        WorldBioTangent = normalize((_e178 * vec4<f32>(_e179.x, _e179.y, _e179.z, 0f)).xyz);
    }
    let _e188 = ubo.view;
    let _e189 = WorldNormal;
    VNormal = (_e188 * vec4<f32>(_e189.x, _e189.y, _e189.z, 0f));
    let _e195 = VNormal;
    SphereUV = ((_e195.xy * 0.5f) + vec2(0.5f));
    ViewSpaceOutline = false;
    let _e200 = ViewSpaceOutline;
    if _e200 {
        let _e202 = ubo.view;
        let _e203 = WorldPos;
        CameraPos = (_e202 * _e203);
        let _e206 = ubo.view;
        let _e207 = WorldNormal;
        CameraNormal = (_e206 * vec4<f32>(_e207.x, _e207.y, _e207.z, 0f)).xyz;
        let _e214 = CameraNormal;
        let _e218 = ubo.edgeSize;
        let _e221 = CameraPos;
        let _e223 = (_e221.xy + ((normalize(_e214).xy * _e218) * 0.001f));
        CameraPos[0u] = _e223.x;
        CameraPos[1u] = _e223.y;
        let _e229 = ubo.proj;
        let _e230 = CameraPos;
        unnamed.gl_Position = (_e229 * _e230);
    } else {
        let _e233 = WorldNormal;
        let _e236 = ubo.edgeSize;
        let _e239 = WorldPos;
        let _e241 = (_e239.xyz + ((normalize(_e233) * _e236) * 0.001f));
        WorldPos[0u] = _e241.x;
        WorldPos[1u] = _e241.y;
        WorldPos[2u] = _e241.z;
        let _e249 = ubo.proj;
        let _e251 = ubo.view;
        let _e253 = WorldPos;
        unnamed.gl_Position = ((_e249 * _e251) * _e253);
    }
    let _e256 = WorldNormal;
    f_WorldNormal = _e256;
    let _e257 = inTexcoord_1;
    f_Texcoord = _e257;
    let _e258 = WorldPos;
    f_WorldPos = _e258;
    let _e259 = WorldTangent;
    f_WorldTangent = _e259;
    let _e260 = WorldBioTangent;
    f_WorldBioTangent = _e260;
    let _e262 = ubo.lightVPMat;
    let _e263 = WorldPos;
    f_LightSpacePos = (_e262 * _e263);
    let _e265 = SphereUV;
    f_SphereUV = _e265;
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
