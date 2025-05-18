using System.IO;
using ProtoBuf;

namespace Cookgame.Message
{
    public class BaseMessage : IGameMessage
    {
        private int _messageId;
        //private int _commandType;
        //private int _commandId;
        private bool _isDummyMessage;
        private IExtensible _messageData;
        private bool _isUdpMsg;
        private int _sessionId;
        private long _udpKeyId;
        public BaseMessage()
        {
            _messageId = 0;
            //_commandId = 0;
            //_commandType = 0;
            _isDummyMessage = false;
            _messageData = null;
        }

        public int MessageId
        {
            get
            {
                //if (_messageId < 0)
                //{
                //    _messageId = (_commandType << 16) + _commandId;
                //}
                return _messageId;
            }
        }

        public bool IsUdpMsg
        {
            get { return _isUdpMsg; }
        }

        public long udpKeyId
        {
            get { return _udpKeyId; }
        }

        //public int CommandId
        //{
        //    get { return _commandId; }
        //}
        //public int CommandType
        //{
        //    get { return _commandType; }
        //}

        public int SessionId {
            get
            {
                if (_sessionId == 0)
                {
                    _sessionId = CalcSessionType();
                }
                return _sessionId;
            }  set{} }

        //public void InitMessage(int commandType, int commandId)
        //{
        //    _commandType = commandType;
        //    _commandId = commandId;
        //    _messageId = (_commandType << 16) + _commandId;
        //}
        public void InitMessage(int msgKey)
        {
            _messageId = msgKey;
        }

        public bool IsCacheable
        {
            get { return true; }
        }

        public virtual void Dispose()
        {
            _messageId = -1;
            //_commandId = 0;
            //_commandType = 0;
            _messageData = null;
        }

        public bool IsDummyMessage
        {
            get { return _isDummyMessage; }
        }

        public void SetDummyMessage(bool dummyMessage)
        {
            _isDummyMessage = dummyMessage;
        }

        public void SetUdpMessageKeyId(long keyId)
        {
            _udpKeyId = keyId;
            _isUdpMsg = true;
        }

        public IExtensible MessageData
        {
            get { return _messageData; }
            set { _messageData = value; }
        }

        public byte[] Stream { get; set; }

        public virtual void CustomDecode(MemoryStream inStream, int dataSize)
        {

        }

        public virtual void CustomEncode(MemoryStream outStream)
        {

        }

        int CalcSessionType()
        {
            int destPoint = _messageId >> 25;
            SessionType type = SessionType.None;
            switch (destPoint)
            {
                case (int)ClientMessage.eDestServerPoint.MSG_POINT_AUTH_SERVER:
                    type = SessionType.Login;
                    break;
                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_LOGIN_SERVER:
                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_GATEWAY_SERVER:
                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_HALL_SERVER:
                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_MATCH_SERVER:
                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_ROOM_SERVER:
                //    type = SessionType.Lobby;
                //    break;

                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_BATTLE_GATE_SERVER:
                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_BATTLE_ROUTE_SERVER:
                //case (int)ClientMessage.eDestServerPoint.MSG_POINT_BATTLE_SERVER:
                //    type = SessionType.Race;
                //    break;
                default: type = SessionType.Lobby;break;
            }
            if (type == SessionType.None)
            {
                GameLog.LogError("unknown msg type for " + _messageId);
            }
            return (int)type;
        }

        public bool NeedGetKey()
        {
            int keyModule = _messageId >> 16;
            switch (keyModule)
            {
                case 30://BATTLEPERSON
                    return true;
                default:return false;
            }
        }
    }
}
