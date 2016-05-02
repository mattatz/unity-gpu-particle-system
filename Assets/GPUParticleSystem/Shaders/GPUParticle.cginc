#ifndef _PARTICLE_INCLUDED_
#define _PARTICLE_INCLUDED_

struct Particle {
	float mass;
	float lifetime;
	float3 ori;
	float3 pos;
	float4 rot;
	float3 scale;
	float3 vel;
	float3 acc;
	float4 col;
	bool reactive;
};

#endif // _PARTICLE_INCLUDED_
