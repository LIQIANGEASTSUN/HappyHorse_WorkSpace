using System;
using System.Collections.Generic;
using ClientMessage;
using Cookgame.Module;
using ProtoBuf;

namespace Cookgame.Entity
{
    public class PersonCarPart : IEntityPart
    {
        private IPerson __master = null;
        private List<Int64> _carList = new List<Int64>();

        //XX

        private uint __nGridID = 0;
        private uint __nGridName = 0;
        private GridClientModule _gridClientModule;
        public PersonCarPart()
        {
            _gridClientModule = GameUtility.GetModule<GridClientModule>(DataModuleEnum.GridClient);
        }
        public uint GetPartID()
        {
            return (uint)Enum_PersonPart_Type.EN_PERSON_PART_CAR;
        }
        public IPerson GetMaster()
        {
            return __master;
        }
        public bool Create(IPerson master)
        {
            __master = master;
            return true;
        }

        public bool UpdateProp(byte[] entityPartData)
        {
            MsgCar_CarEntityList_Res res = entityPartData.ToMessageData<MsgCar_CarEntityList_Res>();
            if (res == null)
            {
                return false;
            }
            _carList.Clear();


            for (int i = 0; i < res.carEntityuid.Count; i++)
            {
                _carList.Add(res.carEntityuid[i]);
            }
            return true;
        }

        public bool UpdateProp(IExtensible msgData)
        {
            return true;
        }


        public int GetTotalRefitPerformance()
        {
            if (_carList.Count == 0)
            {
                GameLog.LogError("当前玩家拥有的车辆数为0");
                return 0;
            }
            int nRefitSum = 0;
            for (int i = 0; i < _carList.Count; i++)
            {
                //CarProp carProp =  GarageSystem.GetCarProp(_carList[i]);
                //if(carProp== null)
                //{
                //    continue;
                //}
                //nRefitSum = nRefitSum + (int)(carProp.carDataRefit[(int)Enum_Car_Data_Performance.ePerformance]);
            }
            return nRefitSum;
        }


        //设置格子ID
        public void SetGridID(uint nGridID)
        {
            VirtualGrid grid = _gridClientModule.GetVirtualGrid(nGridID);
            if (grid == null)
            {
                return;
            }
            __nGridName = grid.GetGridName();
            __nGridID = nGridID;
        }

        //取得格子对象
        public VirtualGrid GetVirtualGrid()
        {
            return _gridClientModule.GetVirtualGrid(__nGridID);
        }
    }
}