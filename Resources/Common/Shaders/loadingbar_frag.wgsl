struct UniformBufferObject {
    rate: f32,
    time: f32,
    alpha: f32,
    pad: f32,
}

var<private> fragTexCoord_1: vec2<f32>;
@group(0) @binding(0) 
var<uniform> ubo: UniformBufferObject;
var<private> outColor: vec4<f32>;

fn main_1() {
    var uv: vec2<f32>;
    var st: vec2<f32>;
    var pad: vec2<f32>;
    var col: vec3<f32>;
    var w: f32;
    var phi_54_: bool;
    var phi_61_: bool;
    var phi_67_: bool;

    let _e27 = fragTexCoord_1;
    uv = _e27;
    let _e28 = fragTexCoord_1;
    st = ((_e28 * 2f) - vec2(1f));
    pad = vec2<f32>(0.2f, 0.48f);
    let _e32 = uv;
    let _e33 = pad;
    let _e35 = pad;
    let _e40 = (vec2(1f) / (vec2(1f) - (_e35 * 2f)));
    uv = ((_e32 - _e33) * vec2<f32>(_e40.x, _e40.y));
    col = vec3<f32>(0f, 0f, 0f);
    let _e46 = uv[0u];
    let _e47 = (_e46 >= 0f);
    phi_54_ = _e47;
    if _e47 {
        let _e49 = uv[0u];
        phi_54_ = (_e49 <= 1f);
    }
    let _e52 = phi_54_;
    phi_61_ = _e52;
    if _e52 {
        let _e54 = uv[1u];
        phi_61_ = (_e54 >= 0f);
    }
    let _e57 = phi_61_;
    phi_67_ = _e57;
    if _e57 {
        let _e59 = uv[1u];
        phi_67_ = (_e59 <= 1f);
    }
    let _e62 = phi_67_;
    if _e62 {
        let _e64 = uv[0u];
        let _e66 = ubo.rate;
        if (_e64 <= _e66) {
            let _e69 = uv[0u];
            col = mix(vec3<f32>(0.1f, 0.1f, 0.1f), vec3<f32>(1f, 1f, 1f), vec3(_e69));
        } else {
            col = vec3<f32>(0.1f, 0.1f, 0.1f);
        }
    } else {
        w = 0.04f;
        let _e72 = st;
        let _e74 = w;
        let _e77 = w;
        if (length(max(vec2<f32>(0f, 0f), (abs(_e72) - vec2<f32>((0.5f + (_e74 * 2.35f)), _e77)))) <= 0.01f) {
            let _e83 = col;
            col = (_e83 + vec3<f32>(1f, 1f, 1f));
        }
    }
    let _e85 = col;
    let _e87 = ubo.alpha;
    outColor = vec4<f32>(_e85.x, _e85.y, _e85.z, _e87);
    return;
}

@fragment 
fn main(@location(0) fragTexCoord: vec2<f32>) -> @location(0) vec4<f32> {
    fragTexCoord_1 = fragTexCoord;
    main_1();
    let _e3 = outColor;
    return _e3;
}
