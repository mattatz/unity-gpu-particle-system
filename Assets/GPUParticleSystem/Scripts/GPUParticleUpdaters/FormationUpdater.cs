using UnityEngine;
using Random = UnityEngine.Random;

using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

using mattatz.Utils;

namespace mattatz {

    public class FormationUpdater : GPUParticleUpdater {

        [System.Serializable]
        enum FormationMode {
            Ring,
            Circle,
            Wave
        };

        [SerializeField] FormationMode mode = FormationMode.Ring;

        public float speed = 1f;
        public float size = 1.5f;

        [Range(0f, 1f)] public float intensity = 0.5f;

        float ticker = 0f;

        protected override void Update() {
            base.Update();
            ticker += Time.deltaTime;
        }

        public override void Dispatch(GPUParticleSystem system) {
            shader.SetFloat("_Size", size);
            shader.SetFloat("_Intensity", intensity);
            shader.SetFloat("_Speed", speed);

            shader.SetFloat("_R", 1f / system.ParticleBuffer.count);
            shader.SetFloat("_Time", ticker);
            shader.SetFloat("_DT", Time.deltaTime * speed);

            base.Dispatch((int)mode, system);
        }

    }

}
