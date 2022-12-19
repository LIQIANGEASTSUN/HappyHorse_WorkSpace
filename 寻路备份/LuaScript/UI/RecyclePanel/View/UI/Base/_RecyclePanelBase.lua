--insertRequire

---@class _RecyclePanelBase:BasePanel
local _RecyclePanelBase = class(BasePanel)

function _RecyclePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
end

function _RecyclePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _RecyclePanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        self.scrollList = find_component(self.gameObject, "itemsView", ScrollListRenderer)
        self.btnClose = find_component(self.gameObject, "btnClose")
        self.btnSellAll = find_component(self.gameObject, "btnSellAll")
        self.txtTitle = find_component(self.gameObject, "txtTitle")
        self.txtSliderDesc = find_component(self.gameObject, "txtSliderDesc")
		--insertInitComp
		--insertOnClick
		local function onClose()
			sendNotification(RecyclePanelNotificationEnum.RecyclePanelNotificationEnum_Close)
		end
		Util.UGUI_AddButtonListener(self.btnClose, onClose)
		local function onSellAll()
			sendNotification(RecyclePanelNotificationEnum.RecyclePanelNotificationEnum_SellAll)
		end
		Util.UGUI_AddButtonListener(self.btnSellAll, onSellAll)
		
		--insertDeclareBtn
    end
end

--insertSetTxt

return _RecyclePanelBase
