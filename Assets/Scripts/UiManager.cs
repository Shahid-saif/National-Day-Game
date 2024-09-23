using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UiManager : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI Distance;
    [SerializeField] TextMeshProUGUI PlayerLives;
    [SerializeField] TextMeshProUGUI PlayerCoins;
    [SerializeField] TextMeshProUGUI PlayerFinalScore;
    [SerializeField] GameManager gameManager => GameManager.Instance;
    public void UpdateUI()
    {
        Distance.text = gameManager.totalDistance.ToString("00");
        PlayerLives.text = gameManager.PlayerLives.ToString();
        PlayerCoins.text = gameManager.ColletedCoins.ToString();
        PlayerFinalScore.text = gameManager.ColletedCoins.ToString();
    }
}
