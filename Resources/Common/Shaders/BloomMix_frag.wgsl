var<private> fUV_1: vec2<f32>;
@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
@group(0) @binding(2) 
var bloomImage: texture_2d<f32>;
@group(0) @binding(3) 
var bloomSampler: sampler;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn main_1() {
    var col: vec3<f32>;
    var st: vec2<f32>;
    var mainCol: vec3<f32>;
    var bloomCol: vec3<f32>;

    col = vec3<f32>(0f, 0f, 0f);
    let _e15 = fUV_1;
    st = _e15;
    let _e16 = st;
    let _e17 = textureSample(texImage, texSampler, _e16);
    mainCol = _e17.xyz;
    let _e19 = st;
    let _e20 = textureSample(bloomImage, bloomSampler, _e19);
    bloomCol = _e20.xyz;
    let _e22 = mainCol;
    let _e23 = bloomCol;
    col = (_e22 + _e23);
    let _e25 = col;
    outColor = vec4<f32>(_e25.x, _e25.y, _e25.z, 1f);
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
