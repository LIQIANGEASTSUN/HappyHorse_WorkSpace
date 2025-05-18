using System;
using System.Collections.Generic;
using ClientMessage;
using Cookgame.Module;
using ProtoBuf;

namespace Cookgame.Entity
{
    //仓库部件接口
    public interface IPersonWarehousePart : IEntityPart
    {
        //设置格子ID
        void SetGridID(uint nGridID);
        //取得格子对象
        VirtualGrid GetVirtualGrid(uint nGridName);
        //取得格子对象
        VirtualGrid GetVirtualGrid();
    }

    class PersonWarehousePart : IPersonWarehousePart
    {
        /// <summary>
        /// 拥有的物品ID
        /// </summary>
        public List<Int64> uids;


        private IPerson __master = null;

        private uint __nGridID = 0;
        private uint __nGridName = 0;
        private GridClientModule _gridClientModule;

        public PersonWarehousePart()
        {
            _gridClientModule = GameUtility.GetModule<GridClientModule>(DataModuleEnum.GridClient);
        }
        public uint GetPartID()
        {
            return (uint)Enum_PersonPart_Type.EN_PERSON_PART_PACKAGE;
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
        public bool UpdateProp(byte[] EntityPartData)
        {
            return true;
        }

        public bool UpdateProp(IExtensible msgData)
        {
            return true;
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
        public VirtualGrid GetVirtualGrid(uint nGridName)
        {
            if (__nGridName != nGridName)
            {
                return null;
            }
            return _gridClientModule.GetVirtualGrid(__nGridID);
        }


        //取得格子对象
        public VirtualGrid GetVirtualGrid()
        {
            return _gridClientModule.GetVirtualGrid(__nGridID);
        }

    }
}