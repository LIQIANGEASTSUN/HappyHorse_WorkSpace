using System;
using System.Collections.Generic;
using UnityEngine;
using ClientMessage;
using ProtoBuf;

namespace Cookgame.Entity
{
    

    //实体对象基类
    public static class EntityUtility
    {
        //转换EntityData数据
        public static bool BuildData(ref PropItemInfo propItemInfo, Enum_EntityType entityClass, byte[] entityData)
        {
            if (entityClass == Enum_EntityType.EN_ENTITY_TYPE_GROCERIES)
            {
                GroceriesInfo propGoods = entityData.ToMessageData<GroceriesInfo>();

                propItemInfo = PropGroceriesInfo2PropItemInfo(propGoods);

                Debug.Log("entityClass:" + entityClass + ", propItemInfo.id:" + propItemInfo.nGoodsID + ",propGoods:" + propGoods.uidGoods);
            }
            else if (entityClass == Enum_EntityType.EN_ENTITY_TYPE_EQUIPMENT)
            {
                ComponentInfo propComponent = entityData.ToMessageData<ComponentInfo>();
                propItemInfo = PropComponentInfo2PropItemInfo(propComponent);
                Debug.Log("entityClass:" + entityClass + ", propItemInfo.id:" + propItemInfo.nGoodsID + ",propComponent:" + propComponent.uidComponent);
            }
            else
            {
                Debug.LogError("未知实体类型的创建处理,请联系程序员! entityClass=" + (int)entityClass);
                return false;
            }

            //残留旧的
            //GameManager.Instance.GetPropStorageModule().AddPropItem(propItemInfo, true);
            return true;
        }

        private static PropItemInfo PropGroceriesInfo2PropItemInfo(GroceriesInfo itemPropDic)
        {

            PropItemInfo itemInfo = new PropItemInfo
            {
                nGoodsID = itemPropDic.nGoodsID,
                uidGoods = itemPropDic.uidGoods,
                nGoodsNum = itemPropDic.nGoodsNum,
                exp = 0,
                lv = 0,
                expiryType = (EGoods_Expirytype)itemPropDic.nexpirytype,
                expiryTime = (uint)itemPropDic.nexpirytime,
                endTime = 0
            };

            propItemData propItemData;
            if (ExcelData.Instance.propItemDataDic.TryGetValue((int)itemInfo.nGoodsID, out propItemData))
            {
                itemInfo.itemData = propItemData;
            }
            else
            {
                Debug.LogError("PropItemMsg2PropItemInfo can't find prop item id,id=" + itemInfo.nGoodsID);
            }

            ////处理材料经验
            //if (CS_TableUtil.IsMatril(itemInfo.itemData.LargeClass, itemInfo.itemData.subClass))
            //{
            //    refitPropUpgradeMatData data;
            //    if (ExcelData.Instance.refitPropUpgradeMatDataDic.TryGetValue(itemInfo.itemData.quality, out data))
            //    {
            //        itemInfo.exp = (uint) data.exp;
            //    }
            //}

            //UpdatePropItemTime(itemInfo);
            //UpdateHrefInfo(itemInfo);
            return itemInfo;
        }

