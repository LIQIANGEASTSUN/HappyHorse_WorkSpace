
local NextFrameActions = class(nil, "NextFrameActions")

function NextFrameActions:ctor()
    self:Clean()
end

function NextFrameActions:Clean()
    self.length = 0
    self.callbacks = {}
end

function NextFrameActions:Add(callback)
    self.callbacks[self.length + 1] = callback
    self.length = self.length + 1
end

function NextFrameActions:Execute()
    if self.length == 0 then return end

    local length = self.length
    local worksets = self.callbacks
    self:Clean()

    for i=1, length do
        local callback = worksets[i]
        local status, info = pcall(callback)
        if not status then
            console.error("NextFrameActions:", info)
        end
    end
end

return NextFrameActions