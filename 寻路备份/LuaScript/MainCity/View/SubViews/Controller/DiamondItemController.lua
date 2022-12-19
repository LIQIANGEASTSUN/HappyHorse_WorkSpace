local DiamondItemController = class("DiamondItemController")

function DiamondItemController:ctor()
    self.views = {}
end

function DiamondItemController:AddView(view)
    table.insert(self.views, view)
end

function DiamondItemController:GetView(eVal)
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

function DiamondItemController:ForEach(func)
    for k, v in ipairs(self.views) do
        func(k, v)
    end
end

function DiamondItemController:Dispose()
    self:ForEach(function(_, v)
        v:Dispose()
    end)
    self.views = {}
end

function DiamondItemController:SetDiamondNumber(val)
    self:ForEach(function(_, v)
        v:SetDiamondNumber(val)
    end)
end

function DiamondItemController:OnHit()
    self:ForEach(function(_, v)
        v:OnHit()
    end)
end

function DiamondItemController:SetDiamondWithAnimation(val, cbk)
    self:ForEach(function(_, v)
        v:SetDiamondWithAnimation(val, cbk)
    end)
end

return DiamondItemController