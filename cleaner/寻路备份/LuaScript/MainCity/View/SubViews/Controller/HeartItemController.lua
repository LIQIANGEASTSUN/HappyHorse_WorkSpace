local HeartItemController = class("HeartItemController")

function HeartItemController:ctor()
    self.views = {}
end

function HeartItemController:AddView(view)
    table.insert(self.views, view)
end

function HeartItemController:GetView(eVal)
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

function HeartItemController:ForEach(func, ...)
    for k, v in ipairs(self.views) do
        func(k, v, ...)
    end
end

function HeartItemController:Dispose()
    self:ForEach(function(k, v)
        v:Dispose()
    end)
    self.views = {}
end

function HeartItemController:Update()
    self:ForEach(function(k, v)
        v:Update(v)
    end)
end

function HeartItemController:RefreshUI(val)
    self:ForEach(function(k, v)
        v:RefreshUI(val)
    end)
end

function HeartItemController:SetValue(val)
    self:ForEach(function (k, v)
        v:SetValue(val)
    end)
end

return HeartItemController