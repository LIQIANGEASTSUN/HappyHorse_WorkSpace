local CoinItemController = class("CoinItemController")

function CoinItemController:ctor()
    self.views = {}
end

function CoinItemController:AddView(view)
    table.insert(self.views, view)
end

function CoinItemController:GetView(eVal)
    eVal = eVal or HUD_ICON_ENUM.AUTO
    if eVal == HUD_ICON_ENUM.AUTO then
        local headInfoView = App.scene:GetWidget(CONST.MAINUI.ICONS.HeadInfoView)
        if headInfoView.isHided then
            -- 只有在HeadInfoView在隐藏状态，才使用隐藏的Item
            return self.views[2]
        end
        return self.views[1]
    elseif eVal == HUD_ICON_ENUM.HEAD then
        return self.views[1]
    else
        return self.views[2]
    end
end

function CoinItemController:ForEach(func)
    for k, v in ipairs(self.views) do
        func(k, v)
    end
end

function CoinItemController:Dispose()
    self:ForEach(function(k, v)
        v:Dispose()
    end)
    self.views = {}
end

function CoinItemController:SetCoinNumber(val)
    self:ForEach(function(k, v)
        v:SetCoinNumber(val)
    end)
end

function CoinItemController:OnHit()
    self:ForEach(function(k, v)
        v:OnHit()
    end)
end

function CoinItemController:SetDiamondWithAnimation(val, cbk)
    self:ForEach(function(k, v)
        v:SetDiamondWithAnimation(val, cbk)
    end)
end

return CoinItemController