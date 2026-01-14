@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> fUV_1: vec2<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn GetTexColor_u0028_vf2_u003b(texcoord: ptr<function, vec2<f32>>) -> vec3<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e23 = (*texcoord);
    let _e24 = textureSample(texImage, texSampler, _e23);
    let _e25 = _e24.xyz;
    col[0u] = _e25.x;
    col[1u] = _e25.y;
    col[2u] = _e25.z;
    let _e32 = col;
    return _e32.xyz;
}

fn main_1() {
    var col_1: vec3<f32>;
    var st: vec2<f32>;
    var texelSize: vec2<f32>;
    var param: vec2<f32>;
    var param_1: vec2<f32>;
    var param_2: vec2<f32>;
    var param_3: vec2<f32>;
    var param_4: vec2<f32>;

    col_1 = vec3<f32>(0f, 0f, 0f);
    let _e29 = fUV_1;
    st = _e29;
    let _e30 = textureDimensions(texImage, 0i);
    texelSize = (vec2(1f) / vec2<f32>(vec2<i32>(_e30)));
    let _e35 = st;
    param = _e35;
    let _e36 = GetTexColor_u0028_vf2_u003b((&param));
    let _e37 = col_1;
    col_1 = (_e37 + _e36);
    let _e39 = st;
    let _e40 = texelSize;
    param_1 = (_e39 + (_e40 * vec2<f32>(-0.5f, -0.5f)));
    let _e43 = GetTexColor_u0028_vf2_u003b((&param_1));
    let _e44 = col_1;
    col_1 = (_e44 + _e43);
    let _e46 = st;
    let _e47 = texelSize;
    param_2 = (_e46 + (_e47 * vec2<f32>(-0.5f, 0.5f)));
    let _e50 = GetTexColor_u0028_vf2_u003b((&param_2));
    let _e51 = col_1;
    col_1 = (_e51 + _e50);
    let _e53 = st;
    let _e54 = texelSize;
    param_3 = (_e53 + (_e54 * vec2<f32>(0.5f, -0.5f)));
    let _e57 = GetTexColor_u0028_vf2_u003b((&param_3));
    let _e58 = col_1;
    col_1 = (_e58 + _e57);
    let _e60 = st;
    let _e61 = texelSize;
    param_4 = (_e60 + (_e61 * vec2<f32>(0.5f, 0.5f)));
    let _e64 = GetTexColor_u0028_vf2_u003b((&param_4));
    let _e65 = col_1;
    col_1 = (_e65 + _e64);
    let _e67 = col_1;
    col_1 = (_e67 * 0.2f);
    let _e69 = col_1;
    outColor = vec4<f32>(_e69.x, _e69.y, _e69.z, 1f);
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
