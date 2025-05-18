using System;
using System.Collections.Generic;

namespace Cookgame.Message
{
    public interface IMessageHandler
    {
        void InitData();

        MessageHandlerType HandlerType { get; }

        List<IMessageProcess> ProcessList { get; }

        void RegProcess(int commandId, MessageProcessFunc process);

        void Dispose();
    }
}
