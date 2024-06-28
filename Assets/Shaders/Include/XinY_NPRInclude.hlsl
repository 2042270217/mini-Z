#ifndef XINY_NPR_INCLUDE
#define XINY_NPR_INCLUDE

#define MAT_LATYER1 0.2
#define MAT_LATYER2 0.4
#define MAT_LATYER3 0.6
#define MAT_LATYER4 0.8
#define MAT_LATYER5 1

TEXTURE2D(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);

struct NPR_LightPreData
{
    float NdotL;
    float NdotV;
    float halfLambert;
    float blinnPhong;
    float2 matcapUV;
    float2 screenUV;
    float3 normalVS;
};

struct NPR_SurfaceOutput
{
    float3 diffuse;
    float3 specular;
    float3 emission;
    float edge;
};

struct LightMap
{
    float specIntensity;
    float shadowTpye;
    float specShape;
    float matId;
};



float GrayscaleSelect(float input, float target, float selectRange)
{
    return step(abs(input - target), selectRange);
}

float NormalizeLambert(float NdotL)
{
    return NdotL * 0.5 + 0.5;
}

float HalfLambert(float NdotL)
{
    float NdotL01 = NormalizeLambert(NdotL);
    return NdotL01 * NdotL01;
}

NPR_LightPreData GetLightPreData(float3 N, float3 L, float2 positionCS, float3 positionWS)
{
    NPR_LightPreData lightData = (NPR_LightPreData)0;
    lightData.NdotL = saturate(dot(N, L));
    float3 V = normalize(_WorldSpaceCameraPos - positionWS);
    lightData.NdotV = saturate(dot(N, V));
    float3 H = normalize(L + V);
    lightData.normalVS = TransformWorldToViewDir(N);
    lightData.matcapUV = lightData.normalVS.xy * 0.5 + 0.5;
    lightData.halfLambert = HalfLambert(lightData.NdotL);
    lightData.blinnPhong = saturate(dot(N, H));
    lightData.screenUV = positionCS.xy / _ScreenParams.xy;
    return lightData;
}

float2 GetShadowRampUV(float matId, float shadowType, float isDay, float halfLambert)
{
    float shadowRampNightV = lerp(0.15, 0.05, step(matId, MAT_LATYER1));
    shadowRampNightV = lerp(0.25, 0.15, step(matId, MAT_LATYER2));
    shadowRampNightV = lerp(0.35, 0.25, step(matId, MAT_LATYER3));
    shadowRampNightV = lerp(0.45, 0.35, step(matId, MAT_LATYER4));
    float shadowRampDayV = shadowRampNightV + 0.5;
    float shadowRampV = lerp(shadowRampNightV, shadowRampDayV, isDay);

    float rampClampMin = 0.04;
    float rampClampMax = 0.96;

    float shadowRampU = clamp(smoothstep(0.2, 0.4, halfLambert), rampClampMin, rampClampMax);
    shadowRampU = lerp(shadowRampU, rampClampMin, step(shadowType, 0.1));
    shadowRampU = lerp(rampClampMax, shadowRampU, step(shadowType, 0.9));
    float2 rampUV = float2(shadowRampU, shadowRampV);
    return rampUV;
}

float2 GetShadowRampUV(LightMap lightMap, float isDay, float halfLambert)
{
    return GetShadowRampUV(lightMap.matId, lightMap.shadowTpye, isDay, halfLambert);
}

float3 GetSpecular(LightMap lightMap, float halfLambert, float blinnPhong, float specSize, float NonKs, float Ks, float metaRef, float3 baseColor)
{
    float stepLambert = smoothstep(0.3, 0.4, halfLambert);
    float3 nonMetaSpec = step(1.04 - blinnPhong, lightMap.specShape * specSize) * NonKs * lightMap.specIntensity;
    float3 metaSpec = step(1.04 - blinnPhong, lightMap.specShape * specSize) * Ks * baseColor;
    float3 spec = lerp(nonMetaSpec, metaSpec, lightMap.specIntensity) * stepLambert;
    float isMetal = step(0.9, lightMap.specIntensity);
    spec = lerp(spec, spec + metaRef, isMetal);
    return spec;
}

float3 GetSpecular(LightMap lightMap, NPR_LightPreData lightData, float specSize, float NonKs, float Ks, float metaRef, float3 baseColor)
{
    return GetSpecular(lightMap, lightData.halfLambert, lightData.blinnPhong, specSize, NonKs, Ks, metaRef, baseColor);
}

float DepthBasedEdge(float2 screenUV, float3 normalVS, float NdotV, float edgeOffset, float edgeThreshold)
{
    float depth = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).x, _ZBufferParams);
    float offset = (normalVS.x > 0 ? 1 : - 1) * 50 * edgeOffset * (_ScreenParams.z - 1);
    float offsetDepth = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, float2(screenUV.x + offset, screenUV.y)).x, _ZBufferParams);
    float edge = step(edgeThreshold, offsetDepth - depth);
    float edgeFresnel = pow(1 - NdotV, 3);
    edge *= edgeFresnel;
    return edge;
}

float DepthBasedEdge(NPR_LightPreData lightData, float edgeOffset, float edgeThreshold)
{
    return DepthBasedEdge(lightData.screenUV, lightData.normalVS, lightData.NdotV, edgeOffset, edgeThreshold);
}

float3 GetSDFShadowData(float3 L, float3 forwardVec, float3 rightVec, float2 uv)
{
    float3 upVec = cross(forwardVec, rightVec);
    float3 LprojUp = dot(upVec, L) * upVec;
    float3 L_PS = normalize(L - LprojUp);

    float LdotR = dot(L_PS, rightVec);
    float LdotF = dot(L_PS, forwardVec);

    float sdfThreshold = abs(LdotR) * 0.5;

    float reverseU = lerp(1, 0, step(LdotR, 0));
    float isBack = lerp(0, 1, step(LdotF, 0));
    sdfThreshold = lerp(sdfThreshold, 1 - sdfThreshold, isBack);
    float2 sdfUV = uv;
    sdfUV.x = lerp(sdfUV.x, 1 - sdfUV.x, reverseU);
    return float3(sdfUV, sdfThreshold);
}

#endif