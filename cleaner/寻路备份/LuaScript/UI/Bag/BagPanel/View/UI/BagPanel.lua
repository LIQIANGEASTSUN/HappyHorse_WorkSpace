--insertWidgetsBegin
--    btn_close
--insertWidgetsEnd

--insertRequire
local _BagPanelBase = require "UI.Bag.BagPanel.View.UI.Base._BagPanelBase"
---@class BagPanel:_BagPanelBase
local BagPanel = class(_BagPanelBase)

local BagItem = require "UI.Bag.BagPanel.View.UI.BagItem"

--道具切页索引
local PageIndex = {
    Item = 1, --道具
    Task = 2  --任务道具
}

function BagPanel:ctor()
    self.curIndex = PageIndex.Item
end

function BagPanel:onAfterBindView()
    self:UpdateView()
end

function BagPanel:UpdateView()
    local mgr = AppServices.BagManager
    self.datas = mgr:GetBagItemDatas()
    self.maxCapacity = mgr:GetCurrentBagCapacity()
    self.totalCount = mgr:GetItemTotalCount()
    self.txtCapacity.text = string.format("%d/%d", self.totalCount, self.maxCapacity)
end

function BagPanel:SwitchTag(tagIndex)
    if tagIndex == PageIndex.Item then

    elseif tagIndex == PageIndex.Task then

    end
    self:InitItems(self.datas[tagIndex])
    self.curIndex = tagIndex
end

function BagPanel:InitItems(datas)
    if not datas then
        datas = {}
    end
    local itmList = {}
    local function onCreate(key)
        local itm = BagItem.Create()
        itmList[key] = itm
        return itm.gameObject
    end
    local function onUpate(key, index)
        local itm = itmList[key]
        itm:SetData(datas[index])
    end
    self.scrollList:InitList(#datas, onCreate, onUpate)
end

function BagPanel:ShowItemTip(dt)
    self.txtTipTittle.text = Runtime.Translate(dt.config.name)
    self.txtTipContent.text = Runtime.Translate(dt.config.desc)
    self.tipCanvasGroup:DOFade(1, 0.05)
    self.tipTrans:DOScale(1, 0.05)
    local tpos = GameUtil.WorldToUISpace(self.transform, dt.pos)
    self.tipTrans.anchoredPosition = Vector2(tpos.x, tpos.y + 30)
    self.tipChecker:SetRaycastEnable(true)
end

function BagPanel:RefreshView()
    self:UpdateView()
    self:InitItems(self.datas[self.curIndex])
end

function BagPanel:Dispose()

end

return BagPanel
