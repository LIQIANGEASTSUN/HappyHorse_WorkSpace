---
--- Created by Betta.
--- DateTime: 2021/8/10 16:07
---

--当前模型显示情况  1 显示女主和龙 2只显示女主 3只显示宠物
local imgStatus = {
    showAll = 1,
    showPerson = 2,
    showPet = 3
}

--使用者名字列表
local roleNames = {
    [imgStatus.showPerson] = "Femaleplayer",
    [imgStatus.showPet] = "Petdragon",
}

local modelPos = {
    [1] = {
        ["Femaleplayer"] = Vector3(-0.1, -0.05, -0.9),
        ["Petdragon"] = Vector3(0, 0.1, -0.8)
    },
    [2] = Vector3(0.05, -0.05, -0.9),
    [3] = Vector3(0, 0.1, 0)
}

--默认的皮肤ID
local defaultSkin = {
    ["Petdragon"] = "27100",
    ["Femaleplayer"] = "27200",
}

local changeStatus =
{
    setToSet = 1,       --套装切套装
    setToPart = 2,      --套装切部件
    partToSet = 3,      --部件切套装
    partToPart = 4,     --部件切部件
}

local defaultFemalePartSkins = {"27350","27351","27352","27353"}
local _UserInfoPanelBase = require "UI.Settings.UserInfo.View.UI.Base._UserInfoPanelBase"
---@class UserInfoPanel:_UserInfoPanelBase
local UserInfoPanel = class(_UserInfoPanelBase)

local SkinIconItem = require "UI.Settings.UserInfo.View.UI.SkinIconItem"
local CharacterItem = require("UI.Components.CharacterItem")

function UserInfoPanel:ctor()
    self.state = nil
    self.itemList = {}
    ---@type Dictionary<string, skinId> 界面中选中的皮肤map (名字 => 皮肤id)(关闭界面后失效)
    self.curChosenSkinId = {}
    ---@type Dictionary<string, skinId> characterItem  (名字 => 角色Item对象)
    self.characters = {}
    ---@type Dictionary<string, skinMeta> skinMeta  (名字 => skinMeta 该角色所有的皮肤配置)
    self.skinMetas = {}
    ---@type Dictionary<string, skinMeta> (名字 => table 该角色需要展示的皮肤)
    self.showingSkins = {}
    self:CheckCurGoldPassSkin()
end

function UserInfoPanel:onAfterBindView()
    self.imgAvatarRaw = self.go_avatar:FindComponentInChildren("img_avatarRaw", typeof(CS.FaceBookAvatar))
    local uid = AppServices.User:GetUid()
    if uid == RuntimeContext.DEVICE_ID then
        uid = ""
    end
    self:SetUserId(uid)
    self:RefreshRedDot()
    --信息界面目前是只显示女主和宠物所以不需要遍历皮肤配置表获取所有的user 只用遍历roleNames即可
    for _, user in pairs(roleNames) do
        self.characters[user] = CharacterItem.new(user, self.camera, self.rawView)
        local ids = AppServices.SkinLogic:GetUsingSkin(user)

        if ids[1] then
            self.curChosenSkinId[user] = ids[1]
        end

        self.showingSkins[user] = {}
        for _, id in pairs(ids) do
            local meta = AppServices.SkinLogic:GetSkinMeta(id)
            self.showingSkins[user][meta.type] = id
        end
    end

    local targetSkin
    if self.arguments then
        if self.arguments.targetSkin then
            targetSkin = self.arguments.targetSkin
        else
            targetSkin = self.arguments.showArrowSkin
        end
    end

    local toggleKey
    if not targetSkin then
        toggleKey = 1
    else
        local skin = AppServices.SkinLogic:GetSkinMeta(targetSkin)
        toggleKey = table.indexOf(roleNames, skin.user)
    end

    self.toggles[toggleKey].isOn = true

    local function OnAppPause(isPause)
        console.warn(nil, "UserInfoPanel RequestChangeSkin:", isPause)
		if isPause then
            self:RequestChangeSkin()
		end
	end
	self.OnAppPause = OnAppPause
	App:AddAppOnPauseCallback(self.OnAppPause)
end

function UserInfoPanel:refreshUI()
    self:InitUserInfo()
end

function UserInfoPanel:InitUserInfo()
    local userManager = AppServices.User
    self.text_name.text = userManager:GetNickName()
    -- self.text_level.text = userManager:GetCurrentLevelId()
    self:ChangeAvatar()
    self:ChangeAvatarFrame()
