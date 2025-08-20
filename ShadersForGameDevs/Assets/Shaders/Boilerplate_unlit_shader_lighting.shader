Shader "Unlit/Boilerplate_unlit_shader_lighting"
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
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Gloss;
            float4 _Color;

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
                float3 normal: TEXCOORD1;
                float3 wPos: TEXCOORD2;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(Interpolators i) : SV_Target
            {
                // diffuse lighting
                float3 N = normalize(i.normal);
                float L = _WorldSpaceLightPos0.xyz; // light direction
                float3 lambert = saturate (dot(N, L));
                float3 diffuseLight = lambert * _LightColor0.xyz;
                // specular lighting
                float3 V = normalize( _WorldSpaceCameraPos - i.wPos);
                //float3 R = reflect(-L, N); // Phong
                float H = normalize((L+V)); // Blinn-Phong
                float3 specularLight = saturate (dot(H, N)) * (lambert>0);
                float specularExponent = exp2(_Gloss *11) +1;
                specularLight = pow(specularLight, specularExponent);
                specularLight *= _LightColor0.xyz;
                return float4(specularLight + diffuseLight * _Color,1);
            }
            ENDCG
        }
    }
}