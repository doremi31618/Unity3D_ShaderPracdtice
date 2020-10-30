// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Eric/HalfLambertDiffuseShader"
{
    Properties
    {
        _Diffuse("Diffuse", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            struct a2f{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert(a2f i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldNormal = normalize(mul((float3x3)unity_WorldToObject, i.normal));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed4 direction_light_color = _LightColor0;
                float3 direction_light_pos = normalize(_WorldSpaceLightPos0);
                fixed4 diffuseColor = (direction_light_color * _Diffuse) * (0.5 * dot(direction_light_pos, i.worldNormal)+0.5);
                fixed4 ambient = unity_AmbientSky;
                return ambient + diffuseColor;
            }
            ENDCG
        }
    }
}
