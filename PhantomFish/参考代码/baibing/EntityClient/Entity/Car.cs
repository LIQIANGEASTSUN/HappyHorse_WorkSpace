using System;
using System.Collections.Generic;
using ClientMessage;
using Cookgame.Module;
using ProtoBuf;

namespace Cookgame.Entity
{
    public interface ICar : IEntity
    {
        //获得车辆属性
        CarProp GetEntityProp();

        //取得该车配置属性
        carData GetCarData();
        // 是否是虚拟车辆
        bool IsVirtual();

        void UpdateCarEquipInfo(uint nPlace, ulong nEntityUID);

    }
    public class Car : ICar
    {
        private Int64 m_uid;
        private CarProp CarPropInfo;
        private bool __bIsVirtual = false;

        private EntityClientModule _entityModule;
        private GridClientModule _gridClientModule;
        private VirtualGrid _grid;
        public Car()
        {
            _entityModule = GameUtility.GetModule<EntityClientModule>(DataModuleEnum.Entity);
            _gridClientModule = GameUtility.GetModule<GridClientModule>(DataModuleEnum.GridClient);
        }
        public Int64 GetUID()
        {
            return m_uid;
        }
        public bool IsVirtual()
        {
            return __bIsVirtual;
        }
        //获得实体类型
        public Enum_EntityType GetEntityClass()
        {
            return Enum_EntityType.EN_ENTITY_TYPE_CAR;
        }

        public bool OnMessage(ClientMsgID msgId, IExtensible msgData)
        {
            switch (msgId)
            {
                case ClientMsgID.MSG_ACTION_BUILDGRID_RES:
                    BuildCarGrid(((MsgAction_head)msgData).ActionData);
                    return true;
                case ClientMsgID.MSG_ACTION_BUILDCARPART_RES:
                    BuildCarPart((CarInfo_PartInfo)msgData);
                    return true;
                default: return false;
            }
           
        }

     


        //获得车辆属性
        public CarProp GetEntityProp()
        {
            return CarPropInfo;
        }


        public carData GetCarData()
        {
            return CarPropInfo.carData;
        }

        public bool ImportDataContext(carData data)
        {
            CarPropInfo = new CarProp();
            CarPropInfo.CarId = data.id;
            CarPropInfo.carData = data;
            return true;
        }
        //导入数据
        public bool ImportDataContext(byte[] entityData)
        {
            CarInfo carInfo = entityData.ToMessageData<CarInfo>();
            
            if (carInfo == null)
            {
                return false;
            }

            // 车辆属性

            if (carInfo.DetailData== null)
            {
                return false;
            }

            int propCount = carInfo.DetailData.propinfo.Count;
            Dictionary<Enum_CarProperty, int> carPropertyList = new Dictionary<Enum_CarProperty, int>();
            carPropertyList.Clear();
            for (int j = 0; j < propCount; j++)
            {
                carPropertyList[(Enum_CarProperty)carInfo.DetailData.propinfo[j].propid] = (int)carInfo.DetailData.propinfo[j].propvalue;
            }

            if (CarPropInfo == null)
                CarPropInfo = new CarProp();
            m_uid = Convert.ToInt64(carInfo.uid);
            CarPropInfo.CaruId =carInfo.caruid;
            if (carPropertyList.ContainsKey(Enum_CarProperty.CARPROPERTY_GETTIME))
            {
                CarPropInfo.getCarTime = (int)carPropertyList[Enum_CarProperty.CARPROPERTY_GETTIME];
            }

            if (carPropertyList.ContainsKey(Enum_CarProperty.CARPROPERTY_USEFLAG))
            {
                CarPropInfo.IsUsed = carPropertyList[Enum_CarProperty.CARPROPERTY_USEFLAG] == 1;
            }

            if (carPropertyList.ContainsKey(Enum_CarProperty.CARPROPERTY_TYPE))
            {
                CarPropInfo.CarId = (int)carPropertyList[Enum_CarProperty.CARPROPERTY_TYPE];
            }
            CarPropInfo.ServerCarPropDic = carPropertyList;
            CarPropInfo.Locked = false;

            // GarageSystem.UpdateCarPropExpiryTime(carPropertyList, CarPropInfo);

            // if(CarPropInfo.idCar!="")
            // {
            //     CarPropInfo.serverCarPropDic[CarPropInfo.idCar] = carPropertyList;
            // }

            // if (carInfo.binuse)
            // {
            //     GarageSystem.CarID      = carInfo.carId;
            //     GarageSystem.CarType    = CarPropInfo.carType;
            // }

            // if (!CarPropInfo.IsUsed)
            // {
            //     GarageSystem.m_newCarList.Add(CarPropInfo.carType);
            // }
            //// Debug.LogError("CarPropInfo.idCar:" + CarPropInfo.idCar + ",m_uid:" + m_uid + ", CarPropInfo.carType:" + CarPropInfo.carType);
            return true;
        }

