Shader "mattatz/GPUParticleSystem/Visualize" {

	Properties {
		_MainTex ("Base (RGB)", 2D) = "black" {}
		_Color ("Color", Color) = (0, 0, 0, 1)
		_Size ("Size", Range(0.0001, 0.2)) = 0.05

		_Shininess ("Shininess", Float) = 2.0
	}

	SubShader {
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGINCLUDE

		ENDCG

		Pass {
			Tags { "LightMode" = "ForwardBase" }
			Lighting On ZWrite On

			CGPROGRAM

			#pragma multi_compile_fwdbase
			#include "./VisualizeCommon.cginc"
			#pragma vertex vert
			#pragma geometry geom_cube
			#pragma fragment frag

			fixed4 _Color;

			fixed _Shininess;

			fixed4 frag(g2f IN) : SV_Target{

				fixed4 col = IN.col * _Color;

				float3 normal = IN.normal;
				normal = normalize(normal);

				float3 lightDir = normalize(IN.lightDir);
				float3 viewDir = normalize(IN.viewDir);
				float3 halfDir = normalize(lightDir + viewDir);

				float nh = dot(normal, halfDir);

				float atten = LIGHT_ATTENUATION(IN);
				float3 spec = max(0.1, pow(saturate(nh), _Shininess));
				col.rgb *= spec * atten;

				return col;
			}

			ENDCG
		}

		Pass {

			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			ZWrite On ZTest LEqual

			CGPROGRAM

			#define _SHADOW_PARTICLE_ 1
			#pragma multi_compile_shadowcaster
			#include "VisualizeCommon.cginc"
			#pragma vertex vert
			#pragma geometry geom_cube
			#pragma fragment shadow_frag

			float4 shadow_frag (g2f IN) : COLOR {
				SHADOW_CASTER_FRAGMENT(IN)
			}

			ENDCG
		}

	}
}
