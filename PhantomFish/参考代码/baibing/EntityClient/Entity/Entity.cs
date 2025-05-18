using System;
using ClientMessage;
using ProtoBuf;

namespace Cookgame.Entity
{
    //实体部件
    public interface IEntityPart
    {
        //创建
        bool Create(IPerson master);

        //取得部件ID
        uint GetPartID();

        //导入部件数据
        bool UpdateProp(byte[] EntityPartData);

        //更新
        bool UpdateProp(IExtensible msgData);
        //更新
        //bool UpdateProp(byte[] partData);
    }

    //实体对象接口
    public interface IEntity
    {
        //获得实体UID
        Int64 GetUID();

        //获得实体类型
        Enum_EntityType GetEntityClass();

        //消息处理
        bool OnMessage(ClientMsgID msgId, IExtensible msgData);
    }
}