        public bool ImportVirtualDataContext(byte[] EntityData)
        {
            //int carType = GameUtility.GetMessageData<int>(EntityData);
            //if (CarPropInfo == null)
            //    CarPropInfo = new CarProp(carType.ToString(), true);

            //CarPropInfo.carType = carType;
            return true;
        }
        //创建 
        public bool Create(Int64 uid)
        {
            this.m_uid = uid;
            //是否存在本地配置属性
            int id = CarPropInfo.CarId;
            if (!ExcelData.Instance.carDataDic.ContainsKey(id))
            {
                GameLog.LogError(" car:ceate false !ExcelData.Instance.carDataDic.ContainsKey(id) id=" + id);
                return false;
            }
            CarPropInfo.carData = ExcelData.Instance.carDataDic[id];
            //增加到实体中
            if (!_entityModule.AddEntity(this, GetEntityClass()))
            {
                return false;
            }
            return true;
        }

        //创建虚拟车辆
        public bool CreateVirtual(Int64 uid)
        {
            this.m_uid = uid;
            int id = CarPropInfo.CarId;
            if (!ExcelData.Instance.carDataDic.ContainsKey(id))
            {
                return false;
            }
            CarPropInfo.carData = ExcelData.Instance.carDataDic[id];
            if (!_entityModule.AddVirtualCar(this))
            {
                return false;
            }
            __bIsVirtual = true;
            return true;
        }

        //释放
        public void Destroy()
        {
            _entityModule.DestroyEntity(GetUID(), GetEntityClass());
        }

        private void BuildCarGrid(byte[] actionData)
        {
            MsgAction_BuildGridClient_Res res = actionData.ToMessageData<MsgAction_BuildGridClient_Res>();
            if (res == null)
            {
                return;
            }
            if (res.nGridName != (uint)eGridName.EN_GRID_NAME_CAR_EQUIP)
            {
                GameLog.LogError("BuildPacketGrid未知类型的格子创建,nGridName=" + res.nGridName);
                return;
            }
            _grid = _gridClientModule.BuildGrid(res.nGridID, res.nGridName, res.nGridType, res.nMaxSize, res.szGridName);
            if (_grid == null)
            {
                return;
            }
        }
        private void BuildCarPart(CarInfo_PartInfo msgData)
        {

            if (msgData == null)
            {
                return;
            }
            // 车辆部件

            if (msgData.partInfo == null)
            {
                return ;
            }

            for (int n = 0; n < msgData.partInfo.Count; n++)
            {
                uint partId = msgData.partInfo[n].propid;
                byte[] partByteData = msgData.partInfo[n].propvalue;
                // 装备部件
                if (partId == (uint)Enum_CarPartType.EN_CAR_PART_EQUIP)
                {
                    BuildCarEquipPartData(partByteData);
                }
                // 外观部件
                else if (partId == (uint)Enum_CarPartType.EN_CAR_PART_PAINT)
                {
                    BuildCarPaintPartData(partByteData);
                }
            }
        }