        public static PropItemInfo PropComponentInfo2PropItemInfo(ComponentInfo itemPropDic)
        {
            PropItemInfo itemInfo = new PropItemInfo
            {
                uidGoods = itemPropDic.uidComponent,
                nGoodsID = itemPropDic.nComponentID,
                nGoodsNum = itemPropDic.nComponentNum,
                exp = itemPropDic.nExp,
                lv = itemPropDic.nLevel,
                //nTag = itemPropDic.nTag
            };

            //本地数据赋值
            carRefitPropData carData;
            if (ExcelData.Instance.carRefitPropDataDic.TryGetValue((int)itemInfo.nGoodsID, out carData))
            {
                //车辆零件的结构转换成物品结构
                if (itemInfo.itemData == null)
                {
                    //itemInfo.itemData =  PropItemDataAdapter( carData);
                    itemInfo.refitData = carData;
                }
            }
            else
            {
                Debug.LogError("PropItemMsg2PropItemInfo can't find prop item id,id=" + itemInfo.nGoodsID);
            }


            //未实现零件的过期时间
            itemInfo.expiryType = EGoods_Expirytype.EN_GOODS_EXPIRYTYPE_FOREVERTIME;
            itemInfo.expiryTime = 0;
            itemInfo.expiryFreshTime = 0;

            //carRefitPropData carRefitPropData;
            //if (ExcelData.Instance.carRefitPropDataDic.TryGetValue((int) itemInfo.id, out carRefitPropData))
            //{
            //    //refitData数据会被外部修改，生成新拷贝
            //    itemInfo.refitData    = new carRefitPropData();
            //    itemInfo.refitData.id = (int) itemInfo.id;
            //    CarRefitModule.CopyValue(carRefitPropData, itemInfo.refitData);
            //}
            //else
            //{
            //    Debug.LogError("PropItemMsg2PropItemInfo can't find refit item id,id=" + itemInfo.id);
            //}

            //UpdatePropItemTime(itemInfo);
            //UpdateHrefInfo(itemInfo);

            return itemInfo;
        }
        private static propItemData PropItemDataAdapter(carRefitPropData carData)
        {
            propItemData itemData = new propItemData
            {
                
            };
            return itemData;
        }
        private static void UpdatePropItemTime(PropItemInfo itemInfo)
        {
            if (itemInfo.expiryTime > 0)
            {
                uint utcTime = (uint)TimeManager.ConvertUtcDateTimeSecond(DateTime.UtcNow);
                switch (itemInfo.expiryType)
                {
                    case EGoods_Expirytype.EN_GOODS_EXPIRYTYPE_NORMALTIME:
                    case EGoods_Expirytype.EN_GOODS_EXPIRYTYPE_FIXEDTIME:
                        {
                            //expiryTime服务器下发的是到期时间
                            itemInfo.endTime = itemInfo.expiryTime > utcTime ? itemInfo.expiryTime : 0;
                        }
                        break;
                    case EGoods_Expirytype.EN_GOODS_EXPIRYTYPE_ONLINETIME:
                        {
                            //expiryTime服务器下发的是剩余时间
                            itemInfo.endTime = (uint)utcTime + itemInfo.expiryTime;
                        }
                        break;
                    default:
                        {
#if UNITY_EDITOR
                            Debug.LogWarning("不支持当前物品到期类型，type=" + itemInfo.expiryType);
#endif
                            itemInfo.expiryType = EGoods_Expirytype.EN_GOODS_EXPIRYTYPE_FOREVERTIME;
                            itemInfo.endTime = 0;
                        }
                        break;
                }
                //if (itemInfo.endTime > utcTime)
                //{
                //    itemInfo.leftTime = itemInfo.endTime - utcTime;
                //}
            }
            else
            {
                itemInfo.expiryType = EGoods_Expirytype.EN_GOODS_EXPIRYTYPE_FOREVERTIME;
                itemInfo.endTime = 0;
                //itemInfo.leftTime = 0;
            }
        }

        private static void UpdateHrefInfo(PropItemInfo itemInfo)
        {
            if (itemInfo == null || itemInfo.itemData == null)
            {
                return;
            }
            if (itemInfo.itemData.hrefType == "-1" || string.IsNullOrEmpty(itemInfo.itemData.hrefType))
            {
                itemInfo.hrefInfo = null;
                return;
            }
            List<PropHrefInfo> hrefInfo;
            string[] fncNames = itemInfo.itemData.hrefType.Split(';');
            hrefInfo = new List<PropHrefInfo>();
            for (int i = 0; i < fncNames.Length; i++)
            {
                hrefInfo.Add(new PropHrefInfo() { fncName = fncNames[i] });
            }
            itemInfo.hrefInfo = hrefInfo;
        }
    }
}