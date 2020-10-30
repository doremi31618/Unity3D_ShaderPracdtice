// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Eric/VertexDiffuseShader"
{
    Properties
    {
        _DiffuseColor ("Diffuse", color) = (1,1,1,1)
    }
    SubShader
    {
       pass{
           Tags{"LightMode"="ForwardBase"}
           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #include "Lighting.cginc"

           fixed4 _DiffuseColor;
           struct a2v{
               float4 vertex : POSITION;
               float3 normal : NORMAL;
           };
           struct v2f{
               float4 pos : SV_POSITION;
               fixed3 color : COLOR0;
           };

           //to do : calculate diffuse color 
           //final color = ( light color * diffuse color ) * max(0, l*n)
           //1 .get light color 
           //2. get light direction
           //3. get normal 
           //4. calulate through formula 
           v2f vert(a2v i) {
               v2f o;
               o.pos = UnityObjectToClipPos(i.vertex);
               //get ambient color 
               fixed3 ambient_light_color = UNITY_LIGHTMODEL_AMBIENT.xyz;

               //get light color 
               fixed4 direction_light_color = _LightColor0;

               //get light direction
               float3 direction_light_pos = normalize(_WorldSpaceLightPos0.xyz);
               
               //get normal 
               float3 normal = normalize( mul(i.normal, (float3x3) unity_WorldToObject));

               o.color = (direction_light_color * _DiffuseColor) * saturate(dot(normal, direction_light_pos));
               o.color += ambient_light_color;

               return o;
           }

           //to do : output final color
           fixed4 frag(v2f i) : SV_Target{
               return fixed4(i.color, 1.0);
           }
           ENDCG
       }
        
    }
}
