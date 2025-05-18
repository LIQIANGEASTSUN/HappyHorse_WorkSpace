using Cookgame.Message;

namespace Cookgame.Network
{
    public interface IMessageProtocal
    {
        ProtocalProcessFunc OnReceiveMessage { get; set; }

        DataProcess OnMessageEncoded { get; set; }

        void SendNetMessage(IMessage message);

        DecodeStatus ReceiveNetData(byte[] msgData, int length);
    }
}