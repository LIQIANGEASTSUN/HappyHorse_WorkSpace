--insertWidgetsBegin
--	img_bg	text_title	text_content	text_award_desc
--	text_prop_count	btn_cancel	btn_update	btn_force_update
--insertWidgetsEnd

--insertRequire

local _TeamMapAppUpdatePanelBase = require "UI.AppUpdate.TeamMapAppUpdatePanel.View.UI.Base._TeamMapAppUpdatePanelBase"

local TeamMapAppUpdatePanel = class(_TeamMapAppUpdatePanelBase)

function TeamMapAppUpdatePanel:ctor()
end

function TeamMapAppUpdatePanel:onAfterBindView()
end

function TeamMapAppUpdatePanel:refreshUI()
end

function TeamMapAppUpdatePanel:ShowButton(isForceUpdate)
    self.btn_update.gameObject:SetActive(not isForceUpdate)
    self.btn_cancel.gameObject:SetActive(not isForceUpdate)
    local function set_btn_text(btn, textKey)
        local btnText = btn:GetComponentInChildren(typeof(Text))
        if btnText ~= nil then
            btnText.text = Runtime.Translate(textKey)
        end
    end
    if isForceUpdate then
        self.text_title.text = Runtime.Translate("update_outdated_title")
        self.text_content.text = Runtime.Translate("update_outdated_des")
    else
        self.text_title.text = Runtime.Translate("update_newVersion_title")
        self.text_content.text = Runtime.Translate("update_newVersion_des")
        set_btn_text(self.btn_update, "update_newVersion_button_update")
        set_btn_text(self.btn_cancel, "update_newVersion_button_later")
    end
end

return TeamMapAppUpdatePanel
