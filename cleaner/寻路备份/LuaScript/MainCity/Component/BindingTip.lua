---@class BindingTip
local BindingTip = class(nil, "BindingTip")
local TransparencyState = {
    half = 0, --半透明
    full = 1 --不透明
}

local NotEnoughJumpHandler = {
    [ItemId.ENERGY] = function()
        App.mapGuideManager:StartSeries(GuideConfigName.GuideEnergy)
        if App.mapGuideManager:HasRunningGuide(GuideConfigName.GuideEnergy) then
            return
        end
        PanelManager.showPanel(GlobalPanelEnum.PowerShopPanel, {source = "bindTip"})
    end,
    [ItemId.DIAMOND] = function()
        require("Game.Processors.RequestIAPProcessor").Start(
            function()
                PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {source = "bindTip"})
            end
        )
    end,
    [ItemId.COIN] = function()
        PanelManager.showPanel(GlobalPanelEnum.MoneyShopPanel, {selectIndex = MoneyShopPage.Coin, source = "bindTip"})
    end,
    [ItemId.GoldPanningShovel] = function()
        AppServices.Jump.FocusFactory(ItemId.GoldPanningShovel)
    end
}

function BindingTip:ctor(gameObject)
    self.gameObject = gameObject
    ---@type TransparencyState
    self.state = nil
    ---@type BaseAgent
    self.agent = nil
    self.agentId = nil
    -- self.funId = nil
    self.root = find_component(self.gameObject, "tween/root")
    self.icon = find_component(self.root, "Icon", Image)
    local bgParent = find_component(self.root, "bg", Transform)
    self.bgs = {}
    local childCount = bgParent.childCount
    for i = 1, childCount do
        local bg = find_component(self.root, "bg/" .. tostring(i), Image)
        table.insert(self.bgs, bg)
    end
    local function onClick()
        if self.state == TransparencyState.half then
            SceneServices.BindingTip:OnclickHalfTransparencyTip(self.agentId)
        else
            local function onFinishHide()
                local ret = self:EmitClean()
                if ret then
                    SceneServices.BindingTip:RefreshOtherTips(self.agentId)
                    self:Hide()
                end
            end
            local itemId = self.agent:GetCurrentCost()
            if itemId == tonumber(ItemId.DIAMOND) then
                AppServices.DiamondConfirmUIManager:Click(
                    self:GetBg().gameObject,
                    function()
                        self:ZoomInAnim(onFinishHide)
                    end
                )
            else
                self:ZoomInAnim(onFinishHide)
            end
        end
    end
    Util.UGUI_AddButtonListener(self.root, onClick)
end

function BindingTip:Show(agent, index)
    if Runtime.CSNull(self.gameObject) then
        return
    end
    self.inUse = true
    self.agent = agent
    self.agentId = agent:GetId()

    self.gameObject:SetActive(true)
    self:ShowBg()
    self:HandleAgentHighlight(index)
    self:SetPosition(agent)
    self:SetSiblingIndex()
    self:SetNum(agent)
    self:SetSize()
end

function BindingTip:ZoomInAnim(callback)
    self.zooming = true
    self:CancelZoomTween()
    self.zoomTween = GameUtil.DoScale(self.gameObject, Vector3(0, 0, 0), 0.2)
    self.zoomTween.onComplete = function()
        self:CancelZoomTween()
        self.zooming = false
        Runtime.InvokeCbk(callback)
    end
end

function BindingTip:ShowBg()
    local index = 1
    local isbomb
    if self.agent:GetType() == AgentType.bomb then
        index = 2
        isbomb = true
    else
        local itemId = self.agent:GetCurrentCost()
        if tostring(itemId) == ItemId.GoldPanningShovel then
            index = 3
        end
    end
    for i, bg in ipairs(self.bgs) do
        bg:SetActive(i == index)
    end
    self.icon:SetActive(not isbomb)
end

function BindingTip:GetBg()
    local isbomb = self.agent:GetType() == AgentType.bomb
    if isbomb then
        return self.bgs[2]
    else
        return self.bgs[1]
    end
end

function BindingTip:GetGuideClickObj()
    return self.root
end

function BindingTip:HandleAgentHighlight(index)
    if index == 1 then
        self.agent:SetHighlight(true)
    end
end

function BindingTip:Hide()
    AppServices.DiamondConfirmUIManager:Release()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(false)
    end
    if not self.zooming then
        if self.agent then
            self.agent:SetHighlight(false)
            self.agent = nil
        end
        self.inUse = false
        return
    end
    self:EmitClean(true)
