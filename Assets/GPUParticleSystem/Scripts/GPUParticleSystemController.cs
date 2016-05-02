using UnityEngine;
using UnityEngine.UI;

using Random = UnityEngine.Random;

using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace mattatz {

    [System.Serializable]
    public class GPUParticleUpdaterGroup {
        public string name;
        public List<GPUParticleUpdater> updaters;

        public void Activate () {
            updaters.ForEach(updater => {
                updater.gameObject.SetActive(true);
            });
        }

        public void Deactivate () {
            updaters.ForEach(updater => {
                updater.gameObject.SetActive(false);
            });
        }
    }

    public class GPUParticleSystemController : MonoBehaviour {

        [SerializeField] Dropdown menu;
        [SerializeField] GPUParticleSystem system;
        public List<GPUParticleUpdaterGroup> groups;

        GPUParticleUpdaterGroup cur;

        void Start () {
            if(groups.Count > 0) {
                cur = groups.First();
                cur.Activate();
            }

            menu.AddOptions(groups.Select(group => {
                var option = new Dropdown.OptionData();
                option.text = group.name;
                return option;
            }).ToList());
        }

        public void OnInit () {
            if (cur != null) cur.Deactivate();
        }

        public void OnMenuChanged (int option) {
            if (cur != null) cur.Deactivate();
            if (option < groups.Count) {
                cur = groups[option];
                cur.Activate();
            }
        }

    }

}


