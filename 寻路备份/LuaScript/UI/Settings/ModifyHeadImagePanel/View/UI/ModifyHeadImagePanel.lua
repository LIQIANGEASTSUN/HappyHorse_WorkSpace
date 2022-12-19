local stateLis = {
    showHeadImage = 1,
    showAvatarFrame = 2,
}
local _ModifyHeadImagePanelBase = require "UI.Settings.ModifyHeadImagePanel.View.UI.Base._ModifyHeadImagePanelBase"
local HeadImageItem = require "UI.Settings.ModifyHeadImagePanel.View.UI.HeadImageItem"
local AvatarFrameItem = require "UI.Settings.ModifyHeadImagePanel.View.UI.AvatarFrameItem"

---@class ModifyHeadImagePanel
local ModifyHeadImagePanel = class(_ModifyHeadImagePanelBase)

function ModifyHeadImagePanel:ctor()
	self.headItems = {}
    self.frameList = {}
    self.cfgs = {}
    self.state = nil
end

function ModifyHeadImagePanel:onAfterBindView()
    self.img_avatarRaw = find_component(self.go_avatar, "img_avatarRaw", typeof(CS.FaceBookAvatar))
    -- UITool.ShowSelfHead(self.img_avatar, self.img_avatarRaw)
    AppServices.Avatar:ShowAvatar(self.img_avatar, self.img_avatarRaw)
    self.frameCfgs = AppServices.AvatarFrame:GetFrameMetaTable()
    self.avatarCfgs = AppServices.Avatar:GetAvatarMetaTable()
    local frame = AppServices.AvatarFrame:GetUsingFrame()
    self:ChangePanelAvatarFrame(frame)
    self.toggles[1].isOn = true
end

function ModifyHeadImagePanel:refreshUI()
end

function ModifyHeadImagePanel:SwitchState(newState)
    if self.state and newState == self.state then
        return
    end
    self.state = newState

    local showHead = self.state == stateLis.showHeadImage
    self.head_scrollList:SetActive(showHead)
    self.frame_scrollList:SetActive(not showHead)
    if showHead then
        self:InitHeadImages()
    else
        self:InitAvatarFrames()
    end
end

