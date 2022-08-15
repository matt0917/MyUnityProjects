Shader "Custom/cb_fresnel" {
    //show values to edit in inspector
    Properties{
        _Color("Tint", Color) = (0, 0, 0, 1)
        _MainTex("Texture", 2D) = "white" {}
        _BumpMap("Bumpmap", 2D) = "bump" {}
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Metallic("Metalness", Range(0, 1)) = 0
        _Emission("Emission", color) = (0,0,0)
        [ToggleOff] _FresnelTrigger("Fresnel On", Float) = 0.0

        _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
        [PowerSlider(4)] _FresnelExponent("Fresnel Exponent", Range(0.25, 10)) = 1
    }
        SubShader{
            //the material is completely non-transparent and is rendered at the same time as the other opaque geometry
            Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

            CGPROGRAM

            //the shader is a surface shader, meaning that it will be extended by unity in the background to have fancy lighting and other features
            //our surface shader function is called surf and we use the standard lighting model, which means PBR lighting
            //fullforwardshadows makes sure unity adds the shadow passes the shader might need
            #pragma surface surf Standard fullforwardshadows
            #pragma target 3.0

            sampler2D _MainTex;
            fixed4 _Color;
            sampler2D _BumpMap;

            half _Smoothness;
            half _Metallic;
            half3 _Emission;

            float3 _FresnelColor;
            float _FresnelExponent;
            half _FresnelTrigger;

            //input struct which is automatically filled by unity
            struct Input {
                float2 uv_MainTex;
                float2 uv_BumpMap;
                float3 worldNormal;
                float3 viewDir;
                INTERNAL_DATA
            };

            void surf(Input i, inout SurfaceOutputStandard o) {
                o.Albedo = tex2D(_MainTex, i.uv_MainTex).rgb;
                o.Normal = UnpackNormal (tex2D(_BumpMap, i.uv_BumpMap));

                o.Metallic = _Metallic;
                o.Smoothness = _Smoothness;

                float fresnel = dot(i.viewDir, o.Normal);
                fresnel = saturate(1 - fresnel);
                fresnel = pow(fresnel, _FresnelExponent);
                float3 fresnelColor = (fresnel* _FresnelTrigger) * _FresnelColor;
                o.Emission = _Emission + fresnelColor;
            }
            ENDCG
        }
            FallBack "Standard"
}

