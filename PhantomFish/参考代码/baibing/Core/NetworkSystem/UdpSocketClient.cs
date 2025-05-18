using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using Cookgame.Message;
using UnityEngine;

namespace Cookgame.Network
{
    public class UdpSocketClient : SocketClient, IMessageProtocal
    {
        private EndPoint _remoteIPPoint = null;
        private EndPoint _receiveIPPoint = null;
        private IAsyncResult _result;
        private IMessageProtocal _messageProtocal;
        private ProtocalProcessFunc _onReceiveMessage;
        private DataProcess _onReceiveDataNotify;
        private Queue<IMessage> _receiveWaitingMsgQueue = new Queue<IMessage>();
        private Queue<IMessage> _receiveMsgQueue = new Queue<IMessage>();
        private static readonly object _receiveLock = new object();

        private const int BufferSize = ushort.MaxValue;
        private byte[] _socketAsyncBuffer = new byte[BufferSize];

        public IMessageProtocal MessageProtocal
        {
            get { return _messageProtocal; }
            set
            {
                if (_messageProtocal != null)
                {
                    _messageProtocal.OnReceiveMessage = null;
                    _messageProtocal.OnMessageEncoded = null;
                }

                _messageProtocal = value;
                if (_messageProtocal != null)
                {
                    _messageProtocal.OnReceiveMessage = DoReceiveMessage;
                    _messageProtocal.OnMessageEncoded = WillSendData;
                }
            }
        }

        public override bool IsConnected => Status == ConnectionStatus.Connected;

        public override void Connect(string ip, int port)
        {
            Close();
            if (string.IsNullOrEmpty(ip) || port < 0 || port > ushort.MaxValue)
            {
                return;
            }

            OnReceiveDataNotify = DoReceiveDataFromNet;
            _remoteIPPoint = new IPEndPoint(IPAddress.Parse(ip), port);
            _receiveIPPoint = new IPEndPoint(IPAddress.Any, 0);

            IPAddress[] localPs = Dns.GetHostAddresses(ip);
            AddressFamily addressFamily = AddressFamily.InterNetwork;
            if (localPs[0].AddressFamily != AddressFamily.InterNetwork)// is ipv4 or ipv6
            {
                addressFamily = AddressFamily.InterNetworkV6;
            }
            mSocket = new Socket(addressFamily, SocketType.Dgram, ProtocolType.Udp);
            mSocket.Bind(_receiveIPPoint);

            Status = ConnectionStatus.Connected;

            GameLog.Log("network", $"UdpSocketClient  Connect ! ip={ip}  port={port}");
            _result = mSocket.BeginReceiveFrom(_socketAsyncBuffer, 0, BufferSize, SocketFlags.None, ref _remoteIPPoint, OnDataReceived, null);
        }

        #region IMessageProtocal
        //Socket => NetWork => Message
        public ProtocalProcessFunc OnReceiveMessage
        {
            get { return _onReceiveMessage; }
            set { _onReceiveMessage = value; }
        }
        //NotUse
        public DataProcess OnMessageEncoded { get; set; }
        //Encode msg  OnMessageEncoded => WillSendData
        public void SendNetMessage(IMessage message)
        {
            _messageProtocal.SendNetMessage(message);
        }
        //decode msg =>DoReceiveMessage
        public DecodeStatus ReceiveNetData(byte[] msgData, int length)
        {
            return _messageProtocal.ReceiveNetData(msgData, length);
        }
        #endregion

        private bool WillSendData(byte[] buf, int dataSize)
        {
            SendData(buf, dataSize);
            return true;
        }

        public override void SendData(byte[] buf, int dataSize)
        {
            if (mSocket == null || Status != ConnectionStatus.Connected)
                return;

            if (buf == null || dataSize <= 0)
                return;

            try
            {
                mSocket.BeginSendTo(buf, 0, dataSize, SocketFlags.None, _remoteIPPoint, iAsyncResult =>
                {
                    if (iAsyncResult.IsCompleted)
                    {
                        mSocket.EndSendTo(iAsyncResult);
                    }
                }, null);
            }
            catch (Exception ex)
            {
                GameLog.Log("network", ex);
                //Close();
                //throw;
            }
        }

        public void OnDataReceived(IAsyncResult result)
        {
            if (result.IsCompleted && mSocket != null)
            {
                try
                {
                    int len = mSocket.EndReceiveFrom(result, ref _remoteIPPoint);
                    if (_onReceiveDataNotify != null)
                    {

                        if (!_onReceiveDataNotify(_socketAsyncBuffer, len))
                        {
                            GameLog.LogError("network", "ParseReceiveData _serverDataNotify Invalid package");
                            //this.Close();
                            //throw new Exception("Invalid package length!");
                        }
                    }

                }
                catch (Exception)
                {
                    // ignored
                }
                finally
                {
                    //再次启动接收消息
                    _result = mSocket.BeginReceiveFrom(_socketAsyncBuffer, 0, BufferSize, SocketFlags.None,
                        ref _remoteIPPoint, OnDataReceived, null);
                }
            }
        }

        private bool DoReceiveDataFromNet(byte[] data, int length)
        {
            return (ReceiveNetData(data, length) != DecodeStatus.Invalid);
        }

        private void DoReceiveMessage(IMessage message)
        {
            if (message != null)
            {
                GameLog.Log("network", $"Receive<color=red>Udp</color>Message  {(ClientMessage.ClientMsgID)message.MessageId}");
                ((BaseMessage)message).SetUdpMessageKeyId(0);
                _receiveWaitingMsgQueue.Enqueue(message);
            }
        }

        public override DataProcess OnReceiveDataNotify
        {
            get { return _onReceiveDataNotify; }
            set { _onReceiveDataNotify = value; }
        }

        public override void DoUpdate()
        {
            if (mSocket == null) return;
            if (_receiveMsgQueue.Count == 0)
            {
                lock (_receiveLock)
                {
                    if (_receiveWaitingMsgQueue.Count > 0)
                    {
                        Queue<IMessage> temp = _receiveMsgQueue;
                        _receiveMsgQueue = _receiveWaitingMsgQueue;
                        _receiveWaitingMsgQueue = temp;
                    }
                }
            }
            else
            {
                if (_receiveMsgQueue.Count > 0 && _onReceiveMessage != null)
                {
                    while (_receiveMsgQueue.Count > 0)
                    {
                        _onReceiveMessage(_receiveMsgQueue.Dequeue());
                    }
                }
            }
        }

        public override void Close()
        {
            if (mSocket != null && Status==ConnectionStatus.Connected)
            {
                GameLog.Log("network", "UdpSocketClient  Close !");
                _result = null;
                mSocket.Close();
                mSocket = null;
                Status = ConnectionStatus.None;
            }
        }
    }
}