end

function BindingTip:SetPosition(agent)
    local pos = agent:GetAnchorPosition()
    if not pos then
        self:Hide()
        return
    end
    self.gameObject:SetPosition(pos)
end

function BindingTip:SetSiblingIndex()
    self.gameObject.transform:SetAsLastSibling()
end

function BindingTip.GetSize()
    local orgCamSize = 3
    local scale
    MoveCameraLogic.Instance():GetCamera(
        function(camera)
            scale = camera.orthographicSize / orgCamSize
        end
    )
    return scale
end

function BindingTip:SetSize(Size)
    if not Size then
        local orgCamSize = 3
        MoveCameraLogic.Instance():GetCamera(
            function(camera)
                Size = Vector3.one * camera.orthographicSize / orgCamSize
            end
        )
    end
    self.gameObject:SetLocalScale(Size)
end

function BindingTip:SetNum(agent)
    self.txt_num = self.txt_num or find_component(self.root, "Text", Text)
    self.txt_num_outline = self.txt_num_outline or find_component(self.root, "Text", Outline)
    local itemId, count = agent:GetCurrentCost()
    if not count or count <= 0 then
        self:Hide()
        return
    end
    self.offObj = self.offObj or find_component(self.root, "buffBg")
    local offInfo = AppServices.EnergyDisCountBuff:GetOffPercent()
    if agent:GetType() == AgentType.obstacle and offInfo < 1 and ItemId.IsEnergy(itemId) then
        self.offObj:SetActive(true)
        self.txtOffNum = self.txtOffNum or find_component(self.offObj, "num", Text)
        local _, orCost = agent.data:GetNoDiscountCost()
        self.txtOffNum.text = tostring(orCost)
    else
        self.offObj:SetActive(false)
    end

    local sprite
    if itemId ~= 0 then
        sprite = AppServices.ItemIcons:GetSprite(itemId)
    end
    self.icon = self.icon or find_component(self.root, "Icon", Image)
    self.icon.sprite = sprite

    if tostring(itemId) == ItemId.GoldPanningShovel then
        local hasCount = AppServices.User:GetItemAmount(ItemId.GoldPanningShovel)
        if hasCount < count then
            self.txt_num.text = "<color=#E72222>" .. count .. "</color>"
            --outline F2E0C0
            local color = Color(0.9490196, 0.8784314, 0.7529412, 1)
            self.txt_num_outline.effectColor = color
        else
            --outline 89551D
            self.txt_num.text = count
            local color = Color(0.5372549, 0.3333333, 0.1137255, 1)
            self.txt_num_outline.effectColor = color
        end
    else
        self.txt_num.text = count
        local color = Color(0, 0, 0, 0.5)
        self.txt_num_outline.effectColor = color
    end
end

function BindingTip:SetTransparency(val)
    if Runtime.CSValid(self.gameObject) then
        local canvasGroup = self.gameObject:GetOrAddComponent(typeof(CanvasGroup))
        canvasGroup.alpha = val
        local state = val == 1 and 1 or 0
        self.state = state
    end
end

function BindingTip:EmitClean(fromHide)
    if not self.agent then
        return
    end
    if not self.agent.data then
        return
    end
    local level = AppServices.User:GetCurrentLevelId()
    local needLevel = self.agent.data.meta.roleLevel
    if level < needLevel then
        local desc = Runtime.Translate("ui_system_unlock_level", {level = tostring(needLevel)})
        AppServices.UITextTip:Show(desc)
        return
    end

    local itemId, count = self.agent:GetCurrentCost()
    local had = AppServices.User:GetItemAmount(itemId)
    local function checkItem()
        local need = tostring(itemId) == ItemId.ENERGY and 1 or count
        return had < need
    end
    if checkItem(itemId) then
        if not fromHide then
            SceneServices.BindingTip:HideAll()
        end
        local handler = NotEnoughJumpHandler[tostring(itemId)]
        if handler then
            return handler()
        else
            local description = Runtime.Translate("errorcode_25002")
            return AppServices.UITextTip:Show(description)
        end
    end
    if self.agent:IsCleaning() then
        return
    end
    AppServices.Clean:InsertCleanQueue(self.agent)
    return true
end

function BindingTip:CancelZoomTween()
    if self.zoomTween then
        self.zoomTween:Kill()
        self.zoomTween = nil
    end
end

function BindingTip:SetZoomingFalse()
    self.zooming = false
end

function BindingTip:Destory()
    self:Hide()
    self.agentId = nil
end

return BindingTip
