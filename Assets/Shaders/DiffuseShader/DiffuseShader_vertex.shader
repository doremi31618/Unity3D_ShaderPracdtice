Shader "Unlit/DiffuseShader_vertex"
{
    subshader{
        pass{
            Tags{ "LightMode" = "ForwardBase"}
            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vertex
            #pragma fragment fragment

            fixed4 _Diffuse;
            



            ENDCG
        }
    }
}
