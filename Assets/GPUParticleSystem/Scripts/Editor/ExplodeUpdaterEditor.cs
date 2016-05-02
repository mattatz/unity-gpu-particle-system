using UnityEngine;
using UnityEditor;

using System.Collections;

namespace mattatz {

    [CustomEditor (typeof(ExplodeUpdater))]
    public class ExplodeUpdaterEditor : Editor {

        public override void OnInspectorGUI() {
            base.OnInspectorGUI();

            if(GUILayout.Button("Explode")) {
                var updater = target as ExplodeUpdater;
                updater.Explode();
            }
        }

    }

}


