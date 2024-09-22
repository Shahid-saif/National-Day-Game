using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndOfBlockTrigger : MonoBehaviour
{
    [SerializeField] float AddWorldSpeed = 0.02f;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            GameManager.Instance.BlocksManager.AddNewBlock();
            GameManager.Instance.AddWorldSpeed(AddWorldSpeed);
        }
    }
}
