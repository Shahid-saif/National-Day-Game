using System;

using UnityEngine;

namespace FirebaseWebGL.Scripts.Objects
{
    [Serializable]
    public class FirebaseError
    {
        public string code;
        public string message;
        public string details;

        public override string ToString()
        {
            return $"Firebase Error, Code: ({code}), Message: ({message}), Details: ({details})";
        }

        public static class Codes
        {
            public const string EmailAlreadyInUse = "auth/email-already-in-use";
        }

        public static FirebaseError Parse(string json) => JsonUtility.FromJson<FirebaseError>(json);
    }
}