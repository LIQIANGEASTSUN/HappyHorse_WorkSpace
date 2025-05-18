using System;
using Cookgame.Message;
using Cookgame.Network;

namespace Cookgame
{
    public enum SessionType
    {
        None = -1,
        Login,
        //Gate,
        Lobby,
        Race,
        SessionTypeCount,
    }


    public class NetworkSystem : ISystem, IMessageDispatcher
    {
        private static int MAX_CLIENT_COUNT = (int)SessionType.SessionTypeCount;
        private ConnectSession[] _sessions = new ConnectSession[MAX_CLIENT_COUNT];

        private UdpSocketClient _udpClient;

        public MessageProcessFunc OnReceiveMessage;

        public void InitSystem()
        {
            
        }

        public void InitData()
        {
            
        }
        public void DoUpdate()
        {
            for (int i = 0; i < MAX_CLIENT_COUNT; i++)
            {
                if (_sessions[i] != null)
                    _sessions[i].DoUpdate();
            }
            if (_udpClient != null)
            {
                _udpClient.DoUpdate();
            }
        }
        public void DoFixedUpdate()
        {

        }

        public void DoLateUpdate()
        {

        }

        public void OnDispose()
        {
            for (int i = 0; i < MAX_CLIENT_COUNT; i++)
            {
                if (_sessions[i] != null)
                {
                    _sessions[i].Disconnect();
                    _sessions[i] = null;
                }
            }

            if (_udpClient != null)
            {
                _udpClient.Close();
            }
        }

        
        public void ReceiveMessage(IMessage message)
        {
            if (message != null && OnReceiveMessage != null)
                OnReceiveMessage(message);
        }

        public void SendMessage(IMessage message)
        {
            IGameMessage gameMessage = (IGameMessage)message;
            if (gameMessage.IsUdpMsg)
            {
                _udpClient.SendNetMessage(message);
            }
            else
            {
                if (message != null && message.SessionId >= 0 && message.SessionId < MAX_CLIENT_COUNT && _sessions[message.SessionId] != null)
                {
                    if (_sessions[message.SessionId].IsConnected)
                        _sessions[message.SessionId].SendMessage(message);
                    else
                    {

                        GameLog.Log($"TCP没有连接  {(SessionType)message.SessionId}");
                    }
                }
            }
        }

        public void PrepareConnection(SessionType sessionType, IMessageProtocal messageProtocal)
        {
            int sessionId = (int)sessionType;
            if (sessionId >= 0 && sessionId < MAX_CLIENT_COUNT)
            {
                if (_sessions[sessionId] == null)
                    _sessions[sessionId] = new ConnectSession(sessionId);

                _sessions[sessionId].MessageProtocal = messageProtocal;
                _sessions[sessionId].OnReceiveMessage = this.ReceiveMessage;
            }
        }

        public void CloseConnection(SessionType sessionType)
        {
            int sessionId = (int)sessionType;
            if (sessionId >= 0 && sessionId < MAX_CLIENT_COUNT && _sessions[sessionId] != null)
            {
                _sessions[sessionId].Disconnect();
            }
        }
        public bool IsConnected(SessionType sessionType)
        {
            int sessionId = (int)sessionType;
            if (sessionId >= 0 && sessionId < MAX_CLIENT_COUNT && _sessions[sessionId] != null)
            {
                return _sessions[sessionId].IsConnected;
            }
            return false;
        }

        public ConnectSession ConnectionOf(SessionType sessionType)
        {
            int sessionId = (int)sessionType;
            if (sessionId >= 0 && sessionId < MAX_CLIENT_COUNT)
                return _sessions[sessionId];
            else
                return null;
        }

        public void CreateUdpConnect(IMessageProtocal messageProtocal)
        {
            _udpClient = new UdpSocketClient();
            _udpClient.MessageProtocal = messageProtocal;
            _udpClient.OnReceiveMessage = this.ReceiveMessage;
        }

        public SocketClient UdpClient
        {
            get { return _udpClient;}
        }
    }
}
