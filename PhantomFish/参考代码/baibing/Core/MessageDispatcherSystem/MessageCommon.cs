

namespace Cookgame.Message
{
    public delegate bool DataProcess(byte[] data, int length);

    public delegate void MessageProcessFunc(IMessage message);

    public delegate void ProtocalProcessFunc(IMessage message);

    public enum MessageHandlerType
    {
        DownMsgProcess = 0,
        UpMsgFilter
    }

    public enum DecodeStatus
    {
        Normal = 0,
        Ignore,
        Invalid
    }
}
