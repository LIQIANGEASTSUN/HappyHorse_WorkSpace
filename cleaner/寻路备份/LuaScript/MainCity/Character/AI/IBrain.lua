local BDTreeType = typeof(CS.BehaviorDesigner.Runtime.BehaviorTree)
local BehaviorManager = CS.BehaviorDesigner.Runtime.BehaviorManager
---@class IBrain
local IBrain = class()

function IBrain:ctor(avatar)
    self.active = nil
    self.avatar = avatar.renderObj
end

function IBrain:Init()
    local go = self:GetGameObject()
    if Runtime.CSNull(go) then
        return
    end

    self.bdTree = go:GetComponent(BDTreeType)
    if Runtime.CSValid(self.bdTree) then
        BDFacade.RegisterAIEntity(self, self.bdTree)
    end
end

function IBrain:SetActive(active)
    if self.active == active then
        return
    end
    if active then
        if App.screenPlayActive then
            return
        end
        if not App.scene then
            return
        end
    end
    self.active = active
    -- self.avatar:SetBool("ai", self.active)
    if self.bdTree then
        self.bdTree:SetEnable(active)
        if active then
            BehaviorManager.instance:RestartBehavior(self.bdTree)
        end
    end
end

function IBrain:Update(dt)
end

function IBrain:GetGameObject()
    return self.avatar
end
function IBrain:GetEntity()
    return self.entity
end

function IBrain:Destroy()
    if Runtime.CSValid(self.bdTree) then
        BDFacade.UnRegisterAIEntity(self, self.bdTree)
    end
end

return IBrain
