---@type PetTemplateTool
local PetTemplateTool = require "Cleaner.Entity.Pet.PetTemplateTool"

---@class PetIllustratedTeamEditor
local PetIllustratedTeamEditor = {
    petIllustratedPanel = nil,
    teamEditor = nil
}


function PetIllustratedTeamEditor:refreshUI(petIllustratedPanel, teamEditor, pet)
    self.petIllustratedPanel = petIllustratedPanel
    self.teamEditor = teamEditor
    self.pet = pet

    self.go = self.teamEditor.gameObject
    self:Show(true)

    local icon = find_component(self.go,'Icon',Image)
    local txtHp = find_component(self.go,'HpBg/txt_hp',Text)
    local txt_attack = find_component(self.go,'AttackBg/txt_attack', Text)
    local txt_level = find_component(self.go, 'txt_level', Text)

    local btn_up = find_component(self.go, 'btn_up', Button)
    local btn_down = find_component(self.go, 'btn_down', Button)
    local btn_upgrade = find_component(self.go, 'btn_upgrade', Button)

    Util.UGUI_AddButtonListener(btn_up, function() self:UpTeamClick() end)
    Util.UGUI_AddButtonListener(btn_down, function() self:DownTeamClick() end)
    Util.UGUI_AddButtonListener(btn_upgrade, function() self:UpGradeClick() end)

    local showUp = (self.pet.up ~= 1)
    btn_up.gameObject:SetActive(showUp)
    btn_down.gameObject:SetActive(not showUp)

    local petId = PetTemplateTool:Getkey(self.pet.type, self.pet.level)
    local petData = AppServices.Meta:Category("PetTemplate")[tostring(petId)]

    icon.sprite = self:GetSprite(petData.icon)

    txtHp.text = tostring(petData.hp)
    local skillId = petData.skillId
    local skillData = AppServices.Meta:Category("SkillTemplate")[tostring(skillId)]
    txt_attack.text = tostring(skillData.attackPower)
    txt_level.text = string.format("Lv%d", self.pet.level)
end

function PetIllustratedTeamEditor:UpTeamClick()
    self:Show(false)
    AppServices.NetPetManager:SendPetUp(self.pet.id)
    self.petIllustratedPanel:PetUpTeam(self.pet)
    MessageDispatcher:SendMessage(MessageType.Pet_Up_Team, self.pet)
end

function PetIllustratedTeamEditor:DownTeamClick()
    self:Show(false)
    AppServices.NetPetManager:SendPedDown(self.pet.id)
    self.petIllustratedPanel:PetDownTeam(self.pet)
end

function PetIllustratedTeamEditor:UpGradeClick()
    self:Show(false)
    self.petIllustratedPanel:CloseBtnClick()
    PanelManager.showPanel(GlobalPanelEnum.PetInfoPanel)
end

function PetIllustratedTeamEditor:Show(value)
    self.go:SetActive(value)
end

function PetIllustratedTeamEditor:GetSprite(spriteName)
    self.petAtlas = App.uiAssetsManager:GetAsset(CONST.ASSETS.G_ITEM_ICONS)
    local sprite = self.petAtlas:GetSprite(spriteName)
    return sprite
end

return PetIllustratedTeamEditor