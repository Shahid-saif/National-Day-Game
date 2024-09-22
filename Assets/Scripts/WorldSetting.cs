using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldSetting : MonoBehaviour
{
    [Header("Global Settings")]
    public float WolrdSpeed = 1f;


    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    #region Help Classes
    public class WorldBlocks
    {
        public GameObject Block;
        public List<Transform> BlockPoints;
    }
    #endregion
}
