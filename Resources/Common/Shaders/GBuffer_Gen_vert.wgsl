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
var<private> v2f_ProjPos: vec4<f32>;

fn main_1() {
    var BioTangent: vec3<f32>;
    var SkinMat: mat4x4<f32>;
    var WorldPos: vec4<f32>;
    var WorldNormal: vec3<f32>;
    var WorldTangent: vec3<f32>;
    var WorldBioTangent: vec3<f32>;
    var ProjPos: vec4<f32>;

    let _e33 = inNormal_1;
    let _e34 = inTangent_1;
    BioTangent = cross(_e33, _e34.xyz);
    let _e38 = ubo.useSkinMeshAnimation;
    if (_e38 != 0i) {
        let _e41 = inWeights0_1[0u];
        let _e43 = inJoint0_1[0u];
        let _e46 = r_SkinMatrixBuffer.SkinMat[_e43];
        let _e47 = (_e46 * _e41);
        let _e49 = inWeights0_1[1u];
        let _e51 = inJoint0_1[1u];
        let _e54 = r_SkinMatrixBuffer.SkinMat[_e51];
        let _e55 = (_e54 * _e49);
        let _e68 = mat4x4<f32>((_e47[0] + _e55[0]), (_e47[1] + _e55[1]), (_e47[2] + _e55[2]), (_e47[3] + _e55[3]));
        let _e70 = inWeights0_1[2u];
        let _e72 = inJoint0_1[2u];
        let _e75 = r_SkinMatrixBuffer.SkinMat[_e72];
        let _e76 = (_e75 * _e70);
        let _e89 = mat4x4<f32>((_e68[0] + _e76[0]), (_e68[1] + _e76[1]), (_e68[2] + _e76[2]), (_e68[3] + _e76[3]));
        let _e91 = inWeights0_1[3u];
        let _e93 = inJoint0_1[3u];
        let _e96 = r_SkinMatrixBuffer.SkinMat[_e93];
        let _e97 = (_e96 * _e91);
        SkinMat = mat4x4<f32>((_e89[0] + _e97[0]), (_e89[1] + _e97[1]), (_e89[2] + _e97[2]), (_e89[3] + _e97[3]));
        let _e111 = SkinMat;
        let _e112 = inPosition_1;
        WorldPos = (_e111 * vec4<f32>(_e112.x, _e112.y, _e112.z, 1f));
        let _e118 = SkinMat;
        let _e119 = inNormal_1;
        WorldNormal = normalize((_e118 * vec4<f32>(_e119.x, _e119.y, _e119.z, 0f)).xyz);
        let _e127 = SkinMat;
        let _e128 = inTangent_1;
        WorldTangent = normalize((_e127 * _e128).xyz);
        let _e132 = SkinMat;
        let _e133 = BioTangent;
        WorldBioTangent = normalize((_e132 * vec4<f32>(_e133.x, _e133.y, _e133.z, 0f)).xyz);
    } else {
        let _e142 = ubo.model;
        let _e143 = inPosition_1;
        WorldPos = (_e142 * vec4<f32>(_e143.x, _e143.y, _e143.z, 1f));
        let _e150 = ubo.model;
        let _e151 = inNormal_1;
        WorldNormal = normalize((_e150 * vec4<f32>(_e151.x, _e151.y, _e151.z, 0f)).xyz);
        let _e160 = ubo.model;
        let _e161 = inTangent_1;
        WorldTangent = normalize((_e160 * _e161).xyz);
        let _e166 = ubo.model;
        let _e167 = BioTangent;
        WorldBioTangent = normalize((_e166 * vec4<f32>(_e167.x, _e167.y, _e167.z, 0f)).xyz);
    }
    let _e176 = ubo.proj;
    let _e178 = ubo.view;
    let _e180 = WorldPos;
    ProjPos = ((_e176 * _e178) * _e180);
    let _e182 = ProjPos;
    unnamed.gl_Position = _e182;
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
    let _e189 = ProjPos;
    v2f_ProjPos = _e189;
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
    let _e29 = v2f_ProjPos;
    return VertexOutput(_e23, _e24, _e25, _e26, _e27, _e28, _e29);
}
