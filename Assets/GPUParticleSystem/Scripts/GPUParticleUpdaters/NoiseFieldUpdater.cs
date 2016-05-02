using UnityEngine;
using System.Collections;

using mattatz.Utils;

namespace mattatz {

    public class NoiseFieldUpdater : GPUParticleUpdater {

        public float scale = 1f;
        public float intensity = 0.3f;
        public float speed = 0.3f;

        float ticker = 0f;

        protected override void Update() {
            base.Update();
            ticker += Time.deltaTime * speed;
        }

        public override void Dispatch(GPUParticleSystem system) {
            shader.SetFloat("_Time", ticker);
            shader.SetFloat("_Scale", scale);
            shader.SetFloat("_Intensity", intensity);
            base.Dispatch(system);
        }

    }

}


