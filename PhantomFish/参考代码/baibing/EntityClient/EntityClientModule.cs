using System;
using System.Collections.Generic;
using System.Linq;
using ClientMessage;
using Cookgame.Message;
using Cookgame.Module;

namespace Cookgame.Entity
{
    //实体ID组成
    public class EntityUID
    {
        //虚拟实体的UID序号
        private UInt32 m_nUIDAllotSerialNo = 0x7FFFFFFF;

        public static UInt32 Resolve_SerialNo(Int64 uidEntity)
        {
            UInt32 nSerialNo = (UInt32) (uidEntity >> 32);
            return nSerialNo;
        }

        //产生一个与服务器无法重复的UID,序号采用最大值(0x7FFFFFFF)往后递减,句柄固定大小为0xFFFFF
        public Int64 MakeVirtualEntityUID()
        {
            m_nUIDAllotSerialNo--;
            return (Int64) m_nUIDAllotSerialNo << 32 | 0xFFFFF;
        }
    }

    public class EntityClientModule : BaseModule
    {
        // private Dictionary<类型, 接口> __AllGroceriesEntity = new Dictionary<Int64, IEntity>();
        //实体UID
        public EntityUID __EntityUID = new EntityUID();

        //全部实体对象列表
        //Key:UID-IEntity  零件/杂货
        private Dictionary<Int64, IEntity> __AllGroceriesEntity = new Dictionary<Int64, IEntity>();

        //Key:SNO-IEntity 零件/杂货
        private Dictionary<UInt32, IEntity> __AllGroceriesEntityBySerial = new Dictionary<UInt32, IEntity>();

        //Key:UID-ICar 车辆
        private Dictionary<Int64, IEntity> __AllCarEntity = new Dictionary<Int64, IEntity>();

        //Key:UID-IPerson 人物
        private Dictionary<Int64, IEntity> __AllPersonEntity = new Dictionary<Int64, IEntity>();

        //Key:SNO-IPerson 人物
        private Dictionary<UInt32, IEntity> __AllPersonEntityBySerialNo = new Dictionary<UInt32, IEntity>();

        //Key:PDBID-IPerson 人物
        private Dictionary<Int64, IEntity> __AllPersonEntityByPDBID = new Dictionary<Int64, IEntity>();

        //所有虚拟车辆实体列表Key:UID-ICar
        private Dictionary<Int64, IEntity> __AllVirtualCarEntity = new Dictionary<Int64, IEntity>();

        //拥有的数据汇总
        private Hero __hero = null; /* -->key*/

        public Car CurCar { get; set; } = null;

        //初始化
        public override void InitData()
        {
        }

        #region   protocol

        public override void InitProcessList()
        {
            RegServerMessageProcess<MsgProp_UpdatePersonPart_Res>(ClientMsgID.MSG_PROP_CREATE_SELFPART_RES,
                OnCreateSelfPart);
            RegServerMessageProcess<MsgProp_UpdateEntityProp_Res>(ClientMsgID.MSG_PROP_UPDATE_ENTITY_RES,
                OnUpdateEntityProp);
            RegServerMessageProcess<MsgProp_Batch_CreateEntity>(ClientMsgID.MSG_PROP_BATCH_CREATEENTITY_RES,
                OnBatchCreateEntity);
            RegServerMessageProcess<MsgProp_DestroyEntity_Res>(ClientMsgID.MSG_PROP_DESTROY_ENTITY_RES,
                OnDestroyEntity);
            RegServerMessageProcess<MsgAction_ChangeUseCar_Res>(ClientMsgID.MSG_ACTION_CHANGEUSECAR_RES,
                OnChangeUseCar);
            RegServerMessageProcess<MsgAction_head>(ClientMsgID.MSG_ACTION_BUILDGRID_RES, OnBuildGrid);
            RegServerMessageProcess<CarInfo_PartInfo>(ClientMsgID.MSG_ACTION_BUILDCARPART_RES, OnBuildCarPart);
        }

