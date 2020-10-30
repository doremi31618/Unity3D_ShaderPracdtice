// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Eric/DebugMaterial"{
    Properties {

    }
    SubShader{
        Tags{"RenderType" = "Transparent" "Queue"="Transparent" }
        LOD 100
        Pass{
            CGPROGRAM
            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            struct v2f{
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };

            v2f vert(appdata_full i){
                v2f o;

                o.pos = UnityObjectToClipPos(i.vertex);

                //可視化切線的部分
                o.color = fixed4(i.tangent * 0.5 + fixed3(0.5,0.5,0.5),1);

                //可視化法線
                o.color = fixed4(i.normal * 0.5 + fixed3(0.5,0.5,0.5),1);

                //可視化副切線
                fixed3 binormal = cross(i.normal, i.tangent.xyz) * i.tangent.w;
                o.color = fixed4(binormal * 0.5 + fixed3(0.5,0.5,0.5), 1);

                //可視化頂點顏色
                o.color = i.color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return i.color;
            }
            ENDCG
        }
    }
}