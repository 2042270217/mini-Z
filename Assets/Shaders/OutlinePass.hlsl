#ifndef OUTLINE_PASS_INCLUDE
#define OUTLINE_PASS_INCLUDE

#include "./ToonLitInput.hlsl"
#include "./Include/XinY_NPRInclude.hlsl"

v2f ToonOutlineVert(appdata input)
{
    v2f output = (v2f)0;
    #ifdef USE_OUTLINE
        float3 normalCS = TransformWorldToHClipDir(TransformObjectToWorldNormal(input.normalOS));
        // output.positionWS = TransformObjectToWorld(input.positionOS) + output.normalWS * 0.002 * _OutlineWidth;
        output.uv = input.texcoord;
        output.positionCS = TransformObjectToHClip(input.positionOS);
        float w = clamp(output.positionCS.w, 0, 0.8);
        output.positionCS.xy += normalCS.xy * 0.01 * _OutlineWidth * w;
    #else
        output.positionCS = TransformObjectToHClip(input.positionOS);
    #endif
    return output;
}

float4 ToonOutlineFrag(v2f input) : SV_TARGET
{
    #ifdef USE_OUTLINE
        Light mainLight = GetMainLight();
        float isDay = lerp(0, 1, mainLight.direction.y);
        LightMap lightMap = SampleLightMap(input.uv);
        float2 rampUV = GetShadowRampUV(lightMap.matId, 0, isDay, 0);
        float3 shadowRamp = SampleShadowRamp(rampUV);
        return float4(shadowRamp * 0.1, 1);
    #else
        return 0;
    #endif
}

#endif