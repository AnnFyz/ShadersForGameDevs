Shader "Unlit/Boilerplate_unlit_shader_SDF"
{
    Properties // input data
    {
       [NoScaleOffset]  _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha //Alpha Blending
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

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
                float2 coord = i.uv;
                coord.x *= 8; // for making unit coordinate space

                float2 pointOnLineSegment = float2(clamp(coord.x, 0.5, 7.5), 0.5);
                float sdf = distance(coord, pointOnLineSegment);
                float mask = step(0.5, sdf);
                clip(-mask);
                return float4(sdf.xxx, 1 );
            }
            ENDCG
        }
    }
}