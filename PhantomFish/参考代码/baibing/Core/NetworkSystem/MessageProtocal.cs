using ProtoBuf;
using System;
using System.IO;
using Cookgame.Message;

namespace Cookgame.Network
{
    public class MessageProtocal : IMessageProtocal
    {
        public const int HEAD_LENGTH_SIZE = 2;//4;
        public const int HEAD_INFO_SIZE = 4;

        public virtual int HEAD_TOTAL_SIZE
        {
            get { return HEAD_INFO_SIZE + HEAD_LENGTH_SIZE; }
        }

        private const int RECV_BUFFER_SIZE = 65536;
        private const int SEND_BUFFER_SIZE = 65536;

        //****************************************************************
        protected byte[] mSendHeadBuffer;

        private MemoryStream _recvBuffer;
        private MemoryStream _sendStream;

        private int _lastMsgLength;

        private byte[] _sendBuffer;

        public ProtocalProcessFunc _onReceiveMessage;

        public DataProcess _onMessageEncoded;

        public MessageProtocal()
        {
            mSendHeadBuffer = new byte[HEAD_TOTAL_SIZE];
            _sendBuffer = new byte[SEND_BUFFER_SIZE];
            _sendStream = new MemoryStream(_sendBuffer);

            _recvBuffer = new MemoryStream();
            _lastMsgLength = -1;
        }

        public ProtocalProcessFunc OnReceiveMessage
        {
            get { return _onReceiveMessage; }
            set { _onReceiveMessage = value; }
        }

        public DataProcess OnMessageEncoded
        {
            get { return _onMessageEncoded; }
            set { _onMessageEncoded = value; }
        }

        //MARK: Send Msg
        public void SendNetMessage(IMessage message)
        {
            if (_onMessageEncoded != null && message != null)
            {
                int dataSize = MessageEncode(message, _sendStream);
                if (dataSize < HEAD_TOTAL_SIZE)
                {
                    //GameLog.Log("network", "Message encoding failed");
                }
                else
                {
                    _onMessageEncoded(_sendBuffer, dataSize);
                }
            }
        }

        public DecodeStatus ReceiveNetData(byte[] msgData, int length)
        {
            //就新数据添加到buffer末尾
            this._recvBuffer.Position = this._recvBuffer.Length;
            this._recvBuffer.Write(msgData, 0, length);
            this._recvBuffer.Position = 0L;
            int dataSize = (int)this._recvBuffer.Length;
            int leftSize = dataSize;

            //确保至少能读出消息ID的buffer长度
            if (this._lastMsgLength < 0 && leftSize < HEAD_LENGTH_SIZE)
            {
                return DecodeStatus.Ignore;
            }

            //从buffer头开始尝试解析            
            DecodeStatus result = DecodeStatus.Normal;
            while (result == DecodeStatus.Normal)
            {
                if (this._lastMsgLength < 0)
                {
                    //读取消息数据长度
                    _lastMsgLength = GetMessageSize(_recvBuffer);
                    leftSize = (int)(dataSize - this._recvBuffer.Position);
                    if (this._lastMsgLength > RECV_BUFFER_SIZE || this._lastMsgLength < HEAD_INFO_SIZE)
                    {
                        result = DecodeStatus.Invalid;
                    }
                }
                if (result == DecodeStatus.Normal)
                {
                    if (leftSize >= this._lastMsgLength)
                    {
                        if (!MessageDecode(_recvBuffer, _lastMsgLength))
                        {
                            GameLog.Log("network", "Decode message failed");
                        }

                        //将待读取数据长度置为-1
                        this._lastMsgLength = -1;

                        //重新计算是否还要继续读取
                        leftSize = (int)(dataSize - this._recvBuffer.Position);
                        if (leftSize < HEAD_LENGTH_SIZE)
                            result = DecodeStatus.Ignore;
                    }
                    else
                    {
                        //消息体不完整，直接结束本次读取，等待下次数据到达
                        result = DecodeStatus.Ignore;
                    }
                }
            }
            //整理buffer，剔除已经读取的数据
            if (result == DecodeStatus.Ignore)
            {
                leftSize = (int)(dataSize - this._recvBuffer.Position);
                if (leftSize > 0)
                {
                    byte[] buffer = this._recvBuffer.GetBuffer();
                    Array.Copy(buffer, this._recvBuffer.Position, buffer, 0L, (long)leftSize);
                }
                this._recvBuffer.Position = 0L;
                this._recvBuffer.SetLength((long)leftSize);
            }
            return result;
        }

