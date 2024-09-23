using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Coin : MonoBehaviour
{
    [SerializeField] int coinsCount;
    [SerializeField] string CollectSound = "CollectCoin";
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            GameManager g = GameManager.Instance;
            if (g.GameOver) { return; }

            GameManager.Instance.ColletctCoins(coinsCount);

            g.CollectCoin.transform.position = transform.position;
            g.CollectCoin.Play();
            g.audioManager.PlaySoundEffectById(CollectSound);
            //AddEffects
            Destroy(gameObject);
        }
    }
}
