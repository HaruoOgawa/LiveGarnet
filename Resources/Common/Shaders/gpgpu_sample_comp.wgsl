struct TestData {
    offset: vec4<f32>,
    color: vec4<f32>,
    AccumulateDeltaTime: f32,
    pad0_: f32,
    pad1_: f32,
    pad2_: f32,
}

struct WriteOnlyTestBufferObject {
    data: array<TestData>,
}

struct ParamUBO {
    time: f32,
    deltaTime: f32,
    pad0_: f32,
    pad1_: f32,
}

struct ReadOnlyTestBufferObject {
    data: array<TestData>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(2) 
var<storage, read_write> w_TBO: WriteOnlyTestBufferObject;
@group(0) @binding(0) 
var<uniform> ubo: ParamUBO;
@group(0) @binding(1) 
var<storage> r_TBO: ReadOnlyTestBufferObject;

fn rand_u0028_vf2_u003b(st: ptr<function, vec2<f32>>) -> f32 {
    let _e21 = (*st);
    return fract((sin(dot(_e21, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn main_1() {
    var id: u32;
    var id_f: f32;
    var param: vec2<f32>;

    let _e24 = gl_GlobalInvocationID_1[0u];
    id = _e24;
    let _e25 = id;
    id_f = f32(_e25);
    let _e27 = id;
    let _e29 = ubo.deltaTime;
    let _e33 = w_TBO.data[_e27].AccumulateDeltaTime;
    w_TBO.data[_e27].AccumulateDeltaTime = (_e33 + _e29);
    let _e38 = id;
    let _e42 = w_TBO.data[_e38].AccumulateDeltaTime;
    if (_e42 >= 0.008333334f) {
        let _e44 = id;
        w_TBO.data[_e44].AccumulateDeltaTime = 0f;
        let _e48 = id;
        let _e50 = ubo.time;
        let _e51 = id_f;
        let _e52 = id_f;
        param = vec2<f32>(_e51, (_e52 + 12.394f));
        let _e55 = rand_u0028_vf2_u003b((&param));
        let _e64 = w_TBO.data[_e48].offset[1u];
        w_TBO.data[_e48].offset[1u] = (_e64 + (sin((_e50 + (_e55 * 10f))) * 0.1f));
    }
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
