struct FragUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    texelSize: vec2<f32>,
    fPad0_: f32,
    fPad1_: f32,
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

fn GetTexColor_u0028_vf2_u003b(texcoord: ptr<function, vec2<f32>>) -> vec4<f32> {
    var col: vec4<f32>;

    col = vec4<f32>(0f, 0f, 0f, 0f);
    let _e18 = (*texcoord);
    let _e19 = textureSample(texImage, texSampler, _e18);
    col = _e19;
    let _e20 = col;
    return _e20;
}

fn main_1() {
    var pos: vec2<f32>;
    var lumaMiddle: f32;
    var param: vec2<f32>;
    var lumaUp: f32;
    var param_1: vec2<f32>;
    var lumaDown: f32;
    var param_2: vec2<f32>;
    var lumaLeft: f32;
    var param_3: vec2<f32>;
    var lumaRight: f32;
    var param_4: vec2<f32>;
    var maxLuma: f32;
    var minLuma: f32;
    var contrast: f32;
    var edgeThreshold: f32;
    var param_5: vec2<f32>;
    var horizontal: f32;
    var vertical: f32;
    var isHorizontal: bool;
    var offset: vec2<f32>;
    var local: vec2<f32>;
    var colA: vec3<f32>;
    var param_6: vec2<f32>;
    var colB: vec3<f32>;
    var param_7: vec2<f32>;
    var blendedColor: vec3<f32>;

    let _e42 = v2f_UV_1;
    pos = _e42;
    let _e43 = pos;
    param = _e43;
    let _e44 = GetTexColor_u0028_vf2_u003b((&param));
    lumaMiddle = _e44.y;
    let _e46 = pos;
    let _e49 = frag_ubo.texelSize[1u];
    param_1 = (_e46 + vec2<f32>(0f, _e49));
    let _e52 = GetTexColor_u0028_vf2_u003b((&param_1));
    lumaUp = _e52.y;
    let _e54 = pos;
    let _e57 = frag_ubo.texelSize[1u];
    param_2 = (_e54 - vec2<f32>(0f, _e57));
    let _e60 = GetTexColor_u0028_vf2_u003b((&param_2));
    lumaDown = _e60.y;
    let _e62 = pos;
    let _e65 = frag_ubo.texelSize[0u];
    param_3 = (_e62 - vec2<f32>(_e65, 0f));
    let _e68 = GetTexColor_u0028_vf2_u003b((&param_3));
    lumaLeft = _e68.y;
    let _e70 = pos;
    let _e73 = frag_ubo.texelSize[0u];
    param_4 = (_e70 + vec2<f32>(_e73, 0f));
    let _e76 = GetTexColor_u0028_vf2_u003b((&param_4));
    lumaRight = _e76.y;
    let _e78 = lumaUp;
    let _e79 = lumaDown;
    let _e81 = lumaLeft;
    let _e82 = lumaRight;
    maxLuma = max(max(_e78, _e79), max(_e81, _e82));
    let _e85 = lumaUp;
    let _e86 = lumaDown;
    let _e88 = lumaLeft;
    let _e89 = lumaRight;
    minLuma = min(min(_e85, _e86), min(_e88, _e89));
    let _e92 = maxLuma;
    let _e93 = minLuma;
    contrast = (_e92 - _e93);
    edgeThreshold = 0.0166f;
    let _e95 = contrast;
    let _e96 = edgeThreshold;
    if (_e95 < _e96) {
        let _e98 = pos;
        param_5 = _e98;
        let _e99 = GetTexColor_u0028_vf2_u003b((&param_5));
        outColor = _e99;
        return;
    }
    let _e100 = lumaUp;
    let _e101 = lumaDown;
    let _e103 = lumaMiddle;
    horizontal = abs(((_e100 + _e101) - (2f * _e103)));
    let _e107 = lumaLeft;
    let _e108 = lumaRight;
    let _e110 = lumaMiddle;
    vertical = abs(((_e107 + _e108) - (2f * _e110)));
    let _e114 = horizontal;
    let _e115 = vertical;
    isHorizontal = (_e114 > _e115);
    let _e117 = isHorizontal;
    if _e117 {
        let _e120 = frag_ubo.texelSize[1u];
        local = vec2<f32>(0f, _e120);
    } else {
        let _e124 = frag_ubo.texelSize[0u];
        local = vec2<f32>(_e124, 0f);
    }
    let _e126 = local;
    offset = _e126;
    let _e127 = pos;
    let _e128 = offset;
    param_6 = (_e127 - _e128);
    let _e130 = GetTexColor_u0028_vf2_u003b((&param_6));
    colA = _e130.xyz;
    let _e132 = pos;
    let _e133 = offset;
    param_7 = (_e132 + _e133);
    let _e135 = GetTexColor_u0028_vf2_u003b((&param_7));
    colB = _e135.xyz;
    let _e137 = colA;
    let _e138 = colB;
    blendedColor = ((_e137 + _e138) * 0.5f);
    let _e141 = blendedColor;
    outColor = vec4<f32>(_e141.x, _e141.y, _e141.z, 1f);
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
