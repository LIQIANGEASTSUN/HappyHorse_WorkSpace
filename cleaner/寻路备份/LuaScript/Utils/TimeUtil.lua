---@class TimeUtil
TimeUtil = {
    _19H_To_Sec = 19 * 60 * 60, -- 19个小时的秒数 跨天判断用
    _24H_To_Sec = 24 * 60 * 60, -- 24个小时的秒数 跨天判断用
    HOUR = 60 * 60,
    MIN = 60
}

function TimeUtil.ServerRefreshTime(ts)
    RuntimeContext.SERVER_TIME_DIFF = math.floor(ts / 1000) - os.time()
    RuntimeContext.CURRENT_DATATIME = TimeUtil.GetDayStartTs(math.floor(ts / 1000) - TimeUtil._19H_To_Sec)
    console.lj("时间同步，目前差值："..RuntimeContext.SERVER_TIME_DIFF)
end

function TimeUtil.ServerTime()
    return os.time() + RuntimeContext.SERVER_TIME_DIFF
end

function TimeUtil.ServerTimeMilliseconds()
    return TimeUtil.ServerTime() * 1000
end

function TimeUtil.LocalTime()
    return os.time()
end

function TimeUtil.GetServerTimeDate()
    return os.date("*t", TimeUtil.ServerTime())
end

function TimeUtil.GetServerTimeDateWithOffset()
    return os.date("*t", TimeUtil.ServerTime() - TimeUtil._19H_To_Sec)
end

---2010.01.02 00：00：00
function TimeUtil.GetTimeString(ts)
    ts = ts or TimeUtil.ServerTime()
    local str = os.date("%Y.%m.%d %H:%M:%S", math.floor(ts))
    return str
end

function TimeUtil.SecToMin(seconds)
    return string.format("%02s", math.floor(seconds / 60))
end

---convert seconds to hour
---exp: 1800  =>  0.5
---      900  =>  0.25
---     3600  =>  1
---     5400  =>  1.5
---@return int,float if fraction of return value is zero then return interger. otherwise return foat
function TimeUtil.SecondsToHour(seconds)
    local hour, frac = math.modf(seconds / 3600, 60)
    if frac > 0 then
        hour = hour + frac
    else
        hour = math.floor(hour)
    end
    return hour
end

