using System.IO;
using ProtoBuf;

namespace Cookgame.Message
{
    public interface IGameMessage : IMessage
    {
        bool IsUdpMsg { get; }

        //int CommandId { get; }

        //int CommandType { get; }
        long udpKeyId { get;}

        IExtensible MessageData { get; set; }

        void CustomDecode(MemoryStream inStream, int dataSize);

        void CustomEncode(MemoryStream outStream);
    }
}