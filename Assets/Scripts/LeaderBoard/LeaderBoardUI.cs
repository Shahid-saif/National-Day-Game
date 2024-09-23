using System;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using TMPro;
using UnityEngine;

public class LeaderBoardUI : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] GameBackend gameBackend;
    [SerializeField] GameManager gameManager;

    [Header("LeaderBoard")]
    [SerializeField] GameObject UIRef;
    [SerializeField] RectTransform RefParent;
    [SerializeField] GameObject LeaderBoardHolder;

    [Header("Submit Score")]
    public GameObject SubmitFormHolder;
    [SerializeField] TMP_InputField PlayerEmail;
    [SerializeField] TMP_InputField PlayerName;
    [SerializeField] TextMeshProUGUI errorMessage;
    private string emailPattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";
    bool IsCorrectEmail = false;

    [Header("LoadingScreen")]
    [SerializeField] GameObject loadingScreen;

    public GameObject CatchMenu;

    private void Start()
    {
        gameBackend = FindAnyObjectByType<GameBackend>();
        gameManager = FindAnyObjectByType<GameManager>();
        PlayerEmail.onEndEdit.AddListener(ValidateEmail);
    }
    public async Task SetupLeaderBoardUI()
    {
        SubmitFormHolder.SetActive(false);
        loadingScreen.SetActive(true);
        Debug.Log("Query Leaderboard");
        var leaderboard = await gameBackend.QueryLeaderboard(10);

        Debug.Log($"Leaderboard Count: {leaderboard.Length}");

        foreach (var entry in leaderboard)
        {
            Debug.Log($"Leaderboard Entry, Email: {entry.email}, Points: {entry.points}");
            GameObject go = Instantiate(UIRef, RefParent);
            go.SetActive(true);
            LeaderBoardUIRef uIRef = go.GetComponent<LeaderBoardUIRef>();
            uIRef.PlayerName.text = entry.name;
            uIRef.Score.text = entry.points.ToString();
        }
        loadingScreen.SetActive(false);
        LeaderBoardHolder.SetActive(true);
    }

    public async Task SubmitScore(string name, string email, int points)
    {
        loadingScreen.SetActive(true);
        email = email.ToLower();

        var response = await FirebaseSubmitScoreOperation.Create().Call(name, email, points);

        if (response.IsError)
        {
            Debug.LogError($"Failed to Submit Score, Email: {email}, Points: {points}, Error: {response.Error}");
            return;
        }

        Debug.LogError($"Submit Result: {response.Value}");
        loadingScreen.SetActive(false);
    }


    public void ShowSubmitUI()
    {
        SubmitFormHolder.SetActive(true);
    }

    public void ValidateEmail(string email)
    {
        if (Regex.IsMatch(email, emailPattern))
        {
            Debug.Log("البريد الإلكتروني صحيح");
            errorMessage.text = "";
            IsCorrectEmail = true;
        }
        else
        {
            Debug.Log("البريد الإلكتروني غير صحيح");
            errorMessage.text = "الايميل المدخل غير صحيح";
            IsCorrectEmail = false;
        }
    }
    public async void SubmitScore()
    {
        if (IsCorrectEmail)
        {
            if (PlayerName.text != string.Empty || PlayerName.text != "")
            {
                await SubmitScore(PlayerName.text, PlayerEmail.text, gameManager.ColletedCoins);
                await SetupLeaderBoardUI();
            }
            else
            {
                errorMessage.text = "ادخل اسم مناسب";
            }

        }

    }
    public async void ShowLeaderBoard()
    {
        await SetupLeaderBoardUI();
    }
}
