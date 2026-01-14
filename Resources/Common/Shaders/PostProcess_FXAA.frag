#version 450

layout(location = 0) in vec2 v2f_UV;
layout(location = 1) in vec4 v2f_ProjPos;
layout(location = 2) in vec4 v2f_WorldPos;

layout(location = 0) out vec4 outColor;

#ifdef USE_OPENGL
layout(binding = 0) uniform sampler2D texImage;
#else
layout(binding = 0) uniform texture2D texImage;
layout(binding = 1) uniform sampler texSampler;
#endif

layout(binding = 2) uniform FragUniformBuffer
{
	mat4 mPad0;
	mat4 mPad1;
	mat4 mPad2;
	mat4 mPad3;

	vec2 texelSize;
    float fPad0;
    float fPad1;
} frag_ubo;

vec4 GetTexColor(vec2 texcoord)
{
	vec4 col = vec4(0.0);

	#ifdef USE_OPENGL
	col = texture(texImage, texcoord);
	#else
	col = texture(sampler2D(texImage, texSampler), texcoord);
	#endif

	return col;
}

void main()
{
    vec2 pos = v2f_UV;

    // 1. 中心と上下左右の輝度を取得 /////////////////////////////////////////////////////////////////////////////////////
    // サンプリングするチャンネルはどれでもいいが、人間が最も敏感なGチャンネルを使う
    float lumaMiddle = GetTexColor(pos).g;
    float lumaUp = GetTexColor(pos + vec2(0.0, frag_ubo.texelSize.y)).g;
    float lumaDown = GetTexColor(pos - vec2(0.0, frag_ubo.texelSize.y)).g;
    float lumaLeft = GetTexColor(pos - vec2(frag_ubo.texelSize.x, 0.0)).g;
    float lumaRight = GetTexColor(pos + vec2(frag_ubo.texelSize.x, 0.0)).g;

    // 2. エッジ検出(コントラスト計算 → つまり、輝度差の計算) ////////////////////////////////////////////////////////////
    float maxLuma = max(max(lumaUp, lumaDown), max(lumaLeft, lumaRight));
    float minLuma = min(min(lumaUp, lumaDown), min(lumaLeft, lumaRight));
    float contrast = maxLuma - minLuma;

    // 3. エッジ判定。エッジ(境界線)とは色の急激な変化が起こる場所なのでコントラストが閾値以上ならエッジと判定 ////////////////
    float edgeThreshold = 0.0166; // エッジの閾値
    if (contrast < edgeThreshold)
    {
        // エッジではない場合は、元の色をそのまま出力
        outColor = GetTexColor(pos);
        // outColor = vec4(0.0);
        return;
    }

    // 4. エッジの方向を判定(水平な線か垂直な線か) //////////////////////////////////////////////////////////////////////
    // 例えば水平判定の場合、上下は似た値で中心だけ違う値となり、計算結果が大きくなるので水平となる
    // 上: 明るい → 輝度:100
    // 中: エッジ(境界) → 輝度: 25
    // 下: 明るい → 輝度:100
    // 式に沿って輝度差を計算すると、100 + 100 - 2 * 25 = 150となり、明るい部分と暗い部分の差が大きくなる
    float horizontal = abs(lumaUp + lumaDown - 2.0 * lumaMiddle);
    float vertical = abs(lumaLeft + lumaRight - 2.0 * lumaMiddle);

    // 水平と垂直で大きい方を方向と判定する
    bool isHorizontal = horizontal > vertical;

    // 5. エッジに垂直な方向にサンプリングしてブレンドする //////////////////////////////////////////////////////////////
    vec2 offset = isHorizontal ? vec2(0.0, frag_ubo.texelSize.y) : vec2(frag_ubo.texelSize.x, 0.0);

    // 簡易的なブレンド
    vec3 colA = GetTexColor(pos - offset).rgb;
    vec3 colB = GetTexColor(pos + offset).rgb;
    vec3 blendedColor = (colA + colB) * 0.5;

    outColor = vec4(blendedColor, 1.0);
    // outColor = vec4(1.0);
}