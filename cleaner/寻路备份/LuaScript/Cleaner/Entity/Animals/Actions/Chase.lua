-- Attack
local BaseAction = require "Cleaner.Entity.Animals.Actions.BaseAction"
---@class Attack : BaseAction
local Attack = class(BaseAction)
local sliderAssetPath = "Prefab/UI/MagicalCreatures/Slider.prefab"
local strengthAssetPath = "Prefab/UI/MagicalCreatures/StrengthReduce.prefab"
local SliderType = typeof(Slider)

function Attack:OnEnter()
    self.active = true
    console.tprint(self.entity.gameObject, "In Action: Attack") --@DEL
    self.entity:SetBlockDrag(true)
    local target = self.entity:GetTarget()
    if target:IsCleaning() then
        return self:ChangeToNextState()
    end
    if target:IsLocked() then
        return self:ChangeToNextState()
    end
    local id = self.entity.data and self.entity.data.creatureId
    target:SetCleanDragon(true, id)
    SceneServices.BindingTip:HideAll()
    local lookDir = self.entity:GetTarget():GetWorldPosition() - self.entity:GetPosition()
    lookDir.y = 0
    self.entity:SetForward(lookDir)
    self:CreateSlider(
        function()
            self:StartAttack()
        end
    )
end

function Attack:CanChangeTo(state)
    if state == EntityState.fly_out then
        return true
    end
end

function Attack:ChangeToNextState()
    ---@type DragonCollectAgent
    local agent = self.entity:GetTarget()
    agent:FreeCollectAgent()
    local id = self.entity.data and self.entity.data.creatureId
    agent:SetCleanDragon(false, id)
    self.entity:BeginRest()
    if self.entity.data.physicalStrength > 0 then
        self.entity.AttackBehaviour:ChangeToIdle({noWait = true})
    else
        self.entity:BeginFlyout()
    end
end

function Attack:CheckTargetValid()
    if not self.active then
        return
    end
    if not self.entity:IsAgentAvailable() then
        self:Abort("AgentUnavailable")
        return
    end
    return true
end

function Attack:CreateSlider(callback)
    if Runtime.CSValid(self.goSlider) then
        self.goSlider:SetActive(true)
        return callback()
    end
    local function onLoaded()
        if not self.active then
            return
        end
        local go = BResource.InstantiateFromAssetName(sliderAssetPath)
        if Runtime.CSValid(go) then
            self.goSlider = go
            self.slider = go:GetComponent(SliderType)
            local parent = self.entity:GetUIAnchor()
            go:SetParent(parent, false)
        end
        callback()
    end
    App.buildingAssetsManager:LoadAssets({sliderAssetPath, strengthAssetPath}, onLoaded)
end

function Attack:CreateStrengthEffect(callback)
    if Runtime.CSValid(self.strengthEffect) then
        return callback()
    end

    local go = BResource.InstantiateFromAssetName(strengthAssetPath)
    if Runtime.CSValid(go) then
        self.strengthEffect = go
        local parent = App.scene.sceneCanvas
        go:SetParent(parent, false)
    end
    return callback()
end

function Attack:SetSliderValue(value)
    if Runtime.CSValid(self.slider) then
        self.slider.value = value
    end
    -- console.tprint(self.entity.gameObject, "收集中..... => ", value) --@DEL
end

-- 表现攻击动画, 开始采集流程
function Attack:StartAttack()
    -- 如果障碍物不可被龙采集, 退出
    if not self.entity:GetTarget():CanBeAttack() then
        self:ChangeToNextState()
        return
    end

    -- 如果龙不能采集, 退出
    if not self.entity:CanAttack() then
        self:ChangeToNextState()
        return
    end

    self.entity:PlayCollect()
    self:Start()
end

function Attack:FinishAttack()
end

function Attack:Start()
    if self.timer then
        return
    end

    local duration = AnimatorEx.GetClipLength(self.entity.render, "collect")
    local value = 0
    self:SetSliderValue(value)
    self.timer =
        WaitExtension.InvokeRepeating(
        function()
            if self:CheckTargetValid() then
                value = value + Time.deltaTime
                self:SetSliderValue(value / duration)
                if value >= duration then
                    self:SendRequest()
                    self:Stop()
                end
            end
        end,
        0,
        0
    )
    -- App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_dragon_collection)
end

function Attack:Stop(isExit)
    if not isExit then
        self.entity:PlayFlyIdle()
    end
    if self.timer then
        WaitExtension.CancelTimeout(self.timer)
        self.timer = nil
    end
end

