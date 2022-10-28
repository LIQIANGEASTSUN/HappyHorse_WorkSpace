using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Network
{
    public class UdpReceive
    {
        private const int intLength = 4;
        private Action<int, int, byte[]> _callBack;
        public UdpReceive()
        {
        }

        public void SetCompleteCallBack(Action<int, int, byte[]> callBacka)
        {
            _callBack = callBacka;
        }

        public void ReceiveMessage(byte[] bytesData)
        {
            int messageNumber = BitConverter.ToInt32(bytesData, 0);
            messageNumber = IPAddressTool.NetworkToHostOrderInt32(messageNumber);

            int packageCount = BitConverter.ToInt32(bytesData, intLength);
            packageCount = IPAddressTool.NetworkToHostOrderInt32(packageCount);

            int pcakageIndex = BitConverter.ToInt32(bytesData, intLength * 2);
            pcakageIndex = IPAddressTool.NetworkToHostOrderInt32(pcakageIndex);

            int bytesLength = BitConverter.ToInt32(bytesData, intLength * 3);
            bytesLength = IPAddressTool.NetworkToHostOrderInt32(bytesLength);

            int uid = BitConverter.ToInt32(bytesData, intLength * 4);
            uid = IPAddressTool.NetworkToHostOrderInt32(uid);

            int cmdID = BitConverter.ToInt32(bytesData, intLength * 5);
            cmdID = IPAddressTool.NetworkToHostOrderInt32(cmdID);

            byte[] dataBytes = new byte[bytesLength];
            Array.Copy(bytesData, intLength * 6, dataBytes, 0, bytesLength);
        }

        private void CompleteBuff(byte[] bytes)
        {

        }
    }

    public class UdpReceiveDataController
    {
        private List<ReceiveData> receiveList = new List<ReceiveData>();

        public void Receive(int messageNumber, int packageCount, int pcakageIndex, int bytesLength, int uid, int cmdID, byte[] dataBytes)
        {
            if (receiveList.Count <= 0)
            {

            }
        }

        private int InsertIndex(List<ReceiveData> list, int value)
        {
            int left = 0;
            int right = list.Count - 1;
            int index = 0;
            while (left <= right)
            {
                int mid = (left + right) / 2;
                if (list[mid]._messageNumber > value)
                {
                    right = mid - 1;
                }
                else if (list[mid]._messageNumber == value)
                {
                    index = mid;
                    break;
                }
                else
                {
                    left = mid + 1;
                }
            }

            return index;
        }

    }

    public class ReceiveData
    {
        public int _messageNumber;
        public int _uid;
        public int _cmdId;
        public int _packageCount;
        public Dictionary<int, byte[]> _dataDic = new Dictionary<int, byte[]>();

        public ReceiveData(int messageNumber, int uid, int cmdId, int packageCount)
        {
            _messageNumber = messageNumber;
            _uid = uid;
            _cmdId = cmdId;
        }

        public bool Add(int index, byte[] data)
        {
            if (_dataDic.ContainsKey(index))
            {
                return false;
            }
            _dataDic[index] = data;
            return _dataDic.Count == _packageCount;
        }
    }

}