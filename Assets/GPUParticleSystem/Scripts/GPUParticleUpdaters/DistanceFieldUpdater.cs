using UnityEngine;
using System.Collections;

using mattatz.Utils;

namespace mattatz {

    public class DistanceFieldUpdater : GPUParticleUpdater {

        public float speed = 1f;

        float ticker = 0f;

        protected override void Update() {
            base.Update();

            ticker += Time.deltaTime * speed;
        }

        public override void Dispatch(GPUParticleSystem system) {

            shader.SetFloat("_Time", ticker);

            base.Dispatch(system);
        }

    }

}



