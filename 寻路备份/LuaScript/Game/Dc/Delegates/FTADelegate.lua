local IDelegate = require("Game.Dc.Delegates.IDelegate")
---@class FTADelegate:IDelegate
local FTADelegate = class(IDelegate)

function FTADelegate:InitEvent()
    local events = {}
    for key, value in pairs(events) do
        self:RegisterEvent(value, function(del, params)
            del:OnFacebookLog(value, params)
        end)
    end
end

---是否可以分享到Meta的Messager App
function FTADelegate:CanShareMessage()
    if self.delegate then
        return self.delegate:CanShareMessage()
    end
end

---分享到Facebook的Timeline
function FTADelegate:Share(content, url, callback)
    if self.delegate then
        local cbk = function(msg)
            Runtime.InvokeCbk(callback, msg)
        end
        self.delegate:Share(content, url, cbk)
    end
end

---分享到Messager一条链接
function FTADelegate:ShareMessage(url, callback)
    if self.delegate then
        local cbk = function(msg)
            Runtime.InvokeCbk(callback, msg)
        end
        self.delegate:ShareMessage(url, cbk)
    end
end

return FTADelegate