Shader "Eric/Blinn_SpecularShader"
{
    Properties
    {
        _Diffuse("Diffuse", color) = (1,1,1,1)
        _Specular("Specular", color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0,256)) = 9.0
        _UseSpecular("is use specular", int) = 1
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;
            int _UseSpecular;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };


            v2f vert (a2v v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul((float3x3)unity_WorldToObject, v.normal));
                o.worldPos = mul(unity_WorldToObject, v.vertex.xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //ambient 
                fixed4 ambient_color = unity_AmbientSky;

                //diffuse : half lambert shader 
                fixed3 light_color = _LightColor0.xyz;
                fixed3 light_direction = normalize(_WorldSpaceLightPos0.xyz);
                fixed4 diffuseColor = fixed4(light_color.xyz * _Diffuse.xyz * (0.5*dot(i.worldNormal, light_direction) + 0.5),1.0);

                //specular 
                // fixed3 reflect_direction = reflect(-light_direction, i.worldNormal);
                fixed3 view_direciton = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 h_vector = normalize(view_direciton+light_direction);
                fixed3 specularColor =  light_color * _Specular.xyz * pow( saturate( dot(h_vector, i.worldNormal) ), _Gloss);

                //adding color 
                fixed4 outputColor = ambient_color + diffuseColor + fixed4(specularColor,1.0);

                return outputColor;
            }
            ENDCG
        }
    }
}
