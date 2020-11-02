Shader "Eric/NormalMapInTangentSpace"
{
    Properties
    {
        _Color("Color", color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Specular("Specular", color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 250)) = 20

        _NormalMap("Normal Map Texture", 2D) = "White"{}

    }
    SubShader
    {
        Tags { "LightModel"="ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            
            sampler2D _NormalMap;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : Normal;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                //get information from unity 
                fixed3 light_color = _LightColor0;
                fixed3 light_dir = normalize(UnityWorldSpaceLightDir(i.worldPos).xyz);
                fixed3 view_dir = normalize(UnityWorldSpaceViewDir(i.worldPos).xyz);
                fixed3 half_dir = normalize(view_dir + light_dir);
                fixed3 normal = normalize(i.worldNormal);

                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uv).xyz * _Color.xyz;
                fixed3 diffuse = (albedo * light_color * saturate(dot(light_dir, normal)));
                fixed3 specular = (_Specular * light_dir * saturate(pow(dot(half_dir, normal), _Gloss)));
                fixed4 col = fixed4( albedo + diffuse + specular, 1);
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
