--insertRequire
local _CollectAllPanelBase = require "MainCity.UI.CollectAllPanel.View.UI.Base._CollectAllPanelBase"
---@class CollectAllPanel:_CollectAllPanelBase
local CollectAllPanel = class(_CollectAllPanelBase)

function CollectAllPanel:ctor()
end

function CollectAllPanel:onAfterBindView()
    self.text_tips = self.gameObject:FindComponentInChildren("text_tips", typeof(Text))
    local shakeButton = App.scene:GetWidget(CONST.MAINUI.ICONS.ShakeButton)
    if shakeButton then
        self:SetHideTopIconType(TopIconHideType.stayShakeIcon|TopIconHideType.stayBagIcon)
        local hasFinish = App.mapGuideManager:HasComplete(GuideIDs.Shake)
        --hasFinish = false
        shakeButton:KeepIconsPos()
        shakeButton:ShowGuide(not hasFinish)
        shakeButton:OnHit()
        if not hasFinish then
            App.mapGuideManager:MarkGuideComplete(GuideIDs.Shake)
        end
        self.text_tips.text = Runtime.Translate("guide_16002")
        return
    end
    self.text_tips.text = Runtime.Translate("guide_16001")
    self:SetHideTopIconType(TopIconHideType.stayBagIcon)
end

function CollectAllPanel:refreshUI()
end

--function CollectAllPanel:fadeIn(_finishCallBack)
    --[[if self.panelVO == nil then
        XWarn("fade in panelVO is nil!!!")
        return
    end

    self.gameObject:SetActive(true)
    self.gameObject:SetTimeOut(_finishCallBack,0.4)
    self.animator:Play("PanelIn")--]]
    --CollectAllPanel.super.fadeIn(self, _finishCallBack)
    --App.scene:HideAllIcons()
--end

--function CollectAllPanel:fadeOut(_finishCallBack)
    --[[local function fadeOutFinish()
        if Runtime.CSValid(self.gameObject) then
            self.gameObject:SetActive(false)
        end

        if _finishCallBack then
            _finishCallBack()
        end
    end
    self.gameObject:SetTimeOut(fadeOutFinish, 0.433)
    self.animator:Play("PanelOut")--]]
    --CollectAllPanel.super.fadeOut(self, _finishCallBack)
    --App.scene:ShowAllIcons()
--end



return CollectAllPanel
