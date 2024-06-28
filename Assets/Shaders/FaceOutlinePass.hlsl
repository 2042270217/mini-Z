#ifndef FACE_OUTLINE_PASS_INLCUDE
#define FACE_OUTLINE_PASS_INLCUDE

#include "./FaceOutlinePass.hlsl"


v2f ToonFaceOutlineVert(appdata input)
{
    v2f output = (v2f)0;
    #ifdef USE_OUTLINE
        float3 normalCS = TransformWorldToHClipDir(TransformObjectToWorldNormal(input.normalOS));
        output.uv = input.texcoord;
        output.positionCS = TransformObjectToHClip(input.positionOS);
        float w = clamp(output.positionCS.w, 0, 0.8);
        output.positionCS.xy += normalCS.xy * 0.01 * _OutlineWidth * w;
    #else
        output.positionCS = TransformObjectToHClip(input.positionOS);
    #endif
    return output;
}

float4 ToonFaceOutlineFrag(v2f input) : SV_TARGET
{
    #ifdef USE_OUTLINE
        float3 shadowRamp = _ShadowColor;
        return float4(shadowRamp * 0.1, 1);
    #else
        return 0;
    #endif
}

#endif