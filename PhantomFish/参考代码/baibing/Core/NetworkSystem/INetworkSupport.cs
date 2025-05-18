using Cookgame.Message;

namespace Cookgame.Network
{
    public interface INetworkSupport
    {
        DataProcess OnReceiveDataNotify { get; set; }

        void SendData(byte[] buf, int dataSize);
    }
}