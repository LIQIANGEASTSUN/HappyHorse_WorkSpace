--insertWidgetsBegin
--    btn_ok    go_rewardItem
--insertWidgetsEnd

--insertRequire
local _SingleRewardPanelBase = require "UI.Common.SingleRewardPanel.View.UI.Base._SingleRewardPanelBase"

---@class SingleRewardPanel:_SingleRewardPanelBase
local SingleRewardPanel = class(_SingleRewardPanelBase)

function SingleRewardPanel:ctor()

end

function SingleRewardPanel:onAfterBindView()
    local args = self.arguments
    local itemId = args.itemTemplateId or args.ItemId or args[1]
    local count = args.count or args.Amount or args[2]
    self.itemId = itemId
    self.count = count
    if string.isEmpty(itemId) then
        WaitExtension.InvokeDelay(function()
            PanelManager.closePanel(GlobalPanelEnum.SingleRewardPanel)
        end)
        return
    end
    self.num.text = count
    local itemIcon = AppServices.ItemIcons
    local metaMgr = AppServices.Meta
    self.num:SetActive(count > 1)
    if ItemId.IsDragon(itemId) then
        self.icon:SetActive(false)
        self.raw_icon:SetActive(true)
        local spriteName = metaMgr:GetItemIcon(itemId)
        itemIcon:SetDragonIcon(raw_icon, spriteName)
    else
        self.icon:SetActive(true)
        self.raw_icon:SetActive(false)
        itemIcon:SetItemIcon(self.icon, itemId)
    end
    self.label_itemName.text = metaMgr:GetItemName(itemId)
    Runtime.Localize(self.label_itemDesc, metaMgr:GetItemDesc(itemId))
end

function SingleRewardPanel:FlyItem()
    UITool.ShowPropsAni(self.itemId, self.count, self.icon.gameObject:GetPosition())
end

return SingleRewardPanel
