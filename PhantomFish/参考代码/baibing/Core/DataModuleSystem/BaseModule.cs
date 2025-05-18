using System.Collections.Generic;
using Cookgame.Broadcast;
using Cookgame.Message;
using ProtoBuf;
using ClientMessage;

namespace Cookgame
{
    public abstract class BaseModule : IDataModule
    {
        protected bool mNeedFrameUpdate;
        protected bool mActive;
        
        private readonly Dictionary<BroadcastId, BroadcastDataListener> _broadcastList = new Dictionary<BroadcastId, BroadcastDataListener>();
        private readonly ModuleGameMessageHandler _msgHandler;

        protected BaseModule()
        {
            mNeedFrameUpdate = false;
            mActive = false;

            _msgHandler = new ModuleGameMessageHandler();
            InitProcessList();
            GameWorld.MessageDispatcher.RegHandler(_msgHandler);
        }

        public abstract void InitData();

        public abstract void InitProcessList();

        
        public bool IsNeedFrameUpdate => mNeedFrameUpdate;

        public bool IsActive => mActive;

        public virtual void Dispose()
        {
            AutoUnRegisterBroadcast();
        }

        public virtual void DoUpdate()
        {

        }
        #region BroadcastData
        protected void BroadcastData(BroadcastId dataId, IBroadcastData data, int flag = 0)
        {
            GameWorld.Broadcast.BroadcastData(dataId, data, flag);
        }

        protected void RegisterBroadcast(BroadcastId dataId, BroadcastDataListener dataReceive)
        {
            _broadcastList[dataId] = dataReceive;
            GameWorld.Broadcast.RegisterDataListener(dataId, dataReceive);
        }

        protected void UnRegisterBroadcast(BroadcastId dataId, BroadcastDataListener dataReceive)
        {
            _broadcastList.Remove(dataId);
            GameWorld.Broadcast.UnRegisterDataListener(dataId, dataReceive);
        }

        protected void AutoUnRegisterBroadcast()
        {
            foreach (var dataListener in _broadcastList)
            {
                GameWorld.Broadcast.UnRegisterDataListener(dataListener.Key, dataListener.Value);
            }
            _broadcastList.Clear();
        }
        #endregion

        #region MessageData
        protected void RegClientMessageData<T>(ClientMsgID msgKey) where T : IExtensible
        {
            _msgHandler?.RegClientMessageData<T>((int)msgKey);
        }

        protected void RegClientMessageData(ClientMsgID msgKey)
        {
            _msgHandler?.RegClientMessageData((int)msgKey);
        }

        protected void RegServerMessageProcess<T>(ClientMsgID msgKey, MessageProcessFunc process) where T : IExtensible
        {
            _msgHandler?.RegServerMessageProcess<T>((int)msgKey, process);
        }

        protected void RegServerMessageProcess(ClientMsgID msgKey, MessageProcessFunc process)
        {
            _msgHandler?.RegServerMessageProcess((int)msgKey, process);
        }

        protected BaseMessage CreateCSMessage(ClientMsgID msgKey)
        {
            return MessageDataFactory.CreateCSMessage((int)msgKey);
        }

        protected void SendMessage(IMessage msg)
        {
            GameWorld.MessageDispatcher.SendMessage(msg);
        }
        //protected void RegClientMessageData<T>(int commandType, int commandId) where T : IExtensible
        //{
        //    if (_msgHandler == null) return;
        //    _msgHandler.RegClientMessageData<T>(commandType, commandId);
        //}

        //protected void RegClientMessageData(int commandType, int commandId)
        //{
        //    if (_msgHandler == null) return;
        //    _msgHandler.RegClientMessageData(commandType, commandId);
        //}

        //protected void RegServerMessageProcess<T>(int commandType, int commandId, MessageProcessFunc process) where T : IExtensible
        //{
        //    if (_msgHandler == null) return;
        //    _msgHandler.RegServerMessageProcess<T>(commandType, commandId, process);
        //}

        //protected void RegServerMessageProcess(int commandType, int commandId, MessageProcessFunc process)
        //{
        //    if (_msgHandler == null) return;
        //    _msgHandler.RegServerMessageProcess(commandType, commandId, process);
        //}
        #endregion
    }
}
