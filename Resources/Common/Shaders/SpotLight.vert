#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inTexcoord;
layout(location = 3) in vec4 inTangent;
layout(location = 4) in uvec4 inBone0;
layout(location = 5) in vec4 inWeights0;

layout(location = 0) out vec2 v2f_UV;
layout(location = 1) out vec4 v2f_ProjPos;
layout(location = 2) out vec4 v2f_WorldPos;

layout(binding = 0) uniform VertUniformBuffer{
	mat4 model;
    mat4 view;
    mat4 proj;
    mat4 lightVPMat;

    float angle; // 初期値: 45° (0.0 ~ 89.0の間の値しか取れない)
    float height; // 初期値: 1.0
    float pan;
    float tilt;
} v_ubo;

#define rot(a) mat2(cos(a), sin(a), -sin(a), cos(a))

void main()
{
    vec4 pos = vec4(inPosition, 1.0);
    
    // スポットライトの初期値は下を向かせたい
    pos.y *= -1.0;

    // 高さの割合
    // 円柱はプリミティブ作成段階で高さ１・半径１の想定
    // この時、円柱の上端を半径0にしぼり、下端は半径1のままにしてそれを2Dで考えると・・・
    // 高さ1、底面1、角度が45・45・90の二等辺三角形が初期値としてできる
    // 高さとスポットライトの半分の角度がUniformとしてわかっているのでこれらの情報を使って正弦定理を解くことで、スポットライトの形を作るための拡大率を求めることができる
    float HeightRate = abs(pos.y) / 1.0;

    float angle = radians(v_ubo.angle);
    float subAngle = 3.1415 * 0.5 - angle;
    float height = v_ubo.height;

    // XZ方向の拡大率
    // 正弦定理より => A / sin(a) = B / sin(b) = C / sin(c)
    float XZExpandRate = (height / sin(subAngle)) * sin(angle);

    // Y方向の拡大率
    float YExpandRate = height / 1.0;

    // ライトのエミッタのサイズにスポットライトの初めの形を合わせる
    float realRadius = 0.35;
    float XZScale = mix(realRadius, XZExpandRate, HeightRate);

    float YScale = YExpandRate;

    // ライトの変形
    vec3 DeformedScale = vec3(XZScale, YScale, XZScale);

    pos *= mat4(
        DeformedScale.x, 0.0, 0.0, 0.0,
        0.0, DeformedScale.y, 0.0, 0.0,
        0.0, 0.0, DeformedScale.z, 0.0,
        0.0, 0.0, 0.0, 1.0
    );

    pos.yz *= rot(v_ubo.pan); // X軸回転
    pos.xz *= rot(v_ubo.tilt); // Y軸回転

    //
	vec4 ProjPos = v_ubo.proj * v_ubo.view * v_ubo.model * pos;

	gl_Position = ProjPos;
	v2f_UV = inTexcoord;
	v2f_ProjPos = ProjPos;
    v2f_WorldPos = v_ubo.model * pos;
}