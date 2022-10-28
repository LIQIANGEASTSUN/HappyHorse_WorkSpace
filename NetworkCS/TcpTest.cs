using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Network;
using System.Text;
using System;

public class TcpTest : MonoBehaviour
{
    private TcpReceive _tcpReceive;
    // Start is called before the first frame update
    void Start()
    {
        _tcpReceive = new TcpReceive();
        _tcpReceive.SetCompleteCallBack(ReceiveComplete);

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            UnityEngine.Debug.LogError("Test");
            Test();
        }
    }

    private void Test()
    {
        //UnityEngine.Random.seed = 1000;

        List<byte[]> list = new List<byte[]>();
        int count = 0;

        for (int i = 0; i < 15; ++i)
        {
            int messageId = i;
            int seqId = i;

            int value = i * 1000;

            string str = string.Empty;
            for (int j = 0; j < 3; ++j)
            {
                str += value.ToString();
            }

            byte[] bytes = Encoding.ASCII.GetBytes(str);
            byte[] bytesData = SendData.ToTcpByte(messageId, seqId, bytes);

            count += bytesData.Length;
            list.Add(bytesData);
        }

        byte[] byteS = new byte[count];
        count = 0;
        foreach(var data in list)
        {
            Array.Copy(data, 0, byteS, count, data.Length);
            count += data.Length;
        }

        int max = 50;
        int index = 0;

        int sendCount = 0;
        while (count > 0)
        {
            int random = UnityEngine.Random.Range(1, max);
            random = Math.Min(random, count);

            byte[] sendByte = new byte[random];
            Array.Copy(byteS, index, sendByte, 0, random);

            count -= random;
            index += random;

            sendCount += random;
            UnityEngine.Debug.LogError("Send:" + random + "     " + (sendCount));
            if (sendCount == 242)
            {
                int a = 0;
            }

            _tcpReceive.ReceiveMessage(sendByte.Length, sendByte);
        }
    }

    private void ReceiveComplete(int uid, int cmdID, byte[] byteData)
    {
        string content = Encoding.ASCII.GetString(byteData);
        UnityEngine.Debug.LogError("uid : " + uid + "    cmdID : " + cmdID + "   content : " + content);
    }

}

