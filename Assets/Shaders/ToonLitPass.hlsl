#ifndef TOON_LIT_PASS_INCLUDE
#define TOON_LIT_PASS_INCLUDE

#include "./ToonLitInput.hlsl"
#include "./Include/XinY_NPRInclude.hlsl"

v2f ToonLitVert(appdata input)
{
    v2f output;
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformWorldToHClip(output.positionWS);

    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.uv = input.texcoord;
    return output;
}

float4 ToonLitFrag(v2f input) : SV_TARGET
{
    NPR_SurfaceOutput output;

    float4 baseColor = SampleBaseMap(input.uv);
    LightMap lightMap = SampleLightMap(input.uv);
    #ifdef LIGHTMAP_R
        return lightMap.specIntensity;
    #elif defined LIGHTMAP_G
        return lightMap.shadowTpye;
    #elif defined LIGHTMAP_B
        return lightMap.specShape;
    #elif defined LIGHTMAP_A
        return lightMap.matId;
    #endif
    float4 shadowcrood = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowcrood);

    float3 L = normalize(mainLight.direction);
    float3 N = normalize(input.normalWS);

    NPR_LightPreData lightData = (NPR_LightPreData)0;
    lightData = GetLightPreData(N, L, input.positionCS.xy, input.positionWS);

    float isDay = lerp(0, 1, L.y);

    float2 rampUV = GetShadowRampUV(lightMap, isDay, lightData.halfLambert);
    float3 shadowRamp = SampleShadowRamp(rampUV);
    output.diffuse = shadowRamp * baseColor.xyz * mainLight.color;

    float metaRef = SampleMetaReflect(lightData.matcapUV);
    output.specular = GetSpecular(lightMap, lightData, _SpecSize, _NonMetaSpecIntensity, _MetaSpecIntensity, metaRef, baseColor.xyz);

    output.edge = DepthBasedEdge(lightData, _EdgeOffset, _EdgeThreshold);

    output.emission = baseColor.a * _EmissColor.xyz;
    float alpha = 1;

    float4 final = float4(output.diffuse + output.specular + output.edge * _EdgeIntensity + output.emission, alpha);

    return final;
}

#endif