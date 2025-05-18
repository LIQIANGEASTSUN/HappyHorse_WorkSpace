
namespace Cookgame.Message
{
    public interface IMessage
    {
        int MessageId { get; }

        //bool IsCacheable { get; }

        int SessionId { get; set; }

        bool IsDummyMessage { get; }

        void Dispose();

    }
}
