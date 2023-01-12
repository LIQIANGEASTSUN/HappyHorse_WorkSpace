---@class GlobalFlags
local GlobalFlags = {
    showLoading = true,
    data = {}
}

function GlobalFlags:Reset()
end

function GlobalFlags:SetClickFlag(delay)
    if self.clickTimerId then
        WaitExtension.CancelTimeout(self.clickTimerId)
        self.clickTimerId = nil
    end
    self.clickFlag = true
    WaitExtension.SetTimeout(
        function()
            self.clickTimerId = nil
            self.clickFlag = false
        end,
        delay or 1
    )
end

function GlobalFlags:CanClick()
    return self.clickFlag ~= true
end

function GlobalFlags:SetEnterGameSource(source)
    self.enterGameSource = source
end

function GlobalFlags:GetEnterGameSource()
    return self.enterGameSource
end

function GlobalFlags:Set(key, value)
    self.data[key] = value
end

function GlobalFlags:Get(key, defaultValue)
    return self.data[key] or defaultValue
end

return GlobalFlags
