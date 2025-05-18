
using System.Net.Sockets;

namespace Cookgame.Network
{
    public enum ConnectionStatus
    {
        None = 0,
        TryConnecting,
        Connected,
        ConnectFailed
    }
    public abstract class SocketClient : INetworkSupport
    {
        protected Socket mSocket;
        public ConnectionStatus Status { get; protected set; }
        public abstract bool IsConnected { get; }
        public abstract void Connect(string ip, int port);
        public abstract void SendData(byte[] buf, int dataSize);
        public abstract DataProcess OnReceiveDataNotify { get; set; }
        public abstract void DoUpdate();
        public abstract void Close();
    }
}