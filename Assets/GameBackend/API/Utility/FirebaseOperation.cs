using System;
using System.Text;

using Cysharp.Threading.Tasks;

using FirebaseWebGL.Scripts.Objects;

using UnityEngine;

public abstract class FirebaseOperation : MonoBehaviour
{
    protected string ObjectName => gameObject.name;

    public static T Create<T>()
        where T : FirebaseOperation
    {
        var id = Guid.NewGuid().ToString();

        var gameObject = new GameObject(id);
        var component = gameObject.AddComponent<T>();

        return component;
    }
}
public abstract class FirebaseOperation<TSelf, TValue, TMedium> : FirebaseOperation
    where TSelf : FirebaseOperation<TSelf, TValue, TMedium>
{
    UniTaskCompletionSource<Response<TValue, FirebaseError>> Operation;

    protected virtual void Awake()
    {
        Operation = new();
    }

    protected virtual async UniTask<Response<TValue, FirebaseError>> Invoke()
    {
        var paramters = new InvokeParamters()
        {
            ValueHandlerCallback = nameof(FirebaseValueHandler),
            ErrorHandlerCallback = nameof(FirebaseErrorHandler)
        };
        Invoke(paramters);

        var response = await Operation.Task;

        Destroy(gameObject);

        return response;
    }

    protected abstract void Invoke(InvokeParamters paramters);
    public struct InvokeParamters
    {
        public string ValueHandlerCallback;
        public string ErrorHandlerCallback;
    }

    void FirebaseValueHandler(TMedium output)
    {
        var value = MediumParser(output);
        Operation.TrySetResult(value);
    }
    public abstract TValue MediumParser(TMedium medium);

    void FirebaseErrorHandler(string output)
    {
        var error = FirebaseError.Parse(output);
        Operation.TrySetResult(error);
    }

    public static TSelf Create()
    {
        var id = Guid.NewGuid().ToString();

        var gameObject = new GameObject(id);
        var component = gameObject.AddComponent<TSelf>();

        return component;
    }
}

public struct UnityJsonArrayWrapper<T>
{
    public T[] Data;

    public UnityJsonArrayWrapper(T[] data)
    {
        this.Data = data;
    }

    public static T[] ParseJSON(string value)
    {
        var builder = new StringBuilder(value.Length + 20);

        builder.Append("{ \"Data\": ");
        builder.Append(value);
        builder.Append(" }");

        var json = builder.ToString();

        var array = JsonUtility.FromJson<UnityJsonArrayWrapper<T>>(json);

        return array.Data;
    }
}