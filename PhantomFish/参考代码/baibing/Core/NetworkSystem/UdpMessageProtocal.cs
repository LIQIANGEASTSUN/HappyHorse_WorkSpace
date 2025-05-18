using System.Collections;
using System.Collections.Generic;
using System.IO;
using Cookgame.Message;
using ProtoBuf;
using UnityEngine;

namespace Cookgame.Network
{
    public class UdpMessageProtocal : MessageProtocal
    {
        public const int UDP_KEY_SIZE =8;
        public override int HEAD_TOTAL_SIZE
        {
            get { return base.HEAD_TOTAL_SIZE + UDP_KEY_SIZE; }
        }
        
        public override int MessageEncode(IMessage message, MemoryStream outStream)
        {
            IGameMessage gameMessage = (IGameMessage)message;
            //客户端上行消息肯定是单线程，隐藏此处处理为共享上行Stream
            //if (gameMessage.IsUdpMsg)
            //    outStream.Seek(HEAD_TOTAL_SIZE + HEAD_UDP_SIZE, SeekOrigin.Begin);
            //else
            outStream.Seek(HEAD_TOTAL_SIZE, SeekOrigin.Begin);
            //if (gameMessage.CommandType == ProtocalGateWay.CMD_TYPE_GATE)
            //{
            //    gameMessage.CustomEncode(outStream);
            //}
            //else 
            if (gameMessage.MessageData != null)
            {
                ProtoBuf.Serializer.Serialize(outStream, gameMessage.MessageData);
                //			ProtoBuf.Serializer.NonGeneric.Serialize(outStream, gameMessage.MessageData);
            }
            EncodeBytes(message, outStream);

            int messageSize = (int)outStream.Position;//消息数据总长度（包括头)
            int writeCursor = 0;
            writeCursor = MessageUtils.writeShortToBuffer(mSendHeadBuffer, (short)(messageSize - HEAD_LENGTH_SIZE), writeCursor);  //写真实size
            //writeCursor = MessageUtils.writeIntToBuffer(mSendHeadBuffer, messageSize, writeCursor);  //写真实size
            writeCursor = MessageUtils.writeUintToBuffer(mSendHeadBuffer, (uint)gameMessage.MessageId, writeCursor);
            writeCursor = MessageUtils.writeInt64ToBuffer(mSendHeadBuffer, gameMessage.udpKeyId, writeCursor);

            outStream.Seek(0L, SeekOrigin.Begin);
            outStream.Write(mSendHeadBuffer, 0, HEAD_TOTAL_SIZE);
            outStream.Seek(messageSize, SeekOrigin.Begin);


            GameLog.Log($"SendUdpLog==> msgKey='{gameMessage.MessageId}'  Id='{gameMessage.udpKeyId}'  totalSize={messageSize}  msg={PrintUdp(outStream, messageSize)}");
            return messageSize;
        }

        public override bool MessageDecode(MemoryStream inStream, int dataSize)
        {
            int msgKey = GetInt(inStream);

            BaseMessage message = (BaseMessage) MessageDataFactory.CreateSCMessage(msgKey);
            dataSize -= HEAD_INFO_SIZE;
            long key = 0;
            if (message.NeedGetKey())
            {
                key = (long)GetInt(inStream) | ((long)GetInt(inStream) << 32);
                message.SetUdpMessageKeyId(key);
                dataSize -= UDP_KEY_SIZE;
            }
            GameLog.Log($"GetUdpLog==> msgKey='{msgKey}'  Id='{key}'  size={dataSize}  msg={PrintUdp(inStream, dataSize)}");
            DecodeBytes(message, inStream, dataSize);
            message.MessageData = MessageDataFactory.DeserializeMessageData(msgKey, inStream, dataSize);

            OnReceiveMessage?.Invoke(message);

            return true;
        }

        private int GetInt(MemoryStream inStream)
        {
            return (inStream.ReadByte() & 0xFF) | ((inStream.ReadByte() & 0xFF) << 8) | ((inStream.ReadByte() & 0xFF) << 16) | ((inStream.ReadByte() & 0xFF) << 24);
        }


        private string PrintUdp(MemoryStream inStream, int dataSize)
        {
            long pos = inStream.Position;
            inStream.Position = 0;
            System.Text.StringBuilder sb = new System.Text.StringBuilder();

            sb.Append("[");
            for (int i = 0; i < dataSize-1; i++)
            {
                if(i%4 == 0) sb.Append("|");
                sb.Append(inStream.ReadByte());
                sb.Append(", ");
            }
            sb.Append(inStream.ReadByte());
            sb.Append("]");

            inStream.Position = pos;
            return sb.ToString();
        }
    }
}