function ModifyHeadImagePanel:InitHeadImages()
    if self.headImgInited then
        return
    end
    self.headImgInited = true
    local curAvatarId = AppServices.Avatar:GetUsingAvatar() --- 当前头像Id
    print("ModifyHeadImagePanel.InitHeadImages:current image num",curAvatarId) --@DEL
    self:RefreshAvatarDesc(curAvatarId)
    self.chosenAvatar = curAvatarId
    -- if not BCore.IsDisable("FaceBookLogin") then
    --     --self:InitFbHead(curImageNum, callback)
    -- end
    -- local len = table.len(self.avatarCfgs)
    -- for i = 1, len do
    --     local curType = tostring(i)

    --     local spriteName = self.avatarCfgs[tostring(i)].icon
    --     local sprite = AppServices.ItemIcons:GetFriendIconSprite(spriteName)
    --     local fbRecommand = false

    --     local template_res = "Prefab/UI/UserInfo/ModifyHeadImage/headImageItem.prefab"

    --     local go = BResource.InstantiateFromAssetName(template_res)

    --     local item =  HeadImageItem:Create()
    --     item:Init(go, sprite, i, fbRecommand)
    --     local function selectCallback()
    --         self:RefreshAvatarDesc(tostring(i))
    --         sendNotification(ModifyHeadImagePanelNotificationEnum.Select_New_HeadImage, {newNum = curType})
    --     end
    --     item:SetCallback(selectCallback)
    --     item:SetParent(self.tf_itemContent.transform)
    --     item:MarkChosen(curImageNum == curType)
    --     item:ShowCheckMark(curImageNum == curType)
    --     self.headItems[curType] = item
    -- end
    local avatarMeta = {}
    for _, cfg in pairs(self.avatarCfgs) do
        table.insert(avatarMeta, cfg)
    end
    table.sort(avatarMeta, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)

    --创建最大显示数量的item
    local function onCreateItemCallback(key)
        local item = HeadImageItem.Create(self)
        self.headItems[key] = item
        return item.gameObject
    end

    --滑动时更新变动的item数据
    local function onUpdateInfoCallback(key, index)
        self.headItems[key]:Show(avatarMeta[index], curAvatarId)
    end

    self.head_scrollList:InitList(#avatarMeta, onCreateItemCallback, onUpdateInfoCallback)
end

function ModifyHeadImagePanel:InitFbHead(curImageNum)
    local curType = CONST.GAME.HEADIMAGE_FACEBOOK_AVATAR_NUM

    local fbRecommand = false

    local template_res = "Prefab/UI/UserInfo/ModifyHeadImage/headImageItem.prefab"
    if not AppServices.User:HaveFbAccount() then
        template_res = "Prefab/UI/UserInfo/ModifyHeadImage/headImageItem_fb.prefab"
        fbRecommand = true
    end
    local go = BResource.InstantiateFromAssetName(template_res)

    local item =  HeadImageItem:Create()
    item:Init(go, nil, 0, fbRecommand)

    local function selectCallback()
        sendNotification(ModifyHeadImagePanelNotificationEnum, {newNum = curType})
    end
    item:SetCallback(selectCallback)
    item:SetParent(self.tf_itemContent)
    go.transform:SetSiblingIndex(0)
    item:MarkChosen(curImageNum == curType)
    item:ShowCheckMark(curImageNum == curType)

    self.headItems[curType] = item
end

function ModifyHeadImagePanel:InitAvatarFrames()
    if self.avatarFrameInited then
        return
    end
    self.avatarFrameInited = true
    local curFrame = AppServices.AvatarFrame:GetUsingFrame()  --curFrame string 当前使用的头像框Id
    print("ModifyHeadImagePanel.InitAvatarFrames:current image num",curFrame) --@DEL
    self.chosenFrame = curFrame
    self:RefreshAvatarDesc(curFrame)
    local frameMeta = {}
    for _, cfg in pairs(self.frameCfgs) do
        local openTime = cfg.openTime
        if string.isEmpty(openTime) then
            table.insert(frameMeta, cfg)
        elseif tonumber(openTime) <= TimeUtil.ServerTime() then
            table.insert(frameMeta, cfg)
        end
    end
    table.sort(frameMeta, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)
    --创建最大显示数量的item
    local function onCreateItemCallback(key)
        local item = AvatarFrameItem.Create(self)
        self.frameList[key] = item
        return item.gameObject
    end

    --滑动时更新变动的item数据
    local function onUpdateInfoCallback(key, index)
        self.frameList[key]:Show(frameMeta[index], curFrame)
    end

    self.frame_scrollList:InitList(#frameMeta, onCreateItemCallback, onUpdateInfoCallback)
end

function ModifyHeadImagePanel:OnLogin(curImageNum)
    local item = self.headItems[CONST.GAME.HEADIMAGE_FACEBOOK_AVATAR_NUM]
    if item ~= nil then
        BResource.DestroyGameObject(item.gameObject)
    end
    self.headItems[CONST.GAME.HEADIMAGE_FACEBOOK_AVATAR_NUM] = nil
    self:InitFbHead(curImageNum)
end

function ModifyHeadImagePanel:OnSelectAvatar(oldAvatar, newAvatar)
    local isNewAvatarUnlock = AppServices.Avatar:IsAvatarUnlock(tostring(newAvatar))
    local cnt = 2
    for _, v in pairs(self.headItems) do
        if cnt == 0 then
            break
        end

        if v.id == oldAvatar then
            v:MarkChosen(false)
            v:ShowCheckMark(not isNewAvatarUnlock)
            cnt = cnt - 1
        end
        if v.id == newAvatar then
            v:MarkChosen(true)
            v:ShowCheckMark(isNewAvatarUnlock)
            cnt = cnt - 1
        end
    end
    self:ChangePanelAvatar(newAvatar)
end

function ModifyHeadImagePanel:OnSelectAvatarFrame(oldFrame, newFrame)
    local isUnlock =AppServices.AvatarFrame:IsFrameUnlock(newFrame)
    local cnt = 2
    for _, v in pairs(self.frameList) do
        if cnt == 0 then
            break
        end

        if v.id == oldFrame then
            v:MarkChosen(false)
            v:ShowCheckMark(false)
            cnt = cnt - 1
        end
        if v.id == newFrame then
            v:MarkChosen(true)
            v:ShowCheckMark(isUnlock)
            cnt = cnt - 1
        end
    end
    self:ChangePanelAvatarFrame(newFrame)
end

function ModifyHeadImagePanel:ChangePanelAvatarFrame(frameId)
    local spriteName = self.frameCfgs[frameId].icon
    local sprite = AppServices.ItemIcons:GetFriendIconSprite(spriteName)
    self.img_avatarFrame.sprite = sprite
end

function ModifyHeadImagePanel:ChangePanelAvatar(avatarId)
    local spriteName = self.avatarCfgs[avatarId].icon
    local sprite = AppServices.ItemIcons:GetFriendIconSprite(spriteName)
    self.img_avatar.sprite = sprite
end

function ModifyHeadImagePanel:SetChosenFrame(frameId)
    self.chosenFrame = frameId
end

function ModifyHeadImagePanel:GetChosenFrame()
    return self.chosenFrame
end

function ModifyHeadImagePanel:SetChosenAvatar(avatarId)
    self.chosenAvatar = avatarId
end

function ModifyHeadImagePanel:GetChosenAvatar()
    return self.chosenAvatar
end

function ModifyHeadImagePanel:RefreshAvatarDesc(id)
    if not self.cfgs[self.state] then
        self.cfgs[self.state] = self.state == stateLis.showHeadImage and self.avatarCfgs or self.frameCfgs
    end
    local cfg = self.cfgs[self.state][id]
    local key_name, key_desc = cfg.name, cfg.desc
    self.txt_headName.text = Runtime.Translate(key_name)
    self.txt_avatarDesc.text = Runtime.Translate(key_desc)
end

return ModifyHeadImagePanel
