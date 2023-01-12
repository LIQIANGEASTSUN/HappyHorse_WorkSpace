local AreaLayout = {}
local showBetween = 0.2
local hideBetween = 0.5
function AreaLayout:Create(container)
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_SAFE_AREA_PANEL)
    go:SetParent(container, false)

    self.go = go
    self.transform = go.transform
    self.transRT = self.transform:Find("HomeRightTop")
    self.transR = self.transform:Find("HomeRight")
    self.transR_Act = self.transR:Find("ActiveView")
    self.transR_Pro = self.transR:Find("PromotionView")
    -- self.transR_SV_Act = self.transR:Find("ActiveView/Viewport/Content")
    -- self.transR_SV_Pro = self.transR:Find("PromotionView/Viewport/Content")
    self.transLT = self.transform:Find("HomeLeftTop")
    self.transL = self.transform:Find("HomeLeft")
    self.transBL = self.transform:Find("HomeLeftBottom")
    self.transBR = self.transform:Find("BottomRight")
    -- self.transBR_S = self.transform:Find("BottomRight_Sub")
    self.transTC = self.transform:Find("TopCenter")
    self.transTC2 = self.transform:Find("TopCenter2")
    self.transBC = self.transform:Find("BottomCenter")

    self.safeAreaRight_AnchoredPosX = self.transR.anchoredPosition.x
    self.safeAreaLeft_AnchoredPosX = self.transL.anchoredPosition.x
    self.safeAreaLeftTop_AnchoredPosX = self.transLT.anchoredPosition.x
    self.safeAreaRightTop_AnchoredPosX = self.transRT.anchoredPosition.x
    self.safeAreaLeftBottom_AnchoredPosX = self.transBL.anchoredPosition.x
    self.safeAreaBottomRight_AnchoredPosY = self.transBR.anchoredPosition.y
    -- self.safeAreaBottomRight_Sub_AnchoredPosY = self.transBR_S.anchoredPosition.y
    self.safeAreaTopCenter_AnchoredPosY = self.transTC.anchoredPosition.y
    self.safeAreaTopCenter2_AnchoredPosY = self.transTC2.anchoredPosition.y
    self.safeAreaBottonCenter_AnchoredPosY = self.transBC.anchoredPosition.y

    self.safeArea_AnchorMin = self.go:GetComponent(typeof(RectTransform)).anchorMin
    self.safeArea_AnchorMax = self.go:GetComponent(typeof(RectTransform)).anchorMax

    -- widgets
    self.transWidgets = self.transform:Find("RHWidgets")
    self.goWidgets_AnchoredPosX = self.transWidgets.anchoredPosition.x

    self.rightList = {}
    self.orderAry = nil
    return self
end

function AreaLayout:Node()
    return self.transform
end

function AreaLayout:WidgetsNode()
    return self.transWidgets
end

function AreaLayout:WidgetsIn()
    --小图标滑入
    DOTween.Kill(self.transWidgets, false)
    GameUtil.DoAnchorPosX(
        self.transWidgets,
        self.goWidgets_AnchoredPosX,
        showBetween,
        function()
        end
    )
end

function AreaLayout:WidgetOut()
    -- 小图标滑出
    local layout = self.transR:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    local widgetsMenu = App.scene:GetWidget(CONST.MAINUI.ICONS.HRWidgetsMenu)
    DOTween.Kill(self.transWidgets)
    GameUtil.DoAnchorPosX(
        self.transWidgets,
        self.goWidgets_AnchoredPosX + widgetsMenu.transform.sizeDelta.x + 90 + layout.preferredWidth +
            self.safeArea_AnchorMin.x * Screen.width,
        hideBetween
    )
end

function AreaLayout:TopLeft()
    return self.transLT
end

function AreaLayout:BottomLeft()
    return self.transBL
end

function AreaLayout:BottomRight()
    return self.transBR
end

function AreaLayout:BottomRight_Sub()
    return self.transBR_S
end

function AreaLayout:BottomCenter()
    return self.transBC
end

function AreaLayout:RightLayout()
    return self.transR
end

