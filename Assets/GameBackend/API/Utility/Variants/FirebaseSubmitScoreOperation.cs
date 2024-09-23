using Cysharp.Threading.Tasks;

using FirebaseWebGL.Scripts.FirebaseBridge;
using FirebaseWebGL.Scripts.Objects;

public class FirebaseSubmitScoreOperation : FirebaseOperation<FirebaseSubmitScoreOperation, string, string>
{
    string Name;
    string Email;
    int Points;

    public UniTask<Response<string, FirebaseError>> Call(string name, string email, int points)
    {
        this.Name = name;
        this.Email = email;
        this.Points = points;

        return Invoke();
    }

    protected override void Invoke(InvokeParamters paramters)
    {
        FirebaseFirestore.SubmitScore(Name, Email, Points, ObjectName, paramters.ValueHandlerCallback, paramters.ErrorHandlerCallback);
    }

    public override string MediumParser(string medium) => medium;
}