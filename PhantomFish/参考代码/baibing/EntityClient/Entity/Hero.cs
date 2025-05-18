using System;
using System.Collections.Generic;
using ClientMessage;
using Cookgame.Module;
using ProtoBuf;

namespace Cookgame.Entity
{
    public class MatchRecordPlayerData
    {
        public Int64 pdbid;
        public string name;
        public uint ranking;
        public uint useTickCount;
        public bool isNewRecord;
        public uint useCarType;
    }
    //比赛数据
    public class MatchRecordData
    {
        public uint mapID;
        public uint createTime;
        public uint methodType;
        public MatchRecordPlayerData matchRecordPlayerData;
    }

    public class Hero : Person
    {
        //比赛记录
        protected List<MatchRecordData> matchRecordData = new List<MatchRecordData>();
        //玩家地图挑战成绩和PVP成绩
        //id,地图id;
        //id:	EN_MAP_BEST_RECORD_PVP = 0;		//PVP地图记录  EN_MAP_BEST_RECORD_CHALLENGE = 1;		//挑战赛记录
        //value：跑完地图的总毫秒数
        protected Dictionary<uint, Dictionary<uint, uint>> mapBestRecordData = new Dictionary<uint, Dictionary<uint, uint>>();
        private EntityClientModule _entityModule;
        private GridClientModule _gridClientModule;
        public Hero()
        {
            _entityModule = GameUtility.GetModule<EntityClientModule>(DataModuleEnum.Entity);
            _gridClientModule = GameUtility.GetModule<GridClientModule>(DataModuleEnum.GridClient);
        }
        public bool Create(Int64 uid)
        {
            __uid = uid;

            //设置客户端主角
            //GameManager.Instance.SetMyPlayerInfo(this);
            //添加实体到世界
            _entityModule.AddEntity(this,GetEntityClass());
            _entityModule.SetHero(this);
            GameLog.Log("创建主角:" + GetPlayerName() + " 等级:" + GetNumProp((int)Enum_Person_Prop.EN_PERSON_PROP_LEVEL) + " 性别:" + GetNumProp((int)Enum_Person_Prop.EN_PERSON_PROP_SEX));
            return true;
        }
        //释放
        public void Destroy()
        {
            //GameManager.Instance.SetMyPlayerInfo(null);
            _entityModule.SetHero(null);
            _entityModule.DestroyEntity(GetUID(), GetEntityClass());
        }
        //取得玩家地图挑战和pvp的最佳成绩
        public Dictionary<uint, uint> GetMapBestRecordData(uint id)
        {
            Dictionary<uint, uint> mapData = new Dictionary<uint, uint>();
            if (!mapBestRecordData.ContainsKey(id))
            {
                return null;
            }
            return mapData;
        }
        //更新玩家地图挑战和pvp的最佳成绩
        private void UpDateMapBestRecordData(byte[] actionData)
        {
            Msg_ActionMapBestRecord_Res res = actionData.ToMessageData<Msg_ActionMapBestRecord_Res>();

            Dictionary<uint, uint> mapdata = new Dictionary<uint, uint>();
            if (mapBestRecordData.ContainsKey(res.mapid))
            {
                mapBestRecordData.TryGetValue(res.mapid, out mapdata);
                if (res.prop.propid == 0)
                {
                    mapdata[res.prop.propid] = res.prop.propvalue;
                }
                else if (res.prop.propid == 1)
                {
                    mapdata[res.prop.propid] = res.prop.propvalue;
                }
            }
            else
            {
                Dictionary<uint, uint> mapData = new Dictionary<uint, uint>();
                mapData.Add(res.prop.propid, res.prop.propvalue);
                mapBestRecordData.Add(res.mapid, mapData);
            }

        }

        //更新比赛记录
        private void UpDateHistoryMatchRecord(byte[] actionData)
        {
            MsgAction_HistoryMatchRecord_Res res = actionData.ToMessageData<MsgAction_HistoryMatchRecord_Res>();
            MatchRecordData matchRecordData = new MatchRecordData();
            for (int i = 0; i < res.recordList.Count; i++)
            {
                matchRecordData.mapID = res.recordList[i].mapID;
                matchRecordData.createTime = res.recordList[i].createTime;
                matchRecordData.methodType = res.recordList[i].methodType;
                matchRecordData.matchRecordPlayerData = new MatchRecordPlayerData();
                List<MsgAction_HistoryMatchRecord_Res.MatchRecordPlayerInfo> memberList = res.recordList[i].memberList;
                for (int j = 0; j < memberList.Count; j++)
                {
                    matchRecordData.matchRecordPlayerData.pdbid = memberList[j].pdbid;
                    matchRecordData.matchRecordPlayerData.name =memberList[j].name;
                    matchRecordData.matchRecordPlayerData.ranking = memberList[j].ranking;
                    matchRecordData.matchRecordPlayerData.useTickCount = memberList[j].useTickCount;
                    matchRecordData.matchRecordPlayerData.isNewRecord = memberList[j].isNewRecord;
                    matchRecordData.matchRecordPlayerData.useCarType = memberList[j].useCarID;
                }
            }
        }

        //创建格子
        private void BuildGrid(ClientMsgID msgId, IExtensible msgData)
        {
            MsgAction_BuildGridClient_Res res = ((MsgAction_head)msgData).ActionData.ToMessageData<MsgAction_BuildGridClient_Res>();
            if (res == null)
            {
                return;
            }
            GameLog.Log("BuildGrid 格子创建,nGridName=" + res.nGridName + ",res.nGridID:" + res.nGridID);
            MsgActicon_CreatePackageContext byExpand = res.byExpand.ToMessageData<MsgActicon_CreatePackageContext>();
            switch (res.nGridName)
            {
                // 如果是仓库 则创建仓库部件
                case (uint)eGridName.EN_GRID_NAME_PACKET:
                    {
                        VirtualGrid grid = _gridClientModule.BuildGrid(res.nGridID, res.nGridName, res.nGridType, res.nMaxSize, res.szGridName);
                        if (grid == null)
                        {
                            return;
                        }
                        IPersonWarehousePart WarePart = GetEntityPart((uint)Enum_PersonPart_Type.EN_PERSON_PART_PACKAGE) as IPersonWarehousePart;
                        if (WarePart != null)
                        {
                            WarePart.SetGridID(res.nGridID);
                        }
                        break;
                    }
                // 车辆装备部件
                case (uint)eGridName.EN_GRID_NAME_CAR_EQUIP:
                    {
                        _entityModule.GetEntity(byExpand.uidEntity, (Enum_EntityType)byExpand.EntityClass)?.OnMessage(msgId, msgData);
                        //PersonCarPart carPart = GetEntityPart((uint)Enum_PersonPart_Type.EN_PERSON_PART_CAR) as PersonCarPart;
                        //if (carPart != null)
                        //{
                        //    carPart.SetGridID(res.nGridID);
                        //}
                        break;
                    }
                default:
                    {
                        break;
                    }
            }
        }

        public override bool OnMessage(ClientMsgID msgId, IExtensible msgData)
        {
            switch (msgId)
            {
                case ClientMsgID.MSG_ACTION_BUILDGRID_RES:
                    BuildGrid(msgId, msgData/*((MsgAction_head)msgData).ActionData*/);
                    return true;
                default:
                    base.OnMessage(msgId, msgData); return false;
            }
        }

    }
}
