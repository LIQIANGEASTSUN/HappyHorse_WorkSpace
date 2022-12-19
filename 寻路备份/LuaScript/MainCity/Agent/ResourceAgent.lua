local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class ResourceAgent:BaseAgent 可消除障碍物
local ResourceAgent = class(NormalAgent, "ResourceAgent")

function ResourceAgent:Suckable()
    if self.alive then
        return true
    end
end
---资源建筑的吸取等级
function ResourceAgent:GetSuckLevel()
    if self.data and self.data.meta then
        return self.data.meta.resourceBuildingLevel
    end
end

function ResourceAgent:AfterCleaned()
    self:SetVisible(false)
    local delay = self.data.meta.refreshCd
    if not delay or delay == 0 then
        self:Destroy()
        return
    end
    self.rebornTimer = WaitExtension.SetTimeout(
        function()
            if not self.alive then
                return
            end
            self:SetVisible(true)
            local go = self:GetGameObject()
            self.data:GetRawLocalScale()
            local orgScale = go:GetLocalScale()
            local tween = go.transform:DOScale(orgScale, 0.35)
            tween:ChangeStartValue(Vector3.zero)
            tween:SetEase(Ease.OutBack)
        end,
        delay,
        true
    )
end

function ResourceAgent:CanEdit()
    return false
end

function ResourceAgent:EnterEditMode()
    return false
end

function ResourceAgent:Destroy()
    NormalAgent.Destroy(self)
    if self.rebornTimer then
        WaitExtension.CancelTimeout(self.rebornTimer)
        self.rebornTimer = nil
    end
end

return ResourceAgent
