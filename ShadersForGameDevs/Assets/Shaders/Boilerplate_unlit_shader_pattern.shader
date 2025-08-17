Shader "Unlit/Boilerplate_unlit_shader_pattern"
{
    Properties // input data
    {
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TAU  6.283185307179586
            float4 _ColorA;
            float4 _ColorB;

            // automatically filled out by unity
            struct MeshData // per-vertex mesh data
            {
                float4 vertex : POSITION; // vertex position in local space
                float3 normals: NORMAL; // normal position in local space
                float4 tangent: TANGENT; // tangent direction xyz tangent sign (w)
                float4 color: COLOR; //vertex color
                float2 uv0 : TEXCOORD0; // uv0 diffuse/normal map textures
                float2 uv1 : TEXCOORD1; // uv1 coordinates lightmap coordinates
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION; // clip space position 
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = v.uv0;
                return o;
            }

            fixed4 frag(Interpolators i) : SV_Target
            {
                //float xOffset = i.uv.y; // swirl pattern
                float xOffset =  cos(i.uv.y * TAU *5) * 0.05; // zigzag pattern

                float t = cos((i.uv.xy+ xOffset) * TAU *7 + _Time.y) * 0.5 + 0.5;
                float4 lerpedColor = lerp(_ColorA, _ColorB, t);
                return lerpedColor;
            }
            ENDCG
        }
    }
}