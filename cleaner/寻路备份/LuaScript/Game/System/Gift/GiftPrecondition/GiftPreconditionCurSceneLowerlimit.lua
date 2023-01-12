---
--- Created by Betta.
--- DateTime: 2021/12/21 18:08
---

local Base = require("Game.System.Gift.GiftPrecondition.GiftPreconditionBase")
---@class GiftPreconditionCurSceneLowerlimit : GiftPreConditionBase
local GiftPreconditionCurSceneLowerlimit = class(Base, "GiftPreconditionCurSceneLowerlimit")

function GiftPreconditionCurSceneLowerlimit:ctor(sceneType, sceneID)
    self:SetCheckParam(sceneType, sceneID)
end

function GiftPreconditionCurSceneLowerlimit:SetCheckParam(sceneType, sceneID)
    self.sceneType = sceneType
    self.sceneID = sceneID
end

function GiftPreconditionCurSceneLowerlimit:Check()
    if self.sceneType ~= nil then
        local curSceneType = tonumber(App.scene:GetSceneType())
        if curSceneType == nil or curSceneType ~= self.sceneType then
            return false
        end
    end
    if self.sceneID ~= nil then
        local curSceneId = tonumber( App.scene:GetCurrentSceneId())
        if curSceneId == nil or curSceneId < self.sceneID then
            return false
        end
    end
    return true
end

return GiftPreconditionCurSceneLowerlimit