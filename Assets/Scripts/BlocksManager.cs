using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlocksManager : MonoBehaviour
{
    [Header("Blocks")]
    public List<GameObject> AllGameBlocks;
    public GameObject CurrBlock;
    public GameObject PreBlock;
    public GameObject NextBlock;
    void Start()
    {

    }

    public void AddNewBlock()
    {
        GameObject Go = Instantiate(AllGameBlocks[Random.Range(0, AllGameBlocks.Count - 1)]);
        Block block = NextBlock.GetComponent<Block>();
        Go.transform.position = block.End.position;
        Destroy(PreBlock);
        PreBlock = CurrBlock;
        CurrBlock = NextBlock;
        NextBlock = Go;
    }

}
