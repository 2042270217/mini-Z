#ifndef TOON_FACE_LIT_INPUT_INCLUDE
#define TOON_FACE_LIT_INPUT_INCLUDE

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
    float3 positionWS : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float2 uv : TEXCOORD2;
};

CBUFFER_START(UnityPerMaterial)
    float4 _BaseColor;
    float _Test;
    float3 _ForwardVec;
    float3 _RightVec;
    float3 _ShadowColor;
    float3 _FaceToon;
    float _OutlineWidth;
CBUFFER_END
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_SDF);
SAMPLER(sampler_SDF);
TEXTURE2D(_LightMap);
SAMPLER(sampler_LightMap);

float3 SampleBaseMap(float2 uv)
{
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    return lerp(baseMap.rgb, baseMap.rgb * _FaceToon.rgb, baseMap.a) * _BaseColor.rgb;
}

float SampleSDF(float2 uv)
{
    return SAMPLE_TEXTURE2D(_SDF, sampler_SDF, uv).r;
}

float4 SampleLightMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, uv);
}
#endif