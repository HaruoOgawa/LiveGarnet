var<private> fUV_1: vec2<f32>;
@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn main_1() {
    var col: vec4<f32>;
    var st: vec2<f32>;

    col = vec4<f32>(1f, 1f, 1f, 1f);
    let _e13 = fUV_1;
    st = _e13;
    let _e14 = st;
    let _e15 = textureSample(texImage, texSampler, _e14);
    let _e16 = _e15.xyz;
    col[0u] = _e16.x;
    col[1u] = _e16.y;
    col[2u] = _e16.z;
    let _e23 = col;
    outColor = _e23;
    return;
}

@fragment 
fn main(@location(0) fUV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    fUV_1 = fUV;
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
