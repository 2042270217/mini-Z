#ifndef TOON_LIT_INPUT_INCLUDE
#define TOON_LIT_INPUT_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "./Include/XinY_NPRInclude.hlsl"

struct appdata
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord : TEXCOORD0;
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float3 normalWS : TEXCOORD0;
    float2 uv : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
};

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _Test;
    float _SpecSize;
    float _NonMetaSpecIntensity;
    float _MetaSpecIntensity;
    float _EdgeOffset;
    float _EdgeThreshold;
    float _EdgeIntensity;
    float4 _EmissColor;
    float _OutlineWidth;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_LightMap);
SAMPLER(sampler_LightMap);
TEXTURE2D(_ShadowRamp);
SAMPLER(sampler_ShadowRamp);
TEXTURE2D(_MetaReflect);
SAMPLER(sampler_MetaReflect);




float4 SampleBaseMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv) * _BaseColor;
}

LightMap SampleLightMap(float2 uv)
{
    LightMap lim;
    float4 output = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, uv);
    lim.specIntensity = output.r;
    lim.shadowTpye = output.g;
    lim.specShape = output.b;
    lim.matId = output.a;
    return lim;
}

float3 SampleShadowRamp(float2 uv)
{
    return SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, uv).xyz;
}

float SampleMetaReflect(float2 uv)
{
    return SAMPLE_TEXTURE2D(_MetaReflect, sampler_MetaReflect, uv).r;
}


#endif