local BaseIconButton = require "UI.Components.BaseIconButton"

---@class UserInfoWidget:BaseIconButton
local UserInfoWidget = class(BaseIconButton, "UserInfoWidget")

function UserInfoWidget.Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_USERINFO)
    return UserInfoWidget:CreateWithGameObject(gameObject)
end

function UserInfoWidget:CreateWithGameObject(gameObject)
    local instance = UserInfoWidget.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function UserInfoWidget:InitWithGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    local experienceGo = find_component(gameObject, "experienceBar")
    self.txtLevel = find_component(experienceGo, "levelBg/txtLevel", Text)
    self.txtExperience = find_component(experienceGo, "txtExperience", Text)

    self:SyncLevel()
    self:SyncExp()

    local function onClickExp()
        UITool.ShowContentTipAni("模块开发中...")
    end
    Util.UGUI_AddButtonListener(experienceGo, onClickExp)

    local btnSetting = find_component(gameObject, "btnSetting")
    local function onClickSetting()
        UITool.ShowContentTipAni("模块开发中...")
        -- DOTO
        PanelManager.showPanel(GlobalPanelEnum.OnHookBuildPanel, nil)
    end
    Util.UGUI_AddButtonListener(btnSetting, onClickSetting)
end

function UserInfoWidget:SyncLevel()
    local level = AppServices.User:GetCurrentLevelId()
    self.txtLevel.text = level
end

function UserInfoWidget:SyncExp()
    local mgr = AppServices.User
    local conf = AppServices.Meta:GetLevelConfig(mgr:GetCurrentLevelId())
    local needExp = conf.exp
    local curExp = mgr:GetExp()
    self.txtExperience.text = string.format("%d/%d", curExp, needExp)
end

function UserInfoWidget:ShowExitAnim(exitImmediate, callback)
    -- local time = 0.5
    -- if exitImmediate then
    --     time = 0
    -- end
    -- local tarPos = self:GetOutsideAnchoredPosition()
    -- local tween = GameUtil.DoAnchorPos(self.rectTransform, tarPos, time)
    -- if callback then
    --     tween:OnComplete(callback)
    -- end
end

function UserInfoWidget:ShowEnterAnim(callback)
    -- local tarPos = self:GetInsideAnchoredPosition()
    -- local tween = GameUtil.DoAnchorPos(self.rectTransform, tarPos, 0.5)
    -- if callback then
    --     tween:OnComplete(callback)
    -- end
end

function UserInfoWidget:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function UserInfoWidget:SetInteractable(value)
    self.Interactable = value
end

return UserInfoWidget
