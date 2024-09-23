using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
    [System.Serializable]
    public class EffectSound
    {
        public string ID;
        public AudioClip Sound;
    }

    [SerializeField] float MusicVolume;
    [SerializeField] float EffectVolume;
    [SerializeField] AudioSource MusicAS;
    [SerializeField] AudioSource EffectsAS;
    [SerializeField] List<EffectSound> AllEffectSounds;

    public void PlaySoundEffectById(string ID)
    {
        foreach (EffectSound sound in AllEffectSounds)
        {

            if (sound.ID == ID)
            {
                EffectsAS.PlayOneShot(sound.Sound);
            }
        }
    }

}
