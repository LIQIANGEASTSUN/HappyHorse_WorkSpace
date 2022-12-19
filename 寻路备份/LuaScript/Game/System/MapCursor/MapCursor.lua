local MapCursor = {}
local MapTipItem = require "Game.System.MapCursor.MapTipItem"

function MapCursor:_Init()
    self.itemList = {}
    local root = BResource.InstantiateFromAssetName(CONST.ASSETS.G_MAP_TIP_CANVAS)
    root:SetParent(App.scene.canvas, false)
    root.transform:SetAsFirstSibling()
    self.root = root
    self.showed = true
    self.canvasGroup = find_component(root, "", CanvasGroup)
    self.canvasGroup.alpha = 1
    self.canvasGroup.interactable = true

    if self.tickId then
        WaitExtension.CancelTimeout(self.tickId)
    end
    self.tickId = WaitExtension.InvokeRepeating(
        function()
            self:_TickMapTipItems()
        end
    , 0, 0)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Start, self.HideAll, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_Drama_Over, self.ShowAll, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_Show_Panel, self.HideAll, self)
    MessageDispatcher:AddMessageListener(MessageType.Global_After_Destroy_Panel, self.ShowAll, self)
end

function MapCursor:Show(id, targetObj, params)
    if not id then
        return
    end
    if Runtime.CSNull(targetObj) then
        return
    end
    self:Remove(id)
    local itm = MapTipItem.Create(self.root)
    itm:SetTarget(targetObj)
    itm:SetParam(params)
    self.itemList[#self.itemList + 1] = {item = itm, id = id, dirty = false}
end

function MapCursor:Remove(id)
    if not id then
        return
    end
    for _,v in ipairs(self.itemList) do
        if v.id == id then
            v.dirty = true
        end
    end
end

function MapCursor:ShowAll()
    if not self.showed then
        self.showed = true
        self.canvasGroup.alpha = 1
        self.canvasGroup.interactable = true
    end
end

function MapCursor:HideAll()
    if self.showed then
        self.showed = false
        self.canvasGroup.alpha = 0
        self.canvasGroup.interactable = false
    end
end

function MapCursor:_TickMapTipItems()
    if #self.itemList == 0 then
        return
    end
    for k,v in ipairs(self.itemList) do
        if v.dirty then
            table.remove(self.itemList, k)
            v.item:Destroy()
        else
            v.item:UpdateState()
        end
    end
end

function MapCursor:OnDestroy()
    if self.tickId then
        WaitExtension.CancelTimeout(self.tickId)
        self.tickId = nil
    end
    for _,v in ipairs(self.itemList) do
        v.item:Destroy()
    end
    MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Start, self.HideAll, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_Drama_Over, self.ShowAll, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Show_Panel, self.HideAll, self)
    MessageDispatcher:RemoveMessageListener(MessageType.Global_After_Destroy_Panel, self.ShowAll, self)
end

MapCursor:_Init()

return MapCursor