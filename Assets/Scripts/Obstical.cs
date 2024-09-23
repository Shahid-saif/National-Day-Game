using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class Obstical : MonoBehaviour
{
    [SerializeField] float SlowDamage;
    [SerializeField] int HitLives = 1;
    [SerializeField] string HitSound = "Hit";
    [SerializeField] bool Dest = false;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {

            GameManager g = GameManager.Instance;
            if (g.GameOver) { return; }

            g.PlayerDamage(HitLives);
            g.CameraController.ShakeCamera();
            g.PlayerController.GitHit();
            g.DestroyEffect.transform.position = transform.position;
            g.DestroyEffect.Play();
            g.audioManager.PlaySoundEffectById(HitSound);
            //Add Sound
            if (Dest)
            {
                Destroy(gameObject);
            }
        }
    }
}
