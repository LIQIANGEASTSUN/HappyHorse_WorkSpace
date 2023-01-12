local SuperCls = require "MainCity.Character.AI.IBrain"
---@class DragonBrain:IBrain
local DragonBrain = class(SuperCls, "DragonBrain")

local BDTreeType = typeof(CS.BehaviorDesigner.Runtime.BehaviorTree)
---@param dragon Dragon
function DragonBrain.Create(dragon)
    local inst = DragonBrain.new(dragon)
    inst:Init()
    return inst
end

function DragonBrain:ctor(dragon)
    ---@type Dragon
    self.dragon = dragon
    self.bdTree = nil
    self.alive = true
end

function DragonBrain:Init()
    local go = self:GetGameObject()
    if Runtime.CSNull(go) then
        return
    end

    local workSlot = self.dragon:GetSlot()
    if not workSlot then
        return
    end

    local assetPath = workSlot:GetAIAssetPath()

    App.uiAssetsManager:LoadAssets(
        {assetPath},
        function()
            if not self.alive then
                return
            end
            local behavior = App.uiAssetsManager:GetAsset(assetPath)
            self.bdTree = go:GetOrAddComponent(BDTreeType)
            BDFacade.RegisterAIEntity(self, self.bdTree)
            self.bdTree.RestartWhenComplete = true
            self.bdTree.PauseWhenDisabled = true
            self.bdTree.ExternalBehavior = behavior
        end
    )
end

function DragonBrain:GetGameObject()
    return self.dragon.render
end
function DragonBrain:GetEntity()
    return self.dragon
end

function DragonBrain:Destroy()
    if self.bdTree then
        self.bdTree:SetEnable(false)
    end
    SuperCls.Destroy(self)
    -- Runtime.CSDestroy(self.bdTree)
    self.bdTree = nil
    self.alive = nil
end

return DragonBrain
