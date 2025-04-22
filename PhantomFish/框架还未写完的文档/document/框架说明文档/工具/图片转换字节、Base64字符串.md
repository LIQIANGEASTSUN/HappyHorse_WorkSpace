# 图片转换字节、Base64字符串


图片转换 <br>
用途：当图片需要通过网络传输时 <br>
方案一：将图片转换为 byte 数组 <br>
方案二：当接收的某一方不能通过字节传输，而只能支持铭文字符串传输，那么可以将 方案一的 byte 数组，进一步处理为 Base64 字符串，然后传输 <br>


项目中 Texture2DTransform.cs


```csharp
/// <summary>
/// 图片转化为 byte 数组
/// </summary>
/// <param name="texture">图片需要读写，所以要打开 Write/Read</param>
/// <returns></returns>
public static byte[] Texture2DToBytes(Texture2D texture)


/// <summary>
/// 图片转化为 base64 编码字符串
/// </summary>
/// <param name="texture">图片需要读写，所以要打开 Write/Read</param>
/// <returns></returns>
public static string Texture2DToBase64(Texture2D texture)


/// <summary>
/// 图片转化为 base64 编码字符串,并且包含 base64 信息头
/// 为什么要加上 "data:image/png;base64,"
/// 这是一个标准，加上这个头信息，会让接收方知道，现在收到的字符串是一张图片，png格式，
/// 并且转换成base64字符串了。
/// 如果收发双方都是你自己，你也可以不用加这个信息。
/// 这个信息对于图片解码本身是无意义的，所以接收方在把字符串转图片的时候，还需要把这段去掉。
/// </summary>
/// <param name="texture"></param>
/// <returns></returns>
public static string Texture2DToBase64WithHeader(Texture2D texture)



/// <summary>
/// byte 数组转换为 Texture2D
/// </summary>
/// <param name="bytes"></param>
/// <returns></returns>
public static Texture2D BytesToTexture2D(byte[] bytes)


/// <summary>
/// Base64 编码字符串，转化为 Texture2D
/// </summary>
/// <param name="base64String"></param>
/// <returns></returns>
public static Texture2D Base64StringToTexture2D(string base64String)


/// <summary>
/// 带有信息头的，Base64 编码字符串，转化为 Texture2D
/// </summary>
/// <param name="base64String"></param>
/// <returns></returns>
public static Texture2D Base64StringWithHeaderToTexture2D(string base64String)

```



测试代码 Testure2DTransformTest.cs

```csharp
using UnityEngine;
using UnityEditor;
using PFramework;

public class Testure2DTransformTest : MonoBehaviour
{
    private string path = "Assets/Scripts/Frame/UtilsTools/Texture2DTransform/AAA.png";

    private void Load()
    {
        Texture2D texture2D = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        byte[] bytes = Texture2DTransform.Texture2DToBytes(texture2D);

        Texture2D newTexture = Texture2DTransform.BytesToTexture2D(bytes);
        SetTexture(newTexture);
    }

    private void Load2()
    {
        Texture2D texture2D = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        string base64String = Texture2DTransform.Texture2DToBase64(texture2D);

        string base64WithHeader = Texture2DTransform.Texture2DToBase64WithHeader(texture2D);
        FileWriteWithLine fileWriteWithLine = new FileWriteWithLine("G:/Base64String.txt", true);
        fileWriteWithLine.AppendLine(base64WithHeader);
        fileWriteWithLine.Close();

        Texture2D newTexture = Texture2DTransform.Base64StringToTexture2D(base64String);
        SetTexture(newTexture);
    }


    private void SetTexture(Texture2D texture)
    {
        GetComponent<Renderer>().material.mainTexture = texture;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            Load();
        }

        if (Input.GetKeyDown(KeyCode.D))
        {
            Load2();
        }

        if (Input.GetKeyDown(KeyCode.W))
        {
            SetTexture(null);
        }
    }
}

```



















