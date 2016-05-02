using UnityEngine;
using System.Collections;

namespace mattatz
{

    public class GravityUpdater : GPUParticleUpdater {

        public Vector3 direction = Vector3.down;
        [Range(0f, 10f)] public float gravity = 0.81f;

        protected override void Update() {
            base.Update();
        }

        public override void Dispatch(GPUParticleSystem system) {
            shader.SetVector("_GravityDirection", system.transform.InverseTransformDirection(direction));
            shader.SetFloat("_Gravity", gravity);
            base.Dispatch(system);
        }

    }

}


