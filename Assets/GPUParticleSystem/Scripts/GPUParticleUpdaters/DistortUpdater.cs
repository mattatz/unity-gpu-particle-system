using UnityEngine;
using System.Collections;

using mattatz.Utils;

namespace mattatz {

    public class DistortUpdater : GPUParticleUpdater {

        [Range(0f, 1f)] public float t = 1f;

        [Range(0f, 0.5f)] public float scale = 0.25f;
        public float intensity = 0.75f;
        public float speed = 0.3f;

        float ticker = 0f;

        protected override void Update() {
            base.Update();

            ticker += Time.deltaTime * speed;
        }

        public override void Dispatch(GPUParticleSystem system) {
            shader.SetFloat("_DT", Time.deltaTime * speed);
            shader.SetFloat("_Time", ticker);
            shader.SetFloat("_Scale", scale);
            shader.SetFloat("_Intensity", intensity);

            base.Dispatch(system);
        }

    }

}


