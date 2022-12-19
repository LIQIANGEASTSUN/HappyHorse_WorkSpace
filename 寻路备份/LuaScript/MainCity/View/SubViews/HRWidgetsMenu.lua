---@class HRWidgetsMenu
local HRWidgetsMenu = class(nil, HRWidgetsMenu)
--基础宽度
local orgWidth = 60
--组件宽度
local itemWidth = 60

function HRWidgetsMenu:Create(layout)
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_WIDGETS_MENU)
    go.transform:SetParent(layout.transform, false)
    local instance = HRWidgetsMenu.new()
    instance:InitWithGameObject(go, layout)
    return instance
end

function HRWidgetsMenu:InitWithGameObject(go, layout)
    self.gameObject = go
    self.transform = go.transform
    self.layout = layout
    self.widgetKeys = {}
    self.out_widgetKeys = {}
    self.btn = find_component(go, "btn_menu", Button)
    self.go_inRoot = find_component(go, "ScrollView/Viewport/Content")
    self.go_outRoot = find_component(go, "go_outRoot")
    self.isOn = false
    --显示计数
    self.showCount = 1
    self.showType = {
        [CONST.MAINUI.ICONS.SettingButton] = true,
        -- [CONST.MAINUI.ICONS.InviteButton] = true,
    }

    --self.gameObject.transform:DOSizeDelta(Vector2(orgWidth, 60), 0, true)
    self:SortRHButtons()
    self:SetBtnIcon()
    self:RefreshItem()
    Util.UGUI_AddButtonListener(self.btn, function()
        self:OnClickMenuBtn()
        self:SetBtnIcon()
    end)
end

function HRWidgetsMenu:RefreshItem()
    if self.isOn then
        -- local width = self.go_inRoot.transform.rect.width + orgWidth
        local width = itemWidth * #self.widgetKeys + orgWidth - 10
        self.gameObject.transform:DOSizeDelta(Vector2(width, 60), 0.5, true)
    else
        self.gameObject.transform:DOSizeDelta(Vector2(orgWidth + itemWidth * self.showCount, 60), 0.5, true)
    end
end

function HRWidgetsMenu:OnClickMenuBtn()
    self.isOn = not self.isOn
    if self:IsChangeWidgetParent() then
        self:SortRHButtons()
    end
    self:RefreshItem()
end

function HRWidgetsMenu:ResetToggle()
    if self.isOn then
        self.isOn = false
        self:RefreshItem()
    end
end

function HRWidgetsMenu:ForceViewOutItem(type,value)
    if self.showType[type] == nil then
        self.showType[type] = false
    end

    if self.showType[type] == value then
        return
    end

    self.showType[type] = value
    if value then
        self.showCount = self.showCount + 1
    else
        self.showCount = self.showCount - 1
    end

    if not self.isOn then
        self:RefreshItem()
    end
end

---向收缩列表加入按钮
function HRWidgetsMenu:AddRHButton(eType, buttonIns)
    local parent = self.go_inRoot.gameObject.transform
    buttonIns:SetParent(parent, false)
    table.insertIfNotExist(self.widgetKeys, eType)
    App.scene:AddWidget(eType, buttonIns)
    self:SortRHButtons()
end

---删除收缩列表中的某个按钮
function HRWidgetsMenu:DelRHButton(eType)
    local buttonIns = App.scene:GetWidget(eType)
    if buttonIns then
        buttonIns:Dispose()
        App.scene:DelWidget(eType)
        table.removeIfExist(self.widgetKeys, eType)
        self:SortRHButtons()
    end
end

-- attach  child directly
---向收缩列表外加入按钮
function HRWidgetsMenu:AddButton(eType, buttonIns)
    local parent = self.go_outRoot
    table.insertIfNotExist(self.out_widgetKeys, eType)
    buttonIns:SetParent(parent.transform, true)
    App.scene:AddWidget(eType, buttonIns)
