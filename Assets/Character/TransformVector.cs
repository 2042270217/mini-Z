using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class TransformVector : MonoBehaviour
{
    public Transform Forward;
    public Transform Right;
    Material[] m_Materials;
    public SkinnedMeshRenderer sRenderer;
    // Start is called before the first frame update
    void Start()
    {
        if (sRenderer == null)
        {
            Debug.Log("renderer is null");
        }
        else
        {
            m_Materials = sRenderer.sharedMaterials;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (m_Materials != null)
        {
            foreach (Material mat in m_Materials)
            {
                mat.SetVector("_ForwardVec", Vector3.Normalize(Forward.position - transform.position));
                mat.SetVector("_RightVec", Vector3.Normalize(Right.position - transform.position));
            }
        }
        else
        {
            Debug.Log("material is null");
        }
    }
}
