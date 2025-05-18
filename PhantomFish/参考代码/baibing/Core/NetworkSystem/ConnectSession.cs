using Cookgame.Message;

namespace Cookgame.Network
{
    public class ConnectSession
    {
        private int _sessionId;
        private TcpSocketClient _client;
        private IMessageProtocal _messageProtocal;
        private ProtocalProcessFunc _onReceiveMessage;
        private string _connectIp = "";
        private int _connectPort = 0;

        public string ConnectIp
        {
            get { return _connectIp; }
        }

        public int ConnectPort
        {
            get { return _connectPort; }
        }

        public ConnectSession(int sessionId)
        {
            _sessionId = sessionId;
            _client = new TcpSocketClient();
            _messageProtocal = null;

            this._client.OnReceiveDataNotify = DoReceiveDataFromNet;
            this._client.OnConnect = onConnect;
            this._client.OnConnectFailed = onConnectFailed;
            this._client.OnClose = onClose;
        }

        public TcpSocketClient TcpSocketClient => _client;

        public int SessionId => _sessionId;

        public bool IsConnected => _client != null && _client.IsConnected;

        public void DisposeData()
        {
            this._client.Close();
            this._client.OnReceiveDataNotify = null;
            this._client.OnConnect = null;
            this._client.OnClose = null;
            this._client.OnConnectFailed = null;
        }

        public ProtocalProcessFunc OnReceiveMessage
        {
            get { return _onReceiveMessage; }
            set { _onReceiveMessage = value; }
        }

        //MARK:Try Connect
        public void TryConnect(string ip, int port)
        {
            _connectIp = ip;
            _connectPort = port;
            GameLog.Log("network", $"SessionType.{(SessionType)SessionId}  tryConnect ip={ip},port={port}");
            this._client.Connect(ip, port);
        }

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
                    _messageProtocal.OnReceiveMessage = this.DoReceiveMessage;
                    _messageProtocal.OnMessageEncoded = this.DoSendDataData;
                }
            }
        }

        public void SendMessage(IMessage message)
        {
            if (_messageProtocal != null)
                _messageProtocal.SendNetMessage(message);
        }

        private bool DoSendDataData(byte[] buf, int dataSize)
        {
            _client.SendData(buf, dataSize);
            return true;
        }

        private void DoReceiveMessage(IMessage message)
        {
            if (message != null && _onReceiveMessage != null)
            {
                //message.SessionId = _sessionId;
                _onReceiveMessage(message);
            }
        }

        private bool DoReceiveDataFromNet(byte[] data, int length)
        {
            if (_messageProtocal != null)
                return (_messageProtocal.ReceiveNetData(data, length) != DecodeStatus.Invalid);
            else
                return true;
        }

        public void Disconnect()
        {
            this._client.Close();
        }

        public void DoUpdate()
        {
            _client.DoUpdate();
        }

        private void onConnect()
        {
            GameLog.Log("network", $"SessionType.{(SessionType)SessionId}  On connected ip={_connectIp},port={_connectPort}");
        }

        private void onConnectFailed()
        {
            GameLog.Log("network", $"SessionType.{(SessionType)SessionId}  On connection failed ip={_connectIp},port={_connectPort}");


        }
        private void onClose()
        {
            GameLog.Log("network", $"SessionType.{(SessionType)SessionId}  On connection close ip={_connectIp},port={_connectPort}");
        }

    }
}