require "UI.Components.HomeSceneTopIconBase"
---@class UpdatingButton:HomeSceneTopIconBase
local UpdatingButton = class(HomeSceneTopIconBase)

function UpdatingButton.Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_UPDATINGBUTTON)
    return UpdatingButton:CreateWithGameObject(gameObject)
end

function UpdatingButton:CreateWithGameObject(gameObject)
    local instance = UpdatingButton.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function UpdatingButton:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.newMsgGo = self.gameObject.transform:Find("img_new_msg")
    --self:ShowOrHideNewMsgFlag(App.HSSdk:GetHSMsgCount() > 0 and RuntimeContext.FAQ_ENABLE)
    self.Interactable = true
    self.slider = find_component(self.gameObject, "progress", Image)

    local function OnClick_btn_add()
        self:OnClick()
    end
    Util.UGUI_AddButtonListener(self.gameObject, OnClick_btn_add)

    AppServices.EventDispatcher:addObserver(self, SystemEvent.UPDATING_PROGRESS,
        function(eventData)
            self.progressInfo = eventData.data.info or ""
            self:setProgress(eventData.data.val)
        end
    )
    self.progressVal = 0
    self.progressInfo = ""
    self:setProgress(self.progressVal)
end

function UpdatingButton:setProgress(val)
    self.progressVal = val or 0
    if Runtime.CSNull(self.slider) then return end

    local function updateCallback(value)
        if Runtime.CSValid(self.slider) then
            self.slider.fillAmount = value
        end
    end

    local function completeCallback()
        if self.floatSmoothTweener ~= nil then
            self.floatSmoothTweener:Kill()
            self.floatSmoothTweener = nil
        end
    end

    completeCallback()
    self.floatSmoothTweener = LuaHelper.FloatSmooth(self.slider.fillAmount, val, 0.3, updateCallback, completeCallback)
end

function UpdatingButton:OnClick()
    if not self.Interactable then
        return
    end
    PanelManager.showPanel(GlobalPanelEnum.DynamicUpdatePanel, {value = self.progressVal, content = self.progressInfo})
    DcDelegates:Log(SDK_EVENT.mainUI_button, {buttonName = "updating"})
end

function UpdatingButton:SetStarNumber(value)
    self.text_number.text = tostring(value)
end

function UpdatingButton:SetInteractable(value)
    self.Interactable = value
end

function UpdatingButton:ShowOrHideNewMsgFlag(isShow)
    if self.newMsgGo  then
        self.newMsgGo:SetActive(isShow == true)
    end
end

function UpdatingButton:Unload()
end

function UpdatingButton:Dispose()
    AppServices.EventDispatcher:removeObserver(self, SystemEvent.UPDATING_PROGRESS)
    HomeSceneTopIconBase.Dispose(self)
end

--是否显示红点提示
function  UpdatingButton:ShowReddot(isShow)
    self.image_reddot:SetActive(isShow)
end

function UpdatingButton:InitRedDotInfo()

end

return UpdatingButton