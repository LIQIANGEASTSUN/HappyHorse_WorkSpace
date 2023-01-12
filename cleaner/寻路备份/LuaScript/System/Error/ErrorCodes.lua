ErrorCodeEnums = {

    NOT_PROCESSED  = 1,

    TIMEOUT        = 2,

    NOT_SENT       = 3, -- 前端错误码，意思是由于前面的请求出错，所以该请求没有发送

    -- 正常状态
    SUCCESS        = 0,

    -- 被顶号
    REPEATEDLOGIN  = 1002,

    -- 消息不可为空
    MSGISNULL      = 1003,

    -- 玩家为空
    NULLPLAYER     = 1004,

    -- 错误
    TIME_ERROR          = 1005,

    -- session过期，需要重新登录
    SESSION_EXPIRED     = 1006,

    -- sequenceId重发，离线缓存被重发
    SEQUENCE_ID_USED    = 1007,

    SERVER_ERROR = 1008,

    VERSION_ERROR = 1009,

    BIND_ERROR = 1011,

    -- 道具不充足
    ITEM_NOTENOUGH = 2001,

    -- 限时道具失效
    ITEM_TIMEOUT   = 2002,

    --兑换道具钻石不足
    ITEM_EXCHANGE_DIAMONDSENOUGH = 2005,

    -- 充值订单校验失败，需要重发
    RECHARGE_FAIL = 2007,

    -- 不需要清空cd时间
    BOX_NOT_CLAERTIME                  = 7001,

    -- 清空cd时间钻石不足
    BOX_NOT_CLEARTIMEDIAMONDSENOUGH    = 7002,

    -- 清空cd时间客户端与服务器端的钻石数量不匹配
    BOX_NOT_DIAMONDSMISMATCH           = 7003,

    -- 打开宝箱物资不足
    BOX_NOT_MATERIALENOUGH             = 7004,

    -- 打开宝箱cd时间未到
    BOX_NOT_CDARRIVING                 = 7005,

    -- 对应累计奖励的索引处没有奖励
    BOX_NOT_TOTALREWARD                = 7006,

    -- 精力不足
    LEVELS_NOT_ENERGYVALUEENOUGH       = 8001,
    -- 通关结果不一致
    LEVELS_NOT_FINISHLEVEL             = 8002,
    --客户端打关时间异常
	LEVELS_TIME_ERROR                  = 8006,

    -- 奖励已经领取过
    DAYREWARD_NOT_REPEATEDGETREWARD    = 9001,

    RECHARGE_DUPLICATE    = 12001,
    -- 订单校验失败（由于），需要清除数据
    RECHARGE_VERIFY_ERROR = 12005,

    -- 魔法生物数据异常
	MAGICALCREATURE_DATA_ERROR = 25001,
	-- 道具不足
	MAGICALCREATURE_ITEMENOUGH = 25002,

    -- 订单数据异常
	ORDERTASK_DATA_ERROR = 25201,
	-- 位置已有订单任务
	ORDERTASK_POSITION_HAVATASK = 25202,
	-- 删除订单CD中
	ORDERTASK_CD_ERROR = 25203,
	-- 应该生成困难订单
	ORDERTASK_DIFFICULTY_ORDER = 25204,
	-- 完成订单需求物品不足
	ORDERTASK_FINISH_ITEM_NOT_ENOUGH = 25205,
	-- 海航订单数据错误
	TIMEORDERTASK_DATA_ERROR = 25206,

--************************************通用模块*************************************/
    -- 功能尚未开启
    COMMON_SYSTEM_NOT_OPEN = 13001,
    -- 配置不存在
    COMMON_CONFIG_NOT_EXIST = 13002,
    -- 玩家名字不能为空
    COMMON_PLAYER_NAME_CAN_NOT_NULL = 13003,
    -- 玩家名字太长
    COMMON_PLAYER_NAME_TOO_LONG = 13004,
    -- 玩家头像不能为空
    COMMON_PLAYER_ICON_CAN_NOT_NULL = 13005,
    -- 玩家头像类型错误
    COMMON_PLAYER_ICON_ERROR = 13006,
    -- 功能重复开启
    COMMON_SYSTEM_REPEAT_OPEN = 13009,

    STEAL_TARGET_STOLEN_LIMIT = 24001,

    -- 不可升级
	BUIDING_TO_MAX_LEVEL = 3001,

	-- 升级材料不足
	BUILDING_ITEM_NOT_ENOUGH = 3002,

	-- 障碍物不存在
	BUILDING_NOT_EXIST = 3003,

	-- 建筑不能清除
	BUILDING_CAN_NOT_CLEAN = 3004,

	-- 建筑未到最大等级不能清除
	BUILDING_CAN_NOT_CLEAN_ON_LEVEL = 3005,

    ---没有找到对应的任务模板id
	TASK_NOT_FIND_TASK = 10001,
	---任务没有完成
	TASK_NOT_FINISH = 10002,
	---任务图已经关闭
	TASK_GRAPH_CLOSED = 10003,
	---任务已经提交
	TASK_ALREADY_SUBMIT= 10004,
    ---支付重复订单（已发货）
    RECHARGE_REPEATE_ORDER = 12001,
}

--[[
function IsTimeOutCode(errorCode)
    return errorCode == ErrorCodeEnums.TIMEOUT or errorCode == ErrorCodeEnums.SERVER_ERROR or (errorCode >= 100 and errorCode <= 600)
end

function IsOfflineError(errorCode)
    return errorCode == ErrorCodeEnums.TIME_ERROR or errorCode > 2000
end
]]
---需要重启的error
RestartError = {
    ErrorCodeEnums.TIME_ERROR,
    ErrorCodeEnums.SEQUENCE_ID_USED,
    ErrorCodeEnums.BIND_ERROR,
    18005,
    18004,
}

function IsRestartError(errorCode)
    return table.indexOf(RestartError,errorCode)
end

function IsRetryError(errorCode)
    return errorCode == ErrorCodeEnums.TIMEOUT or (errorCode >= 100 and errorCode <= 600)
end