function Attack:SendRequest(callback)
    if not self.active then
        return Runtime.InvokeCbk(callback, false)
    end

    local params = {
        creatureId = self.entity.data.creatureId,
        sceneId = App.scene:GetCurrentSceneId(),
        plantId = self.entity:GetTarget():GetId()
    }

    local function onSuc(response)
        console.warn(nil, "采集成功: ", table.tostring(response)) --@DEL

        if not self.active then
            return
        end
        self:ShowStrengthReduceEffect(response.deltaCount)
        if response.skinRewards then
            for _, v in ipairs(response.skinRewards) do
                UITool.ShowPropsAniWithCount(v.itemTemplateId, v.count, self.slider:GetPosition())
                AppServices.User:AddItem(v.itemTemplateId, v.count, ItemGetMethod.CollectExtraSkinReward)
                local widget = App.scene:GetWidget(ItemId.GetWidgetType(v.itemTemplateId))
                if widget and widget.Refresh then
                    widget:Refresh()
                end
            end
        end
        -- local creatureMsg = response.creature
        -- self.entity:SetStrengthData(creatureMsg)
        local agent = self.entity:GetTarget()
        local plantMsg = response.plant
        if plantMsg and not string.isEmpty(plantMsg.plantId) then
            agent:SetServerData(plantMsg)
        end
        local ble = MapBubbleManager:GetShowedBubble(self.entity.data.creatureId)
        if ble and ble.type == BubbleType.DragonDetail then
            ble:UpdateEnergy(self.entity)
        end
        if self.entity:IsAgentAvailable() then
            if response.creature.physicalStrength > 0 then
                self:StartAttack()
                return
            end
        -- else
        --     agent:CheckHasArchievement(response)
        end
        self:ChangeToNextState()
    end
    local function onFail()
        console.tprint(self.entity.gameObject, "采集请求失败!!!") --@DEL
        if not self.active then
            return Runtime.InvokeCbk(callback, false)
        end
        Runtime.InvokeCbk(callback, false)
        self:ChangeToNextState()
    end
    --发送采集请求
    --   => 返回成功 => 建筑进入冷却 => 魔法生物进入等待领取
    --   => 返回失败 => 魔法生物进入漫游
    -- console.warn(nil, table.tostring(params))
    AppServices.MagicalCreatures:RequestCollect(params, onSuc, onFail)
end

function Attack:ShowStrengthReduceEffect(deltaCount)
    if not self.active then
        return
    end
    if deltaCount == 0 then
        return
    end
    self:CreateStrengthEffect(
        function()
            if not self.active then
                return
            end
            if not Runtime.CSValid(self.strengthEffect) then
                return
            end

            local text = find_component(self.strengthEffect, "Text", Text)
            -- local strength = self.entity.meta.attackEffect
            text.text = "-" .. deltaCount
            self.strengthEffect:SetActive(true)

            -- local position = self.entity:GetTarget():GetAnchorPosition()
            -- local position = self.entity:GetPosition()
            local position = self.goSlider:GetPosition()
            self.strengthEffect:SetPosition(self.goSlider:GetPosition())
            GameUtil.DoFade(self.strengthEffect, 1, 0.1, 0)
            -- local scaleTween = GameUtil.DoScale(self.strengthEffect, Vector3.one, 0.2)
            local moveTween = self.strengthEffect.transform:DOMove(position + Vector3.up * 0.75, 0.8)
            moveTween:SetDelay(0.3)
            local fadeOutTween = GameUtil.DoFade(self.strengthEffect, 0, 0.7, 1)
            fadeOutTween:SetDelay(0.3)
            fadeOutTween.onComplete = function()
                if Runtime.CSValid(self.strengthEffect) then
                    self.strengthEffect:SetActive(false)
                end
            end
        end
    )
end

-- 采集被中断
function Attack:Abort(reason)
    console.tprint(self.entity.gameObject, "采集被中断, 原因是 => ", reason) --@DEL
    self:Stop()
    self.entity:SetTarget(nil)
    if self.entity.data.physicalStrength > 0 then
        self.entity.AttackBehaviour:ChangeToIdle()
    else
        -- self.entity:ChangeAction(EntityState.fly_out)
        self.entity:BeginFlyout()
    end
end

function Attack:OnExit()
    self.entity:SetBlockDrag(false)
    if Runtime.CSValid(self.goSlider) then
        self.goSlider:SetActive(false)
    end
    BaseAction.OnExit(self)
    self:Stop(true)
    local agent = self.entity:GetTarget()
    if agent then
        local id = self.entity.data and self.entity.data.creatureId
        agent:SetCleanDragon(false, id)
    end
    self.entity:SetTarget(nil)
end

return Attack
