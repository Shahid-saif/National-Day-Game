using System;
using System.Threading.Tasks;

using UnityEngine;
using UnityEngine.Scripting;

[Preserve]
public class GameBackend : MonoBehaviour
{
    public static GameBackend Instance { get; private set; }

    [Preserve]
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    static void OnLoad()
    {
        var prefab = Resources.Load<GameObject>("Game Backend");

        var instance = Instantiate(prefab);

        instance.name = prefab.name;
        DontDestroyOnLoad(instance);
    }

    void Awake()
    {
        Instance = this;
    }

    public async Task SubmitScore(string name, string email, int points)
    {
        email = email.ToLower();

        var response = await FirebaseSubmitScoreOperation.Create().Call(name, email, points);

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
    public string name;
    public string email;
    public int points;
}