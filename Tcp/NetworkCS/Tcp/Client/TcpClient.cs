using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace Network
{
    [XLua.CSharpCallLua]
    public delegate void NewWorkReceiveHandle(int messageId, int seqId, byte[] byteData);
    [XLua.CSharpCallLua]
    public delegate void NewWorkConnectFail();

    [XLua.LuaCallCSharp]
    public class TcpClient
    {
        private Socket _clientSocket = null;
        private string _ip;
        private int _port;

        private ManualResetEvent connectDone = new ManualResetEvent(false);
        private ManualResetEvent sendDone = new ManualResetEvent(false);
        private ManualResetEvent receiveDone = new ManualResetEvent(false);

        private TcpReceive _tcpReceive;
        private NetWorkState _netWorkState;
        private int _reConnectCount;
        private const int Max_ReConnect_Count = 3;

        public NewWorkReceiveHandle receiveCallBack;
        private NewWorkConnectFail newWorkConnectFail;

        public TcpClient()
        {
            _tcpReceive = new TcpReceive();
            _tcpReceive.SetCompleteCallBack(ReceiveComplete);
        }

        public void StartConnect(string ip, int port)
        {
            _ip = ip;
            _port = port;
            SetConnectCount(0);

            StartConnect();
        }

        private void StartConnect()
        {
            IPAddress ipAddress = IPAddress.Parse(_ip);
            IPEndPoint ipEndPoint = new IPEndPoint(ipAddress, _port);
            _clientSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            _clientSocket.SendTimeout = 5000;
            _clientSocket.ReceiveTimeout = 5000;
            _clientSocket.SendBufferSize = StateObject.bufferSize;
            _clientSocket.ReceiveBufferSize = StateObject.bufferSize;
            _clientSocket.Blocking = false;
            _clientSocket.NoDelay = true;

            try
            {
                ChangeState(NetWorkState.Connecting);

                StateObject state = new StateObject();
                state.workSocket = _clientSocket;
                // Connect to the remote endpoint.  
                state.workSocket.BeginConnect(ipEndPoint, ConnectCallBack, state);  // 异步连接

                // 用于暂停主线程的执行，并在可以继续执行时发出信号
                //connectDone.WaitOne();
                //receiveDone.WaitOne();
            }
            catch (SocketException se)
            {
                NotifyException(se.StackTrace, se.Message, se.ErrorCode);
                ChangeState(NetWorkState.ConnectFailed);
            }
        }

        // 连接服务器成功
        private void ConnectCallBack(IAsyncResult ar)
        {
            try
            {
                StateObject state = (StateObject)ar.AsyncState;
                Socket socket = state.workSocket;
                if (socket.Connected)
                {
                    ChangeState(NetWorkState.Connected);

                    socket.EndConnect(ar);
                    //Debug.Log("连接服务器成功:" + socket.RemoteEndPoint.ToString());

                    // 当远程设备可用时，它连接到远程设备，然后通过设置ManualResetEvent 向应用程序线程发送连接已完成的信号connectDone
                    // Signal that the connection has been made.
                    //connectDone.Set();
                    Receive(_clientSocket);
                }
                else
                {
                    ChangeState(NetWorkState.ConnectFailed);
                }
            }
            catch (SocketException se)
            {
                NotifyException(se.StackTrace, se.Message, se.ErrorCode);
                ChangeState(NetWorkState.ConnectFailed);
            }
        }

        private void ReConnect()
        {
            if (_netWorkState == NetWorkState.Connecting)
            {
                // 正在连接中
                return;
            }

            if (_reConnectCount < Max_ReConnect_Count)
            {
                SetConnectCount(_reConnectCount + 1);
                Dispose();
                ChangeState(NetWorkState.Connecting);
                StartConnect();
            }
            else
            {
                Debug.Log("通知：超出重连次数，连接失败");
            }
        }

        /// <summary>
        /// 接收消息
        /// </summary>
        private void Receive(Socket client)
        {
            try
            {
                // Create the state object
                StateObject state = new StateObject();
                state.workSocket = _clientSocket;
                // Begin receiving the data from the remote device.  
                state.workSocket.BeginReceive(state.buffer, 0, StateObject.bufferSize, SocketFlags.None, new AsyncCallback(ReceiveCallBack), state);
            }
            catch (SocketException se)
            {
                NotifyException(se.StackTrace, se.Message, se.ErrorCode);
                ChangeState(NetWorkState.ConnectFailed);
            }
        }

        private void ReceiveCallBack(IAsyncResult ar)
        {
            try
            {
                // Retrieve the state object and the client socket from the asynchronous state object. 
                StateObject state = (StateObject)ar.AsyncState;
                Socket client = state.workSocket;
                // Read data from the remote device.  
                int bytesRead = client.EndReceive(ar);
                if (bytesRead > 0)
                {
                    _tcpReceive.ReceiveMessage(bytesRead, state.buffer);
                    Receive(client);
                }
                else
                {
                    ChangeState(NetWorkState.ConnectFailed);
                }
            }
            catch (SocketException se)
            {
                NotifyException(se.StackTrace, se.Message, se.ErrorCode);
                ChangeState(NetWorkState.ConnectFailed);
            }
        }

        /// <summary>
        /// 发送消息
        /// </summary>
        /// <param name="bytes"></param>
        public void Send(int messageId, int seqld, byte[] bytes)
        {
            if(!CheckConnectState())
            {
                ReConnect();
                return;
            }

            try
            {
                byte[] bytesData = SendData.ToTcpByte(messageId, seqld, bytes);
                StateObject stateObject = new StateObject();
                stateObject.workSocket = _clientSocket;
                // 异步发送数据到指定套接字所代表的网络设备
                stateObject.workSocket.BeginSend(bytesData, 0, bytesData.Length, SocketFlags.None, SendCallBack, stateObject);
            }
            catch (SocketException se)
            {
                NotifyException(se.StackTrace, se.Message, se.ErrorCode);
                ChangeState(NetWorkState.ConnectFailed);
            }
        }

        /// <summary>
        /// 发送消息回调
        /// </summary>
        /// <param name="ar"></param>
        private void SendCallBack(IAsyncResult ar)
        {
            try
            {
                StateObject state = (StateObject)ar.AsyncState;
                Socket socket = state.workSocket;
                int send = socket.EndSend(ar);

                // Siganl that all bytes have been set
                // sendDone.Set();
            }
            catch (SocketException se)
            {
                NotifyException(se.StackTrace, se.Message, se.ErrorCode);
                ChangeState(NetWorkState.ConnectFailed);
            }
        }

        public void Dispose()
        {
            ChangeState(NetWorkState.Closed);
            _tcpReceive.Clear();
            if (null == _clientSocket)
            {
                return;
            }

            try
            {
                _clientSocket.Shutdown(SocketShutdown.Both);
                _clientSocket.Disconnect(true);
                _clientSocket.Close();
                _clientSocket = null;
            }
            catch (SocketException se)
            {
                NotifyException(se.StackTrace, se.Message, se.ErrorCode);
            }
        }

        private bool CheckConnectState()
        {
            if (null == _clientSocket || !_clientSocket.Connected)
            {
                return false;
            }
            return _netWorkState == NetWorkState.Connected;
        }

        private void ChangeState(NetWorkState netWorkState)
        {
            _netWorkState = netWorkState;
            if (_netWorkState == NetWorkState.ConnectFailed)
            {
                ReConnect();
            }
            else if (_netWorkState == NetWorkState.Connected)
            {
                SetConnectCount(0);
            }
        }

        private void SetConnectCount(int count)
        {
            _reConnectCount = count;
        }

        private void NotifyException(string stackTrace, string msssage, int errorCode)
        {

        }

        private void ReceiveComplete(int messageId, int seqId, byte[] msgBytes)
        {
            receiveCallBack?.Invoke(messageId, seqId, msgBytes);
            //string content = Encoding.ASCII.GetString(byteData);
            //Debug.Log("uid : " + uid + "    cmdID : " + cmdID + "   content : " + content);
        }

        public void AddReceiveCallBack(NewWorkReceiveHandle callBack)
        {
            receiveCallBack += callBack;
        }

        public void RemoveReceiveCallBack(NewWorkReceiveHandle callBack)
        {
            receiveCallBack -= callBack;
        }

    }
}