function AreaLayout:RightLayoutAddChild(btn, iconName, isPromotion)
    local trans = self.transR_SV_Act
    if isPromotion then --是否是限时特惠icon
        trans = self.transR_SV_Pro
    end
    btn.gameObject:SetParent(trans, false)
    local order = nil
    if iconName ~= nil then
        if self.orderAry == nil then
            local value = AppServices.Meta:GetConfigMetaValue("activityIcon")
            if not string.isEmpty(value) then
                self.orderAry = table.deserialize(value)
            else
                self.orderAry = {}
            end
        end
        order = table.indexOf(self.orderAry, iconName)
    end

    if not self.orderList then
        self.orderList = {}
        self.orderCount = 0
    end
    if order ~= nil then
        for i = 1, #self.orderList do
            local last = self.orderList[i]
            local next = self.orderList[i + 1]
            if order < last then
                if next and order < next or not next then
                    table.insert(self.orderList, i, order)
                    btn.transform:SetSiblingIndex(i - 1)
                    self.orderCount = self.orderCount + 1
                    -- self.transR:GetComponent(typeof(Image)).enabled = self.orderCount>2
                    return
                end
            end
        end
        table.insert(self.orderList, order)
    else
        table.insert(self.orderList, math.maxinteger)
    end
    self.orderCount = self.orderCount + 1
    -- self.transR:GetComponent(typeof(Image)).enabled = self.orderCount>2
end

function AreaLayout:RightLayoutDelChild(child)
    child.gameObject:SetActive(false)
    self.orderCount = self.orderCount - 1
    --self.transR:GetComponent(typeof(Image)).enabled = self.orderCount > 2
    --查位置
    --插入
end

function AreaLayout:BeforeUnload()
    self.orderList = {}
    self.orderCount = 0
end

function AreaLayout:LeftLayout()
    return self.transL
end

function AreaLayout:HideLeftTop()
    -- transLT
    local layout = self.transLT:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    local offset = layout and layout.preferredWidth or 0
    local size = self.transLT.transform.sizeDelta.x
    DOTween.Kill(self.transLT, false)
    GameUtil.DoAnchorPosX(
        self.transLT,
        self.safeAreaLeftTop_AnchoredPosX - size - offset - self.safeArea_AnchorMin.x * Screen.width,
        hideBetween,
        function()
            MessageDispatcher:SendMessage(MessageType.MainUI_TopLeft_OnHide)
        end
    )
end

function AreaLayout:HideRightTop()
    local layout = self.transRT:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    local offset = layout and layout.preferredWidth or 0
    local size = self.transRT.transform.sizeDelta.x
    DOTween.Kill(self.transRT, false)
    GameUtil.DoAnchorPosX(
        self.transRT,
        self.safeAreaRightTop_AnchoredPosX + size + offset + self.safeArea_AnchorMin.x * Screen.width,
        hideBetween,
        function()
            MessageDispatcher:SendMessage(MessageType.MainUI_TopLeft_OnHide)
        end
    )
end

function AreaLayout:ShowLeftTop()
    DOTween.Kill(self.transLT)
    GameUtil.DoAnchorPosX(self.transLT, self.safeAreaLeftTop_AnchoredPosX, showBetween)
end

function AreaLayout:HideLeft()
    local layout = self.transL:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    local offset = layout and layout.preferredWidth or 0
    DOTween.Kill(self.transL, false)
    GameUtil.DoAnchorPosX(
        self.transL,
        self.safeAreaLeft_AnchoredPosX - 150 - offset - self.safeArea_AnchorMin.x * Screen.width,
        hideBetween
    )
end
function AreaLayout:ShowLeft()
    DOTween.Kill(self.transL)
    GameUtil.DoAnchorPosX(self.transL, self.safeAreaLeft_AnchoredPosX, showBetween)
end

