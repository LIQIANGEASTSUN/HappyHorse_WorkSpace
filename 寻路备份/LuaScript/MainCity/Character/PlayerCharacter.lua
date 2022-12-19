local Brain = require "MainCity.Character.AI.PlayerBrain"
local SuperCls = require "MainCity.Character.Base.Character"

local RoleSrc = {
    ["Maleplayer"] = "Configs.ScreenPlays.Characters.Maleplayer",
    ["Femaleplayer"] = "Configs.ScreenPlays.Characters.Femaleplayer"
}

local cName = {
    "Femaleplayer",
    "Maleplayer"
}
---@class PlayerCharacter:Character
local PlayerCharacter = class(SuperCls, "PlayerCharacter")
function PlayerCharacter:Create(name, params)
    local inst = PlayerCharacter.new(name, require(RoleSrc[name]), params or {})
    inst:Init()
    return inst
end

function PlayerCharacter:ctor()
    self.targetResId = nil
    self.isBusy = nil
end

function PlayerCharacter:Init()
    SuperCls.Init(self)
    self:RegiseterListeners()

    ---@type VaccumCleaner
    self.vaccum = include("MainCity.Character.VaccumCleaner")
    self.vaccum:Create(self)
end

function PlayerCharacter:RegiseterListeners()
    MessageDispatcher:AddMessageListener(MessageType.Camera_Follow_Player, self.CameraFollowPlayer, self)

    local gameObject = self:GetGameObject()
    if Runtime.CSNull(gameObject) then
        return
    end

    local moveControl = gameObject:GetOrAddComponent(typeof(CS.MovePlayer))
    moveControl:SetEnablePathHandle(function(pos, dir) return self:EnablePath(pos, dir) end)
    local callback = function(joyStick)
        moveControl:SetJoystick(joyStick)
        AppServices.PlayerJoystickManager:SetActiveRock(true)
    end
    AppServices.PlayerJoystickManager:GetJoyStick(callback)

    self:CameraFollowPlayer(true)
end

function PlayerCharacter:Awake()
    SuperCls.Awake(self)

    self.brain = Brain.Create(self)
    self.brain:SetActive(true)
end

function PlayerCharacter:LateUpdate(dt)
    SuperCls.LateUpdate(self)
    if self.brain and not self:IsIdlePaused() then
        self.brain:Update(dt)
    end
    if self.vaccum and self.vaccum.alive then
        self.vaccum:Update(dt)
    end
end

function PlayerCharacter:CastSpellTo(destPosition, duration, hitCallback)
    local playerAction = Actions.PlayAnimationAction:Create("Player", "magic_common")
    local spellAction = Sequence:Create()
    spellAction:Append(Actions.DelayS:Create(2.5))
    spellAction:Append(Actions.SpellFlyTo:Create(destPosition, duration or 1, hitCallback))
    local spawn = Spawn:Create()
    spawn:Append(playerAction)
    spawn:Append(spellAction)
    App.scene:AddFrameAction(spawn)
end

function PlayerCharacter:GetHandPosition(hand)
    local path =
        "Bip001/Bip001 Pelvis/Bip001 Spine/Bip001 Spine1/Bip001 Neck/Bip001 replace Clavicle/Bip001 replace UpperArm/Bip001 replace Forearm/Bip001 replace Hand"
    local replace = "R"
    if hand == "L" then
        replace = "L"
    end
    path = string.gsub(path, "replace", replace)
    local transform = self.renderObj.transform:Find(path)
    if transform then
        return transform.position
    else
        console.assert(false)
        return Vector3.zero
    end
end

