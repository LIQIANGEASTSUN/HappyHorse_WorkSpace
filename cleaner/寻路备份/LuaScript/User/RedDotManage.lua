---tip:add by long
-- 红点管理器
---@class RedDotManage
local RedDotManage = {}

function RedDotManage:Init()
    local function switchToMap(config, parent)
        for key, value in pairs(config) do
            self.RedMap[key] = {parent = parent, count = 0, name = key}
            if not table.isEmpty(value) then
                switchToMap(value, key)
            end
        end
    end
    self.RedMap = {}
    switchToMap(CONST.REDDOT.redConfig, nil)
end

function RedDotManage:RegisterNew(key, parent, value)
    if not self.RedMap then
        self.RedMap = {}
    end
    self.RedMap[key] = {parent = parent, count = value, name = key}
end

--直接设置数量，用于第一次计算红点数量
function RedDotManage:SetDate_Count(name, count)
    local function RefreshParentCount(redDotInfo, addCount)
        local result = math.max(0, redDotInfo.count + addCount)
        redDotInfo.count = result

        if redDotInfo.parent then
            local parentInfo = self.RedMap[redDotInfo.parent]
            RefreshParentCount(parentInfo, addCount)
        end
    end

    if not self.RedMap[name] then
        return
    end

    local redDotInfo = self.RedMap[name]
    if redDotInfo.count ~= count then
        --触发数量变化逻辑
        RefreshParentCount(redDotInfo, count - redDotInfo.count)
    end
end

--增加与删减的红点数记录，触发回调逻辑
function RedDotManage:FreshDate_Count(name, _addCount)
    if not self.RedMap[name] then
        return
    end

    local function RefreshParentCount(redDotInfo, addCount)
        local result = math.max(0, redDotInfo.count + addCount)

        --需要判断是否触发红点或隐藏红点
        local isTrigger = (redDotInfo.count ~= 0 and result == 0) or (redDotInfo.count == 0 and result > 0)
        redDotInfo.count = result

        --发送红点变化事件
        local eventMap = CONST.REDDOT.eventMap
        if isTrigger and eventMap[redDotInfo.name] then
            sendNotification(eventMap[redDotInfo.name], redDotInfo.name)
        end

        if redDotInfo.parent then
            local parentInfo = self.RedMap[redDotInfo.parent]
            RefreshParentCount(parentInfo, addCount)
        end
    end

    local redInfo = self.RedMap[name]
    if _addCount ~= 0 then
        --触发数量变化逻辑
        RefreshParentCount(redInfo, _addCount)
    end
end

function RedDotManage:ClearCount(name)
    if not self.RedMap[name] then
        return
    end

    local redDotInfo = self.RedMap[name]
    self:FreshDate_Count(name, -1 * redDotInfo.count)
end

--获取红点
function RedDotManage:GetRed(name)
    if self.RedMap and self.RedMap[name] then
        return self.RedMap[name].count > 0
    end
    return false
end

RedDotManage:Init()

return RedDotManage
