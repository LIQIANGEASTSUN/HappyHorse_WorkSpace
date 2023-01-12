--insertWidgetsBegin
--	text_title	btn_collect
--insertWidgetsEnd

--insertRequire
local _MailCollectPanelBase = require "UI.Mail.MailCollectPanel.View.UI.Base._MailCollectPanelBase"
---@class MailCollectPanel:_MailCollectPanelBase
local MailCollectPanel = class(_MailCollectPanelBase)

function MailCollectPanel:ctor()
end

function MailCollectPanel:onAfterBindView()
end

function MailCollectPanel:refreshUI()
    local rewards = self.arguments.rewards
    local rewardCount = table.len(rewards)
    local usedItem
    local usedParent
    if rewardCount > 5 then
        usedItem = self.tran_list_item
        usedParent = self.tran_list_parent
    else
        usedItem = self.oneRowItem
        usedParent = self.oneRowContent
    end
    -- console.assert(Runtime.CSValid(usedItem))
    -- console.assert(Runtime.CSValid(usedParent))
    usedParent:ClearAllChildren()
    self.rewardGos = {}
    for i, v in ipairs(rewards) do
        local go = GameObject.Instantiate(usedItem)
        go.transform:SetParent(usedParent, false)
        local icon = find_component(go, "Image", Image)
        icon.sprite = AppServices.ItemIcons:GetSprite(v.itemTemplateId)

        local countText = find_component(go, "BText", Text)
        local itemConfig = AppServices.Meta:GetItemMeta(v.itemTemplateId)
        if itemConfig.limittime > 0 then
            countText.text = ItemId.GetEnergyBuffTimeText(v.itemTemplateId)
        else
            countText.text = "X" .. tostring(v.count)
        end
        go:SetActive(true)
        table.insert(self.rewardGos, go)
    end
    self:Translate()
end

function MailCollectPanel:Translate()
    if self.arguments.translate then
        self.txt_btn_collect.text = Runtime.Translate(self.arguments.translate.btn)
        self.txt_description.text = Runtime.Translate(self.arguments.translate.desc)
        self.text_title.text = Runtime.Translate(self.arguments.translate.title)
    else
        self.txt_btn_collect.text = Runtime.Translate("ui_mail_collect_all_btn")
        self.txt_description.text = Runtime.Translate("ui_mail_collect_all_description")
        self.text_title.text = Runtime.Translate("ui_mail_collect_all_title")
    end
end

return MailCollectPanel