        #region response

        /// <summary>
        /// 创建角色信息
        /// </summary>
        public void CreatePlayerInfo(IMessage msg)
        {
            MsgProp_CreateEntityProp_Res msgData = msg.GetMessageData<MsgProp_CreateEntityProp_Res>();
            BuildEntity(msgData.uidEntity, (Enum_EntityType) msgData.EntityClass, msgData.EntityData, msgData.bIsHero);
        }

        /// <summary>
        /// 创建部件
        /// </summary>
        private void OnCreateSelfPart(IMessage msg)
        {
            MsgProp_UpdatePersonPart_Res msgData = msg.GetMessageData<MsgProp_UpdatePersonPart_Res>();
            GetPersonByPDBID(msgData.pdbid)?.OnMessage(ClientMsgID.MSG_PROP_CREATE_SELFPART_RES, msgData);
        }

        /// <summary>
        /// 通知客户端批量创建实体
        /// </summary>
        private void OnBatchCreateEntity(IMessage msg)
        {
            MsgProp_Batch_CreateEntity msgData = msg.GetMessageData<MsgProp_Batch_CreateEntity>();
            List<MsgProp_Batch_CreateEntity.SingleEntity> entityList = msgData.EntityList;
            for (int i = 0; i < msgData.nCount; i++)
            {
                BuildEntity(entityList[i].uidEntity, (Enum_EntityType) entityList[i].EntityClass,
                    entityList[i].EntityProp);
            }
        }

        /// <summary>
        /// 通知客户端销毁实体对象
        /// </summary>
        private void OnDestroyEntity(IMessage msg)
        {
            MsgProp_DestroyEntity_Res msgData = msg.GetMessageData<MsgProp_DestroyEntity_Res>();
            List<MsgProp_DestroyEntity_Res.Entity> entity = msgData.EntityList;
            for (int i = 0; i < msgData.nCount; i++)
            {
                DestroyEntity(entity[i].uidEntity, (Enum_EntityType) entity[i].EntityClass);
            }
        }

        /// <summary>
        /// 大厅服通知客户端更新实体属性
        /// </summary>
        private void OnUpdateEntityProp(IMessage msg)
        {
            MsgProp_UpdateEntityProp_Res msgData = msg.GetMessageData<MsgProp_UpdateEntityProp_Res>();
            GetEntity(msgData.uidEntity, (Enum_EntityType) msgData.EntityClass)
                ?.OnMessage(ClientMsgID.MSG_PROP_UPDATE_ENTITY_RES, msgData);
        }

        /// <summary>
        /// 更新客户端正在使用车辆
        /// </summary>
        private void OnChangeUseCar(IMessage msg)
        {
            MsgAction_ChangeUseCar_Res msgData = msg.GetMessageData<MsgAction_ChangeUseCar_Res>();
            CurCar = GetCar(msgData.nCarUID);
            GameUtility.BroadcastData(BroadcastId.GaragePanelChangeUseCar, null);
        }

        /// <summary>
        /// 创建格子信息
        /// </summary>
        public void OnBuildGrid(IMessage msg)
        {
            MsgAction_head msgData = msg.GetMessageData<MsgAction_head>();
            GetEntity(msgData.uidEntity, (Enum_EntityType) msgData.EntityClass)
                ?.OnMessage(ClientMsgID.MSG_ACTION_BUILDGRID_RES, msgData);
        }
        /// <summary>
        /// 更新车辆部件
        /// </summary>
        private void OnBuildCarPart(IMessage msg)
        {
            CarInfo_PartInfo msgData = msg.GetMessageData<CarInfo_PartInfo>();
            GetEntity(msgData.uidEntity, Enum_EntityType.EN_ENTITY_TYPE_CAR)?.OnMessage(ClientMsgID.MSG_ACTION_BUILDCARPART_RES, msgData);
        }

        #endregion

