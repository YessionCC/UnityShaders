Shader "Unlit/CubeFade"
{
	Properties
	{
		_Size("Cube Size", float) = 0.05
		_Width("Wire Width", float) = 0.2
		_Color("Wire Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags{ "RenderType"="Transparent" "Queue" = "Transparent"}

		Blend SrcAlpha OneMinusSrcAlpha
		Cull off ZWrite off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#define AP(x) stream.Append(v[x]);

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float3 bary : TEXCOORD0;
			};

			float _Size;
			float _Width;
			float4 _Color;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.pos = v.vertex;
				o.uv = v.uv;
				return o;
			}

			g2f initVert() {
				g2f output;

				output.pos = float4(0, 0, 0, 0);
				output.norm = float3(0, 0, 0);
				output.bary = float3(0, 0, 0);

				return output;
			}

			[maxvertexcount(23)]
			void geom(point v2g points[1], inout TriangleStream<g2f> stream)
			{
				g2f v[8] = {
					initVert(), initVert(), initVert(), initVert(),
					initVert(), initVert(), initVert(), initVert()
				};
				float4 opos = points[0].pos;
				float osize = _CosTime.w*_Size;
				v[0].pos = opos + float4(osize, osize, osize, 1);
				v[6].pos = opos + float4(osize, osize, -osize, 1);
				v[4].pos = opos + float4(-osize, osize, -osize, 1);
				v[2].pos = opos + float4(-osize, osize, osize, 1);
				v[1].pos = opos + float4(osize, -osize, osize, 1);
				v[7].pos = opos + float4(osize, -osize, -osize, 1);
				v[5].pos = opos + float4(-osize, -osize, -osize, 1);
				v[3].pos = opos + float4(-osize, -osize, osize, 1);

				v[0].bary = float3(0, 0, 1);
				v[1].bary = float3(0, 1, 0);
				v[2].bary = float3(1, 0, 0);
				v[3].bary = float3(0, 0, 1);
				v[4].bary = float3(0, 0, 1);
				v[5].bary = float3(0, 1, 0);
				v[6].bary = float3(1, 0, 0);
				v[7].bary = float3(0, 0, 1);

				for (int i = 0; i < 8; i++) {
					v[i].pos = UnityObjectToClipPos(v[i].pos);
				}
				AP(0) AP(1) AP(2) AP(3) AP(5) AP(2) AP(4) AP(5) AP(6) AP(7) AP(1) AP(6) AP(0)

				v[2].bary = float3(0, 1, 0);
				AP(6) AP(2) AP(4) AP(4) AP(5)
				v[1].bary = float3(0, 0, 1);
				v[5].bary = float3(0, 0, 1);
				v[7].bary = float3(0, 1, 0);
				v[3].bary = float3(1, 0, 0);
				AP(5) AP(3) AP(7) AP(1)
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				float width = min(i.bary.x, i.bary.y);
				float alpha = smoothstep(0, _Width / 2, _Width - width);
				return fixed4(_Color.rgb, alpha);
			}
			ENDCG
		}
	}
}