        public VirtualGrid GetVirtualGrid()
        {
            return _grid;
        }
        // 车辆装备部件数据解析
        public void BuildCarEquipPartData(byte[] data)
        {
            if (data == null)
            {
                return;
            }
            CarEquiplist messageData = data.ToMessageData<CarEquiplist>();

            if (messageData == null)
            {
                return;
            }

            for (int i = 0; i < messageData.carEquipList.Count; i++)
            {
                ComponentInfo componentInfo = messageData.carEquipList[i].equipInfo.ToMessageData<ComponentInfo>();
                CarPropInfo.CarEquipDic[(EGoods_Equip_subClass)messageData.carEquipList[i].posid] = componentInfo;
            }
        }

        // 车辆外观部件数据解析
        public void BuildCarPaintPartData(byte[] data)
        {
            if (data == null)
            {
                return;
            }

            CarPaintlist paintData = data.ToMessageData<CarPaintlist>();

            for (int i = 0; i < paintData.carPaintList.Count; i++)
            {
                if (i == (int)Enum_CarPaint_module.CARPAINT_MODULE_MATERIAL)
                    CarPropInfo.MultipleUnlockList.Add((Enum_CarPaint_module)i, paintData.carPaintList[i].normalUnlockList);
                else
                    CarPropInfo.NormalUnlockList.Add((Enum_CarPaint_module)i, paintData.carPaintList[i].normalUnlockList);
            }
            //CarPaintlist paintData = data.ToMessageData<CarPaintlist>();
            //if (paintData == null)
            //{
            //    return;
            //}
            ////设置车辆当前外观信息
            //MsgAction_SyncCarPaint_Res.MsgCarPaintInfo synCar = paintData.paintData.propvalue.ToMessageData<MsgAction_SyncCarPaint_Res.MsgCarPaintInfo>();
            //if (synCar == null)
            //{
            //    return;
            //}
            ////synCar.paintInfo.propList
            //// synCar.normalUnlockList
            //// synCar.multipleUnlockList
            //// 以上三个列表中 含有已解析的数据， 以下是对解析的数据 进行本地赋值

            ////皮肤
            //for (int i = 0; i < synCar.paintInfo.propList.Count; i++)
            //{
            //    CarPropInfo.PaintInfoProp[(Enum_CarPaint_Prop)i] = synCar.paintInfo.propList[i];
            //    CarPropInfo.isRefit = (CarPropInfo.PaintInfoProp[(Enum_CarPaint_Prop)i] != 0);
            //}

            ////解析单重解锁信息
            //List<CarPaintlist.CarPaintData.NormalUnlockList> LockSkinInfo = synCar.normalUnlockList;
            //List<CarPaintlist.CarPaintData.NormalUnlockList> lockList = new List<CarPaintlist.CarPaintData.NormalUnlockList>();
            ////先填充一下list
            //for (int i = 0; i < (int)Enum_CarPaint_Prop.CARPAINT_PROP_MAX_ID; ++i)
            //    lockList.Add(new CarPaintlist.CarPaintData.NormalUnlockList());

            ////i用于索引LockSkinInfo
            ////moduleId用于索引 lockList
            //for (int i = 0; i < LockSkinInfo.Count; ++i)
            //{
            //    int moduleId = (int)LockSkinInfo[i].moduleID;
            //    for (int j = 0; j < LockSkinInfo[i].viewidList.Count; ++j)
            //    {
            //        int viewId = (int)LockSkinInfo[i].viewidList[j];

            //        while (lockList[moduleId].viewidList.Count < viewId + 1)
            //        {
            //            lockList[moduleId].viewidList.Add(0);
            //        }
            //        lockList[moduleId].viewidList[viewId] = 1;
            //    }
            //}

            //////补全unlock列表
            ////if (GarageSystem.instance.unLockInfo.ContainsKey(synCar.carType))
            ////    GarageSystem.instance.unLockInfo[synCar.carType] = lockList;
            ////else
            ////    GarageSystem.instance.unLockInfo.Add(synCar.carType, lockList);

            ////解析多重解锁信息
            //List<CarPaintlist.CarPaintData.MultipleUnlockList> LockSkinInfo_multiple = synCar.multipleUnlockList;
            ////一辆车所有部位的多重解锁表
            //List<List<CarPaintlist.CarPaintData.MultipleUnlockList>> lockList_multiple = new List<List<CarPaintlist.CarPaintData.MultipleUnlockList>>();
            //for (int i = 0; i < (int)Enum_CarPaint_Prop.CARPAINT_PROP_MAX_ID; ++i)
            //    lockList_multiple.Add(new List<CarPaintlist.CarPaintData.MultipleUnlockList>());

            ////i用于索引LockSkinInfo
            ////moduleId用于索引 lockList
            //for (int i = 0; i < LockSkinInfo_multiple.Count; ++i)
            //{
            //    int moduleId = (int)LockSkinInfo_multiple[i].moduleID;
            //    //获取当前部位的Unlockinfo
            //    CarPaintlist.CarPaintData.MultipleUnlockList curModuleUnlockInfo = LockSkinInfo_multiple[moduleId];

            //    //一个unlockInfo的unlockList，存储了所有解锁的paramId和对应的viewIdList
            //    //临时存储一个部位的所有第一层信息 param
            //    List<Msg_CarPaintMultipleUnlockList.CarPaintViewList> tempPaintInfoList = new List<Msg_CarPaintMultipleUnlockList.CarPaintViewList>();
            //    for (int j = 0; j < curModuleUnlockInfo.unlockList.Count; ++j)
            //    {
            //        //补全当前部件下的 当前mat 下的第几个color 列表
            //        uint param = curModuleUnlockInfo.unlockList[j].param;
            //        List<uint> curViewIdList = curModuleUnlockInfo.unlockList[j].viewidList;
            //        while (tempPaintInfoList.Count < param + 1)
            //        {
            //            Msg_CarPaintMultipleUnlockList.CarPaintViewList tempPaintInfo = new Msg_CarPaintMultipleUnlockList.CarPaintViewList();
            //            tempPaintInfoList.Add(tempPaintInfo);
            //        }
            //        //填充对应param的viewList
            //        for (int k = 0; k < curViewIdList.Count; ++k)
            //        {
            //            int viewId = (int)curViewIdList[k];
            //            while (tempPaintInfoList[(int)param].viewidList.Count < curViewIdList[k] + 1)
            //            {
            //                tempPaintInfoList[(int)param].viewidList.Add(0);
            //            }
            //            tempPaintInfoList[(int)param].viewidList[viewId] = 1;
            //        }
            //    }
            //    lockList_multiple[moduleId] = tempPaintInfoList;
            //}

            //////补全unlock_multiple列表
            ////if (GarageSystem.instance.unLockInfo_multiple.ContainsKey(synCar.carType))
            ////    GarageSystem.instance.unLockInfo_multiple[synCar.carType] = lockList_multiple;
            ////else
            ////    GarageSystem.instance.unLockInfo_multiple.Add(synCar.carType, lockList_multiple);


            ////if ((int)synCar.carType == GarageSystem.CarGarageType)
            ////{
            ////    BaseCar carScript = (GarageSystem.CurShowCar == null) ? null : GarageSystem.CurShowCar.GetComponent<BaseCar>();
            ////    if (null == carScript)
            ////    {
            ////        return;
            ////    }
            ////    carScript.SetCarOutlook((int)CarPropInfo.paintInfoProp[Enum_CarPaint_Prop.CARPAINT_PROP_MATERIAL], (int)CarPropInfo.paintInfoProp[(Enum_CarPaint_Prop)1],
            ////        (int)CarPropInfo.paintInfoProp[(Enum_CarPaint_Prop)2], (int)CarPropInfo.paintInfoProp[(Enum_CarPaint_Prop)3], (int)CarPropInfo.paintInfoProp[(Enum_CarPaint_Prop)4],
            ////        (int)CarPropInfo.paintInfoProp[(Enum_CarPaint_Prop)5], (int)CarPropInfo.paintInfoProp[(Enum_CarPaint_Prop)6]);
            ////}

        }

        // 更新车辆上的装备信息
        public void UpdateCarEquipInfo(uint nPlace, ulong nEntityUID)
        {
            //if (CarPropInfo.CarEquipDic.ContainsKey(nPlace))
            //{
            //    CarPropInfo.CarEquipDic[nPlace] = nEntityUID;
            //}
            //GarageSystem.instance.ResetCarDataRefit(CarPropInfo.carType);
        }

    }
}