---@class HeadImageItem:LuaUiBase
local HeadImageItem = class(LuaUiBase,"HeadImageItem")

function HeadImageItem.Create(canvas)
    local instance = HeadImageItem.new()
    local go = BResource.InstantiateFromAssetName("Prefab/UI/UserInfo/ModifyHeadImage/headImageItem.prefab")
    instance:CreateWithGameObject(go, canvas)
    return instance
end

function HeadImageItem:CreateWithGameObject(go, canvas)
    self.canvas = canvas
    self.gameObject = go
    self.transform = self.gameObject.transform
    self.go_checkMark = self.transform:Find("checkMark").GameObject
    self.img_icon = find_component(self.gameObject, "icon", Image)
    self.img_chosen = find_component(self.gameObject, "chosen")
    self.img_lock = find_component(self.gameObject, "lock")
    self.img_reddot = find_component(self.gameObject, "reddot", Image)
    self.go_checkMark = find_component(self.gameObject, "checkMark")
    local function onClick()
        local curChosenAvatar = self.canvas:GetChosenAvatar()
        if curChosenAvatar == self.id then
            return
        end
        local list = AppServices.User.Default:GetKeyValue("NewAvatar", {})
        if list[self.id] then
            list[self.id] = nil
            AppServices.User.Default:SetKeyValue("NewAvatar", list, true)
            self.img_reddot:SetActive(false)
        end
        self.canvas:SetChosenAvatar(self.id)
        self.canvas:RefreshAvatarDesc(self.id)
        sendNotification(ModifyHeadImagePanelNotificationEnum.Select_New_HeadImage, {oldAvatar = curChosenAvatar, newAvatar = self.id})
    end
    Util.UGUI_AddButtonListener(self.gameObject, onClick)
end

function HeadImageItem:Show(data, curAvatar)
    self.id = data.id
    local spriteName = data.icon
    local sprite = AppServices.ItemIcons:GetFriendIconSprite(spriteName)
    self.img_icon.sprite = sprite
    local isUnlock = AppServices.Avatar:IsAvatarUnlock(self.id)
    self.img_lock:SetActive(not isUnlock)
    local list = AppServices.User.Default:GetKeyValue("NewAvatar", {})
    self.img_reddot:SetActive(list[self.id])
    self:MarkChosen(self.id == curAvatar)
    self:ShowCheckMark(self.id == curAvatar)
end

function HeadImageItem:MarkChosen(_bool)
    self.img_chosen:SetActive(_bool)
end

function HeadImageItem:ShowCheckMark(_bool)
    if self.isFbRecommandMode then return end

    -- self.go_glow:SetActive(_bool)
    self.go_checkMark:SetActive(_bool)
end

return HeadImageItem