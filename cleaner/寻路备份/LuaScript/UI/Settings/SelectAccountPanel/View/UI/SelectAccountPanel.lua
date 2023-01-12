--insertWidgetsBegin
--	img_title	btn_close
--insertWidgetsEnd

--insertRequire
local _SelectAccountPanelBase = require "UI.Settings.SelectAccountPanel.View.UI.Base._SelectAccountPanelBase"

local SelectAccountPanel = class(_SelectAccountPanelBase)

function SelectAccountPanel:ctor()
end

function SelectAccountPanel:onAfterBindView()
    self.selectInfo = self.arguments.selectInfo
    self:refreshUI()
end

function SelectAccountPanel:refreshUI()
    local function Show(name,index)
        local level = self.gameObject:FindGameObject(name.."/level/Text"):GetComponent(typeof(Text))
        level.text = Runtime.Translate("ui_chooseprogress_LV",{num = tostring(self.selectInfo[index].level)})

        local txt_diamond = self.gameObject:FindGameObject(name.."/diamond/Text"):GetComponent(typeof(Text))
        txt_diamond.text = self.selectInfo[index].diamond

        --上次登陆时间
        local txt_time = self.gameObject:FindGameObject(name.."/lastLogin/text_time"):GetComponent(typeof(Text))
        txt_time.text = self.selectInfo[index].time and TimeUtil.GetTimeString(self.selectInfo[index].time/1000) or ""

        local txt_name = self.gameObject:FindGameObject(name.."/txt_name"):GetComponent(typeof(Text))
        txt_name.text = self.selectInfo[index].name or ""
    end

    Show("left",1)
    Show("right",2)
end


return SelectAccountPanel
