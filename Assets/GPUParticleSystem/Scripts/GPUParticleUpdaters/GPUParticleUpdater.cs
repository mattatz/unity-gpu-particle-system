using UnityEngine;
using System.Collections;
using System;

namespace mattatz {

    public class GPUParticleUpdater : MonoBehaviour {

        protected int dispatchID = 0;
        [SerializeField] protected ComputeShader shader;

        protected const int _Thread = 8;
        protected const string _BufferKey = "_Particles";

        protected virtual void Start () {}
        protected virtual void Update () {}

        public virtual void Dispatch (GPUParticleSystem system) {
            Dispatch(dispatchID, system);
        }

        protected void Dispatch (int id, GPUParticleSystem system) {
            shader.SetBuffer(id, _BufferKey, system.ParticleBuffer);
            shader.Dispatch(id, system.ParticleBuffer.count / _Thread + 1, 1, 1);
        }

    }

}


