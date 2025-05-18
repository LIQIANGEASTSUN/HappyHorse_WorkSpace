using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using Cookgame.Message;

namespace Cookgame
{
    public class MessageDispatcherSystem : ISystem, IMessageDispatcher
    {
        public void InitSystem()
        {
            for (int i = 0; i < _initDataList.Count; i++)
            {
                _initDataList[i]();
            }
            _initDataList.Clear();
        }

        public void InitData()
        {
            
        }

        public void DoFixedUpdate()
        {
            
        }

        public void DoLateUpdate()
        {
            
        }

        public void OnDispose()
        {
            DisposeData();
        }

        private Dictionary<int, IMessageProcess> _downMsgProcessMap;
        private Dictionary<int, IMessageProcess> _upMsgFilterMap;
        private ThreadSafeQueue<IMessage> _receivePackage;
        private IMessageDispatcher _networkManager;
        private List<Action> _initDataList;

        private ThreadSafeQueue<IMessage> _sendPackage;

        public Func<IMessage, bool> IsGuideIgnoreMsg;
        public Action<IMessage> onProcessMessage;

        private bool _offline = false;

        public bool OffLine
        {
            set
            {
                _offline = value;

                if (_offline) DisposeData();
            }
            get { return _offline; }
        }

        public MessageDispatcherSystem()
        {
            this._downMsgProcessMap = new Dictionary<int, IMessageProcess>();
            this._upMsgFilterMap = new Dictionary<int, IMessageProcess>();
            this._initDataList = new List<Action>();
            this._receivePackage = new ThreadSafeQueue<IMessage>();
            this._sendPackage = new ThreadSafeQueue<IMessage>();
        }

        public IMessageDispatcher NetworkManager
        {
            get { return _networkManager; }
            set { _networkManager = value; }
        }

        public void DisposeData()
        {
            _receivePackage.Clear();
            _sendPackage.Clear();
        }

        public void DoUpdate()
        {
            IMessage message = _receivePackage.Dequeue();
            while (message != null)
            {
                ProcessMessage(message);
                message = _receivePackage.Dequeue();
            }

            IMessage sendMessage = _sendPackage.Dequeue();
            while (sendMessage != null)
            {
                SendMessageReal(sendMessage);
                sendMessage = _sendPackage.Dequeue();
            }
        }

        public void ReceiveMessage(IMessage message)
        {
            if (message != null)
            {
                _receivePackage.Enqueue(message);
            }
        }

        public void RegHandler(IMessageHandler handler)
        {
            if (handler == null)
                return;

            _initDataList.Add(handler.InitData);
            List<IMessageProcess> processList = handler.ProcessList;
            if (processList != null && processList.Count > 0)
            {
#if UNITY_EDITOR
                Func<IMessageProcess, string> getProcessInfo = process =>
                {
                    BaseMessageProcess bp = process as BaseMessageProcess;
                    if (bp != null)
                    {
                        Type type = bp.GetType();
                        FieldInfo info = type.GetField("_process", BindingFlags.Instance | BindingFlags.NonPublic);
                        if (info != null)
                        {
                            MessageProcessFunc pfunc = (MessageProcessFunc)info.GetValue(bp);
                            if (pfunc != null)
                            {
                                return pfunc.Target + " => " + pfunc.Method.Name;
                            }
                        }
                    }
                    return "";
                };
#endif
                IMessageProcess newProcess;
                switch (handler.HandlerType)
                {
                    case MessageHandlerType.DownMsgProcess:
                        for (int i = 0; i < processList.Count; i++)
                        {
                            newProcess = processList[i];
                            if (!_downMsgProcessMap.ContainsKey(newProcess.CommandId))
                                _downMsgProcessMap[newProcess.CommandId] = newProcess;
                            else
                            {
#if UNITY_EDITOR
                                GameLog.LogError(string.Format(" app has added,commandId = {0}  '{1}'   '{2}'", newProcess.CommandId,
                                    getProcessInfo(_downMsgProcessMap[newProcess.CommandId]), getProcessInfo(newProcess)));
#else
                                GameLog.LogError(" app has added,commandId = " + newProcess.CommandId);
#endif
                            }
                        }
                        break;
                    case MessageHandlerType.UpMsgFilter:
                        for (int i = 0; i < processList.Count; i++)
                        {
                            newProcess = processList[i];
                            if (!_upMsgFilterMap.ContainsKey(newProcess.CommandId))
                                _upMsgFilterMap[newProcess.CommandId] = newProcess;
                            else
                            {
#if UNITY_EDITOR
                                GameLog.LogError(string.Format(" app has added,commandId = {0}  '{1}'   '{2}'", newProcess.CommandId,
                                    getProcessInfo(_downMsgProcessMap[newProcess.CommandId]), getProcessInfo(newProcess)));
#else
                                GameLog.LogError(" app has added,commandId = " + newProcess.CommandId);
#endif
                            }
                        }
                        break;
                }
            }
        }

        public bool ProcessMessage(IMessage message)
        {
            if (message == null)
                return false;

            BaseMessage bm = (BaseMessage) message;
            if (bm.Stream != null)
            {
                AppFacade.instance?.GetNetworkManager()?.OnReceiveData(message.MessageId, bm.Stream);
            }
            if (_downMsgProcessMap.ContainsKey(message.MessageId))
            {
                PrintMsg.MessagePrinter.ProcessMessageLog(message);
                if (onProcessMessage != null) onProcessMessage(message);
                _downMsgProcessMap[message.MessageId].ProcessMessage(message);
                return true;
            }
            return false;
        }

        private void SendMessageReal(IMessage message)
        {
            if (message == null)
                return;
            PrintMsg.MessagePrinter.PrintMessageId(message.MessageId, "SendMessageReal");
            if (_upMsgFilterMap.ContainsKey(message.MessageId))
            {
                _upMsgFilterMap[message.MessageId].ProcessMessage(message);
            }

            if (IsGuideIgnoreMsg != null && IsGuideIgnoreMsg(message)) return;

            if (_networkManager != null && !message.IsDummyMessage)
            {
                _networkManager.SendMessage(message);
            }
        }

        public void SendMessage(IMessage message)
        {
            PrintMsg.MessagePrinter.SendMessageLog(message, "<color=red>Want</color> ");
            if (OffLine)
            {
                return;
            }

            if (message != null)
            {
                _sendPackage.Enqueue(message);
            }
        }
    }

}