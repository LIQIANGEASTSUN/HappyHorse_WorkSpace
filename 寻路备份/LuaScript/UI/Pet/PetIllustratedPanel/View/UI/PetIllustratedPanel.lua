local _PetIllustratedPanelBase = require "UI.Pet.PetIllustratedPanel.View.UI.Base._PetIllustratedPanelBase"

---@type PetBattleTeamPanel
local PetBattleTeamPanel = require "UI.Pet.PetIllustratedPanel.View.UI.PetBattleTeamPanel"

---@type PetIllustratedGroupPanel
local PetIllustratedGroupPanel = require "UI.Pet.PetIllustratedPanel.View.UI.PetIllustratedGroupPanel"

---@type PetIllustratedTeamEditor
local PetIllustratedTeamEditor =  require "UI.Pet.PetIllustratedPanel.View.UI.PetIllustratedTeamEditor"

---@class PetIllustratedPanel:_PetIllustratedPanelBase
local PetIllustratedPanel = class(_PetIllustratedPanelBase)

function PetIllustratedPanel:ctor()

end

function PetIllustratedPanel:onAfterBindView()

end

function PetIllustratedPanel:SetArguments(arguments)
    self.arguments = arguments
end

function PetIllustratedPanel:refreshUI()
    -- 从别的地方打开上阵
    -- self.arguments self.arguments.editorPetId

    local illustratedGroup = { typeParent = self.illustratedContent, illustratedType = self.illustratedType}
    PetIllustratedGroupPanel:refreshUI(self, illustratedGroup)

    PetBattleTeamPanel:refreshUI(self, self.battleTeam)
end

function PetIllustratedPanel:ShowTeamEditorUp(pet)
    local enableTakeCount = PetBattleTeamPanel:GetPlayerLevelTakeCount()
    local takeCount = PetBattleTeamPanel:GetTakeCount()
    if takeCount >= enableTakeCount then
        local msg = string.format("当前玩家等级最多携带%d个宠物", enableTakeCount)
        AppServices.UITextTip:Show(msg)
        return
    end
    PetIllustratedTeamEditor:refreshUI(self, self.teamEditor, pet)
end

function PetIllustratedPanel:ShowTeamEditorDown(pet)
    PetIllustratedTeamEditor:refreshUI(self, self.teamEditor, pet)
end

function PetIllustratedPanel:PetUpTeam(pet)
    PetBattleTeamPanel:AddToTeam(pet)
    PetIllustratedGroupPanel:AddToTeam(pet)
end

function PetIllustratedPanel:PetDownTeam(pet)
    PetBattleTeamPanel:DownFromTeam(pet)
    PetIllustratedGroupPanel:DownFromTeam(pet)
end

function PetIllustratedPanel:CloseBtnClick()
    PanelManager.closePanel(GlobalPanelEnum.PetIllustratedPanel, nil)
end

function PetIllustratedPanel:Hide()
    PetIllustratedGroupPanel:Hide()
end

return PetIllustratedPanel