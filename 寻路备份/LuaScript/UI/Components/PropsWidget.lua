local BaseIconButton = require "UI.Components.BaseIconButton"

---@class PropsWidget:BaseIconButton
local PropsWidget = class(BaseIconButton, "PropsWidget")

function PropsWidget.Create()
    local gameObject = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_HOMESCENE_PROPS)
    return PropsWidget:CreateWithGameObject(gameObject)
end

function PropsWidget:CreateWithGameObject(gameObject)
    local instance = PropsWidget.new()
    instance:InitWithGameObject(gameObject)
    return instance
end

function PropsWidget:InitWithGameObject(gameObject)
    self.aniItemCache = {}
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.isEntered = true

    local goldGo = find_component(gameObject, "gold")
    self.txtGoldCount = find_component(goldGo, "txtGoldCount", Text)
    self.itemTemplate = find_component(gameObject, "material/item")
    self.goView = find_component(gameObject, "material/view")

    self:InitShowedItems()
    self:SyncGold()

    local function onClickGold()
        UITool.ShowContentTipAni("模块开发中...")
    end
    Util.UGUI_AddButtonListener(goldGo, onClickGold)
end

function PropsWidget:InitShowedItems()
    local items = {}
    local datas = AppServices.BagManager:GetMainShowedDatas()
    for _, v in ipairs(datas) do
        local itm = self:GetPropItem()
        itm.txt.text = v.count
        itm.currentCount = v.count
        local spr = AppServices.ItemIcons:GetSprite(v.itemId)
        UITool.AdaptImage(itm.icon, spr, 56)
        itm.itemId = v.itemId
        items[v.itemId] = itm
    end
    self.showedItems = items
end

function PropsWidget:SyncGold()
    local count = AppServices.User:GetItemAmount(ItemId.COIN)
    self.goldCount = count
    self.txtGoldCount.text = count
end

--同步显示道具
function PropsWidget:SyncItemCount(itemId, count)
    if not itemId then
        return
    end
    local itm = self.showedItems[itemId]
    if not itm then
        itm = self:GetPropItem()
        local spr = AppServices.ItemIcons:GetSprite(itemId)
        UITool.AdaptImage(itm.icon, spr, 56)
        itm.txt.text = 0
        itm.currentCount = 0
        itm.itemId = itemId
        self.showedItems[itemId] = itm
    end
    itm.targetCount = count
    if self.isEntered then
        self:PlayItemCountAni(itm)
    else
        self.aniItemCache[itemId] = itm
    end
end

function PropsWidget:PlayItemCountAni(itm)
    if itm.tween then
        itm.tween:Kill()
    end
    DOTween.Kill(itm.transform)
    itm.transform.localScale = Vector3.one
    local function set(val)
        if Runtime.CSValid(itm.gameObject) then
            itm.currentCount = math.floor(val)
            itm.txt.text = itm.currentCount
        end
    end
    local function finish()
        itm.tween = nil
        if itm.currentCount == 0 then
            Runtime.CSDestroy(itm.gameObject)
            self.showedItems[itm.itemId] = nil
        end
    end
    itm.tween = DOTween.To(set, itm.currentCount, itm.targetCount, 0.2):OnComplete(finish)
    itm.transform:DOPunchScale(Vector3.one * 0.25, 0.2, 1, 0)
end

function PropsWidget:ShowExitAnim(exitImmediate, callback)
    -- local time = 0.5
    -- if exitImmediate then
    --     time = 0
    -- end
    -- local tarPos = self:GetOutsideAnchoredPosition()
    -- local tween = GameUtil.DoAnchorPos(self.rectTransform, tarPos, time)
    -- if callback then
    --     tween:OnComplete(callback)
    -- end

    self.isEntered = false
end

function PropsWidget:ShowEnterAnim(callback)
    self.isEntered = true
    local cache = self.aniItemCache
    if cache then
        WaitExtension.SetTimeout(function()
            for _, v in pairs(cache) do
                self:PlayItemCountAni(v)
            end
        end, 0.5)
    end
    self.aniItemCache = {}
    -- local tarPos = self:GetInsideAnchoredPosition()
    -- local tween = GameUtil.DoAnchorPos(self.rectTransform, tarPos, 0.5)
    -- if callback then
    --     tween:OnComplete(callback)
    -- end
end

function PropsWidget:SetParent(parent)
    self.gameObject.transform:SetParent(parent, false)
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
end

function PropsWidget:SetInteractable(value)
    self.Interactable = value
end

function PropsWidget:GetPropItem()
    local go = BResource.InstantiateFromGO(self.itemTemplate)
    local itm = {
        gameObject = go,
        transform = go.transform,
        icon = find_component(go, "imgIcon", Image),
        txt = find_component(go, "txtCount", Text)
    }
    go:SetParent(self.goView, false)
    go:SetActive(true)
    return itm
end

function PropsWidget:Dispose()
    self.aniItemCache = nil
    for _, v in ipairs(self.showedItems) do
        if v.tween then
            DOTween.Kill(v.transform)
            v.tween:Kill()
            v.tween = nil
        end
    end
end


return PropsWidget
