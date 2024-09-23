using System;
using System.Threading.Tasks;

using Cysharp.Threading.Tasks;

using UnityEngine;
using UnityEngine.Scripting;

[Preserve]
public class GameBackend : MonoBehaviour
{
    [Preserve]
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    static void OnLoad()
    {
        var prefab = Resources.Load<GameObject>("Game Backend");

        var instance = Instantiate(prefab);

        instance.name = prefab.name;
        DontDestroyOnLoad(instance);
    }

    void Start()
    {
        Procedure().Forget();
        async UniTask Procedure()
        {
            var email = "moe4baker@gmail.com";
            var points = 42;

            Debug.Log("Submit Score");
            await SubmitScore(email, points);

            Debug.Log("Query Leaderboard");
            var leaderboard = await QueryLeaderboard(10);

            Debug.Log($"Leaderboard Count: {leaderboard.Length}");

            foreach (var entry in leaderboard)
                Debug.Log($"Leaderboard Entry, Email: {entry.email}, Points: {entry.points}");
        }
    }

    public async Task SubmitScore(string email, int points)
    {
        var response = await FirebaseSubmitScoreOperation.Create().Call(email, points);

        if (response.IsError)
        {
            Debug.LogError($"Failed to Submit Score, Email: {email}, Points: {points}, Error: {response.Error}");
            return;
        }

        Debug.LogError($"Submit Result: {response.Value}");
    }

    public async Task<LeaderboardEntry[]> QueryLeaderboard(int limit)
    {
        var response = await FirebaseQueryLeaderboard.Create().Call(limit);

        if (response.IsError)
        {
            Debug.LogError($"Failed to Query Leaderboard, Limit: {limit}, Error: {response.Error}");
            return Array.Empty<LeaderboardEntry>();
        }

        return response.Value;
    }
}

[Serializable]
public struct LeaderboardEntry
{
    public string email;
    public int points;

    public LeaderboardEntry(string email, int points)
    {
        this.email = email;
        this.points = points;
    }
}