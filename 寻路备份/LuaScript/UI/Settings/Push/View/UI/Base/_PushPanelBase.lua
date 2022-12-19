--insertRequire

---@class _PushPanelBase:BasePanel
local _PushPanelBase = class(BasePanel)

function _PushPanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
end

function _PushPanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _PushPanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        --insertInitComp
        --insertOnClick
        --insertDeclareBtn
        ---@return pushItem
        local createPushItem = function(gameObject, type)
            ---@class pushItem
            local pushItem = {}
            pushItem.gameObject = gameObject
            pushItem.open = find_component(gameObject, "open")
            pushItem.close = find_component(gameObject, "close")
            pushItem.type = type

            pushItem.Update = function(pushItem)
                pushItem.open:SetActive(pushItem.isOn)
                pushItem.close:SetActive(not pushItem.isOn)
            end

            pushItem.Switch = function(pushItem)
                pushItem.isOn = not pushItem.isOn
                AppServices.Notification:SetIsOpenByType(pushItem.type, pushItem.isOn)
                pushItem:Update()
            end

            pushItem.isOn = AppServices.Notification:GetIsOpenByType(pushItem.type)
            pushItem:Update()

            Util.UGUI_AddButtonListener(
                pushItem.open,
                function()
                    pushItem:Switch()
                end
            )

            Util.UGUI_AddButtonListener(
                pushItem.close,
                function()
                    pushItem:Switch()
                end
            )

            return pushItem
        end
        local itemRoot = find_component(self.gameObject, "Scroll View/Viewport/Content")
        self.energy = createPushItem(find_component(itemRoot, "energy"), AppServices.Notification.E_NOTI_TYPE.Energy)
        self.factory = createPushItem(find_component(itemRoot, "factory"), AppServices.Notification.E_NOTI_TYPE.Factory)
        self.dragon = createPushItem(find_component(itemRoot, "dragon"), AppServices.Notification.E_NOTI_TYPE.Dragon)
        self.timeOrder =
            createPushItem(find_component(itemRoot, "timeOrder"), AppServices.Notification.E_NOTI_TYPE.TimeOrder)

        self.dragonStrength =
            createPushItem(
            find_component(itemRoot, "dragonStrength"),
            AppServices.Notification.E_NOTI_TYPE.DragonStrength
        )
        self.activity =
            createPushItem(find_component(itemRoot, "activity"), AppServices.Notification.E_NOTI_TYPE.Activity)

        local close = find_component(self.gameObject, "close")
        Util.UGUI_AddButtonListener(
            close,
            function()
                PanelManager.closePanel(self.panelVO)
            end
        )
    end
end

--insertSetTxt

return _PushPanelBase
