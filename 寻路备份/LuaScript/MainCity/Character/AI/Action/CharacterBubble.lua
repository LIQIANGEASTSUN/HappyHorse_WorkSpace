--[[
    @ Action Desc: 角色冒气泡
    @ Require Params:
        string:{气泡文字1,气泡文字2,....气泡文字N}
        int:{}
]]
local superCls = require("MainCity.Character.AI.Base.BDActionBase")
local CharacterBubble = class(superCls, "AI.Action.CharacterBubble")
local BDUtil = require("MainCity.Character.AI.Base.BDUtil")

function CharacterBubble:OnUpdate()
    local textNum = self.csTask.StringParamsCount

    local text
    if textNum == 0 then
        return BDTaskStatus.Success
    elseif textNum == 1 then
        text = self:GetStringParam(0)
    else
        local idx = math.random(1, textNum)
        text = self:GetStringParam(idx - 1)
    end

    local defaultY = 1.4
    local defaultX = 0.3

    text = Localization.Instance:GetText(text, nil)
    local duration = BDUtil.GetBubbleDurationByText(text)
    local entity = self:GetEntity()
    entity:AddTalkAction(text, duration, defaultX, defaultY, false, 0)
    return BDTaskStatus.Success
end

return CharacterBubble
