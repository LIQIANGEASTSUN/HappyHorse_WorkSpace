--insertWidgetsBegin
--	img_bg	text_title	text_content	text_award_desc
--	text_prop_count	btn_later	btn_update	btn_force_update
--insertWidgetsEnd

--insertRequire

local _AppUpdatePanelBase = require "UI.AppUpdate.AppUpdatePanel.View.UI.Base._AppUpdatePanelBase"

local AppUpdatePanel = class(_AppUpdatePanelBase)

function AppUpdatePanel:ctor()
end

function AppUpdatePanel:onAfterBindView()
end

function AppUpdatePanel:refreshUI()
end

function AppUpdatePanel:ShowButton(isForceUpdate)
    self.btn_force_update.gameObject:SetActive(isForceUpdate)
    self.btn_update.gameObject:SetActive(not isForceUpdate)
    self.btn_later.gameObject:SetActive(not isForceUpdate)
    local function set_btn_text(btn, textKey)
        local btnText = btn:GetComponentInChildren(typeof(Text))
        if btnText ~= nil then
            btnText.text = Runtime.Translate(textKey)
        end
    end
    if isForceUpdate then
        self.text_title.text = Runtime.Translate("update_outdated_title")
        self.text_content.text = Runtime.Translate("update_outdated_des")
        self.text_award_desc.text = Runtime.Translate("update_outdated_prize_des")
        set_btn_text(self.btn_force_update, "update_outdated_button")
    else
        self.text_title.text = Runtime.Translate("update_newVersion_title")
        self.text_content.text = Runtime.Translate("update_newVersion_des")
        self.text_award_desc.text = Runtime.Translate("update_newVersion_prize_des")
        set_btn_text(self.btn_update, "update_newVersion_button_update")
        set_btn_text(self.btn_later, "update_newVersion_button_later")
    end
end

function AppUpdatePanel:SetRewards(rewards)
    if table.isEmpty(rewards) then
        return
    end
    local container = self.gameObject.transform:Find("prop_container")
    local itemTemplate = container.gameObject.transform:Find("prop")
    for i = 1, #rewards do
        local item
        if i == 1 then
            item = itemTemplate
        else
            item = GameObject.Instantiate(itemTemplate, container.transform)
        end
        local icon = item.gameObject:FindComponentInChildren("img_icon", typeof(Image))
        icon.sprite = AppServices.ItemIcons:GetSprite(rewards[i].itemId)
        local countText = item.gameObject:FindComponentInChildren("text_prop_count", typeof(Text))
        countText.text = "x" .. rewards[i].count
    end
end

return AppUpdatePanel
