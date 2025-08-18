Shader "Unlit/Boilerplate_unlit_shader"
{
    Properties // input data
    {
        _Tex1 ("Texture", 2D) = "white" {}
        _Tex2 ("Texture", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
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
            sampler2D _Tex1;
            float4  _Tex1_ST; // scale offset of the texture
            sampler2D _Tex2;
            float4  _Tex2_ST; // scale offset of the texture
            sampler _Pattern;

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
                float4 vertex : SV_POSITION; // clip space position 
                float2 uv : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.worldPosition = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1)); // transformation from world space to local space - object to world
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = v.uv0;
                return o;
            }
            

            fixed4 frag(Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPosition.xz;
                // sample the texture
                float4 tex1 = tex2D(_Tex1, topDownProjection);
                float4 tex2 = tex2D(_Tex2, topDownProjection);
                float4 pattern = tex2D(_Pattern, i.uv);
                float4 finalRes = lerp(tex2, tex1, pattern);
                return finalRes;
            }
            ENDCG
        }
    }
}