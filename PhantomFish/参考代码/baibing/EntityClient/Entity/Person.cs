using System;
using System.Collections.Generic;
using UnityEngine;
using ClientMessage;
using ProtoBuf;

namespace Cookgame.Entity
{
    public interface IPerson : IEntity
    {
        //获取PDBID(数值类型)
        Int64 GetPDBID();
        //取得玩家名字
        string GetPlayerName();
        //设置属性
        bool SetNumProp(int propid, int value);

        //取得属性
        int GetNumProp(int propid);

        //取得玩家头像ID
        int GetHeadIconID();

        //添加实体部件
        bool AddEntityPart(IEntityPart part);
        //删除实体部件
        bool RemoveEntityPart(uint nPartID);
        //取得实体部件
        IEntityPart GetEntityPart(uint nPartID);
    }
    public class Person : IPerson
    {
        //玩家实体UID
        protected Int64 __uid = 0;
        //玩家姓名
        protected string __playerName = null;
        //玩家pdbid
        protected Int64 __pdbid = 0;

        //玩家部件
        protected Dictionary<uint, IEntityPart> __AllEntityPart = new Dictionary<uint, IEntityPart>();

        //  存储玩家属性枚举和相应的属性值
        protected Dictionary<Enum_Person_Prop, int> personProp = new Dictionary<Enum_Person_Prop, int>(/*new PersonPropComparer()*/);

        //获取PDBID(数值类型)
        public Int64 GetPDBID()
        {
            return __pdbid;
        }
        //获得实体类型
        public Int64 GetUID()
        {
            return __uid;
        }
        //获得玩家名字
        public string GetPlayerName()
        {
            return __playerName;
        }
        //取得玩家头像ID
        public int GetHeadIconID()
        {
            return GetNumProp((int)Enum_Person_Prop.EN_PERSON_PROP_AVATAR_ID);
        }
        //获得实体类型
        public Enum_EntityType GetEntityClass()
        {
            return Enum_EntityType.EN_ENTITY_TYPE_PERSON;
        }

        //设置属性
        public bool SetNumProp(int propid, int value)
        {
            if (propid < 0 || propid >= (int)Enum_Person_Prop.EN_PERSON_PROP_MAXID)
            {
                return false;
            }
            if (personProp.ContainsKey((Enum_Person_Prop)propid))
            {
                personProp[(Enum_Person_Prop)propid] = value;
            }
            else
            {
                personProp.Add((Enum_Person_Prop)propid, value);
            }
            return true;
        }

        //取得属性
        public int GetNumProp(int propid)
        {
            if (propid < 0 || propid >= (int)Enum_Person_Prop.EN_PERSON_PROP_MAXID)
            {
                return 0;
            }
            int value = 0;
            if (!personProp.TryGetValue((Enum_Person_Prop)propid, out value))
            {
                return 0;
            }
            return value;
        }
        //根据属性名返回相应的属性值
        public uint GetPersonPropValue(Enum_Person_Prop prop)
        {
            return (uint)GetNumProp((int)prop);
        }

        //导入数据
        public bool ImportDataContext(byte[] entityData)
        {
            PersonInfo personInfo = entityData.ToMessageData<PersonInfo>();

            __pdbid = personInfo.pdbid;
            __playerName = personInfo.name;


            int count = personInfo.proplist.Count;
            var propList = personInfo.proplist;
            for (int i = 0; i < count; i++)
            {
                uint propId = propList[i].propid;
                SetNumProp((int)propId, (int)propList[i].propvalue);

                ////  当驾照改动和等级改动，处理驾照红点
                //if ((Enum_Person_Prop)propId == Enum_Person_Prop.EN_PERSON_PROP_LICENSE_LEVEL ||
                //    (Enum_Person_Prop)propId == Enum_Person_Prop.EN_PERSON_PROP_LEVEL /*&& lvBefore + 1 == propList[i].propvalue*/)
                //{
                //    DrivingLicenseManager.instance.RedPointLicense();
                //}
            }

            return true;
        }

        public bool AddEntityPart(IEntityPart part)
        {
            if (part == null)
            {
                return false;
            }
            uint nPartID = part.GetPartID();
            if (nPartID <= (int)Enum_PersonPart_Type.EN_PERSON_PART_INVALID || nPartID >= (int)Enum_PersonPart_Type.EN_PERSON_PART_MAX)
            {
                return false;
            }
            IEntityPart __part;
            if (__AllEntityPart.TryGetValue(nPartID, out __part))
            {
                return false;
            }
            __AllEntityPart.Add(nPartID, part);
            return true;
        }

        private bool UpdateEntityPart(uint nPartID, byte[] propvalue)
        {
            if (__AllEntityPart.ContainsKey(nPartID))
            {
                __AllEntityPart[nPartID].UpdateProp(propvalue);
                return true;
            }
            return false;
        }
        public bool RemoveEntityPart(uint nPartID)
        {
            if (nPartID <= (uint)Enum_PersonPart_Type.EN_PERSON_PART_INVALID || nPartID >= (uint)Enum_PersonPart_Type.EN_PERSON_PART_MAX)
            {
                return false;
            }
            IEntityPart __part;
            if (!__AllEntityPart.TryGetValue(nPartID, out __part))
            {
                return false;
            }
            __AllEntityPart.Remove(nPartID);
            return true;
        }

        public IEntityPart GetEntityPart(uint nPartID)
        {
            if (nPartID <= (uint)Enum_PersonPart_Type.EN_PERSON_PART_INVALID || nPartID >= (uint)Enum_PersonPart_Type.EN_PERSON_PART_MAX)
            {
                return null;
            }
            IEntityPart __part;
            if (!__AllEntityPart.TryGetValue(nPartID, out __part))
            {
                return null;
            }
            return __part;
        }
        //消息处理
        public virtual bool OnMessage(ClientMsgID msgId, IExtensible msgData)
        {
            switch (msgId)
            {
                case ClientMsgID.MSG_PROP_UPDATE_ENTITY_RES:
                    OnUpdateAttr(((MsgProp_UpdateEntityProp_Res)msgData).proplist);
                    return true;
                case ClientMsgID.MSG_PROP_CREATE_SELFPART_RES:
                    List<PropStringData> pratList = ((MsgProp_UpdatePersonPart_Res)msgData).PartList;
                    for (int i = 0; i < pratList.Count; i++)
                    {
                        UpdateEntityPart(pratList[i].propid, pratList[i].propvalue);
                    }
                    return true;
                default: return false;
            }
        }

        public void OnUpdateAttr(List<Propdata> proplist)
        {
            for (int i = 0; i < proplist.Count; i++)
            {
                personProp[(Enum_Person_Prop)proplist[i].propid] = (int)proplist[i].propvalue.uint_value;
            }
        }
    }
}