struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    IsXBlur: i32,
    iPad0_: i32,
    iPad1_: i32,
    iPad2_: i32,
}

@group(0) @binding(0) 
var texImage: texture_2d<f32>;
@group(0) @binding(1) 
var texSampler: sampler;
var<private> v2f_UV_1: vec2<f32>;
@group(0) @binding(2) 
var<uniform> frag_ubo: FragUniformBuffer;
var<private> outColor: vec4<f32>;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;

fn GetTexColor_u0028_vf2_u003b(texcoord: ptr<function, vec2<f32>>) -> vec3<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e27 = (*texcoord);
    let _e28 = textureSample(texImage, texSampler, _e27);
    let _e29 = _e28.xyz;
    col[0u] = _e29.x;
    col[1u] = _e29.y;
    col[2u] = _e29.z;
    let _e36 = col;
    return _e36.xyz;
}

fn main_1() {
    var col_1: vec3<f32>;
    var st: vec2<f32>;
    var texelSize: vec2<f32>;
    var weights: array<f32, 5>;
    var BlurDir: vec2<f32>;
    var i: i32;
    var param: vec2<f32>;

    col_1 = vec3<f32>(0f, 0f, 0f);
    let _e32 = v2f_UV_1;
    st = _e32;
    let _e33 = textureDimensions(texImage, 0i);
    texelSize = (vec2(1f) / vec2<f32>(vec2<i32>(_e33)));
    weights = array<f32, 5>(0.227027f, 0.316216f, 0.07027f, 0.002216f, 0.000167f);
    let _e39 = frag_ubo.IsXBlur;
    let _e43 = frag_ubo.IsXBlur;
    BlurDir = vec2<f32>(select(0f, 1f, (_e39 == 1i)), select(1f, 0f, (_e43 == 1i)));
    i = -4i;
    loop {
        let _e47 = i;
        if (_e47 <= 4i) {
            let _e49 = st;
            let _e50 = texelSize;
            let _e51 = i;
            let _e54 = BlurDir;
            param = (_e49 + ((_e50 * f32(_e51)) * _e54));
            let _e57 = GetTexColor_u0028_vf2_u003b((&param));
            let _e58 = i;
            let _e61 = weights[abs(_e58)];
            let _e63 = col_1;
            col_1 = (_e63 + (_e57 * _e61));
            continue;
        } else {
            break;
        }
        continuing {
            let _e65 = i;
            i = (_e65 + 1i);
        }
    }
    let _e67 = col_1;
    outColor = vec4<f32>(_e67.x, _e67.y, _e67.z, 1f);
    return;
}

@fragment 
fn main(@location(0) v2f_UV: vec2<f32>, @location(1) v2f_ProjPos: vec4<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    v2f_UV_1 = v2f_UV;
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
