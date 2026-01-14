struct FragUniformBufferObject {
    lightDir: vec4<f32>,
    lightColor: vec4<f32>,
    cameraPos: vec4<f32>,
    diffuseFactor: vec4<f32>,
    ambientFactor: vec4<f32>,
    specularFactor: vec4<f32>,
    edgeColor: vec4<f32>,
    specularIntensity: f32,
    f_pad0_: f32,
    f_pad1_: f32,
    f_pad2_: f32,
    UseMainTexture: i32,
    UseToonTexture: i32,
    UseSphereTexture: i32,
    SphereMode: i32,
    mPad0_: mat4x4<f32>,
    mPad1_: mat4x4<f32>,
    mPad2_: mat4x4<f32>,
    mPad3_: mat4x4<f32>,
}

var<private> f_WorldNormal_1: vec3<f32>;
@group(0) @binding(2) 
var<uniform> fragUbo: FragUniformBufferObject;
var<private> f_WorldPos_1: vec4<f32>;
@group(0) @binding(3) 
var MainTexture: texture_2d<f32>;
@group(0) @binding(4) 
var MainTextureSampler: sampler;
var<private> f_Texcoord_1: vec2<f32>;
@group(0) @binding(7) 
var SphereTexture: texture_2d<f32>;
@group(0) @binding(8) 
var SphereTextureSampler: sampler;
var<private> f_SphereUV_1: vec2<f32>;
@group(0) @binding(5) 
var ToonTexture: texture_2d<f32>;
@group(0) @binding(6) 
var ToonTextureSampler: sampler;
var<private> outColor: vec4<f32>;
var<private> f_WorldTangent_1: vec3<f32>;
var<private> f_WorldBioTangent_1: vec3<f32>;
var<private> f_LightSpacePos_1: vec4<f32>;

fn main_1() {
    var col: vec3<f32>;
    var alpha: f32;
    var NdotL: f32;
    var v: vec3<f32>;
    var l: vec3<f32>;
    var HalfVector: vec3<f32>;
    var diffuseColor: vec4<f32>;
    var MainColor: vec4<f32>;
    var SphereColor: vec3<f32>;
    var ToonColor: vec3<f32>;
    var specularColor: vec3<f32>;

    col = vec3<f32>(1f, 1f, 1f);
    alpha = 1f;
    let _e47 = f_WorldNormal_1;
    let _e49 = fragUbo.lightDir;
    NdotL = max(0f, dot(_e47, -(_e49.xyz)));
    let _e55 = fragUbo.cameraPos;
    let _e57 = f_WorldPos_1;
    v = normalize((_e55.xyz - _e57.xyz));
    let _e62 = fragUbo.lightDir;
    l = (_e62.xyz * -1f);
    let _e65 = v;
    let _e66 = l;
    HalfVector = normalize((_e65 + _e66));
    let _e70 = fragUbo.diffuseFactor;
    diffuseColor = _e70;
    let _e72 = fragUbo.UseToonTexture;
    if (_e72 == 0i) {
        let _e75 = fragUbo.ambientFactor;
        let _e77 = diffuseColor;
        let _e79 = (_e77.xyz + _e75.xyz);
        diffuseColor[0u] = _e79.x;
        diffuseColor[1u] = _e79.y;
        diffuseColor[2u] = _e79.z;
    }
    let _e86 = diffuseColor;
    diffuseColor = clamp(_e86, vec4(0f), vec4(1f));
    let _e91 = fragUbo.UseMainTexture;
    if (_e91 != 0i) {
        let _e93 = f_Texcoord_1;
        let _e94 = textureSample(MainTexture, MainTextureSampler, _e93);
        MainColor = _e94;
        let _e95 = MainColor;
        let _e96 = diffuseColor;
        diffuseColor = (_e96 * _e95);
    }
    let _e98 = diffuseColor;
    col = _e98.xyz;
    let _e101 = diffuseColor[3u];
    alpha = _e101;
    let _e103 = fragUbo.UseSphereTexture;
    if (_e103 != 0i) {
        let _e105 = f_SphereUV_1;
        let _e106 = textureSample(SphereTexture, SphereTextureSampler, _e105);
        SphereColor = _e106.xyz;
        let _e109 = fragUbo.SphereMode;
        if (_e109 == 1i) {
            let _e111 = SphereColor;
            let _e112 = col;
            col = (_e112 * _e111);
        } else {
            let _e115 = fragUbo.SphereMode;
            if (_e115 == 2i) {
                let _e117 = SphereColor;
                let _e118 = col;
                col = (_e118 + _e117);
            }
        }
    }
    let _e121 = fragUbo.UseToonTexture;
    if (_e121 != 0i) {
        let _e123 = NdotL;
        let _e125 = textureSample(ToonTexture, ToonTextureSampler, vec2<f32>(0f, _e123));
        ToonColor = _e125.xyz;
        let _e127 = ToonColor;
        let _e128 = NdotL;
        let _e134 = col;
        col = (_e134 * mix(_e127, vec3<f32>(1f, 1f, 1f), vec3(clamp(((_e128 * 16f) + 0.5f), 0f, 1f))));
    }
    let _e137 = fragUbo.specularIntensity;
    if (_e137 > 0f) {
        let _e140 = fragUbo.specularFactor;
        let _e142 = HalfVector;
        let _e143 = f_WorldNormal_1;
        let _e147 = fragUbo.specularIntensity;
        specularColor = (_e140.xyz * pow(max(0f, dot(_e142, _e143)), _e147));
        let _e150 = specularColor;
        let _e151 = col;
        col = (_e151 + _e150);
    }
    let _e153 = col;
    let _e154 = alpha;
    outColor = vec4<f32>(_e153.x, _e153.y, _e153.z, _e154);
    return;
}

@fragment 
fn main(@location(0) f_WorldNormal: vec3<f32>, @location(2) f_WorldPos: vec4<f32>, @location(1) f_Texcoord: vec2<f32>, @location(6) f_SphereUV: vec2<f32>, @location(3) f_WorldTangent: vec3<f32>, @location(4) f_WorldBioTangent: vec3<f32>, @location(5) f_LightSpacePos: vec4<f32>) -> @location(0) vec4<f32> {
    f_WorldNormal_1 = f_WorldNormal;
    f_WorldPos_1 = f_WorldPos;
    f_Texcoord_1 = f_Texcoord;
    f_SphereUV_1 = f_SphereUV;
    f_WorldTangent_1 = f_WorldTangent;
    f_WorldBioTangent_1 = f_WorldBioTangent;
    f_LightSpacePos_1 = f_LightSpacePos;
    main_1();
    let _e15 = outColor;
    return _e15;
}
