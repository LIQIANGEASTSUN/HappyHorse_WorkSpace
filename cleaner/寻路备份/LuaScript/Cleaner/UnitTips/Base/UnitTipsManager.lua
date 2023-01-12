---@type UnitTipsInfo
local UnitTipsInfo = require "Cleaner.UnitTips.Base.UnitTipsInfo"

---@type UnitTipsManager
local UnitTipsManager = {
    instanceId = 0,
    ---@type Dictionary<string, UnitBase>
    tipsMap = {},
}

function UnitTipsManager:Init()
    self:RegisterEvents()
end

function UnitTipsManager:ShowTips(unitId, tipsType, tipsData)
    --console.error("ShowTips:"..unitId.."    "..tipsType)
    local find = self:ShowTipsType(unitId, tipsType, tipsData)
    if not find then
        --console.error("CreateTips:"..unitId.."    "..tipsType)
        self:CreateTips(unitId, tipsType, tipsData)
    end
end

function UnitTipsManager:ShowTipsType(unitId, tipsType, tipsData)
    local find = false
    local tipsList = self:GetTips(unitId)
    for _, tips in pairs(tipsList) do
        if tipsType == tips:GetTipsType() then
            tips:Show(tipsData)
            find = true
        else
            tips:Hide()
        end
    end

    return find
end

function UnitTipsManager:CreateTips(unitId, tipsType, tipsData)
    local path = UnitTipsInfo.TipsConfigs[tipsType]
    local tipsAlias = include(path)
    local tips = tipsAlias.new(unitId)

    local instanceId = self:NewInstanceId()
    tips:SetInstanceId(instanceId)
    tips:Show(tipsData)
    local tipsName = tips:TipsName()
    self.tipsMap[tipsName] = tips
end

function UnitTipsManager:HideTips(unitId, tipsType)
    local tipsList = self:GetTips(unitId)
    for _, tips in pairs(tipsList) do
        if tipsType == tips:GetTipsType() then
            tips:Hide()
        end
    end
end

function UnitTipsManager:RemoveTipsAll(unitId)
    local tipsList = self:GetTips(unitId)
    for _, tips in pairs(tipsList) do
        local tipsName = tips:TipsName()
        self.tipsMap[tipsName] = nil
        tips:Destroy()
    end
end

function UnitTipsManager:RemoveTips(unitId, tipsType)
    local tipsList = self:GetTips(unitId)
    for _, tips in pairs(tipsList) do
        if tipsType == tips:GetTipsType() then
            local tipsName = tips:TipsName()
            self.tipsMap[tipsName] = nil
            tips:Destroy()
        end
    end
end

function UnitTipsManager:GetTips(unitId)
    local tipsList = {}
    for _, tips in pairs(self.tipsMap) do
        if unitId == tips:GetUnitId() then
            table.insert(tipsList, tips)
        end
    end
    return tipsList
end

function UnitTipsManager:GetTipsWithName(tipsName)
    return self.tipsMap[tipsName]
end

function UnitTipsManager:NewInstanceId()
    self.instanceId = self.instanceId + 1
    return self.instanceId
end

function UnitTipsManager:LateUpdate()
    for _, tips in pairs(self.tipsMap) do
        if tips:GetUseUpdate() then
            tips:LateUpdate()
        end
    end
end

function UnitTipsManager:TipsClick()
    local names = UserInput.getCastList()
    for _, name in pairs(names) do
        local tips = self:GetTipsWithName(name)
        if tips then
            tips:Click()
        end
    end
end

function UnitTipsManager:RegisterEvents()
    UserInput.registerListener(self, UserInputType.clickTips, self.TipsClick)
end

function UnitTipsManager:UnRegisterEvent()
    UserInput.removeListener(self, UserInputType.clickTips)
end

function UnitTipsManager:Release()
    self:UnregisterEvents()
end

return UnitTipsManager