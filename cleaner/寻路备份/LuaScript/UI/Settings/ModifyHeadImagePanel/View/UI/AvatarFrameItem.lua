---@class AvatarFrameItem:LuaUiBase
local AvatarFrameItem = class(LuaUiBase,"AvatarFrameItem")

function AvatarFrameItem.Create(canvas)
    local instance = AvatarFrameItem.new()
    local go = BResource.InstantiateFromAssetName("Prefab/UI/UserInfo/ModifyHeadImage/AvatarFrameItem.prefab")
    instance:CreateWithGameObject(go, canvas)
    return instance
end

function AvatarFrameItem:CreateWithGameObject(go, canvas)
    self.canvas = canvas
    self.gameObject = go
    self.transform = self.gameObject.transform
    self.frame = find_component(self.gameObject, "frame", Image)
    self.img_chosen = find_component(self.gameObject, "chosen")
    self.img_lock = find_component(self.gameObject, "lock")
    self.img_reddot = find_component(self.gameObject, "reddot", Image)
    self.go_checkMark = find_component(self.gameObject, "checkMark")
    local function onClick()
        local curChosenFrame = self.canvas:GetChosenFrame()
        if curChosenFrame == self.id then
            return
        end
        local list = AppServices.User.Default:GetKeyValue("AvatarFrame", {})
        if list[self.id] then
            list[self.id] = nil
            AppServices.User.Default:SetKeyValue("AvatarFrame", list, true)
            self.img_reddot:SetActive(false)
        end
        self.canvas:SetChosenFrame(self.id)
        self.canvas:RefreshAvatarDesc(self.id)
        sendNotification(ModifyHeadImagePanelNotificationEnum.Select_New_AvatarFrame, {oldFrame = curChosenFrame, newFrame = self.id})
    end
    Util.UGUI_AddButtonListener(self.gameObject, onClick)
end

function AvatarFrameItem:Show(data, curFrame)
    self.id = data.id
    local spriteName = data.icon
    local sprite = AppServices.ItemIcons:GetFriendIconSprite(spriteName)
    self.frame.sprite = sprite
    local isUnlock = AppServices.AvatarFrame:IsFrameUnlock(self.id)
    self.img_lock:SetActive(not isUnlock)
    local list = AppServices.User.Default:GetKeyValue("AvatarFrame", {})
    self.img_reddot:SetActive(list[self.id])
    self:MarkChosen(self.id == curFrame)
    self:ShowCheckMark(self.id == curFrame)
end

function AvatarFrameItem:MarkChosen(_bool)
    self.img_chosen:SetActive(_bool)
end

function AvatarFrameItem:ShowCheckMark(_bool)
    self.go_checkMark:SetActive(_bool)
end

return AvatarFrameItem