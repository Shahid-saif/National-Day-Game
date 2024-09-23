public struct Response<TValue, TError>
{
    public ResponseType Type { get; }

    public TValue Value { get; }
    public TError Error { get; }

    public bool IsSuccess => Type is ResponseType.Success;
    public bool IsError => Type is ResponseType.Error;

    public Response(ResponseType type, TValue value, TError error)
    {
        this.Type = type;
        this.Value = value;
        this.Error = error;
    }

    public static implicit operator Response<TValue, TError>(TValue value) => FromResult(value);
    public static implicit operator Response<TValue, TError>(TError error) => FromError(error);

    public static Response<TValue, TError> FromResult(TValue error) => new Response<TValue, TError>(ResponseType.Success, error, default);
    public static Response<TValue, TError> FromError(TError error) => new Response<TValue, TError>(ResponseType.Success, default, error);
}

public enum ResponseType
{
    Error, Success
}