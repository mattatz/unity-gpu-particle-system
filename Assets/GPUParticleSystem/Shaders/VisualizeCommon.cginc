#pragma target 5.0

#include "UnityCG.cginc"

#ifndef _SHADOW_PARTICLE_
#include "AutoLight.cginc"
#endif

#include "Assets/Common/Shaders/Random.cginc"
#include "Assets/Common/Shaders/Math.cginc"
#include "Assets/Common/Shaders/Noise/SimplexNoise3D.cginc"

#include "./GPUParticle.cginc"

struct appdata {
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};

struct v2g {
	float4 vertex : POSITION;
	float4 rot : NORMAL;
	float2 uv : TEXCOORD0;
	float4 col : TEXCOORD1;
	float3 size : TEXCOORD2;
};

#define _g2f_common_ float4 wpos : TANGENT; float3 normal : NORMAL; float2 uv : TEXCOORD0; float4 col : TEXCOORD1; float3 lightDir : TEXCOORD2; float3 viewDir: TEXCOORD3;

struct g2f {
#ifdef _SHADOW_PARTICLE_
	V2F_SHADOW_CASTER;
	_g2f_common_
#else 
	float4 pos : POSITION;
	_g2f_common_
	LIGHTING_COORDS(5, 6)
#endif
};

sampler2D _MainTex;
fixed _Size;

StructuredBuffer<Particle> _Particles;

v2g vert(appdata IN, uint id : SV_VertexID) {
	v2g OUT;

	Particle p = _Particles[id];

	float3 pos = p.pos;
	OUT.vertex = float4(pos, 1.0);
	OUT.rot = p.rot;
	OUT.col = p.col;
	OUT.uv = float2(0, 0);

	float lifetime = saturate(p.lifetime);
	OUT.size = _Size * p.scale * smoothstep(0.0, 0.1, lifetime) * (1.0 - smoothstep(0.9, 1.0, lifetime));

	return OUT;
}

void add_face(v2g v, in g2f pIn, inout TriangleStream<g2f> OUT, float4 p[4]) {
	float4x4 mvp = UNITY_MATRIX_MVP;

	pIn.pos = mul(mvp, p[0]);
	pIn.wpos = mul(unity_ObjectToWorld, p[0]);
	pIn.lightDir = ObjSpaceLightDir(p[0]);
	pIn.viewDir = ObjSpaceViewDir(p[0]);

	pIn.uv = float2(1.0f, 0.0f);

#ifdef _SHADOW_PARTICLE_
	v.vertex = p[0];
	TRANSFER_SHADOW_CASTER(pIn)
#else
	TRANSFER_VERTEX_TO_FRAGMENT(pIn)
	TRANSFER_SHADOW(pIn);
#endif

	OUT.Append(pIn);

	pIn.pos = mul(mvp, p[1]);
	pIn.wpos = mul(unity_ObjectToWorld, p[1]);
	pIn.lightDir = ObjSpaceLightDir(p[1]);
	pIn.viewDir = ObjSpaceViewDir(p[1]);

	pIn.uv = float2(1.0f, 1.0f);

#ifdef _SHADOW_PARTICLE_
	v.vertex = p[1];
	TRANSFER_SHADOW_CASTER(pIn)
#else
	TRANSFER_VERTEX_TO_FRAGMENT(pIn)
	TRANSFER_SHADOW(pIn);
#endif

	OUT.Append(pIn);

	pIn.pos = mul(mvp, p[2]);
	pIn.wpos = mul(unity_ObjectToWorld, p[2]);
	pIn.lightDir = ObjSpaceLightDir(p[2]);
	pIn.viewDir = ObjSpaceViewDir(p[2]);
	pIn.uv = float2(0.0f, 0.0f);

#ifdef _SHADOW_PARTICLE_
	v.vertex = p[2];
	TRANSFER_SHADOW_CASTER(pIn)
#else
	TRANSFER_VERTEX_TO_FRAGMENT(pIn)
	TRANSFER_SHADOW(pIn);
#endif

	OUT.Append(pIn);

	pIn.pos = mul(mvp, p[3]);
	pIn.wpos = mul(unity_ObjectToWorld, p[3]);
	pIn.lightDir = ObjSpaceLightDir(p[3]);
	pIn.viewDir = ObjSpaceViewDir(p[3]);
	pIn.uv = float2(0.0f, 1.0f);

#ifdef _SHADOW_PARTICLE_
	v.vertex = p[3];
	TRANSFER_SHADOW_CASTER(pIn)
#else
	TRANSFER_VERTEX_TO_FRAGMENT(pIn)
	TRANSFER_SHADOW(pIn);
#endif

	OUT.Append(pIn);

	OUT.RestartStrip();
}

[maxvertexcount(24)]
void geom_cube(point v2g IN[1], inout TriangleStream<g2f> OUT) {

	float3 size = IN[0].size;
	float3 halfS = 0.5f * size;

	float3 pos = IN[0].vertex.xyz;
	float3 right = rotate_vector(float3(1, 0, 0), IN[0].rot) * halfS.x;
	float3 up = rotate_vector(float3(0, 1, 0), IN[0].rot) * halfS.y;
	float3 forward = rotate_vector(float3(0, 0, 1), IN[0].rot) * halfS.z;

	float4 v[4];

	g2f pIn;
	UNITY_INITIALIZE_OUTPUT(g2f, pIn);

	pIn.col = IN[0].col;

	// forward
	v[0] = float4(pos + forward + right - up, 1.0f);
	v[1] = float4(pos + forward + right + up, 1.0f);
	v[2] = float4(pos + forward - right - up, 1.0f);
	v[3] = float4(pos + forward - right + up, 1.0f);
	pIn.normal = normalize(forward);
	add_face(IN[0], pIn, OUT, v);

	// back
	v[0] = float4(pos - forward - right - up, 1.0f);
	v[1] = float4(pos - forward - right + up, 1.0f);
	v[2] = float4(pos - forward + right - up, 1.0f);
	v[3] = float4(pos - forward + right + up, 1.0f);
	pIn.normal = -normalize(forward);
	add_face(IN[0], pIn, OUT, v);

	// up
	v[0] = float4(pos - forward + right + up, 1.0f);
	v[1] = float4(pos - forward - right + up, 1.0f);
	v[2] = float4(pos + forward + right + up, 1.0f);
	v[3] = float4(pos + forward - right + up, 1.0f);
	pIn.normal = normalize(up);
	add_face(IN[0], pIn, OUT, v);

	// down
	v[0] = float4(pos + forward + right - up, 1.0f);
	v[1] = float4(pos + forward - right - up, 1.0f);
	v[2] = float4(pos - forward + right - up, 1.0f);
	v[3] = float4(pos - forward - right - up, 1.0f);
	pIn.normal = -normalize(up);
	add_face(IN[0], pIn, OUT, v);

	// left
	v[0] = float4(pos + forward - right - up, 1.0f);
	v[1] = float4(pos + forward - right + up, 1.0f);
	v[2] = float4(pos - forward - right - up, 1.0f);
	v[3] = float4(pos - forward - right + up, 1.0f);
	pIn.normal = -normalize(right);
	add_face(IN[0], pIn, OUT, v);

	// right
	v[0] = float4(pos - forward + right + up, 1.0f);
	v[1] = float4(pos + forward + right + up, 1.0f);
	v[2] = float4(pos - forward + right - up, 1.0f);
	v[3] = float4(pos + forward + right - up, 1.0f);
	pIn.normal = normalize(right);
	add_face(IN[0], pIn, OUT, v);

};
