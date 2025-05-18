using System;
using ProtoBuf;

namespace Cookgame.Message
{
    public abstract class GameMessageHandler : BaseMessageHandler
    {
        public override MessageHandlerType HandlerType
        {
            get { return MessageHandlerType.DownMsgProcess; }
        }

        public void RegServerMessageProcess<T>(int msgKey, MessageProcessFunc process)
            where T : IExtensible
        {
            MessageDataFactory.RegisterDeserializeDataType<T>(msgKey);
            base.RegProcess(msgKey, process);
        }
        public void RegServerMessageProcess(int msgKey, MessageProcessFunc process)
        {
            base.RegProcess(msgKey, process);
        }

        public void RegClientMessageData<T>(int msgKey) where T : IExtensible
        {
            MessageDataFactory.RegisterCreatingDataType<T>(msgKey);
        }

        public void RegClientMessageData(int msgKey)
        {

        }

        //public void RegServerMessageProcess<T>(int commandType, int commandId, MessageProcessFunc process)
        //    where T : IExtensible
        //{
        //    MessageDataFactory.RegisterDeserializeDataType<T>(commandType, commandId);
        //    base.RegProcess((commandType << 16) + commandId, process);
        //}

        //public void RegServerMessageProcess(int commandType, int commandId, MessageProcessFunc process)
        //{
        //    base.RegProcess((commandType << 16) + commandId, process);
        //}

        //public void RegClientMessageData<T>(int commandType, int commandId) where T : IExtensible
        //{
        //    MessageDataFactory.RegisterCreatingDataType<T>(commandType, commandId);
        //}

        //public void RegClientMessageData(int commandType, int commandId)
        //{

        //}
    }
}
