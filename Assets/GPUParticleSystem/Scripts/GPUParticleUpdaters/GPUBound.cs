using UnityEngine;
using System.Collections;

namespace mattatz {

    [System.Serializable]
    public class GPUBound {
        public Vector3 pos;
        public Vector3 size;
        public Vector3[] axes;

        public Vector3 translation;
        public Quaternion rotation;
        public Vector3 scale;

        public float mass;
        public Vector3 velocity;
        public bool reactive;

        GPUBound_t structure;

        public GPUBound(Vector3 p, Vector3 s, Vector3[] axes) {
            this.pos = p;
            this.size = s;
            this.axes = axes;

            this.rotation = Quaternion.identity;
            this.scale = Vector3.one;

            this.mass = Random.value;

            this.structure = new GPUBound_t(pos, size, Matrix4x4.identity);
        }

        public void AddForce(Vector3 force, float dt)
        {
            velocity += force * mass * dt;
            velocity *= 0.98f;

            // Slerp for "input Quaternion is invalid error" on conversion to matrix4x4 in Structure()
            rotation = Quaternion.Slerp(rotation, rotation * Quaternion.AngleAxis(dt * 10f, velocity.normalized), 0.5f);

            translation += velocity * dt;
        }

        public void Spread(float intensity, float t = 1f)
        {
            rotation = Quaternion.Slerp(rotation, Quaternion.identity, 0.1f);
            translation = Vector3.Lerp(Vector3.zero, pos * intensity, t);
        }

        public void MoveAlongAxis(int index, float intensity = 1f, float t = 1f)
        {
            rotation = Quaternion.Slerp(rotation, Quaternion.identity, 0.1f);
            translation = Vector3.Lerp(Vector3.zero, axes[index % axes.Length] * intensity, t);
        }

        public GPUBound_t Structure()
        {
            this.structure.TRS = Matrix4x4.TRS(translation, rotation, scale);
            this.structure.reactive = reactive;
            return this.structure;
        }

        public void Reset()
        {
            translation = Vector3.zero;
            rotation = Quaternion.identity;
            scale = Vector3.one;

            velocity *= 0f;
        }
    }

    public struct GPUBound_t {
        public Vector3 pos;
        public Vector3 size;
        public Matrix4x4 TRS;
        public bool reactive;
        public GPUBound_t(Vector3 p, Vector3 s, Matrix4x4 m) {
            pos = p;
            size = s;
            TRS = m;
            reactive = false;
        }
    };

}


