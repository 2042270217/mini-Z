Shader "XinY/CommonToon"
{
    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" { }
        _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
        _LightMap ("LightMap", 2D) = "white" { }
        _ShadowRamp ("ShadowRamp", 2D) = "white" { }
        _SpecSize ("SpecSize", Range(0, 1)) = 1
        _NonMetaSpecIntensity ("SpecIntensity", Range(0, 1)) = 0.1
        _MetaSpecIntensity ("SpecIntensity", Range(0, 1)) = 0.9
        _MetaReflect ("MetaReflect", 2D) = "black" { }
        _EdgeOffset ("EdgeOffset", Range(0, 1)) = 0.05
        _EdgeThreshold ("EdgeThreshold", Range(0, 3)) = 0.1
        _EdgeIntensity ("EdgeIntensity", Range(0, 1)) = 1
        [HDR]_EmissColor ("EmissColor", Color) = (0, 0, 0, 0)
        [Toggle(LIGHTMAP_R)]_LIGHTMAP_R ("LightMap_R", int) = 0
        [Toggle(LIGHTMAP_G)]_LIGHTMAP_G ("LightMap_G", int) = 0
        [Toggle(LIGHTMAP_B)]_LIGHTMAP_B ("LightMap_B", int) = 0
        [Toggle(LIGHTMAP_A)]_LIGHTMAP_A ("LightMap_A", int) = 0
        [Toggle(USE_OUTLINE)]_USE_OUTLINE ("Use Outline", int) = 0
        _OutlineWidth ("OutlineWidth", Range(0, 1)) = 1
        _Test ("Test", Range(-1, 2)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "CommonToon"
            Tags { "LightMode" = "UniversalForward" }
            Cull Off
            ZWrite On
            ZTest LEqual
            HLSLPROGRAM
            #pragma shader_feature _ LIGHTMAP_R LIGHTMAP_G LIGHTMAP_B LIGHTMAP_A

            #include "./ToonLitInput.hlsl"
            #include "./ToonLitPass.hlsl"
            
            #pragma vertex ToonLitVert
            #pragma fragment ToonLitFrag
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front
            ZTest LEqual
            ZWrite On
            HLSLPROGRAM
            #pragma shader_feature _ USE_OUTLINE
            #include "./ToonLitInput.hlsl"
            #include "./OutlinePass.hlsl"
            #pragma vertex ToonOutlineVert
            #pragma fragment ToonOutlineFrag

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            HLSLPROGRAM
            #include "./ToonLitInput.hlsl"
            #include "./ShadowCasterPass.hlsl"
            #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma vertex ShadowCasterVert
            #pragma fragment ShadowCasterFrag
            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull Off

            HLSLPROGRAM
            #pragma shader_feature _ USE_OUTLINE
            #include "./ToonLitInput.hlsl"
            #include "./DepthPass.hlsl"
            #pragma vertex DepthVert
            #pragma fragment DepthFrag


            ENDHLSL
        }
    }
}
