
---@class SkinIconItem
local SkinIconItem = class("SkinIconItem")

function SkinIconItem.Create(canvas)
    local instance = SkinIconItem.new(canvas)
    local go = BResource.InstantiateFromAssetName("Prefab/UI/UserInfo/SkinIconItem.prefab")
    instance.canvas = canvas
    instance:InitWithGameObject(go)
    return instance
end

function SkinIconItem:ctor()
    self.data = {}
    self.active = true
    self.isFinished = false
end

function SkinIconItem:InitWithGameObject(go)
    self.gameObject = go
    self.bg = find_component(self.gameObject, "bg")
    self.img_chosen = find_component(self.bg, "chosen")
    self.txt_title = find_component(self.bg, "title", Text)
    self.icon = find_component(self.bg, "icon", Image)
    self.img_check = find_component(self.bg, "check", Image)
    self.img_lock = find_component(self.bg, "lock", Image)
    self.skinReddot = find_component(self.bg, "reddot")
    Util.UGUI_AddButtonListener(self.bg, function()
        self:OnClick()
    end)
end

function SkinIconItem:Show(data, key)
    self.key = key
    self.data = data
    self.id = data.id
    local name = self.data.name
    GameUtil.ShowLimitStringWithDots(self.txt_title, Runtime.Translate(name))
    self.icon.sprite = AppServices.ItemIcons:GetSprite(self.id)
    self.isUnlock = AppServices.SkinLogic:IsSkinPurchased(self.id)
    self.img_lock:SetActive(not self.isUnlock)
    local user = self.canvas:GetCurUser()
    local chosenId = self.canvas:GetUserChosenSkinId(user)
    local isChosen = self.id == chosenId
    self.img_check:SetActive(self.isUnlock and isChosen)
    self.img_chosen:SetActive(isChosen)

    self:RefreshReddot()
end

function SkinIconItem:RefreshReddot()
    self.newList = AppServices.User.Default:GetKeyValue("newPetSkin", {})
    self.hasReddot = table.indexOf(self.newList, self.id)
    self.skinReddot:SetActive(self.hasReddot)
end

function SkinIconItem:ShowChosenFrame(val)
    self.img_chosen:SetActive(val)
end

function SkinIconItem:ShowChosenCheck(val)
    self.img_check:SetActive(val)
end

function SkinIconItem:OnClick()
    if self.canvas:IsShowing() then
        return
    end
    if self.canvas:GetUserChosenSkinId() == self.id then
        return
    end
    self.canvas:SetShowing(true)
    self.img_chosen:SetActive(true)
    self.img_check:SetActive(self.isUnlock)
    self.canvas:SetCurChosenSkinId(self.id)
    self.canvas:ShowSingleCharacter(function()
        self.canvas:SetShowing(false)
    end)
    self.canvas:RefreshItemsChosenState(self.key)
    if self.isUnlock then
        self.canvas:RefreshItemsDoneState(self.key)
    end

    if self.hasReddot then
        table.removeIfExist(self.newList, self.id)
        self.skinReddot:SetActive(false)
        AppServices.User.Default:SetKeyValue("newPetSkin", self.newList,true)
        AppServices.RedDotManage:FreshDate_Count("newPetSkin",-1)
    end
end

return SkinIconItem
