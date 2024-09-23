using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Live : MonoBehaviour
{
    [SerializeField] int Lives;
    [SerializeField] string CollectLive = "CollectLive";

    private void Start()
    {
        int r = Random.Range(0, 10);
        if (r > 5)
            this.gameObject.SetActive(false);
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            GameManager g = GameManager.Instance;
            if (g.GameOver) { return; }

            g.CollectPlayerLive(Lives);

            g.CollectLive.transform.position = transform.position;
            g.CollectLive.Play();
            g.audioManager.PlaySoundEffectById(CollectLive);
            //AddEffects
            Destroy(gameObject);
        }
    }
}
