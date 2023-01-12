--insertRequire

---@class _ItemReplacePanelBase:BasePanel
local _ItemReplacePanelBase = class(BasePanel)

function _ItemReplacePanelBase:ctor()
    self.gameObject = nil
    self.proxy = nil
    --insertCtor
end

function _ItemReplacePanelBase:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

function _ItemReplacePanelBase:bindView()
    if (self.gameObject ~= nil) then
        --insertInit
        --insertInitComp
        --insertOnClick
        --insertDeclareBtn
        local root = find_component(self.gameObject, "root")
        self.btnGoto = find_component(root, "btn_goto")
        self.itemTemplate = find_component(root, "item")
        self.itemContent = find_component(root, "Scroll View/Viewport/Content", Transform)
    end
end

--insertSetTxt

return _ItemReplacePanelBase
