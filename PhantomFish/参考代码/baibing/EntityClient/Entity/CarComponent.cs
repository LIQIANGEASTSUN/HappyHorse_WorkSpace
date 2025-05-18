using System;
using System.Collections.Generic;
using ClientMessage;
using Cookgame.Module;
using ProtoBuf;

namespace Cookgame.Entity
{
    public interface ICarComponent : IEntity
    {
        //获取零件配置属性
        carRefitPropData GetcarRefitPropData();
        //取得物品属性
        PropItemInfo GetEntityProp();
    }
    public class CarComponent : ICarComponent
    {
        private Int64 m_uid;
        //物品属性
        private PropItemInfo propItemInfo = new PropItemInfo();
        //配置属性
        private carRefitPropData __carRefitPropData = null;

        private EntityClientModule _entityModule;
        public CarComponent()
        {
            _entityModule = GameUtility.GetModule<EntityClientModule>(DataModuleEnum.Entity);
        }
        public Int64 GetUID()
        {
            return m_uid;
        }
        //获得实体类型
        public Enum_EntityType GetEntityClass()
        {
            return Enum_EntityType.EN_ENTITY_TYPE_EQUIPMENT;
        }

        public bool OnMessage(ClientMsgID msgId, IExtensible msgData)
        {
            return true;
        }

        //获得实体属性
        public PropItemInfo GetEntityProp()
        {
            return propItemInfo;
        }
        public carRefitPropData GetcarRefitPropData()
        {
            return __carRefitPropData;
        }
        //导入数据
        public bool ImportDataContext(byte[] entityData)
        {
            return EntityUtility.BuildData(ref propItemInfo, GetEntityClass(), entityData);
        }

        //创建 
        public bool Create(Int64 uid)
        {
            this.m_uid = uid;

            //判断客户端是否有该零件配置
            int nGoodsID = (int)propItemInfo.nGoodsID;
            if (!ExcelData.Instance.carRefitPropDataDic.ContainsKey(nGoodsID))
            {
                return false;
            }
            __carRefitPropData = ExcelData.Instance.carRefitPropDataDic[nGoodsID];
            //加入实体中
            if (!_entityModule.AddEntity(this,GetEntityClass()))
            {
                return false;
            }
            return true;
        }
        //释放
        public void Destroy()
        {
            _entityModule.DestroyEntity(GetUID(), GetEntityClass());
        }

        //消息处理
        public void OnMessage(uint actionID, byte[] ActionData)
        {
        }
    }
}