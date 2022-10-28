using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace Network
{

    public class IPAddressTool
    {
        public static int HostToNetworkOrderInt32(int value)
        {
            if (BitConverter.IsLittleEndian)
            {
                return IPAddress.HostToNetworkOrder(value);
            }
            return value;
        }

        public static int HostToNetworkOrderInt64(int value)
        {
            if (BitConverter.IsLittleEndian)
            {
                return IPAddress.HostToNetworkOrder(value);
            }
            return value;
        }

        public static int NetworkToHostOrderInt32(int value)
        {
            if (BitConverter.IsLittleEndian)
            {
                return IPAddress.NetworkToHostOrder(value);
            }
            return value;
        }

        public static Int64 NetworkToHostOrderInt64(Int64 value)
        {
            if (BitConverter.IsLittleEndian)
            {
                return IPAddress.NetworkToHostOrder(value);
            }
            return value;
        }

        public static byte[] HostToNetworkOrderByte(int value)
        {
            value = HostToNetworkOrderInt32(value);
            return BitConverter.GetBytes(value);
        }

        public static int NetworkToHostOrderInt32(byte[] byteData)
        {
            int value = BitConverter.ToInt32(byteData, 0);
            return NetworkToHostOrderInt32(value);
        }

        public static Int64 NetworkToHostOrderInt64(byte[] byteData)
        {
            Int64 value = BitConverter.ToInt64(byteData, 0);
            return NetworkToHostOrderInt64(value);
        }
    }

    class SendData
    {
        #region Tcp
        /// <summary>
        /// 发送的Tcp消息
        /// length = uid字节长度 + cmdID 字节长度 + bytesData字节长度
        /// 发送消息内容为：length + uid + cmdID + bytesData
        /// </summary>
        /// <param name="uid"></param>
        /// <param name="cmdID"></param>
        /// <param name="bytesData"></param>
        /// <returns></returns>
        public static byte[] ToTcpByte(int messageId, int seqId, byte[] bytesData)
        {
            byte[] msgIdBytes = IPAddressTool.HostToNetworkOrderByte(messageId);
            byte[] seqIdBytes = IPAddressTool.HostToNetworkOrderByte(seqId);

            int length = msgIdBytes.Length + seqIdBytes.Length + bytesData.Length;  // uid + cmd + 内容
            length += 4;
            byte[] lengthBytes = IPAddressTool.HostToNetworkOrderByte(length);

            byte[] sendBytes = new byte[length];
            long index = 0;
            Copy(lengthBytes, sendBytes, lengthBytes.Length, ref index);
            Copy(msgIdBytes, sendBytes, msgIdBytes.Length, ref index);
            Copy(seqIdBytes, sendBytes, seqIdBytes.Length, ref index);
            Copy(bytesData, sendBytes, bytesData.Length, ref index);

            return sendBytes;
        }
        #endregion

        private static void Copy(Array sourceArray, Array destinationArray, long length, ref long destinationIndex)
        {
            Copy(sourceArray, 0, destinationArray, length, ref destinationIndex);
        }

        private static void Copy(Array sourceArray, int sourceIndex, Array destinationArray, long length, ref long destinationIndex)
        {
            Array.Copy(sourceArray, sourceIndex, destinationArray, destinationIndex, length);
            destinationIndex += length;
        }

    }
}