        public int GetMessageSize(MemoryStream inStream)
        {
            ////去掉长度所占据的4个字节
            //return MessageUtils.readInt32FromStream(inStream) - HEAD_LENGTH_SIZE;

            //去掉长度所占据的2个字节
            return MessageUtils.readShortFromStream(inStream); // - HEAD_LENGTH_SIZE;
        }

        public virtual int MessageEncode(IMessage message, MemoryStream outStream)
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
                ProtoBuf.Serializer.Serialize<IExtensible>(outStream, gameMessage.MessageData);
                //			ProtoBuf.Serializer.NonGeneric.Serialize(outStream, gameMessage.MessageData);
            }
            EncodeBytes(message, outStream);

            int messageSize = (int)outStream.Position;//消息数据总长度（包括头)

            int writeCursor = 0;
            writeCursor = MessageUtils.writeShortToBuffer(mSendHeadBuffer, (short)(messageSize - HEAD_LENGTH_SIZE), writeCursor);  //写真实size
            //writeCursor = MessageUtils.writeIntToBuffer(_sendHeadBuffer, messageSize, writeCursor);  //写真实size
            writeCursor = MessageUtils.writeUintToBuffer(mSendHeadBuffer, (uint)gameMessage.MessageId, writeCursor);

            outStream.Seek(0L, SeekOrigin.Begin);
            outStream.Write(mSendHeadBuffer, 0, HEAD_TOTAL_SIZE);
            outStream.Seek(messageSize, SeekOrigin.Begin);
            return messageSize;
        }

        //MARK: Msg Decode
        public virtual bool MessageDecode(MemoryStream inStream, int dataSize)
        {
            IGameMessage message;
            //if (commandType == ProtocalGateWay.CMD_TYPE_GATE)
            //{
            //    message = MessageDataFactory.CreateGatewaySCMessage(commandId);
            //    if (message != null)
            //    {
            //        message.CustomDecode(inStream, dataSize);
            //        if (OnReceiveMessage != null)
            //            OnReceiveMessage(message);
            //    }
            //}
            //else
            {
                int msgKey =  (inStream.ReadByte() & 0xFF)   
                            | ((inStream.ReadByte() & 0xFF) << 8)
                            | ((inStream.ReadByte() & 0xFF) << 16)
                            | ((inStream.ReadByte() & 0xFF) << 24);

                message = MessageDataFactory.CreateSCMessage(msgKey);
                dataSize -= HEAD_INFO_SIZE;

                DecodeBytes(message, inStream, dataSize);

                message.MessageData = MessageDataFactory.DeserializeMessageData(msgKey, inStream, dataSize); ;
                if (OnReceiveMessage != null)
                    OnReceiveMessage(message);
            }
            return true;
        }

        protected void EncodeBytes(IMessage message, MemoryStream outStream)
        {
            BaseMessage bm = (BaseMessage)message;
            if (bm.Stream != null)//可能 bm.Stream.Length == 0 没有消息体
            {
                outStream.Write(bm.Stream, 0, bm.Stream.Length);
            }
        }

        protected void DecodeBytes(IGameMessage message, MemoryStream inStream, int dataSize)
        {
            long pos = inStream.Position;
            BaseMessage bm = (BaseMessage)message;
            bm.Stream = new byte[dataSize];
            inStream.Read(bm.Stream, 0, dataSize);
            inStream.Position = pos;
        }
    }

}