        #region request


        #endregion

        #endregion

        /// <summary>
        /// 生成虚拟实体UID
        /// </summary>
        public Int64 MakeVirtualEntityUID()
        {
            return __EntityUID.MakeVirtualEntityUID();
        }

        /// <summary>
        /// 销毁实体
        /// </summary>
        public bool DestroyEntity(Int64 uidEntity, Enum_EntityType entityClass)
        {
            switch (entityClass)
            {
                case Enum_EntityType.EN_ENTITY_TYPE_PERSON:
                    return DestroyPersonEntity(uidEntity);
                case Enum_EntityType.EN_ENTITY_TYPE_CAR:
                    return DestroyCarEntity(uidEntity);
                case Enum_EntityType.EN_ENTITY_TYPE_GROCERIES:
                    return DestroyGroceriesEntity(uidEntity);
                default:
                    return false;
            }
        }

        /// <summary>
        /// 根据实体UID取得序号
        /// </summary>
        public IEntity GetEntity(Int64 uidEntity, Enum_EntityType entityClass)
        {
            IEntity entity;
            switch (entityClass)
            {
                case Enum_EntityType.EN_ENTITY_TYPE_PERSON:
                    return GetPersonEntity(uidEntity);
                case Enum_EntityType.EN_ENTITY_TYPE_CAR:
                    return GetCarEntity(uidEntity);
                case Enum_EntityType.EN_ENTITY_TYPE_GROCERIES:
                    return GetGroceriesEntity(uidEntity);
                default:
                    return null;
            }
        }

        /// <summary>
        /// 添加实体
        /// </summary>
        public bool AddEntity(IEntity entity, Enum_EntityType entityClass)
        {
            if (entity == null)
            {
                return false;
            }

            if (GetEntity(entity.GetUID(), entity.GetEntityClass()) != null)
            {
                GameLog.LogError("重复创建实体 实体类型:" + entity.GetEntityClass());
                return false;
            }

            switch (entityClass)
            {
                case Enum_EntityType.EN_ENTITY_TYPE_PERSON:
                    return AddPersonEntity(entity);
                case Enum_EntityType.EN_ENTITY_TYPE_CAR:
                    return AddCarEntity(entity);
                case Enum_EntityType.EN_ENTITY_TYPE_GROCERIES:
                    return AddGroceriesEntity(entity);
                default:
                    return false;
            }

            return true;
        }




        #region Groceries

        private bool AddGroceriesEntity(IEntity entity)
        {
            //压入实体列表
            __AllGroceriesEntity.Add(entity.GetUID(), entity);
            //压入实体序号列表
            __AllGroceriesEntityBySerial.Add(EntityUID.Resolve_SerialNo(entity.GetUID()), entity);
            return true;
        }

        public IEntity GetGroceriesEntity(Int64 uidEntity)
        {
            IEntity entity;
            __AllGroceriesEntity.TryGetValue(uidEntity, out entity);
            return entity;
        }

        public Groceries GetGroceries(Int64 uidGridgoods)
        {
            foreach (Groceries groceries in __AllGroceriesEntity.Values)
            {
                if(groceries.GetEntityProp().uidGoods == uidGridgoods)
                {
                    return groceries;
                }
            }
            return null;
        }

        /// <summary>
        /// 根据实体序号取得序号
        /// </summary>
        public IEntity GetEntityBySNO(UInt32 nSerialNO)
        {
            IEntity entity;
            if (__AllGroceriesEntityBySerial.TryGetValue(nSerialNO, out entity))
            {
                return entity;
            }

            return null;
        }

        private bool DestroyGroceriesEntity(Int64 uidEntity)
        {
            if (__AllGroceriesEntity.ContainsKey(uidEntity))
            {
                __AllGroceriesEntity.Remove(uidEntity);
            }

            UInt32 nSerialNo = EntityUID.Resolve_SerialNo(uidEntity);
            if (__AllGroceriesEntityBySerial.ContainsKey(nSerialNo))
            {
                __AllGroceriesEntityBySerial.Remove(nSerialNo);
            }

            return true;
        }

