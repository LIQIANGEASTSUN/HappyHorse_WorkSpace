using System;
using ClientMessage;
using ProtoBuf;

namespace Cookgame.Entity
{
    public class MirrorHero : Person
    {
        public bool Create(Int64 uid)
        {
            __uid = uid;
            return true;
        }

        public override bool OnMessage(ClientMsgID msgId, IExtensible msgData)
        {
            switch (msgId)
            {
                //case ClientMsgID.MSG_ACTION_ADDCAR_RES: return true;
                default: return base.OnMessage(msgId, msgData);
            }
        }
    }
}
