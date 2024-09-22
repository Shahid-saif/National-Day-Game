using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public int ColletedCoins = 0;

    [Header("GameSettings")]
    public float WorldSpeedMultiplayer = 1;

    [Header("Ref")]
    public CameraController CameraController;
    public BlocksManager BlocksManager;
    public PlayerController PlayerController;

    [Header("Effect Ref")]
    public ParticleSystem DestroyEffect;

    #region Singleton
    public static GameManager Instance;
    private void Awake()
    {
        if (Instance == null)
            Instance = this;
    }
    #endregion

    void Start()
    {

    }

    public void ColletctCoins(int Coins)
    {
        ColletedCoins += Coins;
        //Update Uis
    }
    public void AddWorldSpeed(float Add)
    {
        WorldSpeedMultiplayer += Add;
    }
    public void PlayerDamage(float sub)
    {
        if (WorldSpeedMultiplayer>1.2f)
        {
            WorldSpeedMultiplayer -= sub;
        }
    }
}