        #endregion

        #region Car

        public Car GetCar(int carId)
        {
            var it = __AllCarEntity.GetEnumerator();
            while (it.MoveNext())
            {
                if (((Car)it.Current.Value).GetEntityProp().CarId == carId)
                {
                    return (Car)it.Current.Value;
                }
            }
            return null;
        }

        private bool AddCarEntity(IEntity entity)
        {
            __AllCarEntity.Add(entity.GetUID(), entity);
            return true;
        }

        /// <summary>
        /// 添加虚拟车实体
        /// </summary>
        public bool AddVirtualCar(ICar car)
        {
            if (car == null)
            {
                return false;
            }

            __AllVirtualCarEntity.Add(car.GetUID(), car);
            return true;
        }

        private IEntity GetCarEntity(Int64 uidEntity)
        {
            IEntity entity;
            __AllCarEntity.TryGetValue(uidEntity, out entity);
            return entity;
        }

        private Car GetCar(Int64 carUId)
        {
            foreach (var item in __AllCarEntity)
            {
                if (((Car)item.Value).GetEntityProp().CaruId == carUId)
                    return (Car)item.Value;
            }
            return null;
        }

        private bool DestroyCarEntity(Int64 uidEntity)
        {
            if (__AllCarEntity.ContainsKey(uidEntity))
                __AllCarEntity.Remove(uidEntity);
            return true;
        }

        #endregion

        #region Person

        private bool AddPersonEntity(IEntity entity)
        {
            Int64 uidEntity = entity.GetUID();
            Int64 pdbid = ((IPerson) entity).GetPDBID();
            __AllPersonEntity.Add(uidEntity, entity);
            uint nSNO = EntityUID.Resolve_SerialNo(uidEntity);
            __AllPersonEntityBySerialNo.Add(nSNO, entity);
            __AllPersonEntityByPDBID.Add(pdbid, entity);
            return true;
        }

        private IEntity GetPersonEntity(Int64 uidEntity)
        {
            IEntity entity;
            __AllPersonEntity.TryGetValue(uidEntity, out entity);
            return entity;
        }

        public IEntity GetPersonByPDBID(Int64 pdbid)
        {
            IEntity person;
            if (__AllPersonEntityByPDBID.TryGetValue(pdbid, out person))
            {
                return person;
            }

            return null;
        }

        private bool DestroyPersonEntity(Int64 uidEntity)
        {
            Int64 pdbid = ((IPerson) GetPersonEntity(uidEntity)).GetPDBID();
            if (__AllPersonEntity.ContainsKey(uidEntity))
            {
                __AllPersonEntity.Remove(uidEntity);
            }

            uint nSNO = EntityUID.Resolve_SerialNo(uidEntity);
            if (__AllPersonEntityBySerialNo.ContainsKey(nSNO))
            {
                __AllPersonEntityBySerialNo.Remove(nSNO);
            }

            if (__AllPersonEntityByPDBID.ContainsKey(pdbid))
            {
                __AllPersonEntityByPDBID.Remove(pdbid);
            }

            return true;
        }

        #endregion


        ///// <summary>
        ///// 取得某一类型的所有实体列表
        ///// </summary>
        //public bool GetAllEntitylist(List<Int64> uidEntitylist, Enum_EntityType entityClass, out int Size)
        //{
        //    var it = __AllGroceriesEntity.GetEnumerator();
        //    while (it.MoveNext())
        //    {
        //        Int64 uid = it.Current.Key;
        //        IEntity entity = it.Current.Value;
        //        if (entity.GetEntityClass() == entityClass)
        //        {
        //            uidEntitylist.Add(uid);
        //        }
        //    }
        //    it.Dispose();
        //    Size = uidEntitylist.Count;
        //    return true;
        //}

