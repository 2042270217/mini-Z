#ifndef TOON_FACE_LIT_PASS_INCLUDE
#define TOON_FACE_LIT_PASS_INCLUDE

#include "./ToonFaceLitInput.hlsl"

v2f ToonFaceLitVert(appdata input)
{
    v2f output = (v2f)0;
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.uv = input.texcoord;
    return output;
}

float4 ToonFaceLitFrag(v2f input) : SV_TARGET
{
    float3 baseColor = SampleBaseMap(input.uv);

    float4 shadowcrood = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowcrood);

    float3 L = mainLight.direction;
    float3 sdfUV = GetSDFShadowData(L, _ForwardVec, _RightVec, input.uv);
    float sdfValue = SampleSDF(sdfUV.xy);
    float sdfShadow = step(sdfUV.z, sdfValue);

    float4 lightMap = SampleLightMap(input.uv);
    
    sdfShadow = lerp(sdfShadow, 1, lightMap.a);

    float4 final = float4(lerp(_ShadowColor.xyz * baseColor, baseColor.xyz, sdfShadow), 1);

    return final;
}

#endif