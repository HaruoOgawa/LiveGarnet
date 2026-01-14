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
}

var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> inWeights0_1: vec4<f32>;
@group(0) @binding(1) 
var<uniform> r_SkinMatrixBuffer: SkinMatrixBuffer;
var<private> inJoint0_1: vec4<u32>;
var<private> inPosition_1: vec3<f32>;
var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
var<private> f_WorldNormal: vec3<f32>;
var<private> f_Texcoord: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> f_WorldPos: vec4<f32>;
var<private> f_WorldTangent: vec3<f32>;
var<private> f_WorldBioTangent: vec3<f32>;
var<private> f_LightSpacePos: vec4<f32>;

fn main_1() {
    var BioTangent: vec3<f32>;
    var SkinMat: mat4x4<f32>;
    var WorldPos: vec4<f32>;
    var WorldNormal: vec3<f32>;
    var WorldTangent: vec3<f32>;
    var WorldBioTangent: vec3<f32>;

    let _e34 = inNormal_1;
    let _e35 = inTangent_1;
    BioTangent = cross(_e34, _e35.xyz);
    let _e39 = ubo.useSkinMeshAnimation;
    if (_e39 != 0i) {
        let _e42 = inWeights0_1[0u];
        let _e44 = inJoint0_1[0u];
        let _e47 = r_SkinMatrixBuffer.SkinMat[_e44];
        let _e48 = (_e47 * _e42);
        let _e50 = inWeights0_1[1u];
        let _e52 = inJoint0_1[1u];
        let _e55 = r_SkinMatrixBuffer.SkinMat[_e52];
        let _e56 = (_e55 * _e50);
        let _e69 = mat4x4<f32>((_e48[0] + _e56[0]), (_e48[1] + _e56[1]), (_e48[2] + _e56[2]), (_e48[3] + _e56[3]));
        let _e71 = inWeights0_1[2u];
        let _e73 = inJoint0_1[2u];
        let _e76 = r_SkinMatrixBuffer.SkinMat[_e73];
        let _e77 = (_e76 * _e71);
        let _e90 = mat4x4<f32>((_e69[0] + _e77[0]), (_e69[1] + _e77[1]), (_e69[2] + _e77[2]), (_e69[3] + _e77[3]));
        let _e92 = inWeights0_1[3u];
        let _e94 = inJoint0_1[3u];
        let _e97 = r_SkinMatrixBuffer.SkinMat[_e94];
        let _e98 = (_e97 * _e92);
        SkinMat = mat4x4<f32>((_e90[0] + _e98[0]), (_e90[1] + _e98[1]), (_e90[2] + _e98[2]), (_e90[3] + _e98[3]));
        let _e112 = SkinMat;
        let _e113 = inPosition_1;
        WorldPos = (_e112 * vec4<f32>(_e113.x, _e113.y, _e113.z, 1f));
        let _e119 = SkinMat;
        let _e120 = inNormal_1;
        WorldNormal = normalize((_e119 * vec4<f32>(_e120.x, _e120.y, _e120.z, 0f)).xyz);
        let _e128 = SkinMat;
        let _e129 = inTangent_1;
        WorldTangent = normalize((_e128 * _e129).xyz);
        let _e133 = SkinMat;
        let _e134 = BioTangent;
        WorldBioTangent = normalize((_e133 * vec4<f32>(_e134.x, _e134.y, _e134.z, 0f)).xyz);
    } else {
        let _e143 = ubo.model;
        let _e144 = inPosition_1;
        WorldPos = (_e143 * vec4<f32>(_e144.x, _e144.y, _e144.z, 1f));
        let _e151 = ubo.model;
        let _e152 = inNormal_1;
        WorldNormal = normalize((_e151 * vec4<f32>(_e152.x, _e152.y, _e152.z, 0f)).xyz);
        let _e161 = ubo.model;
        let _e162 = inTangent_1;
        WorldTangent = normalize((_e161 * _e162).xyz);
        let _e167 = ubo.model;
        let _e168 = BioTangent;
        WorldBioTangent = normalize((_e167 * vec4<f32>(_e168.x, _e168.y, _e168.z, 0f)).xyz);
    }
    let _e177 = ubo.proj;
    let _e179 = ubo.view;
    let _e181 = WorldPos;
    unnamed.gl_Position = ((_e177 * _e179) * _e181);
    let _e184 = WorldNormal;
    f_WorldNormal = _e184;
    let _e185 = inTexcoord_1;
    f_Texcoord = _e185;
    let _e186 = WorldPos;
    f_WorldPos = _e186;
    let _e187 = WorldTangent;
    f_WorldTangent = _e187;
    let _e188 = WorldBioTangent;
    f_WorldBioTangent = _e188;
    let _e190 = ubo.lightPMat;
    let _e192 = ubo.lightVMat;
    let _e194 = WorldPos;
    f_LightSpacePos = ((_e190 * _e192) * _e194);
    return;
}

@vertex 
fn main(@location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(5) inWeights0_: vec4<f32>, @location(4) inJoint0_: vec4<u32>, @location(0) inPosition: vec3<f32>, @location(2) inTexcoord: vec2<f32>) -> VertexOutput {
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inWeights0_1 = inWeights0_;
    inJoint0_1 = inJoint0_;
    inPosition_1 = inPosition;
    inTexcoord_1 = inTexcoord;
    main_1();
    let _e21 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e21);
    let _e23 = unnamed.gl_Position;
    let _e24 = f_WorldNormal;
    let _e25 = f_Texcoord;
    let _e26 = f_WorldPos;
    let _e27 = f_WorldTangent;
    let _e28 = f_WorldBioTangent;
    let _e29 = f_LightSpacePos;
    return VertexOutput(_e23, _e24, _e25, _e26, _e27, _e28, _e29);
}
