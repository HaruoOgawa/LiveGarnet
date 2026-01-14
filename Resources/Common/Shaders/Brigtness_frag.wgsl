struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    Threshold: f32,
    Intencity: f32,
    fPad0_: f32,
    fPad1_: f32,
}

struct FragmentOutput {
    @location(1) member: vec4<f32>,
    @location(0) member_1: vec4<f32>,
}

var<private> fUV_1: vec2<f32>;
@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;
var<private> outColor: vec4<f32>;
var<private> outBrigtnessColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn main_1() {
    var col: vec4<f32>;
    var st: vec2<f32>;
    var BrigtnessCol: vec4<f32>;

    col = vec4<f32>(1f, 1f, 1f, 1f);
    let _e20 = fUV_1;
    st = _e20;
    let _e21 = st;
    let _e22 = textureSample(texImage, texSampler, _e21);
    let _e23 = _e22.xyz;
    col[0u] = _e23.x;
    col[1u] = _e23.y;
    col[2u] = _e23.z;
    let _e30 = col;
    BrigtnessCol = _e30;
    let _e31 = BrigtnessCol;
    let _e34 = frag_ubo.Threshold;
    let _e39 = frag_ubo.Intencity;
    let _e40 = (max(vec3<f32>(0f, 0f, 0f), (_e31.xyz - vec3(_e34))) * _e39);
    BrigtnessCol[0u] = _e40.x;
    BrigtnessCol[1u] = _e40.y;
    BrigtnessCol[2u] = _e40.z;
    let _e47 = col;
    outColor = _e47;
    let _e48 = BrigtnessCol;
    outBrigtnessColor = _e48;
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> FragmentOutput {
    fUV_1 = fUV;
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e8 = outColor;
    let _e9 = outBrigtnessColor;
    return FragmentOutput(_e8, _e9);
}
