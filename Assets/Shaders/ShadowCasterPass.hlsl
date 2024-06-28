#ifndef SHADOW_CASTER_PASS_INCLUDE
#define SHADOW_CASTER_PASS_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float3 _LightDirection;
float3 _LightPosition;

v2f ShadowCasterVert(appdata v)
{
    v2f output = (v2f)0;

    output.uv = v.texcoord;
    float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(v.normalOS);

    //pragma这个变体，然后聚光灯开启阴影这个变体就会自动启动
    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
        float3 lightDirectionWS = normalize(_LightPosition - positionWS);
    #else
        float3 lightDirectionWS = _LightDirection;
    #endif

    output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

    #if UNITY_REVERSED_Z
        output.positionCS.z = min(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #else
        output.positionCS.z = max(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #endif
    return output;
}
half4 ShadowCasterFrag(v2f i) : SV_TARGET
{
    return 0;
}

#endif