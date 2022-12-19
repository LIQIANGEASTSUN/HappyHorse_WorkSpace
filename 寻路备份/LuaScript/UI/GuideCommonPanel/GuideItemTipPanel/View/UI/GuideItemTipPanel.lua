--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _GuideItemTipPanelBase = require "UI.GuideCommonPanel.GuideItemTipPanel.View.UI.Base._GuideItemTipPanelBase"

---@class GuideItemTipPanel:_GuideItemTipPanelBase
local GuideItemTipPanel = class(_GuideItemTipPanelBase)

function GuideItemTipPanel:ctor()

end

function GuideItemTipPanel:onAfterBindView()
    local info = self.arguments
    self.txtTittle.text = Runtime.Translate(info.tittleKey)
    if info.keyParam then
        self.txtContent.text = Runtime.Translate(info.contentKey,{name = Runtime.Translate(info.keyParam)})
    else
        self.txtContent.text = Runtime.Translate(info.contentKey)
    end
    if info.itemId then
        local spr = AppServices.ItemIcons:GetSprite(info.itemId)
        if spr then
            local rc = spr.rect
            local ratio = rc.height / rc.width
            self.imgIcon.sprite = spr
            self.imgIcon.transform.sizeDelta = Vector2(180, 180 * ratio)
        end
    end
    self.txtGo.text = Runtime.Translate(info.buttonKey)
    Util.UGUI_AddButtonListener(self.btnGo, function()
        if info.callback then
            Runtime.InvokeCbk(info.callback)
        end
        sendNotification(GuideItemTipPanelNotificationEnum.Close)
    end)
end

function GuideItemTipPanel:GetGuideBtn()
    return self.btnGo
end

function GuideItemTipPanel:refreshUI()

end

return GuideItemTipPanel
