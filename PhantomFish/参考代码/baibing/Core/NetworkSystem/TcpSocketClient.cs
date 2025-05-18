using System;
using System.Net;
using System.Net.Sockets;

namespace Cookgame.Network
{
    public class TcpSocketClient : SocketClient
    {
        private byte[] _socketAsyncBuffer;

        private SocketAsyncEventArgs _asyncEventArgs;
        private bool _connectingResultNotified;

        private DataProcess _serverDataNotify;

        public Action OnConnect { get; set; }
        public Action OnConnectFailed { get; set; }
        public Action OnClose { get; set; }

        public TcpSocketClient()
        {
            Status = ConnectionStatus.None;
        }

        public override DataProcess OnReceiveDataNotify
        {
            get { return _serverDataNotify; }
            set { _serverDataNotify = value; }
        }

        public override bool IsConnected => Status == ConnectionStatus.Connected && mSocket.Connected;

        public override void Connect(string ip, int port)
        {
            Close();

            _socketAsyncBuffer = new byte[2048];
            // Fixed: zxy ios ipv4 or ipv6
            IPAddress[] localPs = Dns.GetHostAddresses(ip);
            AddressFamily addressFamily = AddressFamily.InterNetwork;
            if (localPs[0].AddressFamily == AddressFamily.InterNetwork)// is ipv4 or ipv6
            {
                addressFamily = AddressFamily.InterNetwork;
            }
            else
            {
                addressFamily = AddressFamily.InterNetworkV6;
            }
            //GameLog.Log("--------------net = "+localPs[0]);
            //IPAddress ipAddress;
            //if (System.Net.IPAddress.TryParse(ip, out ipAddress))
            //{ // is ip address
            //    isIpv4 = true;
            //}
            mSocket = new Socket(addressFamily, SocketType.Stream, ProtocolType.Tcp);
            mSocket.BeginConnect(localPs, port, new AsyncCallback(OnConnected), this);
            Status = ConnectionStatus.TryConnecting;
            _connectingResultNotified = false;
        }

        private void OnConnected(IAsyncResult result)
        {
            if (mSocket.Connected)
            {
                //结束异步连接请求
                mSocket.EndConnect(result);
                //开始异步等待数据
                _asyncEventArgs = new SocketAsyncEventArgs();
                _asyncEventArgs.Completed += new EventHandler<SocketAsyncEventArgs>(AsyncCompletedNotify);
                _asyncEventArgs.SetBuffer(_socketAsyncBuffer, 0, _socketAsyncBuffer.Length);
                mSocket.ReceiveAsync(_asyncEventArgs);
                Status = ConnectionStatus.Connected;
            }
            else
            {
                Status = ConnectionStatus.ConnectFailed;
            }
        }

        private void AsyncCompletedNotify(object sender, SocketAsyncEventArgs eventArgs)
        {
            if (eventArgs.SocketError == SocketError.Success && eventArgs.BytesTransferred > 0)
            {
                try
                {
                    ParseReceiveData(eventArgs.Buffer, eventArgs.BytesTransferred);
                }
                catch (Exception ex)
                {
                    GameLog.Log("network", ex);
                    Close();
                    return;
                }
                //完成一次消息读取后，马上启动下一次异步等待数据
                try
                {
                    if (mSocket != null && !mSocket.ReceiveAsync(_asyncEventArgs))
                    {
                        AsyncCompletedNotify(null, _asyncEventArgs);
                    }
                }
                catch (Exception ex2)
                {
                    GameLog.Log("network", ex2);
                    Close();
                    throw;
                }
            }
            else
            {
                //GameLog.Log("network", string.Format("AsyncCompletedNotify eventArgs.SocketError={0}  {1}", eventArgs.SocketError, DateTime.Now.Ticks));
                Close();
            }
        }

        private void ParseReceiveData(byte[] data, int length)
        {
            if (mSocket == null)
                return;

            if (!mSocket.Connected)
            {
                GameLog.Log("network", "ParseReceiveData mSocket.Connected False");
                Close();
                return;
            }

            if (_serverDataNotify != null)
            {
                if (!_serverDataNotify(data, length))
                {
                    GameLog.Log("network", "ParseReceiveData _serverDataNotify Invalid package");
                    Close();
                    throw new Exception("Invalid package length!");
                }
            }
        }

        //***********************************
        public override void DoUpdate()
        {
            if (mSocket == null)
            {
                onCloseProc();
                return;
            }

            onConnectingProc();
        }

        private void onConnectingProc()
        {
            if (_connectingResultNotified)
                return;

            if (Status == ConnectionStatus.Connected)
            {
                _connectingResultNotified = true;
                if (OnConnect != null)
                {
                    OnConnect();
                }
            }
            else if (Status == ConnectionStatus.ConnectFailed)
            {
                _connectingResultNotified = true;
                if (OnConnectFailed != null)
                {
                    OnConnectFailed();
                }
            }
        }
        private void onCloseProc()
        {
            if (Status == ConnectionStatus.Connected && mSocket == null)
            {
                Status = ConnectionStatus.None;
                if (OnClose != null)
                {
                    OnClose();
                }
            }
        }

        //********************************************                
        public override void SendData(byte[] buf, int dataSize)
        {
            if (mSocket == null || !mSocket.Connected)
                return;

            if (buf == null || dataSize <= 0)
                return;

            try
            {
                mSocket.Send(buf, dataSize, SocketFlags.None);
            }
            catch (Exception ex)
            {
                GameLog.Log("network", ex);
                Close();
                throw;
            }
        }

        public override void Close()
        {
            OnClose?.Invoke();
            //GameLog.Log("<color=red>Close Tcp</color>");
            if (mSocket == null || Status != ConnectionStatus.Connected)
                return;

            if (_asyncEventArgs != null)
            {
                _asyncEventArgs.Dispose();
                _asyncEventArgs = null;
            }
            mSocket.Close();
            mSocket = null;
            _socketAsyncBuffer = null;

            Status = ConnectionStatus.None;
        }
    }
}