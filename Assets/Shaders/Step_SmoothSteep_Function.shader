Shader "Unlit/Step_SmoothSteep_Function"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(Step,SmoothStep)]
            _StepType("StepType", float) = 0
        _StepSmooth("StepSmooth", Range(0.1,0.5)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile _STEPTYPE_STEP _STEPTYPE_SMOOTHSTEP
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _StepSmooth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target{
                float edge = 0.5;
                #if (_STEPTYPE_STEP)
                    fixed3 sstep = step(i.uv.y, edge);
                    return fixed4(sstep,1);
                #else
                    float3 sstep = smoothstep((i.uv.y - _StepSmooth),(i.uv.y + _StepSmooth),edge);
                    return fixed4(sstep,1);
                #endif
            }
            ENDCG
        }
    }
}
