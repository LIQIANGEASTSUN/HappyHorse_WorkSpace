using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Cookgame.Message
{
    public class BaseMessageProcess : IMessageProcess
    {
        private int _commandId;
        private MessageProcessFunc _process;

        public BaseMessageProcess(int commandId, MessageProcessFunc process)
        {
            this._commandId = commandId;
            this._process = process;
        }

        public int CommandId
        {
            get { return _commandId; }
        }

        public void ProcessMessage(IMessage message)
        {
            if (_process != null)
                _process(message);
        }
    }
}
