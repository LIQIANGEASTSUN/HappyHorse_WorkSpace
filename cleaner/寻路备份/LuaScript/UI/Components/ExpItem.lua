local SuperCls = require "UI.Components.HomeSceneTopIconBase"
---@class ExpItem:HomeSceneTopIconBase
local ExpItem = class(SuperCls)

---@return ExpItem
function ExpItem:Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_EXPITEM)
    return ExpItem:CreateWithGameObject(gameObject)
end

function ExpItem:CreateWithGameObject(gameObject)
    local instance = ExpItem.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function ExpItem:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.text_level = gameObject:FindComponentInChildren("img_icon/text_level", typeof(Text))
    self.text_stageProgress = gameObject:FindComponentInChildren("txt_progress", typeof(Text))
    self.slider_progress = gameObject:FindComponentInChildren("Slider", typeof(Slider))
    self.go_icon = gameObject:FindGameObject("img_icon")
    self.icon_animator = self.go_icon:GetComponent(typeof(Animator))
    self.num_animator = gameObject:FindComponentInChildren("add", typeof(Animator))
    self.txt_num = gameObject:FindComponentInChildren("add/text_number_add", typeof(Text))
    -- self.redDot = gameObject:FindGameObject("reddot")

    Util.UGUI_AddButtonListener(gameObject, self.OnClick, self)
    self.Interactable = true
    self:Refresh()
end

function ExpItem:OnClick()
    if not App.globalFlags:CanClick() then
        return
    end
    App.globalFlags:SetClickFlag()
    local curSceneId = App.scene:GetCurrentSceneId()
    local cfg = AppServices.Meta:GetSceneCfg(curSceneId)
    if cfg and cfg.type ~= 6 then
        PanelManager.showPanel(GlobalPanelEnum.ExpHelpPanel)
    end
end

function ExpItem:SetInteractable(value)
    self.Interactable = value
end

-- 等级
function ExpItem:SetLevelText(value)
    value = math.floor(value)
    if Runtime.CSValid(self.text_level) then
        self.text_level.text = value
    end
end

function ExpItem:SetSliderValue(value)
    if Runtime.CSValid(self.slider_progress) then
        self.slider_progress.value = value
    end
end

function ExpItem:SetStageProgressText(cur, full)
    if Runtime.CSValid(self.text_stageProgress) then
        cur = math.round(cur)
        full = math.round(full)
        self.text_stageProgress.text = string.format("%d/%d", cur, full)
    end
end

function ExpItem:TweenNum(toValue, onFinish)
    local expLogic = AppServices.ExpLogic

    self.slider_progress:DOKill()
    local level = AppServices.User:GetCurrentLevelId()
    local exLvl = self:GetValue()
    local count = level - exLvl
    if count and count > 0 then
        toValue = 1
    end
    local function onComplete()
        if Runtime.CSValid(self.gameObject) then
            local fullValue = AppServices.Meta:GetLevelConfig(level).exp
            expLogic:RefreshExpValue(level)
            if count and count > 0 then
                self:SetSliderValue(0)
                self:SetStageProgressText(0, fullValue)
                self:Refresh(onFinish)
            else
                local curValue = AppServices.User:GetExp()
                local lerp = curValue / fullValue
                self:SetLevelText(level)
                self:SetSliderValue(lerp)
                self:SetStageProgressText(curValue, fullValue)
                Runtime.InvokeCbk(onFinish)
            end
        end
    end
    self.slider_progress:DOValue(toValue, 0.45, onComplete)
end

function ExpItem:OnHit()
    if self.icon_animator then
        self.icon_animator:SetTrigger("add")
    end
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_resource)
end

function ExpItem:GetValue()
    return AppServices.ExpLogic:GetExValue()
end

function ExpItem:SetValue(value)
    local level = AppServices.User:GetCurrentLevelId()
    local curValue = AppServices.User:GetExp()
    local fullValue = AppServices.Meta:GetLevelConfig(level).exp
    local lerp = curValue / fullValue
    self:SetLevelText(level)
    self:SetSliderValue(lerp)
    self:SetStageProgressText(curValue, fullValue)
end

function ExpItem:Refresh(finishCallback)
    local level = AppServices.User:GetCurrentLevelId()
    self:SetLevelText(level)
    local curExp = AppServices.User:GetExp()
    local fullExp  = AppServices.Meta:GetLevelConfig(level).exp
    if AppServices.User:IsMaxLevel() and curExp == fullExp then
       self:RefreshMaxLevel(finishCallback)
    else
        local toValue = curExp / fullExp
        self:_Refresh(toValue, finishCallback)
    end
end

function ExpItem:_Refresh(toValue, finishCallback)
    self:TweenNum(toValue, finishCallback)
end
function ExpItem:ShowEnterAnim(instant, finishCallback)
    -- self:Refresh()
    HomeSceneTopIconBase.ShowEnterAnim(self, instant, finishCallback)
end

function ExpItem:GetMainIconGameObject()
    return self.go_icon
end

function ExpItem:RefreshMaxLevel(callabck)
    self:TweenNum(1, function()
        self:SetSliderValue(1)
        self.text_stageProgress.text = Runtime.Translate("ui_fullLevel")
        Runtime.InvokeCbk(callabck)
    end)
end

function ExpItem:GetIconGO()
    return self.go_icon
end

return ExpItem
