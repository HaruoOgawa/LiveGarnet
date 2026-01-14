struct LightUniformBuffer {
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
    type_: f32,
    radius: f32,
    intensity: f32,
    angle: f32,
    height: f32,
    fPad0_: f32,
    fPad1_: f32,
    fPad2_: f32,
    dir: vec4<f32>,
    pos: vec4<f32>,
    color: vec4<f32>,
    cameraPos: vec4<f32>,
}

@group(0) @binding(2) 
var gPositionTexture: texture_2d<f32>;
@group(0) @binding(3) 
var gPositionTextureSampler: sampler;
@group(0) @binding(1) 
var<uniform> l_ubo: LightUniformBuffer;
var<private> v2f_ProjPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;
var<private> v2f_UV_1: vec2<f32>;
var<private> v2f_WorldPos_1: vec4<f32>;
@group(0) @binding(4) 
var gNormalTexture: texture_2d<f32>;
@group(0) @binding(5) 
var gNormalTextureSampler: sampler;
@group(0) @binding(6) 
var gAlbedoTexture: texture_2d<f32>;
@group(0) @binding(7) 
var gAlbedoTextureSampler: sampler;
@group(0) @binding(8) 
var gDepthTexture: texture_2d<f32>;
@group(0) @binding(9) 
var gDepthTextureSampler: sampler;
@group(0) @binding(10) 
var gCustomParam0Texture: texture_2d<f32>;
@group(0) @binding(11) 
var gCustomParam0TextureSampler: sampler;

fn GetWorldPos_u0028_vf2_u003b(ScreenUV: ptr<function, vec2<f32>>) -> vec3<f32> {
    var WorldPos: vec3<f32>;

    let _e28 = (*ScreenUV);
    let _e29 = textureSample(gPositionTexture, gPositionTextureSampler, _e28);
    WorldPos = _e29.xyz;
    let _e31 = WorldPos;
    return _e31;
}

fn main_1() {
    var col: vec3<f32>;
    var alpha: f32;
    var ScreenUV_1: vec2<f32>;
    var worldPos: vec3<f32>;
    var param: vec2<f32>;
    var baseDir: vec3<f32>;
    var l2g: vec3<f32>;
    var l2g_norm: vec3<f32>;
    var coneAngle: f32;
    var l2g_angle: f32;
    var height: f32;
    var len: f32;

    let _e39 = l_ubo.color;
    let _e42 = l_ubo.intensity;
    col = (_e39.xyz * _e42);
    let _e46 = l_ubo.color[3u];
    alpha = _e46;
    let _e47 = alpha;
    alpha = min(0.2f, _e47);
    let _e49 = v2f_ProjPos_1;
    let _e52 = v2f_ProjPos_1[3u];
    ScreenUV_1 = (_e49.xy / vec2(_e52));
    let _e55 = ScreenUV_1;
    ScreenUV_1 = ((_e55 * 0.5f) + vec2(0.5f));
    let _e59 = ScreenUV_1;
    param = _e59;
    let _e60 = GetWorldPos_u0028_vf2_u003b((&param));
    worldPos = _e60;
    let _e62 = l_ubo.dir;
    baseDir = normalize(_e62.xyz);
    let _e65 = worldPos;
    let _e67 = l_ubo.pos;
    l2g = (_e65 - _e67.xyz);
    let _e70 = l2g;
    l2g_norm = normalize(_e70);
    let _e73 = l_ubo.angle;
    coneAngle = radians(_e73);
    let _e75 = baseDir;
    let _e76 = l2g_norm;
    l2g_angle = acos(dot(_e75, _e76));
    let _e79 = l2g_angle;
    let _e80 = coneAngle;
    let _e82 = coneAngle;
    let _e84 = alpha;
    alpha = (_e84 * (clamp(_e79, 0f, _e80) / _e82));
    let _e87 = l_ubo.height;
    height = _e87;
    let _e88 = l2g;
    let _e90 = l2g_angle;
    len = (length(_e88) * cos(_e90));
    let _e93 = len;
    let _e94 = height;
    let _e96 = height;
    let _e99 = alpha;
    alpha = (_e99 * (1f - (clamp(_e93, 0f, _e94) / _e96)));
    let _e101 = col;
    let _e102 = alpha;
    outColor = vec4<f32>(_e101.x, _e101.y, _e101.z, _e102);
    return;
}

@fragment 
fn main(@location(1) v2f_ProjPos: vec4<f32>, @location(0) v2f_UV: vec2<f32>, @location(2) v2f_WorldPos: vec4<f32>) -> @location(0) vec4<f32> {
    v2f_ProjPos_1 = v2f_ProjPos;
    v2f_UV_1 = v2f_UV;
    v2f_WorldPos_1 = v2f_WorldPos;
    main_1();
    let _e7 = outColor;
    return _e7;
}