function AreaLayout:HideRight(onFinished)
    local layout = self.transR:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    local offset = layout and layout.preferredWidth or 0
    DOTween.Kill(self.transR, false)
    GameUtil.DoAnchorPosX(
        self.transR,
        self.safeAreaRight_AnchoredPosX + 250 + offset + (1 - self.safeArea_AnchorMax.x) * Screen.width,
        hideBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end
function AreaLayout:ShowRight(onFinished)
    DOTween.Kill(self.transR)
    GameUtil.DoAnchorPosX(
        self.transR,
        self.safeAreaRight_AnchoredPosX,
        showBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end

function AreaLayout:ShowRightTop()
    DOTween.Kill(self.transRT)
    GameUtil.DoAnchorPosX(self.transRT, self.safeAreaRightTop_AnchoredPosX, showBetween)
end

function AreaLayout:HideBottomLeft()
    local layout = self.transBL:GetComponent(typeof(CS.UnityEngine.UI.VerticalLayoutGroup))
    DOTween.Kill(self.transBL, false)
    GameUtil.DoAnchorPosX(
        self.transBL,
        self.safeAreaLeftBottom_AnchoredPosX - 160 - layout.preferredHeight - self.safeArea_AnchorMin.y * Screen.height,
        0.5
    )
end
function AreaLayout:ShowBottomLeft()
    local function onFinished()
        App.mapGuideManager:OnGuideFinishEvent(GuideEvent.AnimationFinish, "ShowBottomLeft")
    end
    DOTween.Kill(self.transBL)
    GameUtil.DoAnchorPosX(self.transBL, self.safeAreaLeftBottom_AnchoredPosX, showBetween, onFinished)
end

function AreaLayout:HideBottomRight()
    local layout = self.transBR:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    layout.enabled = false
    local sizeFilter = self.transBR:GetComponent(typeof(CS.UnityEngine.UI.ContentSizeFitter))
    sizeFilter.enabled = false
    if self.brTimer then
        WaitExtension.CancelTimeout(self.brTimer)
        self.brTimer = nil
    end

    -- DOTween.Kill(self.transBR_S)
    -- GameUtil.DoAnchorPosY(
    --      self.transBR_S,
    --      self.safeAreaBottomRight_Sub_AnchoredPosY - 300 - layout.preferredHeight - self.safeArea_AnchorMin.y * Screen.height,
    --      0.2
    -- )
end
function AreaLayout:ShowBottomRight()
    self.brTimer =
        WaitExtension.SetTimeout(
        function()
            if self.brTimer then
                self.brTimer = nil

            --local layout = self.transBR:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
            --layout.enabled = true
            --local sizeFilter = self.transBR:GetComponent(typeof(CS.UnityEngine.UI.ContentSizeFitter))
            --sizeFilter.enabled = true
            end
        end,
        0.45
    )
    -- local layout = self.transBR:GetComponent(typeof(CS.UnityEngine.UI.GridLayoutGroup))
    -- layout.enabled = true
    -- DOTween.Kill(self.transBR_S)
    -- GameUtil.DoAnchorPosY(self.transBR_S, self.safeAreaBottomRight_Sub_AnchoredPosY, 0.2)
end

function AreaLayout:HideTopCenter()
    DOTween.Kill(self.transTC)
    GameUtil.DoAnchorPosY(
        self.transTC,
        self.safeAreaTopCenter_AnchoredPosY + 160 - self.safeArea_AnchorMin.y * Screen.height,
        showBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end
function AreaLayout:ShowTopCenter()
    DOTween.Kill(self.transTC)
    GameUtil.DoAnchorPosY(
        self.transTC,
        self.safeAreaTopCenter_AnchoredPosY,
        showBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end

function AreaLayout:HideTopCenter2()
    DOTween.Kill(self.transTC2)
    GameUtil.DoAnchorPosY(
        self.transTC2,
        self.safeAreaTopCenter2_AnchoredPosY + 440 - self.safeArea_AnchorMin.y * Screen.height,
        showBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end
function AreaLayout:ShowTopCenter2()
    DOTween.Kill(self.transTC2)
    GameUtil.DoAnchorPosY(
        self.transTC2,
        self.safeAreaTopCenter2_AnchoredPosY,
        showBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end

function AreaLayout:HideBottomCenter()
    DOTween.Kill(self.transR)
    GameUtil.DoAnchorPosY(
        self.transBC,
        self.safeAreaBottonCenter_AnchoredPosY - 160 - self.safeArea_AnchorMin.y * Screen.height,
        showBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end
function AreaLayout:ShowBottomCenter()
    DOTween.Kill(self.transR)
    GameUtil.DoAnchorPosY(
        self.transBC,
        self.safeAreaBottonCenter_AnchoredPosY,
        showBetween,
        function()
            Runtime.InvokeCbk(onFinished)
        end
    )
end
return AreaLayout
