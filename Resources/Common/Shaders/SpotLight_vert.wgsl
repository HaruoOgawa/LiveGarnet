struct VertUniformBuffer {
    model: mat4x4<f32>,
    view: mat4x4<f32>,
    proj: mat4x4<f32>,
    lightVPMat: mat4x4<f32>,
    angle: f32,
    height: f32,
    pan: f32,
    tilt: f32,
}

struct gl_PerVertex {
    @builtin(position) gl_Position: vec4<f32>,
    gl_PointSize: f32,
    gl_ClipDistance: array<f32, 1>,
    gl_CullDistance: array<f32, 1>,
}

struct VertexOutput {
    @builtin(position) gl_Position: vec4<f32>,
    @location(0) member: vec2<f32>,
    @location(1) member_1: vec4<f32>,
    @location(2) member_2: vec4<f32>,
}

var<private> inPosition_1: vec3<f32>;
@group(0) @binding(0) 
var<uniform> v_ubo: VertUniformBuffer;
var<private> unnamed: gl_PerVertex = gl_PerVertex(vec4<f32>(0f, 0f, 0f, 1f), 1f, array<f32, 1>(), array<f32, 1>());
var<private> v2f_UV: vec2<f32>;
var<private> inTexcoord_1: vec2<f32>;
var<private> v2f_ProjPos: vec4<f32>;
var<private> v2f_WorldPos: vec4<f32>;
var<private> inNormal_1: vec3<f32>;
var<private> inTangent_1: vec4<f32>;
var<private> inBone0_1: vec4<u32>;
var<private> inWeights0_1: vec4<f32>;

fn main_1() {
    var pos: vec4<f32>;
    var HeightRate: f32;
    var angle: f32;
    var subAngle: f32;
    var height: f32;
    var XZExpandRate: f32;
    var YExpandRate: f32;
    var realRadius: f32;
    var XZScale: f32;
    var YScale: f32;
    var DeformedScale: vec3<f32>;
    var ProjPos: vec4<f32>;

    let _e38 = inPosition_1;
    pos = vec4<f32>(_e38.x, _e38.y, _e38.z, 1f);
    let _e44 = pos[1u];
    pos[1u] = (_e44 * -1f);
    let _e48 = pos[1u];
    HeightRate = (abs(_e48) / 1f);
    let _e52 = v_ubo.angle;
    angle = radians(_e52);
    let _e54 = angle;
    subAngle = (1.57075f - _e54);
    let _e57 = v_ubo.height;
    height = _e57;
    let _e58 = height;
    let _e59 = subAngle;
    let _e62 = angle;
    XZExpandRate = ((_e58 / sin(_e59)) * sin(_e62));
    let _e65 = height;
    YExpandRate = (_e65 / 1f);
    realRadius = 0.35f;
    let _e67 = realRadius;
    let _e68 = XZExpandRate;
    let _e69 = HeightRate;
    XZScale = mix(_e67, _e68, _e69);
    let _e71 = YExpandRate;
    YScale = _e71;
    let _e72 = XZScale;
    let _e73 = YScale;
    let _e74 = XZScale;
    DeformedScale = vec3<f32>(_e72, _e73, _e74);
    let _e77 = DeformedScale[0u];
    let _e79 = DeformedScale[1u];
    let _e81 = DeformedScale[2u];
    let _e87 = pos;
    pos = (_e87 * mat4x4<f32>(vec4<f32>(_e77, 0f, 0f, 0f), vec4<f32>(0f, _e79, 0f, 0f), vec4<f32>(0f, 0f, _e81, 0f), vec4<f32>(0f, 0f, 0f, 1f)));
    let _e90 = v_ubo.pan;
    let _e93 = v_ubo.pan;
    let _e96 = v_ubo.pan;
    let _e100 = v_ubo.pan;
    let _e105 = pos;
    let _e107 = (_e105.yz * mat2x2<f32>(vec2<f32>(cos(_e90), sin(_e93)), vec2<f32>(-(sin(_e96)), cos(_e100))));
    pos[1u] = _e107.x;
    pos[2u] = _e107.y;
    let _e113 = v_ubo.tilt;
    let _e116 = v_ubo.tilt;
    let _e119 = v_ubo.tilt;
    let _e123 = v_ubo.tilt;
    let _e128 = pos;
    let _e130 = (_e128.xz * mat2x2<f32>(vec2<f32>(cos(_e113), sin(_e116)), vec2<f32>(-(sin(_e119)), cos(_e123))));
    pos[0u] = _e130.x;
    pos[2u] = _e130.y;
    let _e136 = v_ubo.proj;
    let _e138 = v_ubo.view;
    let _e141 = v_ubo.model;
    let _e143 = pos;
    ProjPos = (((_e136 * _e138) * _e141) * _e143);
    let _e145 = ProjPos;
    unnamed.gl_Position = _e145;
    let _e147 = inTexcoord_1;
    v2f_UV = _e147;
    let _e148 = ProjPos;
    v2f_ProjPos = _e148;
    let _e150 = v_ubo.model;
    let _e151 = pos;
    v2f_WorldPos = (_e150 * _e151);
    return;
}

@vertex 
fn main(@location(0) inPosition: vec3<f32>, @location(2) inTexcoord: vec2<f32>, @location(1) inNormal: vec3<f32>, @location(3) inTangent: vec4<f32>, @location(4) inBone0_: vec4<u32>, @location(5) inWeights0_: vec4<f32>) -> VertexOutput {
    inPosition_1 = inPosition;
    inTexcoord_1 = inTexcoord;
    inNormal_1 = inNormal;
    inTangent_1 = inTangent;
    inBone0_1 = inBone0_;
    inWeights0_1 = inWeights0_;
    main_1();
    let _e18 = unnamed.gl_Position.y;
    unnamed.gl_Position.y = -(_e18);
    let _e20 = unnamed.gl_Position;
    let _e21 = v2f_UV;
    let _e22 = v2f_ProjPos;
    let _e23 = v2f_WorldPos;
    return VertexOutput(_e20, _e21, _e22, _e23);
}
