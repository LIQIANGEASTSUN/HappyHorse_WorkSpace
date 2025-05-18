
namespace Cookgame.Message
{
    public interface IMessageProcess
    {
        int CommandId { get; }

        void ProcessMessage(IMessage message);
    }
}
