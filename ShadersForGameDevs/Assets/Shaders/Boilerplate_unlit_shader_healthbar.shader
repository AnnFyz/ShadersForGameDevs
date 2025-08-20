Shader "Unlit/Boilerplate_unlit_shader_healthbar"
{
    Properties // input data
    {
        _CurrentHealth ("Current Health", Range(0,1)) = 1
        _BorderSize ("Border Size", Range(0,1)) = 0.2
       [NoScaleOffset] _HealthbarTex ("Texture", 2D) = "white" {}
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
            
            float _CurrentHealth;
            float _BorderSize;
            sampler2D _HealthbarTex;

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

             float inverseLerp(float a, float b, float v)
            {
                return ((v - a) / (b - a));
            }


            fixed4 frag(Interpolators i) : SV_Target
            
            {  //round corners
                float2 coord = i.uv;
                coord.x *= 8; // for making unit coordinate space

                float2 pointOnLineSegment = float2(clamp(coord.x, 0.5, 7.5), 0.5);
                float sdf = distance(coord, pointOnLineSegment) * 2 -1;
                clip(-sdf);
                float border = sdf + _BorderSize;
                float pd = fwidth(border); // screen space partial derivative
                //float borderMask = step(0,-border); // alternativ way to make a border
                 float borderMask = 1 - saturate(border/pd);
                
                // half transparent background
                float healthbarMask = _CurrentHealth > i.uv.x;

                float t = saturate(inverseLerp(0.2, 0.8, _CurrentHealth));
                float3 texColor = tex2D(_HealthbarTex, float2(t, i.uv.y));
                float3 flash = cos(_Time.y *4)*0.5+1;
                if (_CurrentHealth < 0.2)
                texColor *= flash;
                return float4(texColor* healthbarMask * borderMask , healthbarMask+0.25);
            }
            ENDCG
        }
    }
}