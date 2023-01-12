local SuperCls = require "MainCity.Character.AI.IBrain"
---@class CrowBrain:IBrain
local CrowBrain = class(SuperCls, "CrowBrain")

function CrowBrain.Create(body)
    local inst = CrowBrain.new(body)
    inst:Init()
    return inst
end

function CrowBrain:ctor(body)
    self.body = body
    self.cacheActions = {}
end

function CrowBrain:Update(dt)
    if not self.active then
        return
    end

    if self.currentAction then
        self.currentAction:OnTick()
    end
end

---重写, 不返回(即返回空)
function CrowBrain:GetGameObject()
end

function CrowBrain:ChangeAction(actionName, params)
    if self.currentAction then
        self.currentAction:OnExit()
    end
    local action = self:GetAction(actionName)
    self.currentAction = action
    if action then
        -- console.tprint(self.body.renderObj, "ChangeAction:", actionName) --@DEL
        action:OnEnter(params)
    end
end

function CrowBrain:GetAction(name)
    if string.isEmpty(name) then
        return
    end
    if not self.cacheActions[name] then
        local cls = include("MainCity.Character.AI.Action.PetAction." .. name)
        local action = cls.new(self)
        self.cacheActions[name] = action
        return action
    end
    return self.cacheActions[name]
end

function CrowBrain:SetActive(active)
    SuperCls.SetActive(self, active)
    if active then
        self:ChangeAction("Idle", true)
    else
        self.body:SetHeight(0)
        if self.currentAction then
            self.currentAction:OnExit()
            self.currentAction = nil
        end
    end
end

function CrowBrain:Destroy()
    SuperCls.Destroy(self)
    if self.currentAction then
        self.currentAction:OnExit()
        self.currentAction = nil
    end
    self.cacheActions = {}
end

return CrowBrain
