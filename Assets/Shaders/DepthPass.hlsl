#ifndef DEPTH_PASS_INCLUDE
#define DEPTH_PASS_INCLUDE

v2f DepthVert(appdata input)
{
    v2f output = (v2f)0;

    output.positionCS = TransformObjectToHClip(input.positionOS);
    return output;
}
half4 DepthFrag(v2f i) : SV_TARGET
{
    return 0;
}

#endif