        public EntityClientModule()
        {
            mNeedFrameUpdate = true;
            mActive = true;
        }

        //销毁
        public override void Dispose()
        {
            base.Dispose();
            __AllGroceriesEntity.Clear();
            __AllGroceriesEntityBySerial.Clear();
            __AllCarEntity.Clear();
            __AllPersonEntity.Clear();
            __AllPersonEntityByPDBID.Clear();
            __AllPersonEntityBySerialNo.Clear();
            __AllVirtualCarEntity.Clear();
        }

        //设置主角
        public void SetHero(Hero hero)
        {
            __hero = hero;
        }

        public IPerson GetHero()
        {
            return __hero;
        }

        //创建实体
        public bool BuildEntity(Int64 uid, Enum_EntityType entityClass, byte[] EntityData, bool bisHero = false)
        {
            if (entityClass == Enum_EntityType.EN_ENTITY_TYPE_PERSON)
            {
                if (bisHero)
                {
                    return BuildHero(uid, EntityData);
                }
            }

            //先销毁
            DestroyEntity(uid, entityClass);
            //再创建
            switch (entityClass)
            {
                case Enum_EntityType.EN_ENTITY_TYPE_GROCERIES:
                {
                    //创建杂货
                    Groceries groceries = new Groceries();
                    if (!groceries.ImportDataContext(EntityData))
                    {
                        return false;
                    }

                    if (!groceries.Create(uid))
                    {
                        return false;
                    }

                    return true;
                }

                case Enum_EntityType.EN_ENTITY_TYPE_EQUIPMENT:
                {
                    //创建零件
                    CarComponent component = new CarComponent();
                    if (!component.ImportDataContext(EntityData))
                    {
                        return false;
                    }

                    if (!component.Create(uid))
                    {
                        return false;
                    }

                    return true;
                }

                case Enum_EntityType.EN_ENTITY_TYPE_CAR:
                {
                    //创建车辆
                    return BuildCar(uid, EntityData);
                }

                case Enum_EntityType.EN_ENTITY_TYPE_PERSON:
                {
                    //创建人物
                    return BuildMirrorHero(uid, EntityData);
                }
            }

            return false;
        }

        //创建主角
        private bool BuildHero(Int64 uid, byte[] EntityData)
        {
            //先释放之前的主角
            //重建新的主角
            Hero hero = new Hero();
            if (!hero.ImportDataContext(EntityData))
            {
                return false;
            }

            if (!hero.Create(uid))
            {
                return false;
            }

            //仓库部件
            PersonWarehousePart __PersonWarehousePart = new PersonWarehousePart();
            if (!__PersonWarehousePart.Create(hero))
            {
                return false;
            }

            hero.AddEntityPart(__PersonWarehousePart);
            //公共部件
            PersonCommonPart __PersonCommonPart = new PersonCommonPart();
            if (!__PersonCommonPart.Create(hero))
            {
                return false;
            }

            hero.AddEntityPart(__PersonCommonPart);
            //车辆部件
            PersonCarPart __PersonCarPart = new PersonCarPart();
            if (!__PersonCarPart.Create(hero))
            {
                return false;
            }

            hero.AddEntityPart(__PersonCarPart);


            //sdk log
            if (GameConfig.Instance.isUseSDK)
            {
#if UNITY_ANDROID && !UNITY_EDITOR
                //if (Ourpalm_SDK_Entry.GetInstance() != null)
                //{
                //    // 目前没开放vip等级，暂时置0发送到sdk日志那边
                //    vipLevel = 0;

                //    // 如果是首次创建角色，发送创建角色的日志
                //    if (LoadingMode.instance.IsFirstTimeCreateRole)
                //    {
                //        Debug.Log("发送创建角色的log到sdk， 角色等级 = " + level + ", VIP等级 = " + vipLevel);
                //        Ourpalm_SDK_Entry.GetInstance().Ourpalm_SetGameInfo(
                //            1, 
                //            LoadingMode.instance.CurSltServerInfo.name, 
                //            LoadingMode.instance.CurSltServerInfo.serverLogicId.ToString(), 
                //            PlayerInfo.playerName, 
                //            PlayerInfo.pdbid, 
                //            level.ToString(), 
                //            vipLevel.ToString());
                //    }
                //    // 发送角色登录的日志
                //    Debug.Log("发送登录角色的log到sdk， 角色等级 = " + level + ", VIP等级 = " + vipLevel);
                //    Ourpalm_SDK_Entry.GetInstance().Ourpalm_SetGameInfo(
                //        2, 
                //        LoadingMode.instance.CurSltServerInfo.name, 
                //        LoadingMode.instance.CurSltServerInfo.serverLogicId.ToString(), 
                //        PlayerInfo.playerName, 
                //        PlayerInfo.pdbid, 
                //        level.ToString(), 
                //        vipLevel.ToString());
                //}
#endif
            }

            return true;
        }