end

function HRWidgetsMenu:RemoveButton(eType)
    local buttonIns = App.scene:GetWidget(eType)
    if buttonIns then
        buttonIns:Dispose()
        App.scene:DelWidget(eType)
    end
end


---展开
local MainUI_LH_SORT = {
    [CONST.MAINUI.ICONS.SettingButton] = 100,
    [CONST.MAINUI.ICONS.MailButton] = 200,
    [CONST.MAINUI.ICONS.Prune] = 300,
    [CONST.MAINUI.ICONS.DayRewardButton] = 400,
    [CONST.MAINUI.ICONS.ActivityCalendarButton] = 500,
    [CONST.MAINUI.ICONS.InviteButton] = 600,
}

local MainUI_LH_SORT_OUT = {
    [CONST.MAINUI.ICONS.InviteButton] = 200,
    [CONST.MAINUI.ICONS.UpdatingButton] = 100,
}

local function checkChanges(widgetKeys, changes, isOn)
    local scene = App.scene
    for _, eType in ipairs(widgetKeys) do
        local ins = scene:GetWidget(eType)
        if ins then
            local changeType = ins:NeedChangeParent(isOn)
            if changeType then
                console.lzl("更换位置", eType, changeType)
                changes = changes or {}
                changes[eType] = changeType
            end
        end
    end
    return changes
end
function HRWidgetsMenu:IsChangeWidgetParent()
    local changes = nil
    local scene = App.scene
    changes = checkChanges(self.widgetKeys, changes, self.isOn)
    changes = checkChanges(self.out_widgetKeys, changes, self.isOn)
    if changes then
        for eType, newSide in pairs(changes) do
            local ins = scene:GetWidget(eType)
            if newSide == 'in' then
                table.removeIfExist(self.out_widgetKeys, eType)
                table.insertIfNotExist(self.widgetKeys, eType)
                ins:SetParent(self.go_inRoot.transform, true)
            elseif newSide == 'out' then
                ins:SetParent(self.go_outRoot.transform, true)
                table.removeIfExist(self.widgetKeys, eType)
                table.insertIfNotExist(self.out_widgetKeys, eType)
            end
        end
        return true
    end
    return false
end

function HRWidgetsMenu:SortRHButtons()
    if #self.widgetKeys > 0 then
        table.sort(
            self.widgetKeys,
            function(a, b)
                return MainUI_LH_SORT[a] < MainUI_LH_SORT[b]
            end
        )

        for index, eType in ipairs(self.widgetKeys) do
            ---@type HomeSceneTopIconBase
            local buttonInstance = App.scene:GetWidget(eType)
            if buttonInstance then
                local go = buttonInstance:GetRootGO()
                if Runtime.CSValid(go) then
                    local trans = go.transform
                    trans:SetSiblingIndex(index - 1)
                end
            end
        end
    end

    if #self.out_widgetKeys > 0 then
        -- MainUI_LH_SORT_OUT
        table.sort(
            self.out_widgetKeys,
            function(a, b)
                return MainUI_LH_SORT_OUT[a] < MainUI_LH_SORT_OUT[b]
            end
        )

        for index, eType in ipairs(self.out_widgetKeys) do
            ---@type HomeSceneTopIconBase
            local buttonInstance = App.scene:GetWidget(eType)
            if buttonInstance then
                local go = buttonInstance:GetRootGO()
                if Runtime.CSValid(go) then
                    local trans = go.transform
                    trans:SetSiblingIndex(index - 1)
                end
            end
        end
    end
end

function HRWidgetsMenu:SetBtnIcon()
    local img_in = find_component(self.btn, "in", Image)
    local img_out = find_component(self.btn, "out", Image)
    img_in:SetActive(self.isOn)
    img_out:SetActive(not self.isOn)
end

function HRWidgetsMenu:Dispose()
end

return HRWidgetsMenu