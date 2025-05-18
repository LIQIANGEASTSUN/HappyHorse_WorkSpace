using Cookgame.Message;

namespace Cookgame.Network
{
    public delegate bool DataProcess(byte[] data, int length);

    public delegate void ProtocalProcessFunc(IMessage message);

    public enum DecodeStatus
    {
        Normal = 0,
        Ignore,
        Invalid
    }
}