        //创建镜像
        private bool BuildMirrorHero(Int64 uid, byte[] EntityData)
        {
            //先释放之前的主角
            //重建新的主角
            MirrorHero mirrorhero = new MirrorHero();

            if (!mirrorhero.ImportDataContext(EntityData))
            {
                return false;
            }

            if (!mirrorhero.Create(uid))
            {
                return false;
            }

            //仓库部件
            PersonWarehousePart __PersonWarehousePart = new PersonWarehousePart();
            if (!__PersonWarehousePart.Create(mirrorhero))
            {
                return false;
            }

            mirrorhero.AddEntityPart(__PersonWarehousePart);
            //公共部件
            PersonCommonPart __PersonCommonPart = new PersonCommonPart();
            if (!__PersonCommonPart.Create(mirrorhero))
            {
                return false;
            }

            mirrorhero.AddEntityPart(__PersonCommonPart);
            //车辆部件
            PersonCarPart __PersonCarPart = new PersonCarPart();
            if (!__PersonCarPart.Create(mirrorhero))
            {
                return false;
            }

            mirrorhero.AddEntityPart(__PersonCarPart);

            return true;
        }

        //创建车辆
        private bool BuildCar(Int64 uid, byte[] entityData)
        {
            Car car = new Car();
            if (!car.ImportDataContext(entityData))
            {
                return false;
            }

            if (!car.Create(uid))
            {
                return false;
            }

           CarInfo carInfo = entityData.ToMessageData<CarInfo>();

            //if (carInfo == null)
            //{
            //    return false;
            //}
            //// 车辆部件

            //if (carInfo.PartData.partInfo == null)
            //{
            //    return false;
            //}

            //for (int n = 0; n < carInfo.PartData.partInfo.Count; n++)
            //{
            //    uint partId = carInfo.PartData.partInfo[n].propid;
            //    byte[] partByteData = carInfo.PartData.partInfo[n].propvalue;
            //    // 装备部件
            //    if (partId == (uint) Enum_CarPartType.EN_CAR_PART_EQUIP)
            //    {
            //        car.BuildCarEquipPartData(partByteData);
            //    }
            //    // 外观部件
            //    else if (partId == (uint) Enum_CarPartType.EN_CAR_PART_PAINT)
            //    {
            //        car.BuildCarPaintPartData(partByteData);
            //    }
            //}

            if (carInfo.binuse)
            {
                CurCar = car;
                GameUtility.BroadcastData(BroadcastId.CarModuleShowCar, null);
            }
            return true;
        }

        //创建虚拟的车辆
        public bool BuildVirtualCar(byte[] EntityData)
        {
            Car car = new Car();
            if (!car.ImportVirtualDataContext(EntityData))
            {
                return false;
            }

            Int64 uid = MakeVirtualEntityUID();
            if (!car.CreateVirtual(uid))
            {
                return false;
            }

            return true;
        }
    }
}

