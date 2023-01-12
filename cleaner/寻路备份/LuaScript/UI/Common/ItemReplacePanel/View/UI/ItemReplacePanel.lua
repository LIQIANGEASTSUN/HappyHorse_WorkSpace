--insertWidgetsBegin
--insertWidgetsEnd

--insertRequire
local _ItemReplacePanelBase = require "UI.Common.ItemReplacePanel.View.UI.Base._ItemReplacePanelBase"

---@class ItemReplacePanel:_ItemReplacePanelBase
local ItemReplacePanel = class(_ItemReplacePanelBase)

function ItemReplacePanel:ctor()
end

function ItemReplacePanel:onAfterBindView()
    self:SetList()
    Util.UGUI_AddButtonListener(
        self.btnGoto,
        function()
            PanelManager.closePanel(self.panelVO)
        end
    )
end

function ItemReplacePanel:SetList()
    for index, value in ipairs(self.arguments.data) do
        local oldId = tostring(value[1])
        local newId = tostring(value[2])
        local rate = value[3]
        local oldCount = AppServices.User:GetItemAmount(oldId)
        if oldCount > 0 then
            local go = GameObject.Instantiate(self.itemTemplate)
            go.transform:SetParent(self.itemContent, false)
            go:SetActive(true)
            local icon1 = find_component(go, "icon1", Image)
            local icon2 = find_component(go, "icon2", Image)
            local count1 = find_component(go, "count1", Text)
            local count2 = find_component(go, "count2", Text)
            icon1.sprite = AppServices.ItemIcons:GetSprite(oldId)
            icon2.sprite = AppServices.ItemIcons:GetSprite(newId)
            count1.text = oldCount
            count2.text = oldCount * rate
        end
    end
end

function ItemReplacePanel:refreshUI()
end

return ItemReplacePanel
