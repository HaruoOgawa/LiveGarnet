var<private> fragPos_1: vec4<f32>;
var<private> outColor: vec4<f32>;

fn main_1() {
    var depth: f32;
    var moment1_: f32;
    var moment2_: f32;
    var dx: f32;
    var dy: f32;

    let _e14 = fragPos_1[2u];
    let _e16 = fragPos_1[3u];
    depth = (_e14 / _e16);
    let _e18 = depth;
    depth = ((_e18 * 0.5f) + 0.5f);
    let _e21 = depth;
    moment1_ = _e21;
    let _e22 = depth;
    let _e23 = depth;
    moment2_ = (_e22 * _e23);
    let _e25 = depth;
    let _e26 = dpdx(_e25);
    dx = _e26;
    let _e27 = depth;
    let _e28 = dpdy(_e27);
    dy = _e28;
    let _e29 = dx;
    let _e30 = dx;
    let _e32 = dy;
    let _e33 = dy;
    let _e37 = moment2_;
    moment2_ = (_e37 + (0.25f * ((_e29 * _e30) + (_e32 * _e33))));
    let _e39 = moment1_;
    let _e40 = moment2_;
    outColor = vec4<f32>(_e39, _e40, 0f, 1f);
    return;
}

@fragment 
fn main(@location(0) fragPos: vec4<f32>) -> @location(0) vec4<f32> {
    fragPos_1 = fragPos;
    main_1();
    let _e3 = outColor;
    return _e3;
}
