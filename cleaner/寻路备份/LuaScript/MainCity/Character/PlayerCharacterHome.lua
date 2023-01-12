---@type IslandTemplateTool
local IslandTemplateTool = require "Fsm.Ship.IslandTemplateTool"

local SuperCls = require "MainCity.Character.Base.Character"

---@class PlayerCharacterHome:Character
local PlayerCharacterHome = class(SuperCls, "PlayerCharacterHome")

function PlayerCharacterHome:ctor()
    self.targetResId = nil
    self.isBusy = nil
end

function PlayerCharacterHome:Init()
    SuperCls.Init(self)
    self:RegiseterListeners()
end

function PlayerCharacterHome:RegiseterListeners()
    local gameObject = self:GetGameObject()
    if Runtime.CSNull(gameObject) then
        return
    end

    local islandId = IslandTemplateTool:GetHomelandId()
    local _, _, shipDir = IslandTemplateTool:GetHomelandPos(islandId)

    local rot = Quaternion.LookRotation(shipDir, Vector3.up)
    self.transform.rotation = rot

    local config = AppServices.Meta:Category("ConfigTemplate")
    local roleHomeAni = config["roleHomeAni"].value
    gameObject:PlayAnim(roleHomeAni)
end

function PlayerCharacterHome:Awake()
    SuperCls.Awake(self)
end

function PlayerCharacterHome:LateUpdate(dt)
    SuperCls.LateUpdate(self)
end

function PlayerCharacterHome:IsBusy()
    return self.isBusy
end

function PlayerCharacterHome:SetBusyState(val)
    self.isBusy = val
end

function PlayerCharacterHome:Destroy()
    if self.brain then
        self.brain:Destroy()
    end
    self:RecordCharacterPos()
    SuperCls.Destroy(self)
end

return PlayerCharacterHome