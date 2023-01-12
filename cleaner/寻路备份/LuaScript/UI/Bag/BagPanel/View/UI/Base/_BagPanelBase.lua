--insertRequire

---@class _BagPanelBase:BasePanel
local _BagPanelBase = class(BasePanel)
-- local ScrollRect = CS.UnityEngine.UI.ScrollRect
function _BagPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
    self.btn_close = nil
    self.onClick_btn_close = nil
end

function _BagPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _BagPanelBase:bindView()
    if (self.gameObject ~= nil) then
        local go = self.gameObject
        self.transform = go.transform
        local togTags = {}
        for k = 1, 2 do
            local toggle = find_component(go, string.format("bg/switchTags/tog_%d", k), Toggle)
            toggle.onValueChanged:AddListener(function(state)
                if state then
                    self:SwitchTag(k)
                else
                end
            end)
            local txt = find_component(go, string.format("bg/togSelect_%d/Text", k), Text)
            togTags[k] = {
                toggle = toggle,
                txt = txt
            }
        end
        self.togTags = togTags
        self.txtTittle = find_component(go, "txtTittle", Text)
        self.txtCapacity = find_component(go, "txtCount", Text)
        self.scrollList = find_component(go, "itemsView/view", ScrollListRenderer)
        self.tipChecker = find_component(go, "itemTip", CS.UITipChecker)
        self.tipCanvasGroup = find_component(go, "itemTip", CanvasGroup)
        self.tipTrans = find_component(go, "itemTip").transform
        self.txtTipTittle = find_component(go, "itemTip/txtTittle", Text)
        self.txtTipContent = find_component(go, "itemTip/txtContent", Text)
        self.tipChecker:SetCallback(function()
			self.tipChecker:SetRaycastEnable(false)
			DOTween.Kill(self.tipTrans)
			DOTween.Kill(self.tipCanvasGroup)
			self.tipCanvasGroup.alpha = 0
			self.tipTrans.localScale = Vector3.one * 0.2
		end)

        local function onClose()
            sendNotification(BagPanelNotificationEnum.Close)
        end
        local btnClose = find_component(go, "btnClose")
        Util.UGUI_AddButtonListener(btnClose, onClose)
    end
end

--insertSetTxt

return _BagPanelBase
