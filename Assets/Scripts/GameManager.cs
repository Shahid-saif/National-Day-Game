using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.SocialPlatforms.Impl;

public class GameManager : MonoBehaviour
{
    public int ColletedCoins = 0;

    [Header("GameSettings")]
    public float WorldSpeedMultiplayer = 1;

    [Header("Ref")]
    public CameraController CameraController;
    public BlocksManager BlocksManager;
    public PlayerController PlayerController;
    public UiManager uiManager;
    public AudioManager audioManager;
    public LeaderBoardUI leaderBoardUI;

    [Header("Effect Ref")]
    public ParticleSystem DestroyEffect;
    public ParticleSystem CollectCoin;
    public ParticleSystem CollectLive;

    public bool GameOver;
    public int PlayerLives;
    public float totalDistance = 0f;

    [Header("Start the Game")]
    [SerializeField] GameObject StartMenu;

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
        StartMenu.SetActive(true);
        PlayerController.enabled = false;
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
    public void PlayerDamage(float sub, int lives)
    {
        if (WorldSpeedMultiplayer > 1.2f)
        {
            WorldSpeedMultiplayer -= sub;
        }
        PlayerLives -= lives;

        if (PlayerLives <= 0)
        {
            GameOver = true;
            PlayerController.PlayerDie();
            leaderBoardUI.SubmitFormHolder.SetActive(true);
            PlayerLives = 0;
        }
    }
    public void PlayerDamage(int lives)
    {
        PlayerLives -= lives;

        if (PlayerLives <= 0)
        {
            GameOver = true;
            PlayerController.PlayerDie();
            leaderBoardUI.SubmitFormHolder.SetActive(true);
            PlayerLives = 0;
        }
    }

    public void CollectPlayerLive(int lives)
    {
        PlayerLives += lives;
    }
    public void RestartLevel()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
    public void StartTheGame()
    {
        StartMenu.SetActive(false);
        PlayerController.enabled = true;
    }
}
