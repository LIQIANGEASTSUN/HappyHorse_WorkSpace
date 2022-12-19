---@class DiamondLogic
local DiamondLogic = {
    exCount = 0,
    count = AppServices.User:GetItemAmount(ItemId.DIAMOND),
    hasClickWhenFirstOpen = App.mapGuideManager:HasComplete(GuideIDs.subscribe_building)
}

function DiamondLogic:GetHasClickWhenFirstOpen()
    return self.hasClickWhenFirstOpen
end

function DiamondLogic:SetHasClickWhenFirstOpen()
    if self.hasClickWhenFirstOpen then
        return
    end
    self.hasClickWhenFirstOpen = true
end

---@param diamondItem DiamondItem
function DiamondLogic:BindView(diamondItem)
    self.diamondItem = diamondItem
    if self.diamondItem then
        self.diamondItem:SetDiamondNumber(AppServices.User:GetItemAmount(ItemId.DIAMOND))
    end
end
function DiamondLogic:GetView(eVal)
    if type(self.diamondItem.GetView) == "function" then
        return self.diamondItem:GetView(eVal)
    end
    return self.diamondItem
end

function DiamondLogic:SetDiamond(value, banRefreshNumber)
    AppServices.User:SetDiamond(value)

end

function DiamondLogic:AddDiamond(count)
    AppServices.User:AddItem(ItemId.DIAMOND, count, "DiamondLogic")
end

function DiamondLogic:UseDiamond(count, banRefreshNumber, method)
    AppServices.User:UseItem(ItemId.DIAMOND, count, method)
    if not banRefreshNumber then
        self:RefreshDiamondNumber()
    end
end

function DiamondLogic:UnbindView()
    self.diamondItem = nil
end

function DiamondLogic:RefreshDiamondNumber() --在usermanager 里已经第一时间修改，但要等待动画效果后再显示
    local diamondNumber = AppServices.User:GetItemAmount(ItemId.DIAMOND)
    if self.diamondItem then
        if self.count > diamondNumber then
            self.diamondItem:SetDiamondNumber(diamondNumber)
            -- App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_PayDiamond)
        elseif self.count < diamondNumber then
            self.diamondItem:SetDiamondNumber(diamondNumber)
            -- App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_GetDiamond)
        end
    end
    self.count = diamondNumber
end

function DiamondLogic:RefreshDiamondNumberWithAnimation(animFinishCallback)
    if self.diamondItem ~= nil then
        self.diamondItem:OnHit()
        self.diamondItem:SetDiamondWithAnimation(AppServices.User:GetItemAmount(ItemId.DIAMOND), animFinishCallback)
    end
    self.count = AppServices.User:GetItemAmount(ItemId.DIAMOND)
end

function DiamondLogic:GetExValue()
    return self.count
end

return DiamondLogic