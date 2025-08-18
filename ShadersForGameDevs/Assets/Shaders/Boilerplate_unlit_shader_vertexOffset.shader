Shader "Unlit/Boilerplate_unlit_shader_vertexOffset"
{
    Properties // input data
    {
        [Toggle]_Reverse("Reverse", Float) = 0
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (1,1,1,1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0,1)) = 1
        _WaveAmplitude("Wave Amplitude", Range(0,0.005)) =0.001
        _WaveSpeed("Wave Speed",Range(0,1)) =0.1
        _Frequence("Frequence", Range(1,10)) = 5
        
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue" = "Geometry"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TAU  6.283185307179586

            float _IsGradientVertical;
            float _Reverse;
            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            float _WaveAmplitude;
            float _WaveSpeed;
            float _Frequence;

            float GetWave(float2 uv)
            {
                float2 centeredUV = uv * 2 -1;
                float radialDistance = length(centeredUV);
                float wave = cos((radialDistance - _Time.y*  _WaveSpeed ) * TAU *_Frequence) * 0.5 + 0.5;
                wave *= 1- radialDistance;
                return wave;
            }
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
                float3 normal: TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                // horizontal waves 
                /*float waveY = cos((v.uv0.y - _Time.y* 0.1 ) * TAU *5);
                float waveX = cos((v.uv0.x - _Time.y* 0.1 ) * TAU *5);
                v.vertex.y = waveY * waveX * _WaveAmplitude;*/

                // radial waves
                float wave = GetWave((v.uv0));
                v.vertex.y =  wave * _WaveAmplitude;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;
                return o;
            }
             float inverseLerp(float a, float b, float v)
            {
                return ((v - a) / (b - a));
            }
    
            fixed4 frag(Interpolators i) : SV_Target
            {
                float wave = GetWave(i.uv);    
                float t;
                if (_Reverse)
                {
                   t = saturate(inverseLerp(_ColorEnd, _ColorStart, wave));
                }
                else
                {
                   t = saturate(inverseLerp(_ColorStart, _ColorEnd, wave));
                }
                float4 lerpedColor = lerp(_ColorA, _ColorB, t);
                return lerpedColor;
            }
            ENDCG
        }
    }
}