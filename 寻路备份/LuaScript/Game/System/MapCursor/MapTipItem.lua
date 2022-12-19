local MapTipItem = {}

--上下左右边界阈值
local BorderThreshold = {
    width = 180,
    height = 190
}

function MapTipItem.Create(parent)
    local itm = {}
    setmetatable(itm, {__index = MapTipItem})
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_MAP_TIP_ITEM)
    go:SetParent(parent, false)
    itm:_Init(go)
    itm.parent = parent.transform
    return itm
end

function MapTipItem:_Init(go)
    self.showed = true
    self.gameObject = go
    self.transform = go.transform
    self.imgIcon = find_component(go, "icon", Image)
    self.mainCamera = App.scene.mainCamera
    self.canvasGroup = find_component(go, "", CanvasGroup)

    local btn = find_component(go, "bg").transform
    self.bgTransform = btn.transform
    Util.UGUI_AddButtonListener(
        go,
        function()
            self.clickMoving = true
            self:Hide()
            MoveCameraLogic.Instance():MoveCameraToLook2(self.targetTrans.position, 1, nil, function()
                self.clickMoving = false
            end)
        end
    )
end

function MapTipItem:UpdateState()
    if not self.targetTrans then
        return
    end
    self:_CheckSide(self.targetTrans.position)
end

function MapTipItem:SetTarget(gameObject)
    if Runtime.CSValid(gameObject) then
        self.targetTrans = gameObject.transform
    end
end

function MapTipItem:SetIcon(spr)
    if not spr then
        return
    end
    UITool.AdaptImage(self.imgIcon, spr, 50)
end

function MapTipItem:SetParam(params)
end

function MapTipItem:Show()
    if not self.showed and not self.clickMoving then
        self.showed = true
        self.canvasGroup.alpha = 1
        self.canvasGroup.interactable = true
    end
end

function MapTipItem:Hide()
    if self.showed then
        self.showed = false
        self.canvasGroup.alpha = 0
        self.canvasGroup.interactable = false
    end
end

function MapTipItem:IsHide()
    return not self.showed
end

function MapTipItem:_CheckSide(targetpos)
    local inScreen, vt2 = self:_CheckPointOnScreen(targetpos)
    if inScreen then
        self:Hide()
    else
        -- self:_UpdateTipPos(vt2)
        self:_UpdateTipPos(vt2)
        self:Show()
    end
end

function MapTipItem:_UpdateTipPos()
    local screenPos = self.mainCamera:WorldToScreenPoint(self.targetTrans.position)
    local viewPortPos = self.mainCamera:ScreenToViewportPoint(screenPos)
    viewPortPos = Vector2(viewPortPos.x - 0.5, viewPortPos.y - 0.5)
    local absX = math.abs(viewPortPos.x)
    local absY = math.abs(viewPortPos.y)
    local rect = self.parent.rect
    local screen_width_pos = rect.width / 2 - BorderThreshold.width - (viewPortPos.x>0 and 100 or 0)
    local screen_height_pos = rect.height / 2 - BorderThreshold.height
    if absX > absY then
        self.transform.anchoredPosition =
            Vector2((screen_width_pos) * viewPortPos.x / absX, (screen_height_pos) * viewPortPos.y / absX)
    else
        self.transform.anchoredPosition =
            Vector2((screen_width_pos) * viewPortPos.x / absY, (screen_height_pos) * viewPortPos.y / absY)
    end
    local rad = math.atan(-viewPortPos.x, viewPortPos.y)
    self.bgTransform.localEulerAngles = Vector3(0, 0, math.deg(rad))
end

function MapTipItem:_CheckPointOnScreen(point)
    local vt2 = self.mainCamera:WorldToScreenPoint(point)
    local inScreen = false
    if (vt2.x > 0 and vt2.x < Screen.width) and (vt2.y > -100 and vt2.y < Screen.height) then
        inScreen = true
    end
    vt2 = GameUtil.ScreenToUISpace(self.parent, Vector2(vt2.x, vt2.y), self.mainCamera)
    return inScreen, vt2
end

function MapTipItem:Destroy()
    if Runtime.CSValid(self.gameObject) then
        Runtime.CSDestroy(self.gameObject)
    end
end

return MapTipItem
