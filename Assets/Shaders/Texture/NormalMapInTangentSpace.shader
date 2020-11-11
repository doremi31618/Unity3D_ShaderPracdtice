Shader "Eric/NormalMapInTangentSpace"
{
    Properties
    {
        _Color("Color", color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Specular("Specular", color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 250)) = 20

        _BumpMap("Normal Map Texture", 2D) = "White"{}
        _BumpScale("Bump Scale", float) = 1.0

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
            
            sampler2D _BumpMap;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;
            float _BumpScale;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;

                //Main tex / normal map use same coordinate system 
                float2 uv : TEXCOORD0;

                //tangent space vector
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //_MainTex 和 _BumpMap通常會使用同一組紋理座標，出於減少差值計算器數目的目的
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //declare the object space to tangnet space translation matrix 
                float3 binormal = cross( normalize(v.normal), normalize(v.tangent));
                float3x3 rotation = fixed3x3(v.tangent.xyz, binormal, v.normal);

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, i.uv);
                fixed3 tangentNormal;

                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;
                fixed3 ambient = unity_AmbientSky.xyz * albedo;
                fixed3 diffuse = (_LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir)));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = (_LightColor0.rgb * _Specular.xyz * pow(dot(tangentNormal, halfDir),_Gloss));
                fixed4 col = fixed4(ambient + diffuse + specular, 1.0);

                return col;
            }
            ENDCG
        }
    }
}