end

function UserInfoPanel:SwitchState(newState)
    if self.state and self.state == newState then
        return
    end
    self.state = newState

    local showAll = self.state == imgStatus.showAll
    self.title_model:SetActive(not showAll)
    self.skins:SetActive(self.state == imgStatus.showPet)
    self.curUser = roleNames[self.state]
    if self.arguments and self.arguments.targetSkin then
        self:SetCurChosenSkinId(self.arguments.targetSkin)
    end
    console.lh("state:", self.state)    --@DEL
    self:ChangeCharacter(showAll)
end

function UserInfoPanel:GetUserSkinsMeta()
    if not self.skinMetas[self.curUser] then
        local metas = AppServices.SkinLogic:GetUserSkinMeta(self.curUser)
        self.skinMetas[self.curUser] = metas
    end
    return self.skinMetas[self.curUser]
end

function UserInfoPanel:RefreshIconList()
    local metas = self:GetUserSkinsMeta()
    local list = {}
    for _, cfg in pairs(metas) do
        local openTime = cfg.openTime
        if string.isEmpty(openTime) or tonumber(openTime) <= TimeUtil.ServerTime() then
            table.insert(list, cfg)
        end
    end
    self.dataList = list

    table.sort(list, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)

    self.itemList = {}
    local targetIdx
    if self.arguments and self.arguments.targetSkin then
        local skin = AppServices.SkinLogic:GetSkinMeta(self.arguments.targetSkin)
        targetIdx = table.indexOf(list, skin)
        self.arguments.targetSkin = nil
    end

    --创建最大显示数量的item
    local function onCreateItemCallback(key)
        local item = SkinIconItem.Create(self)
        self.itemList[key] = item
        return item.gameObject
    end

    --滑动时更新变动的item数据
    local function onUpdateInfoCallback(key, index)
        self.itemList[key]:Show(list[index], key)
        if targetIdx == key then
            self.itemList[key]:OnClick()
        end
    end

    if targetIdx and #self.itemList >= 3 then
        self.skin_ScrollRect:InitList(#list, onCreateItemCallback, onUpdateInfoCallback, nil, targetIdx, 0)
    else
        self.skin_ScrollRect:InitList(#list, onCreateItemCallback, onUpdateInfoCallback)
    end
end

function UserInfoPanel:RefreshModelDesc()
    local showAll = self.state == imgStatus.showAll
    if showAll then
        self.btn_get:SetActive(false)
        self.txt_desc:SetActive(false)
        return
    end
    local skinId = self:GetUserChosenSkinId(self.curUser)
    local isObtained = AppServices.SkinLogic:IsSkinPurchased(skinId)
    local showGetBtn = false
    if not isObtained then
        local skinMeta = AppServices.SkinLogic:GetSkinMeta(skinId)
        if skinMeta then
            if skinMeta.getWay == 1 then
                local isAvailable = tostring(self.curGoldPassSkin) == skinId
                showGetBtn = isAvailable
            elseif skinMeta.getWay == 2 then
                showGetBtn = AppServices.GiftManager:GetGiftInstance(skinMeta.getWayParam) ~= nil
            end
        end
    end
    self.btn_get:SetActive(showGetBtn)
    self.txt_desc:SetActive(not showGetBtn)
    if not showGetBtn and self.state ~=2 then
        local desc_key = AppServices.SkinLogic:GetSkinMeta(skinId).desc
        self.txt_desc.text = Runtime.Translate(desc_key)
    else
        self.txt_desc.text = ""
    end
end

function UserInfoPanel:ChangeCharacter(showAll)
    if showAll then
        self:ShowAllCharacters()
    else
        self:ShowSingleCharacter(function()
            self:RefreshIconList()
        end)
    end
end

function UserInfoPanel:ShowAllCharacters()
    for k, user in pairs(roleNames) do
        local skinIds = self:GetShowingSkin(user)
        local skinMetas = {}
        for _, id in pairs(skinIds) do
            local meta = AppServices.SkinLogic:GetSkinMeta(id)
            table.insert(skinMetas, meta)
        end
        local animName = user == "Femaleplayer" and "IdleHi_UI" or "info_withCynthia"
        self.characters[user]:Show(skinMetas, modelPos[1][user], animName, function()
            self.characters[user]:SetDragMask()
            self.characters[user]:SetActive(true)
            self:RefreshModelDesc()
            self:SetShowing(false)
        end)
    end
    self.skinParts:Hide()
end

function UserInfoPanel:ShowSingleCharacter(callback)
    local user = self.curUser
    local skinIds = self:GetShowingSkin(user)
    local skinMetas = {}
    for _, id in pairs(skinIds) do
        local meta = AppServices.SkinLogic:GetSkinMeta(id)
        table.insert(skinMetas, meta)
    end
    local animName
    if user == "Femaleplayer" then
        animName = "IdleHi_UI"
    end
    self.characters[user]:Show(skinMetas, modelPos[self.state], animName, function()
        for u, c in pairs(self.characters) do
            c:SetActive(u == user)
        end
        self.characters[user]:SetDragMask(self.dragMask)
        self:RefreshModelDesc()
        local skinId = self:GetUserChosenSkinId(user)
        local meta = AppServices.SkinLogic:GetSkinMeta(skinId)
        self.title_model.text = Runtime.Translate(meta.name)
        Runtime.InvokeCbk(callback)
    end)
    if self.state == 2 then
        self.skinParts:Show()
        if (self.arguments or {}).showArrowSkin then
            self.arguments.showArrowSkin = nil
        end
    else
        self.skinParts:Hide()
    end
end

function UserInfoPanel:ChangePart(info)
    if not info then
        return
    end
    self:SetCurChosenSkinId(info.id)
    local skinIds = self:GetShowingSkin(self.curUser)
    local skinMetas = {}
    for _, id in pairs(skinIds) do
        local meta = AppServices.SkinLogic:GetSkinMeta(id)
        table.insert(skinMetas, meta)
    end
    local animName
    if self.curUser == "Femaleplayer" then
        animName = "IdleHi_UI"
    end
    self.characters[self.curUser]:Show(skinMetas, modelPos[self.state], animName, function()
        for user, c in pairs(self.characters) do
            c:SetActive(user == self.curUser)
        end
        self.characters[self.curUser]:SetDragMask(self.dragMask)
        self:RefreshModelDesc()
        self.title_model.text = Runtime.Translate(info.name)
    end)
end

function UserInfoPanel:GetUserChosenSkinId(user)
    user = user or self.curUser
    return self.curChosenSkinId[user] or defaultSkin[user]
end

function UserInfoPanel:SetCurChosenSkinId(id)
    self.curChosenSkinId[self.curUser] = id
    self:SetShowingSkin(id)
end

function UserInfoPanel:SetShowingSkin(id)
    local skinMeta = AppServices.SkinLogic:GetSkinMeta(id)
    if not skinMeta then
        return
    end
    local curShowingSkins = self.showingSkins[skinMeta.user]
    local mType = skinMeta.type
    local isSetSkin_new = mType == SkinType.Pet or mType == SkinType.FemalePlayer
    local isSetSkin_old
    for _, id in pairs(curShowingSkins) do
        local meta = AppServices.SkinLogic:GetSkinMeta(id)
        local mType = meta.type
        if mType == SkinType.Pet or mType == SkinType.FemalePlayer then
            isSetSkin_old = true
            break
        end
    end

    local state
    if isSetSkin_new and isSetSkin_old then
        state = changeStatus.setToSet
    elseif not isSetSkin_new and isSetSkin_old then
        state = changeStatus.setToPart
    elseif isSetSkin_new and not isSetSkin_old then
        state = changeStatus.partToSet
    else
        state = changeStatus.partToPart
    end

    if state == changeStatus.setToSet or state == changeStatus.partToPart then
        self.showingSkins[skinMeta.user][skinMeta.type] = id
    end
    if state == changeStatus.setToPart then
        self.showingSkins[skinMeta.user] = {}
        for _, skinId in pairs(defaultFemalePartSkins) do
            local meta = AppServices.SkinLogic:GetSkinMeta(skinId)
            self.showingSkins[skinMeta.user][meta.type] = skinId
        end
        self.showingSkins[skinMeta.user][skinMeta.type] = id
    end

    if state == changeStatus.partToSet then
        self.showingSkins[skinMeta.user] = {}
        self.showingSkins[skinMeta.user][skinMeta.type] = id
    end
end

function UserInfoPanel:GetShowingSkin(user)
    return self.showingSkins[user]
end

function UserInfoPanel:RefreshItemsChosenState(key)
    for k, v in pairs(self.itemList) do
        if key ~= k and Runtime.CSValid(v.gameObject) then
            v:ShowChosenFrame(false)
        end
    end
end

function UserInfoPanel:RefreshItemsDoneState(key)
    for k, v in pairs(self.itemList) do
        if key ~= k and Runtime.CSValid(v.gameObject) then
            v:ShowChosenCheck(false)
        end
    end
end

function UserInfoPanel:SetUserId(userId)
    self.txt_id.text = userId
end

function UserInfoPanel:GetCharacters()
    return self.characters
end

function UserInfoPanel:GetCurUser()
    return self.curUser
end

function UserInfoPanel:ChangeAvatarFrame()
    AppServices.AvatarFrame:SetAvatarFrame(self.avatar_frame, self.frame_bg)
end

function UserInfoPanel:ChangeAvatar()
    AppServices.Avatar:ShowAvatar(self.img_avatar, self.img_avatarFB)
end

function UserInfoPanel:IsShowing()
    return self.isShowing
end

function UserInfoPanel:SetShowing(val)
    self.isShowing = val
end

function UserInfoPanel:CheckCurGoldPassSkin()
    if not self.curGoldPassSkin then
        if not ActivityServices.GoldPass:IsDataNotEmpty() then
            self.curGoldPassSkin = -1
            return
        end
        local meta = ActivityServices.GoldPass:GetLevelMetaTable()
        if not meta then
            self.curGoldPassSkin = -1
            return
        end
        for _, cfg in pairs(meta) do
            if cfg.vipType == GoldPassRewardKind.Skin then
                self.curGoldPassSkin = cfg.vipItem[1]
                return
            end
        end
        if not self.curGoldPassSkin then
            self.curGoldPassSkin = -1
            return
        end
    end
end

-- function UserInfoPanel:SetSkinAfterRequest()
    -- if not table.isEmpty(self.skinsIdsForRequest) then
    --     for _, id in pairs(self.skinsIdsForRequest) do
    --         AppServices.SkinLogic:SetSkin(id)
    --     end
    --     self.skinsIdsForRequest = {}
    -- end
-- end

function UserInfoPanel:onAfterResumePanel()
    if Runtime.CSValid(self.skin_ScrollRect) then
        self.skin_ScrollRect:MoveTargetItemByIndex(1, 0.3)
    end
    -- self:SetSkinAfterRequest()
end

function UserInfoPanel:RequestChangeSkin(callback)
    local characters = self:GetCharacters()
    local skinsIdsForRequest = {}
    for name, _ in pairs(characters) do
        local skinIds = self:GetShowingSkin(name)
        for _, id in pairs(skinIds) do
            local inUse = AppServices.SkinLogic:IsSkinInUse(id)
            local isAvailable = AppServices.SkinLogic:IsSkinPurchased(id)
            if not inUse and isAvailable then
                table.insert(skinsIdsForRequest, id)
            end
        end
    end

    if table.isEmpty(skinsIdsForRequest) then
       return Runtime.InvokeCbk(callback)
    end

    local function onResponse(result)
        -- if result then
        --     self:SetSkinAfterRequest()
        -- end
        return Runtime.InvokeCbk(callback)
    end
    AppServices.SkinLogic:ChangeSkinRequest(skinsIdsForRequest, onResponse)
end

function UserInfoPanel:RefreshRedDot()
    self.hasReddot = AppServices.RedDotManage:GetRed("HeadInfo")
    self.reddot:SetActive(self.hasReddot)
end

function UserInfoPanel:RefreshSkinReddot(name)
    if self.toggleReddot[name] then
        local hasReddot = AppServices.RedDotManage:GetRed(name)
        self.toggleReddot[name]:SetActive(hasReddot)
    end
end

function UserInfoPanel:GetGuidePlayerHatSkinButton1()
    return  self.toggles[2].gameObject
end

function UserInfoPanel:GuidePlayerHatSkinTarget()
    local targetIdx = -1
    for index, config in ipairs(self.skinParts.showConfigs) do
        if config.id == "27303" then
            targetIdx = index
        end
    end
    if targetIdx > 0 then
        self.skinParts.itemScrollList:MoveTargetItemByIndex_dk(targetIdx, 0, function()
            App.mapGuideManager:OnGuideFinishEvent(GuideEvent.CustomEvent, "GuidePlayerHatSkinTarget")
        end)
    end
end

function UserInfoPanel:GetGuidePlayerHatSkinButton2()
    for _, item in pairs(self.skinParts.itemList) do
        if item.data.id == "27303" then
            return item.gameObject
        end
    end
end

function UserInfoPanel:OnRelease()
    self.skinParts:Dispose()
end

return UserInfoPanel