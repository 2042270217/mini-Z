Shader "XinY/FaceToon"
{
    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" { }
        _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
        _FaceToon("FaceToon",Color)=(1,1,1,1)
        _SDF ("SDF", 2D) = "white" { }
        _ShadowColor ("ShadowColor", Color) = (0, 0, 0, 0)
        _LightMap ("LightMap", 2D) = "white" { }
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

            #include "./ToonFaceLitInput.hlsl"
            #include "./ToonFaceLitPass.hlsl"
            
            #pragma vertex ToonFaceLitVert
            #pragma fragment ToonFaceLitFrag
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
            #include "./ToonFaceLitInput.hlsl"
            #include "./FaceOutlinePass.hlsl"
            #pragma vertex ToonFaceOutlineVert
            #pragma fragment ToonFaceOutlineFrag

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
