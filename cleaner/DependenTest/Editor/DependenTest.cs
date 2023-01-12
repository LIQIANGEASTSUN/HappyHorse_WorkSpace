using UnityEngine;
using UnityEditor;
using System.IO;

public class AssetDepend
{

    [MenuItem("Assets/AssetDepend")]
    static void Depend()
    {
        string[] guids = Selection.assetGUIDs;

        foreach (var guid in guids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            // 判断路径是文件
            if (File.Exists(assetPath))
            {
                Dependencies(assetPath);
            }
        }

    }

    static void Dependencies(string assetPath)
    {
        // 是否迭代
        bool recursive = false;
        // 获取文件依赖的资源路径
        string[] dependencies = AssetDatabase.GetDependencies(assetPath, recursive);
        foreach (var path in dependencies)
        {
            if (path.Contains(".png"))
            {
                Debug.Log(path);
            }
        }
    }

}