-- 判断移动角色是来自移除队列还是点击地面移动, 结合isBusy实现角色在执行队列时，点击地面角色不移动
function PlayerCharacter:StartMove(targetPos, callback)
    local halfGridSize = App.scene.mapManager.gridSize
    local pos = targetPos or UserInput.getPosition()
    local position = pos:Flat()

    local function checkPosConlict(position)
        --移动可能冲突的角色列表，以后也可添加
        local dists = {}
        for _, name in pairs(cName) do
            if name ~= self.name then
                local charactor = CharacterManager.Instance():Find(name)
                if charactor then
                    local charactorPos
                    if charactor.GetMovingPosition then
                        charactorPos = charactor:GetMovingPosition() or charactor:GetPosition()
                    else
                        charactorPos = charactor:GetPosition()
                    end
                    local distance = position:FlatDistance(charactorPos)
                    table.insert(dists, distance)
                end
            end
        end
        local traders = App.scene.objectManager:GetAgentsByType(AgentType.trader)
        for _, trader in pairs(traders or {}) do
            local traderPos = trader:GetWorldPosition()
            local distance = position:FlatDistance(traderPos)
            table.insert(dists, distance)
        end

        if #dists == 0 then
            return true
        end

        table.sort(
            dists,
            function(a, b)
                return a < b
            end
        )
        if dists[1] > halfGridSize * 0.5 then
            return true
        end
        return
    end

    local canMove = checkPosConlict(position)
    console.lh("canMove: ", canMove) --@DEL
    if not canMove then
        self.isBusy = false
        return Runtime.InvokeCbk(callback, canMove)
    end

    local transform = self.renderObj.transform
    transform:LookAt(position)

    self:SetIdlePaused(true)

    self:Move(
        position,
        function()
            self:RecordCharacterPos()
            console.lh("EndMove: busyState:", self:IsBusy()) --@DEL
            MessageDispatcher:SendMessage(MessageType.After_Move_Character, self)
            return Runtime.InvokeCbk(callback, canMove)
        end
    )
end

function PlayerCharacter:Move(position, callback)
    local _MinDist = 1
    local from = self:GetPosition()
    local distance = from:FlatDistance(position)

    if distance <= _MinDist then
        self.renderObj:SetPosition(position)
        return Runtime.InvokeCbk(callback)
    end
    self.moving = true
    console.lh(tostring(self.name) .. "start moving") --@DEL
    self:PlayAnimation("walk")
    local fadeTime = 0.2
    local dirVec = self.transform.forward * fadeTime
    self:DoFade(0, fadeTime)
    self:SetMovingPosition(position)
    self.transform:DOMove(from + dirVec, fadeTime):SetEase(Ease.Linear):OnComplete(
        function()
            console.lh(tostring(self.name) .. "moveEnd") --@DEL
            self:PlayAnimation("defaultIdle")
            self.renderObj:SetPosition(position)
            self:SetMovingPosition()
            self:DoFade(1, fadeTime)
            self.moving = false
            Runtime.InvokeCbk(callback)
        end
    )
    if distance > 3 and CONST.RULES.ActorEffectEanbled() then
        XGE.EffectExtension.ActorSpotEffect_ResetTarget(self.renderObj)
    end
end

function PlayerCharacter:IsBusy()
    return self.isBusy
end

function PlayerCharacter:SetBusyState(val)
    self.isBusy = val
end

function PlayerCharacter:SetMovingPosition(pos)
    self.movingPosition = pos
end

function PlayerCharacter:GetMovingPosition()
    return self.movingPosition
end

function PlayerCharacter:CameraFollowPlayer(follow)
    if follow then
        MoveCameraLogic.Instance():StartFollowOnTransform(self.transform, 50)
    else
        MoveCameraLogic.Instance():StopFollow()
    end
end

function PlayerCharacter:EnablePath(position, dir)
    if not self.islandMapPath then
        local islandId = AppServices.User:GetPlayerIslandInfo()
        self.islandMapPath = AppServices.IslandPathManager:GetMapPath(islandId)
    end
    if not self.islandMapPath then
        return true
    end

    local pos = position + dir * 0.5
    local enablePass = self.islandMapPath:EnablePass(pos.x, pos.z)
    return enablePass
end

function PlayerCharacter:Destroy()
    if self.brain then
        self.brain:Destroy()
    end
    self:RecordCharacterPos()
    SuperCls.Destroy(self)
    MoveCameraLogic.Instance():StopFollow()

    AppServices.PlayerJoystickManager:SetActiveRock(false)

    MessageDispatcher:RemoveMessageListener(MessageType.Camera_Follow_Player, self.CameraFollowPlayer, self)
end

return PlayerCharacter
