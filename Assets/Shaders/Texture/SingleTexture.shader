Shader "Eric/SingleTexture"
{
    Properties
    {
        _Color("Color", color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Specular("Specular", color) = (1,1,1,1)
        _Gloss("Gloss", Range(8,256)) = 20

    }
    SubShader
    {
        Tags { "LightModel" = "FowardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                /*
                 * 也可以寫成 
                 * UnityObectToWorldNormal(v.normal)
                 * UnityObectToWorldDir(v.vertex)
                */
                
                
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                /* _MainTex_ST.xy  : 紋理的縮放值
                 * _MainTex_ST.wz  : 紋理的平移（偏移）值  
                 * 更簡單的寫法：o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);              
                */
                
                return o;
            }

            //normalize 加錯地方會很恐怖
            fixed4 frag (v2f i) : SV_Target
            {
                //get built-in information 
                fixed4 light_color = _LightColor0;
                fixed3 view_dir = normalize( UnityWorldSpaceViewDir(i.worldPos));
                fixed3 light_dir = normalize( UnityWorldSpaceLightDir(i.worldPos));
                fixed3 half_dir = normalize( view_dir + light_dir );

                //get MainTex color
                fixed3 albedo_Color = tex2D(_MainTex, i.uv) * _Color.xyz;

                //get ambient color 
                fixed3 ambient_color = unity_AmbientSky.xyz * albedo_Color;

                //calculate diffuse color 
                fixed3 diffuse_color = albedo_Color * light_color.xyz *  saturate(dot(i.worldNormal, light_dir));

                //calculate specular color 
                fixed3 specular_color = _Specular * light_color.xyz * pow( saturate( dot( half_dir, i.worldNormal)), _Gloss);

                //calculate final color
                fixed4 col = fixed4(specular_color + ambient_color + diffuse_color , 1.0);//specular_color + ambient_color + 

                return col;
            }
            ENDCG
        }
    }
}
