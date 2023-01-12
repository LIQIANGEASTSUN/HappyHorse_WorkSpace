-- 上线100 精力值,当精力值，低于40的时候会变得懒惰，不想走动，自主找长椅休息
-- 每次说话 - 1
-- 走动扣距离
-- idle恢复
local SuperCls = require 'MainCity.Character.AI.IBrain'
---@class PlayerBrain:IBrain
local PlayerBrain = class(SuperCls, 'PlayerBrain')

function PlayerBrain.Create(character)
    local inst = PlayerBrain.new(character)
    inst:Init()
    return inst
end

function PlayerBrain:ctor(character)
    self.body = character
    self.bdTree = nil
end

function PlayerBrain:Init()
    SuperCls.Init(self)
end

function PlayerBrain:Update(dt)
end

function PlayerBrain:GetGameObject()
    return self.body:GetGameObject()
end
function PlayerBrain:GetEntity()
    return self.body
end

return PlayerBrain