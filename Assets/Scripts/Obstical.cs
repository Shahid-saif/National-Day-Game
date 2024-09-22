using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class Obstical : MonoBehaviour
{
    [SerializeField] float Damage;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            GameManager g = GameManager.Instance;
            g.PlayerDamage(Damage);
            g.CameraController.ShakeCamera();
            g.PlayerController.GitHit();
            g.DestroyEffect.transform.position = transform.position;
            g.DestroyEffect.Play();
            //Add Sound
            Destroy(gameObject);
        }
    }
}
