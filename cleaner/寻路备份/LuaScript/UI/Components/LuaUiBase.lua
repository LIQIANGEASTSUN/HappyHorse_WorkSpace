--every lua script binded with component script in c# should inherit this class
---@class LuaUiBase
LuaUiBase = class()

function LuaUiBase:ctor()
    self.gameObject = nil
    self.transform = nil
    self.behaviour = nil
    self.childrenList = {}
    self.isDisposed = false
end

function LuaUiBase:Init()

end

function LuaUiBase:InitFromGameObject(gameObject)
    self:setGameObject(gameObject)
end

function LuaUiBase:setParams(...)
    self.params = { ... }
end

function LuaUiBase:setGameObject(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
end

function LuaUiBase:setBehaviour(behaviour)
    self.behaviour = behaviour
end

function LuaUiBase:GetRootGO()
    return self.gameObject
end

function LuaUiBase:SetPositionXY(x, y)
    self.gameObject:SetLocalPosition(Vector3(x, y, 0))
end

function LuaUiBase:SetPosition(vector2Pos)
    self.gameObject:SetPosition(vector2Pos)
end

function LuaUiBase:GetRectTransform()
    if self.rectTransform == nil then
        self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
    end
    return self.rectTransform
end

function LuaUiBase:GetAnchoredPosition()
    return self:GetRectTransform().anchoredPosition
end

function LuaUiBase:SetAnchoredPosition(pos)
    local rtf = self:GetRectTransform()
    console.assert(rtf)
    rtf.anchoredPosition = pos
end

function LuaUiBase:IsDisposed()
    return self.isDisposed
end

function LuaUiBase:SetLuaChild(key, value)
    self.childrenList[key] = value
end
function LuaUiBase:GetLuaChild(key)
    return self.childrenList[key]
end

function LuaUiBase:DisposeLua()
    self.isDisposed = true
    -- 先调用子节点的dispose，再destroy game object
    for k, v in pairs(self.childrenList) do
        if not v:IsDisposed() then
            v:DisposeLua()
        end
    end
    self.childrenList = {}
end

function LuaUiBase:DisposeGameObject()
    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
    self.transform = nil
    self.behaviour = nil
end

function LuaUiBase:SetTimeout(key, callback, delay)
    if not self._timers then
        self._timers = {}
    end
    if self._timers[key] then
        self:CancelTimeout(key)
    end
    if not key then
        self._timerKeyIndex = (self._timerKeyIndex or 0) + 1
        key = 'timer_'..self._timerKeyIndex
    end
    self._timers[key] = WaitExtension.SetTimeout(function()
        self._timers[key] = nil
        Runtime.InvokeCbk(callback)
    end, delay)
end

function LuaUiBase:CancelTimeout(key)
    if self._timers[key] then
        WaitExtension.CancelTimeout(self._timers[key])
        self._timers[key] = nil
    end
end

function LuaUiBase:CopyComponent(go, parentGo, num)
    if not self.copyComponents then
        self.copyComponents = {}
    end
    if not self.copyComponents[go] then
        self.copyComponents[go] = {go}
    end
    local have = #self.copyComponents[go]
    if num == 0 and have > 0 then
        for i, v in ipairs(self.copyComponents[go]) do
            v:SetActive(false)
        end
        return
    end
    if have < num then
        for i = have + 1, num do
            local copyGo = BResource.InstantiateFromGO(go)
            if not Runtime.CSValid(copyGo) then
                -- console.lzl('------copy error')
            end
            copyGo.name = go.name .. i
            copyGo.transform:SetParent(parentGo.transform, false)
            copyGo:SetActive(false)
            table.insert(self.copyComponents[go], copyGo)
        end
        have = #self.copyComponents[go]
    end
    local ret = {}
    for i = 1, have do
        local retGo = self.copyComponents[go][i]
        if i <= num then
            retGo:SetActive(true)
            table.insert(ret, retGo)
        else
            retGo:SetActive(false)
        end
    end
    return ret
end

function LuaUiBase:SetComponentVisible(com, visible)
    if Runtime.CSNull(com) then
        return
    end
    if visible then
        com.gameObject:SetActive(true)
    else
        com.gameObject:SetActive(false)
    end
end

function LuaUiBase:DisposeCopyComponents()
    self.copyComponents = nil
end

function LuaUiBase:SetRepeating(callback, delay, interval)
    if not self.timeOutJobList then
        self.timeOutJobList = {}
    end

    local id = WaitExtension.InvokeRepeating(function ()
        local key = table.indexOf(self.timeOutJobList, callback)
        if key then
            Runtime.InvokeCbk(callback, key)
        end
    end, delay, interval)
    --table.insert(self.timeOutJobList,{id = id ,callback = callback})
    self.timeOutJobList[id] = callback
    return id
end

function LuaUiBase:SetDelay(callback, delay,unscale)
    if not self.timeOutJobList then
        self.timeOutJobList = {}
    end

    local id = WaitExtension.SetTimeout(function ()
        local key = table.indexOf(self.timeOutJobList, callback)
        if key then
            Runtime.InvokeCbk(callback, key)
        end
    end, delay, unscale)
    --table.insert(self.timeOutJobList,{id = id ,callback = callback})
    self.timeOutJobList[id] = callback
    return id
end

function LuaUiBase:CancelDelay(id)
    if id ~= nil and self.timeOutJobList[id] then
        WaitExtension.CancelTimeout(id)
        self.timeOutJobList[id] = nil
    end
end

function LuaUiBase:CancelDelayAll()
    if not self.timeOutJobList then
        return
    end
    for id, callback in pairs(self.timeOutJobList) do
        --self:CancelDelay(id)
        WaitExtension.CancelTimeout(id)
    end
    self.timeOutJobList = {}
end

function LuaUiBase:OnHit()
    App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_acquire_resource)
end

function LuaUiBase:Dispose()
    if self._timers then
        for key, tid in pairs(self._timers) do
            WaitExtension.CancelTimeout(tid)
        end
        self._timers = nil
    end
    self:CancelDelayAll()
    self:DisposeCopyComponents()
    self:DisposeLua()
    self:DisposeGameObject()
end

