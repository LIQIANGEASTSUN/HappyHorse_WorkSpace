using System;
using System.Collections.Generic;
using ClientMessage;
using Cookgame.Module;
using ProtoBuf;

namespace Cookgame.Entity
{
    public interface IGroceries : IEntity
    {
        //取得实体属性
        PropItemInfo GetEntityProp();

        //获得杂货配置属性
        propItemData GetItemData();

        //能否使用
        bool CanUse(out string result);
    }


    //EntityUtility 所有数据 List<OwendGroceiesUid>  -> Grids (目前还没做，残留在旧逻辑)， ALLEntitys 全部 ,
    public class Groceries : IGroceries
    {
        private Int64 m_uid = 0;
        private PropItemInfo _propItemInfo = new PropItemInfo();
        private propItemData _propItemData = null;
        private EntityClientModule _entityModule;

        public Groceries()
        {
            _entityModule = GameUtility.GetModule<EntityClientModule>(DataModuleEnum.Entity);
        }
        public Hero Owned
        {
            get { return _entityModule.GetHero() as Hero; }
        }

        //获取实体ID
        public Int64 GetUID()
        {
            return m_uid;
        }
        //获得实体类型
        public Enum_EntityType GetEntityClass()
        {
            return Enum_EntityType.EN_ENTITY_TYPE_GROCERIES;
        }

        public bool OnMessage(ClientMsgID msgId, IExtensible msgData)
        {
            switch (msgId)
            {
                case ClientMsgID.MSG_PROP_UPDATE_ENTITY_RES:
                    List<Propdata> proplist = ((MsgProp_UpdateEntityProp_Res) msgData).proplist;
                    for (int i = 0; i < proplist.Count; i++)
                    {
                        _propItemInfo.OnUpdateAttr(proplist[i]);
                    }
                    return true;
                default: return false;
            }
        }


        //获得实体属性
        public PropItemInfo GetEntityProp()
        {
            return _propItemInfo;
        }

        public propItemData GetItemData()
        {
            return _propItemData;
        }
        //导入数据
        public bool ImportDataContext(byte[] EntityData)
        {
            return EntityUtility.BuildData(ref _propItemInfo, GetEntityClass(), EntityData);
        }

        //创建 
        public bool Create(Int64 uid)
        {
            this.m_uid = uid;

            //判断客户端是否有该物品配置
            int nGoodsID = (int)_propItemInfo.nGoodsID;
            if (!ExcelData.Instance.propItemDataDic.ContainsKey(nGoodsID))
            {
                return false;
            }
            _propItemData = ExcelData.Instance.propItemDataDic[nGoodsID];
            //Owned.AddEntityPart()
            //加入实体中
            if (!_entityModule.AddEntity(this, GetEntityClass()))
            {
                return false;
            }
            return true;
        }
        //释放
        public void Destroy()
        {
            _entityModule.DestroyEntity(GetUID(),GetEntityClass());
        }
        public bool IsType(Enum_PersonPart_Type ept)
        {
            var entityPart = (IEntityPart)Owned.GetEntityPart((uint)ept);
            //VirtualGrid          virtualGrid    = entityPart.GetPartID();
            //var                  gridGoodsByUid = virtualGrid.GetGridGoodsByUID(XXX);
            return true;
        }

        //能否使用
        public bool CanUse(out string result)
        {
            result = "";
            IPerson person = _entityModule.GetHero() as Hero;
            if (person == null)
            {
                return false;
            }
            int nLevel = person.GetNumProp((int)Enum_Person_Prop.EN_PERSON_PROP_LEVEL);

            if (_propItemData == null)
            {
                return false;
            }

            if (_propItemData.levelLimit != 0 && nLevel < _propItemData.levelLimit)
            {
                result = "等级不足" + _propItemData.levelLimit + "，无法使用！";
                return false;
            }
            //todo 其他限制
            return true;
        }
    }
}