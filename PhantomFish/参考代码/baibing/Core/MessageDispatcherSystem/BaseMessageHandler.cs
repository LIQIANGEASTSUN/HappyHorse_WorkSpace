using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Cookgame.Message
{
    public abstract class BaseMessageHandler : IMessageHandler
    {
        private readonly List<IMessageProcess> _processList;

        protected BaseMessageHandler()
        {
            this._processList = new List<IMessageProcess>();
            InitProcessList();
        }

        public virtual MessageHandlerType HandlerType
        {
            get { return MessageHandlerType.DownMsgProcess; }
        }

        protected abstract void InitProcessList();

        public virtual void InitData()
        {
            
        }

        public List<IMessageProcess> ProcessList
        {
            get { return _processList; }
        }

        public void RegProcess(int messageId, MessageProcessFunc process)
        {
            if (messageId >= 0 && process != null)
            {
                bool reged = false;
                int i = 0;
                while (!reged && i < _processList.Count)
                {
                    if (_processList[i].CommandId == messageId)
                        reged = true;
                    else
                        i++;
                }
                if (!reged)
                {
                    _processList.Add(new BaseMessageProcess(messageId, process));
                }
            }
        }

        public virtual void Dispose()
        {
        }
    }
}
