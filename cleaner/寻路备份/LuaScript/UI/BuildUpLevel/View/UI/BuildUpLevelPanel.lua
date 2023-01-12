--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _BuildUpLevelPanelBase = require "UI.BuildUpLevel.View.UI.Base._BuildUpLevelPanelBase"

---@class BuildUpLevelPanel:_BuildUpLevelPanelBase
local BuildUpLevelPanel = class(_BuildUpLevelPanelBase)

function BuildUpLevelPanel:ctor()

end

function BuildUpLevelPanel:SetArguments(arguments)
    self.arguments = arguments
end

function BuildUpLevelPanel:refreshUI()
    self.txt_title.text = "升级成功"

    local sn = self.arguments.sn
    local level = self.arguments.level
    local buildingLvCfg = AppServices.BuildingLevelTemplateTool:GetConfig(sn, level - 1)

    self.txt_up_info.text = string.format("%s从%d级升级到%d级", buildingLvCfg.name, level - 1, level)
end

return BuildUpLevelPanel
