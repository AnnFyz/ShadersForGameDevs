Shader "Unlit/Boilerplate_unlit_shader"
{
    // input data  
    Properties
    {
        [Toggle]_IsGradientVertical("Is Gradient Vertical", Float) = 0
        [Toggle]_Reverse("Reverse", Float) = 0
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0,1)) = 1
        _Scale ("UV Scale", Float) = 1
        _Offset ("Offset", Float) = 0
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

            float _IsGradientVertical;
            float _Reverse;
            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            float _Scale;
            float _Offset;

            // automatically filled out by unity
            struct MeshData // per-vertex mesh data
            {
                float4 vertex : POSITION; // vertex position
                float3 normals: NORMAL;
                float4 tangent: TANGENT;
                float4 color: COLOR;
                float2 uv0 : TEXCOORD0; // uv0 coordinates
                //float2 uv1 : TEXCOORD1; // uv1 coordinates
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                //o.normal = v.normals; // in mesh space
                o.normal = UnityObjectToWorldNormal(v.normals); // in world space
                o.uv = v.uv0; //(v.uv0 + _Offset) * _Scale;
                return o;
            }

            float inverseLerp(float a, float b, float v)
            {
                return ((v - a) / (b - a));
            }

            fixed4 frag(Interpolators i) : SV_Target
            {
                // another version with clamped value of i.uv.x
                //float t = inverseLerp(_ColorStart, _ColorEnd, frac(i.uv.x));
                float uvDirection = lerp(i.uv.x , i.uv.y, _IsGradientVertical);
                float t;
                if (_Reverse)
                {
                   t = saturate(inverseLerp(_ColorEnd, _ColorStart, uvDirection));
                }
                else
                {
                   t = saturate(inverseLerp(_ColorStart, _ColorEnd, uvDirection));
                }
                float4 lerpedColor = lerp(_ColorA, _ColorB, t);
                return lerpedColor;
            }
            ENDCG
        }
    }
}