---@class ExpItemController:HomeSceneTopIconBase
local ExpItemController = class("ExpItemController")

function ExpItemController:ctor()
    self.views = {}
end

function ExpItemController:AddView(view)
    table.insert(self.views, view)
end

function ExpItemController:GetView(eVal)
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

function ExpItemController:ForEach(func)
    for k, v in ipairs(self.views) do
        func(k, v)
    end
end

function ExpItemController:OnClick()
    self:ForEach(function(k, v)
        v:OnClick()
    end)
end

function ExpItemController:SetInteractable(val)
    self:ForEach(function(k, v)
        v:SetInteractable(val)
    end)
end

function ExpItemController:SetLevelText(val)
    self:ForEach(function(k, v)
        v:SetLevelText(val)
    end)
end

function ExpItemController:SetSliderValue(val)
    self:ForEach(function(k, v)
        v:SetSliderValue(val)
    end)
end

function ExpItemController:SetStageProgressText(cur, full)
    self:ForEach(function(k, v)
        v:SetStageProgressText(cur, full)
    end)
end

function ExpItemController:TweenNum(toValue, onFinish)
    self:ForEach(function(k, v)
        v:TweenNum(toValue, onFinish)
    end)
end

function ExpItemController:OnHit()
    self:ForEach(function(k, v)
        v:OnHit()
    end)
end

function ExpItemController:GetValue()
    self:GetView():GetValue()
end

function ExpItemController:SetValue(value)
    self:ForEach(function(k, v)
        v:SetValue(value)
    end)
end

function ExpItemController:HandleRedDot()
    self:ForEach(function(k, v)
        v:HandleRedDot()
    end)
end

function ExpItemController:ShowEnterAnim(instant, finishCallback)
    self:GetView():ShowEnterAnim(instant, finishCallback)
end

---@param forceAddValue any for some stupid reason, current prosperity value may not changed
-- function ExpItemController:ShowChangeEffect(num, onComplete, forceAddValue)
--     self:GetView():ShowChangeEffect(num, onComplete, forceAddValue)
-- end

function ExpItemController:GetMainIconGameObject()
    self:GetView():GetMainIconGameObject()
end

function ExpItemController:GetIconGO()
    self:GetView():GetIconGO()
end

function ExpItemController:Dispose()
    self:ForEach(function(_, v)
        v:Dispose()
    end)
    self.views = {}
end

return ExpItemController
