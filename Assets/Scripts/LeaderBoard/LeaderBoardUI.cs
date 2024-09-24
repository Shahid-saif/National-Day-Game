using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

using TMPro;

using UnityEngine;

public class LeaderBoardUI : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] GameBackend gameBackend => GameBackend.Instance;
    [SerializeField] GameManager gameManager;

    [Header("LeaderBoard")]
    [SerializeField] GameObject UIRef;
    [SerializeField] GameObject UIRefResult;
    [SerializeField] RectTransform RefParent;
    [SerializeField] RectTransform RefParentResultMenu;
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

    List<GameObject> list;
    List<GameObject> ResultMenuList;

    public GameObject CatchMenu;

    void Awake()
    {
        list = new();
    }

    private void Start()
    {
        gameManager = FindAnyObjectByType<GameManager>();
        PlayerEmail.onEndEdit.AddListener(ValidateEmail);
    }
    public async Task SetupLeaderBoardUI()
    {
        try
        {


            SubmitFormHolder.SetActive(false);
            loadingScreen.SetActive(true);
            Debug.Log("Query Leaderboard");
            var leaderboard = await gameBackend.QueryLeaderboard(50);

            Debug.Log($"Leaderboard Count: {leaderboard.Length}");

            loadingScreen.SetActive(false);
            LeaderBoardHolder.SetActive(true);

            foreach (var entry in list)
                Destroy(entry);
            foreach (var entry in leaderboard)
            {
                Debug.Log($"Leaderboard Entry, Email: {entry.email}, Points: {entry.points}");
                GameObject go = Instantiate(UIRef, RefParent);
                go.SetActive(true);
                LeaderBoardUIRef uIRef = go.GetComponent<LeaderBoardUIRef>();

                uIRef.PlayerName.text = entry.name;
                uIRef.Score.text = entry.points.ToString();
                list.Add(go);
                uIRef.PlayerNumber.text = (list.IndexOf(go) + 1).ToString();
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex);
        }
    }
    public async Task SetupLeaderBoardUIForResultMenu()
    {
        try
        {
            SubmitFormHolder.SetActive(false);
            loadingScreen.SetActive(true);
            Debug.Log("Query Leaderboard");
            var leaderboard = await gameBackend.QueryLeaderboard(3);

            Debug.Log($"Leaderboard Count: {leaderboard.Length}");

            loadingScreen.SetActive(false);
            LeaderBoardHolder.SetActive(true);

            foreach (var entry in ResultMenuList)
                Destroy(entry);
            foreach (var entry in leaderboard)
            {
                Debug.Log($"Leaderboard Entry, Email: {entry.email}, Points: {entry.points}");
                GameObject go = Instantiate(UIRefResult, RefParentResultMenu);
                go.SetActive(true);
                LeaderBoardUIRef uIRef = go.GetComponent<LeaderBoardUIRef>();

                uIRef.PlayerName.text = entry.name;
                uIRef.Score.text = entry.points.ToString();
                ResultMenuList.Add(go);
                uIRef.PlayerNumber.text = (ResultMenuList.IndexOf(go) + 1).ToString();
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex);
        }
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
                await gameBackend.SubmitScore(PlayerName.text, PlayerEmail.text, gameManager.ColletedCoins);
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
    public async void ShowLeaderBoardResultMenu()
    {
        await SetupLeaderBoardUIForResultMenu();
    }
}
