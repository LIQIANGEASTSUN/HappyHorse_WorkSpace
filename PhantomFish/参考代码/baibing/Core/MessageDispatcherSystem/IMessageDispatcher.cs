namespace Cookgame.Message
{
    public interface IMessageDispatcher
    {
        void ReceiveMessage(IMessage message);

        void SendMessage(IMessage message);
    }
}