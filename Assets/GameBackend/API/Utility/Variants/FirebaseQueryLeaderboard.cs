
using Cysharp.Threading.Tasks;

using FirebaseWebGL.Scripts.FirebaseBridge;
using FirebaseWebGL.Scripts.Objects;

using UnityEngine;

public class FirebaseQueryLeaderboard : FirebaseOperation<FirebaseQueryLeaderboard, LeaderboardEntry[], string>
{
    int Limit;

    public UniTask<Response<LeaderboardEntry[], FirebaseError>> Call(int limit)
    {
        this.Limit = limit;

        return Invoke();
    }

    protected override void Invoke(InvokeParamters paramters)
    {
        FirebaseFirestore.QueryLeaderboard(Limit, ObjectName, paramters.ValueHandlerCallback, paramters.ErrorHandlerCallback);
    }

    public override LeaderboardEntry[] MediumParser(string medium)
    {
        Debug.Log($"Query Result: {medium}");

        return UnityJsonArrayWrapper<LeaderboardEntry>.ParseJSON(medium);
    }
}