using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityToolbarExtender;

public class ToolbarStart : MonoBehaviour
{
    public static readonly GUIStyle commandButtonStyle;

    static class ToolbarStyles
    {
        public static readonly GUIStyle commandButtonStyle;

        static ToolbarStyles()
        {
            commandButtonStyle = new GUIStyle("Command")
            {
                fontSize = 16,
                alignment = TextAnchor.MiddleCenter,
                imagePosition = ImagePosition.ImageAbove,
            };
        }
    }
    [InitializeOnLoad]
    public class ToolbarExtensionDraw
    {
        static ToolbarExtensionDraw()
        {
            ToolbarExtender.LeftToolbarGUI.Add(OnToolbarGUILeft);
            ToolbarExtender.RightToolbarGUI.Add(OnToolbarGUIRight);
        }

        static void OnToolbarGUILeft()
        {
            GUILayout.FlexibleSpace();
        
            if(GUILayout.Button(new GUIContent("Init", "切换到Init")))
            {
                if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                {
                    var lastScene = EditorSceneManager.GetActiveScene();
                    //EditorPrefs.SetString("lastScenePath", lastScene.path);
                    EditorSceneManager.OpenScene("Assets/Scenes/init.unity");
                }
            }
        }
        
        static void OnToolbarGUIRight()
        {
            GUILayout.FlexibleSpace();
            if(GUILayout.Button(new GUIContent("WorldEditor", "切换到世界场景")))
            {
                if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
                {
                    var lastScene = EditorSceneManager.GetActiveScene();
                    //EditorPrefs.SetString("lastScenePath", lastScene.path);
                    EditorSceneManager.OpenScene("Assets/Bundles/Scene/world.unity");
                }
            }
            
            if(GUILayout.Button(new GUIContent("导出Guide", "单独导出新手引导表")))
            {
                ExcelWindow.LoadTargetExcel("Guide");
            }
            // var curScenePath = EditorSceneManager.GetActiveScene().path;
            // if (curScenePath == "Assets/res/scene/common/scene/main.unity")
            // {
            //     var lastScenePath = EditorPrefs.GetString("lastScenePath");
            //     if (lastScenePath!=string.Empty)
            //     {
            //         if (GUILayout.Button(new GUIContent("Last Scene", "切换到上一个场景")))
            //         {
            //             if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
            //             {
            //                 EditorSceneManager.OpenScene(lastScenePath);
            //             }
            //         }
            //     }
            // }
            // else
            // {
            //     
            // }
            // if (GUILayout.Button(new GUIContent("Skill Editor", "打开技能编辑器")))
            // {
            //     if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
            //     {
            //         var lastScene = EditorSceneManager.GetActiveScene();
            //         EditorPrefs.SetString("lastScenePath", lastScene.path);
            //         EditorSceneManager.OpenScene("Assets/Thirds/ASkillEditor/SkillEditor.unity");
            //         AudioMgr.Instance.Init();
            //     }
            // }
        }
    }
}
