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
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec4<f32>,
}

var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> inPosition_1: vec3<f32>;
var<private> fragPos: vec4<f32>;
var<private> inNormal_1: vec3<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inJoint0_1: vec4<u32>;
var<private> inWeights0_1: vec4<f32>;

fn main_1() {
    let _e14 = ubo.lightVPMat;
    let _e16 = ubo.model;
    let _e18 = inPosition_1;
    unnamed.gl_Position = ((_e14 * _e16) * vec4<f32>(_e18.x, _e18.y, _e18.z, 1f));
    let _e26 = unnamed.gl_Position;
    fragPos = _e26;
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
    let _e16 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e16);
    let _e18 = unnamed.gl_Position;
    let _e19 = fragPos;
    return VertexOutput(_e18, _e19);
}
