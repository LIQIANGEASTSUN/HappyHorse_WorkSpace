using System;
using System.Collections;
using System.Collections.Generic;
using ClientMessage;
using UnityEngine;

public class PropItemInfo 
{
    /// <summary>
    /// 物品UID
    /// </summary>
    public Int64 uidGoods;
    /// <summary>
    /// 配置表固定ID
    /// </summary>
    public uint nGoodsID;

    public uint nGoodsNum;
    public uint createTime;

    public uint lv = 0;
    public uint exp;
    public uint isLocked;
    //零件是否被查看过
    public uint bChecked = 0;

    //零件升级材料信息
    public carRefitPropData refitData;
    public EGoods_Expirytype expiryType;
    public uint expiryTime; //服务器下发的各种到期时间
    public uint expiryFreshTime; //服务器刷新时间
    public uint endTime; //UTC到期时间

    public uint leftTime; //剩余时间，方便显示
    public propItemData itemData;
    public List<PropHrefInfo> hrefInfo;

    public void OnUpdateAttr(Propdata propdata)
    {
        switch ((EGoods_Property)propdata.propid)
        {
            case EGoods_Property.GOODS_PROP_UNKNOWN:
                break;
            case EGoods_Property.GOODS_PROP_GOODSID:
                nGoodsID = propdata.propvalue.uint_value;
                break;
            case EGoods_Property.GOODS_PROP_PILE_NUM:
                nGoodsNum = propdata.propvalue.uint_value;
                break;
            case EGoods_Property.GOODS_PROP_BINDFLAG:
                break;
            case EGoods_Property.GOODS_PROP_EXPIRYTYPE:
                break;
            case EGoods_Property.GOODS_PROP_EXPIRYTIME:
                break;
            case EGoods_Property.GOODS_PROP_EXPIRYFLUSHTIME:
                expiryTime= propdata.propvalue.uint_value;
                break;
            case EGoods_Property.GOODS_PROP_CREATETIME:
                createTime  = propdata.propvalue.uint_value;
                break;
            case EGoods_Property.GOODS_PROP_TAGFLAG:
                break;
            case EGoods_Property.GOODS_PROP_GRADE_LEVEL:
                lv = propdata.propvalue.uint_value;
                break;
            case EGoods_Property.GOODS_PROP_GRADE_LEVELEXP:
                exp = propdata.propvalue.uint_value;
                break;
            case EGoods_Property.GOODS_PROP_SCORE:
                break;
            case EGoods_Property.GOODS_PROP_BROADCAST_ID:
                break;
            case EGoods_Property.GOODS_PROP_MAXID:
                break;
            case EGoods_Property.GOODS_PROP_EXTENDBUFF:
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }
    }
}
public class PropHrefInfo
{
    public string fncName;
    //在此添加图片等跳转信息
}