// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Eric/FragmentDiffuseShader"
{
    Properties
    {
       _Diffuse("_Diffuse", color) = (1,1,1,1)
    }
    SubShader
    {
        pass{
            Tags{"LightMode" = "ForwardBase"}
            LOD 100
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Diffuse;

            struct a2f{
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f{
                float4 position : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert(a2f i){
                v2f o;
                o.position = UnityObjectToClipPos(i.vertex);

                //這裡的方向與書裡不同
                o.worldNormal = normalize(mul((float3x3)unity_WorldToObject, i.normal));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed4 ambient = unity_AmbientSky;
                fixed3 direction_light_color = _LightColor0.xyz;
                float4 light_direction = normalize(_WorldSpaceLightPos0);
                fixed4 finalColor = fixed4((direction_light_color * _Diffuse) * saturate(dot(light_direction , i.worldNormal)),1.0) + ambient;
                return finalColor;
                
            }
            ENDCG
        }
    }
}
