local ErrorCodeNames = {

    [ErrorCodeEnums.NOT_PROCESSED]  = "未处理",

    [ErrorCodeEnums.TIMEOUT]        = '超时',

    [ErrorCodeEnums.NOT_SENT]       = "未发送", -- 前端错误码，意思是由于前面的请求出错，所以该请求没有发送

    -- 正常状态
    [ErrorCodeEnums.SUCCESS]        = '成功',

    -- 被顶号
    [ErrorCodeEnums.REPEATEDLOGIN]  = '重复登录',

    -- 消息不可为空
    [ErrorCodeEnums.MSGISNULL]      = '消息为空',

    -- 玩家为空
    [ErrorCodeEnums.NULLPLAYER]     = '玩家为空',

    -- 错误
    [ErrorCodeEnums.TIME_ERROR]          = '玩家时间错误',

    -- session过期，需要重新登录
    [ErrorCodeEnums.SESSION_EXPIRED]     = 'Session过期',

    -- sequenceId重发，离线缓存被重发
    [ErrorCodeEnums.SEQUENCE_ID_USED]    = '请求重发',

    -- 道具不充足
    [ErrorCodeEnums.ITEM_NOTENOUGH] = '道具不充足',

    -- 限时道具失效
    [ErrorCodeEnums.ITEM_TIMEOUT]   = '限时道具失效',

    --兑换道具钻石不足
    [ErrorCodeEnums.ITEM_EXCHANGE_DIAMONDSENOUGH] = '兑换道具钻石不足',

    -- 充值订单校验失败，需要重发
    [ErrorCodeEnums.RECHARGE_FAIL] = '充值订单校验失败，需要重发',

    -- 不需要清空cd时间
    [ErrorCodeEnums.BOX_NOT_CLAERTIME]                  = '不需要清空cd时间',

    -- 清空cd时间钻石不足
    [ErrorCodeEnums.BOX_NOT_CLEARTIMEDIAMONDSENOUGH]    = '清空cd时间钻石不足',

    -- 清空cd时间客户端与服务器端的钻石数量不匹配
    [ErrorCodeEnums.BOX_NOT_DIAMONDSMISMATCH]           = '清空cd时间客户端与服务器端的钻石数量不匹配',

    -- 打开宝箱物资不足
    [ErrorCodeEnums.BOX_NOT_MATERIALENOUGH]             = '打开宝箱物资不足',

    -- 打开宝箱cd时间未到
    [ErrorCodeEnums.BOX_NOT_CDARRIVING]                 = '打开宝箱cd时间未到',

    -- 对应累计奖励的索引处没有奖励
    [ErrorCodeEnums.BOX_NOT_TOTALREWARD]                = '对应累计奖励的索引处没有奖励',

    -- 精力不足
    [ErrorCodeEnums.LEVELS_NOT_ENERGYVALUEENOUGH]       = '精力不足',
    -- 通关结果不一致
    [ErrorCodeEnums.LEVELS_NOT_FINISHLEVEL]             = '通关结果不一致',

    -- 奖励已经领取过
    [ErrorCodeEnums.DAYREWARD_NOT_REPEATEDGETREWARD]    = '奖励已经领取过',

    -- 订单校验失败（由于），需要清除数据
    [ErrorCodeEnums.RECHARGE_VERIFY_ERROR] = '订单校验失败（由于），需要清除数据',

    --************************************通用模块*************************************/
    -- 功能尚未开启
    [ErrorCodeEnums.COMMON_SYSTEM_NOT_OPEN] = '功能尚未开启',
    -- 配置不存在
    [ErrorCodeEnums.COMMON_CONFIG_NOT_EXIST] = '配置不存在',
    -- 玩家名字不能为空
    [ErrorCodeEnums.COMMON_PLAYER_NAME_CAN_NOT_NULL] = '玩家名字不能为空',
    -- 玩家名字太长
    [ErrorCodeEnums.COMMON_PLAYER_NAME_TOO_LONG] = '玩家名字太长',
    -- 玩家头像不能为空
    [ErrorCodeEnums.COMMON_PLAYER_ICON_CAN_NOT_NULL] = '玩家头像不能为空',
    -- 玩家头像类型错误
    [ErrorCodeEnums.COMMON_PLAYER_ICON_ERROR] = '玩家头像类型错误',
    -- 功能重复开启
    [ErrorCodeEnums.COMMON_SYSTEM_REPEAT_OPEN] = '功能重复开启',
}


return ErrorCodeNames