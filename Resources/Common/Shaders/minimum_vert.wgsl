struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32, 1>,
    gl_CullDistance: array<f32, 1>,
}

struct UniformBufferObject {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    cameraPos: vec4<f32>,
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec3<f32>,
    @location(1) member_1: vec2<f32>,
    @location(2) member_2: vec3<f32>,
}

var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> inPosition_1: vec3<f32>;
var<private> fWolrdNormal: vec3<f32>;
var<private> inNormal_1: vec3<f32>;
var<private> fUV: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> fViewDir: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inJoint0_1: vec4<u32>;
var<private> inWeights0_1: vec4<f32>;

fn main_1() {
    let _e19 = ubo.proj;
    let _e21 = ubo.view;
    let _e24 = ubo.model;
    let _e26 = inPosition_1;
    unnamed.gl_Position = (((_e19 * _e21) * _e24) * vec4<f32>(_e26.x, _e26.y, _e26.z, 1f));
    let _e34 = ubo.model;
    let _e35 = inNormal_1;
    fWolrdNormal = (_e34 * vec4<f32>(_e35.x, _e35.y, _e35.z, 0f)).xyz;
    let _e42 = inTexcoord_1;
    fUV = _e42;
    let _e44 = ubo.model;
    let _e45 = inPosition_1;
    let _e53 = ubo.cameraPos;
    fViewDir = normalize(((_e44 * vec4<f32>(_e45.x, _e45.y, _e45.z, 1f)).xyz - _e53.xyz));
    return;
}

@vertex 
fn main(@location(0) inPosition: vec3<f32>, @location(1) inNormal: vec3<f32>, @location(2) inTexcoord: vec2<f32>, @location(3) inTangent: vec4<f32>, @location(4) inJoint0_: vec4<u32>, @location(5) inWeights0_: vec4<f32>) -> VertexOutput {
    inPosition_1 = inPosition;
    inNormal_1 = inNormal;
    inTexcoord_1 = inTexcoord;
    inTangent_1 = inTangent;
    inJoint0_1 = inJoint0_;
    inWeights0_1 = inWeights0_;
    main_1();
    let _e18 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e18);
    let _e20 = unnamed.gl_Position;
    let _e21 = fWolrdNormal;
    let _e22 = fUV;
    let _e23 = fViewDir;
    return VertexOutput(_e20, _e21, _e22, _e23);
}