---时间戳转换为 00：00：00的格式
function TimeUtil.SecToHMS(seconds)
    if seconds then
        seconds = math.max(0, seconds)
        local hours = math.floor(seconds / 3600)
        local mins = math.floor(seconds % 3600 / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02s:%02s:%02s", hours, mins, secs)
    end
end

---秒转换为 00：00的格式
function TimeUtil.SecToMS(seconds)
    if seconds then
        seconds = math.max(0, seconds)
        local hours = math.floor(seconds / 3600)
        local mins = math.floor(seconds % 3600 / 60)
        local secs = math.floor(seconds % 60)
        if hours > 0 then
            return string.format("%02s:%02s:%02s", hours, mins, secs)
        else
            return string.format("%02s:%02s", mins, secs)
        end
    end
end

---秒转换为小时或分钟
function TimeUtil.SecToTimeString(seconds)
    if seconds then
        seconds = math.max(0, seconds)
        local hours = math.floor(seconds / 3600)
        local mins = math.floor(seconds % 3600 / 60)
        -- local secs = math.floor(seconds % 60)
        if hours > 0 then
            return Runtime.Translate("ui_commission_time1", {time = tostring(hours)})
        elseif mins > 0 then
            return Runtime.Translate("ui_commission_time2", {time = tostring(mins)})
        end
    end
end

---如果大于48小时，返回天数，
---否则返回00：00：00
function TimeUtil.SecToOver48H(seconds)
    if seconds then
        seconds = math.max(0, seconds)
        if seconds > 48 * 60 * 60 then
            local oneDayTime = TimeUtil._24H_To_Sec
            local days = math.floor(seconds / oneDayTime)
            local other = seconds % oneDayTime
            if other > 0 then
                days = days + 1
            end
            --return tostring(days)..Runtime.Translate("piggybank_icon_days")
            return days, true
        end
        return TimeUtil.SecToHMS(seconds), false
    end
end

---如果大于48小时，返回天数具体到小时
---否则返回00：00：00
function TimeUtil.SecToDayHour(seconds, hourThreshold)
    hourThreshold = hourThreshold or 48
    if seconds then
        seconds = math.max(0, seconds)
        if seconds > hourThreshold * 60 * 60 then
            local days = math.floor(seconds / TimeUtil._24H_To_Sec)
            local other = seconds % TimeUtil._24H_To_Sec
            if other > 0 then
                local hours = math.floor(TimeUtil.SecondsToHour(other))
                return true, days, hours
            end
            return true, days, 0
        end
        return false, TimeUtil.SecToHMS(seconds)
    end
end

function TimeUtil.SecToDayHourStr(seconds, hourThreshold)
    local ret, time1, time2 = TimeUtil.SecToDayHour(seconds, hourThreshold)

    local str
    if ret then
        str = Runtime.Translate("ui_goldpass_activitytime", {day = tostring(time1), hour = tostring(time2)})
    else
        str = Runtime.formatStringColor(time1, "f14333")
    end
    return str
end

--刷新剩余天数显示，没有0天，最后一天显示1天
function TimeUtil.SecToDays(seconds)
    return math.floor(seconds // TimeUtil._24H_To_Sec) + 1
end

function TimeUtil.SecTo72Hour(seconds)
    if seconds then
        if seconds >= TimeUtil._24H_To_Sec * 3 then
            local day = math.floor(seconds / TimeUtil._24H_To_Sec)
            return Runtime.Translate("UI_common_day", {time = tostring(day)})
        elseif seconds >= TimeUtil._24H_To_Sec then
            local day = math.floor(seconds / TimeUtil._24H_To_Sec)
            local other = seconds % TimeUtil._24H_To_Sec
            local hour = math.floor(TimeUtil.SecondsToHour(other))
            return Runtime.Translate("UI_common_day_hour", {time = tostring(day), time1 = tostring(hour)})
        else
            return TimeUtil.SecToHMS(seconds)
        end
    end
end

---返回给定时间戳所在天的零点零分的时间戳
function TimeUtil.GetDayStartTs(ts)
    if ts < 0 then
        return 0
    end
    return LuaHelper.GetBeijingDayStartTsFromUnixTimeSeconds(ts)
end

---返回今天00:00:00相加时间，hour小时min分钟sec秒后的时间戳
function TimeUtil.GetTsByDayTime(hour, min, sec)
    console.assert(hour)
    if min == nil then
        min = 0
    end
    if sec == nil then
        sec = 0
    end
    local startTs = TimeUtil.GetDayStartTs(TimeUtil.ServerTime())
    local ret = startTs + hour * 3600 + min * 60 + sec
    return ret
end

--给定时间判定与当前是否是同一天
function TimeUtil.InSameRefreshDay(ts)
    if ts <= 0 then
        return false
    end
    local time = ts - TimeUtil.ServerTime()
    --与当前时间相差24小时，必然不在同一天
    if time < -TimeUtil._24H_To_Sec or time > TimeUtil._24H_To_Sec then
        return false
    end
    --都没超过7点
    local ts_19_clock = TimeUtil.GetDayStartTs(ts) + TimeUtil._19H_To_Sec
    if ts < ts_19_clock and TimeUtil.ServerTime() < ts_19_clock then
        return true
    end
    --都超过了7点
    if ts >= ts_19_clock and TimeUtil.ServerTime() >= ts_19_clock then
        return true
    end

    return false
end
--判断给定时间是否已跨天
function TimeUtil.CompareWithDateStart(ts)
    return ts > RuntimeContext.CURRENT_DATATIME + TimeUtil._19H_To_Sec
end

---2020-4-23 08:00:00 转换为 时间戳(配置转lua时已转换为时间戳可以不再使用了)
function TimeUtil.DateToTime(dataStr)
    local arrayDataStr = string.split(dataStr, " ")
    local ymd = string.split(arrayDataStr[1], "-") --年月日
    local hms = string.split(arrayDataStr[2], ":") --时分秒
    local time =
        os.time(
        {
            year = tonumber(ymd[1]),
            month = tonumber(ymd[2]),
            day = tonumber(ymd[3]),
            hour = tonumber(hms[1]),
            min = tonumber(hms[2]),
            sec = tonumber(hms[3])
        }
    )
    return time
end
---2020-4-23 08:00:00 转换为 服务器时区时间戳(配置转lua时已转换为时间戳可以不再使用了)
function TimeUtil.DateToServerTime(dataStr)
    local localZone = -math.round((os.time({year=1970, month=1, day=1, hour=12, min=0, sec = 0}) - 12 * 3600) / 3600)   --本地时区  +1东1区 -1西1区 +8东八区,服务时间。
    local arrayDataStr = string.split(dataStr, " ")
    local ymd = string.split(arrayDataStr[1], "-") --年月日
    local hms = string.split(arrayDataStr[2], ":") --时分秒
    local time =
        os.time(
        {
            year = tonumber(ymd[1]),
            month = tonumber(ymd[2]),
            day = tonumber(ymd[3]),
            hour = tonumber(hms[1]),
            min = tonumber(hms[2]),
            sec = tonumber(hms[3])
        }
    )
    return time + (localZone - 8) * 3600    --服务器时区，东8区
end
---今天凌晨0点
function TimeUtil.Get0ClockOfToday()
    return TimeUtil.GetDayStartTs(TimeUtil.ServerTime())
end
---今天晚上 24点
function TimeUtil.Get24ClockOfToday()
    return TimeUtil.Get0ClockOfToday() + TimeUtil._24H_To_Sec
end

---显示跨天刷新时间(北京时间1970-01-02 19:00:00转换成当地时间)
---@return date returns a string
function TimeUtil.GetRefreshDateTime()
    local ts = 126000
    --TimeUtil.timeOffset + TimeUtil.GetDayStartTs(TimeUtil.ServerTime())
    local date = os.date("*t", ts)
    return string.format("%s:%02s", date.hour, date.min)
end

--显示距离跨天的时间
function TimeUtil.GetRefreshDateRemainTime(refreshHour)
    refreshHour = refreshHour or 19
    local refreshTime = TimeUtil.GetTsByDayTime(refreshHour)

    local ts = refreshTime - TimeUtil.ServerTime()
    if TimeUtil.ServerTime() > refreshTime then
        ts = ts + TimeUtil._24H_To_Sec
    end

    return ts
end

function TimeUtil.GetTimeDescription(sec)
    if sec <= 3600 then --不足1小时显示:刚刚
        return Runtime.Translate("UI_buildingcapture_stolentime1")
    elseif sec < TimeUtil._24H_To_Sec then --不足一天显示: n小时前
        local hours = math.floor(sec // 3600)
        return Runtime.Translate("UI_buildingcapture_stolentime2", {h = tostring(hours)})
    else --超过一天显示:n天前
        local days = math.floor(sec // TimeUtil._24H_To_Sec)
        return Runtime.Translate("UI_buildingcapture_stolentime3", {d = tostring(days)})
    end
end

-- 获取本地时间的时区, 注意是手机/PC时间!!
function TimeUtil.GetLocalTimeZone()
    local now = os.time()
    local localTimeZone = os.difftime(now, os.time(os.date("!*t", now)))
    return localTimeZone / 3600
end

local _localTimeZone = nil
local _isdst = nil
---设置当前时区, 由服务器发给客户端, 登录后设置, 新账号创建的时候, 会根据系统时间计算当前时区
function TimeUtil.SetTimeZone(timeZone)
    _localTimeZone = timeZone
    TimeUtil.SetDayLight(TimeUtil.GetNewDayLight())
end

---是否开启了夏令时
function TimeUtil.IsDayLight()
    return _isdst
end

function TimeUtil.GetNewDayLight()
    local tzTime = TimeUtil.GetTimeZoneTime()
    local date = os.date("*t", tzTime)
    return date.isdst
end

function TimeUtil.SetDayLight(dayLight)
    _isdst = dayLight
end
---获取当前时区
function TimeUtil.GetTimeZone()
    return _localTimeZone
end

function TimeUtil.GetTimeZoneTime()
    if not _localTimeZone then
        return nil
    end
    -- local date0 = os.date("!*t", math.floor(TimeUtil.ServerTime()))
    -- local timeSec = os.time(date0) - (date0.isdst and 3 * 3600 or 2 * 3600)
    -- timeSec = timeSec + _localTimeZone * 60 * 60
    -- return timeSec
    return TimeUtil.ServerTime()
end

--当前时区0点
function TimeUtil.GetTimeZoneDay0Time()
    local t = TimeUtil.GetTimeZoneTime()
    if not t then
        return
    end
    local date0 = os.date("*t", t)
    date0.hour, date0.min, date0.sec = 0, 0, 0
    local ts = os.time(date0)
    return ts
end

function TimeUtil.GetTimeZoneLeftTime()
    local serverTime = TimeUtil.ServerTime()
    local time1 = serverTime + _localTimeZone * 3600
    local time2 = time1 % TimeUtil._24H_To_Sec
    return TimeUtil._24H_To_Sec - time2
end

function TimeUtil.GetTimeZoneNextDayTime()
    return TimeUtil.ServerTime() + TimeUtil.GetTimeZoneLeftTime()
end

function TimeUtil.Cd(e, k, t) --自定义cd中
    local now = os.clock()
    if not e.___cooldown then
        e.___cooldown = {}
    end
    if e.___cooldown[k] and now - e.___cooldown[k] < t then
        return true, t - now + e.___cooldown[k]
    end
    e.___cooldown[k] = now
end
