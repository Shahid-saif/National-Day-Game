using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneControl : MonoBehaviour
{
    public bool Daytime = true;
    
    // Start is called before the first frame update
    void Start()
    {
        if (Daytime)
        {
            Shader.SetGlobalFloat("EmissionStrenght", 0);
        }
        else
        {
            Shader.SetGlobalFloat("EmissionStrenght", 1);
        }
        
        
    }
}
