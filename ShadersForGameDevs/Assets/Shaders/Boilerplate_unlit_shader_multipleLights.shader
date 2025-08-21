Shader "Unlit/Boilerplate_unlit_shader_multipleLights"
{
    Properties // input data
    {
       [NoScaleOffset]  _MainTex ("Texture", 2D) = "white" {}
        _Gloss("Gloss", Range(0,1)) = 1
        _Color("Color", Color) = (0, 0, 0, 1)
        
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        // base pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "FGLighting_shader.cginc"
            ENDCG
        }
        // add pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "FGLighting_shader.cginc"
            ENDCG
        }
    }
}