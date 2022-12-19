local Director = class(nil, "Director")

function Director:ctor()
    self.actions = {}
    self.count = 0
    self.taggedActions = {}
    self.actors = {} -- 演员列表
end

function Director:AddActor(name, go)
    self.actors[name] = go
end

function Director:FindActor(name)
    local go = self.actors[name]
    if Runtime.CSValid(go) then
        return go
    end
    return GameObject.Find(name)
end

function Director:RemoveAllActors()
    self.actors = {}
end

function Director:Update()
    if self.count == 0 then return end

    local dt = Time.deltaTime
    local needRefreshList = false

    for _, action in ipairs(self.actions) do
        if action:IsFinished() then
            print("Finish", action.name) --@DEL
            needRefreshList = true
            action:CallFinishCallback()
        else
            action:Update(dt)
        end
    end

    -- 减少GC
    if needRefreshList then
        local runningList = {}
        for i, action in ipairs(self.actions) do
            if not action:IsFinished() then
                table.insert(runningList, action)
            end
        end
        self.actions = runningList
        self.count = #runningList
    end
end

function Director:AppendFrameAction(action, channel)
    table.insert(self.actions, action)
    self.count = self.count + 1

    -- 加到tag
    local tag = action:GetTag()
    if tag then
        if self.taggedActions[tag] == nil then
            self.taggedActions[tag] = {}
        end
        table.insert(self.taggedActions, action)
    end
end

function Director:KillAllActionsByTag(tag)
    print('KillAllActionsByTag(tag)', tag) --@DEL
    if tag == nil then
        return
    end
    local remain = {}
    for i, v in ipairs(self.actions) do
        if v:GetTag() ~= tag then
            table.insert(remain, v)
        end
    end
    self.count = #remain
    self.actions = remain
    self.taggedActions[tag] = {}
end

function Director:Clear(closePlaying)
    -- console.lzl("Drama_LOG Director 清理") --@DEL
    if closePlaying then
        if App:IsScreenPlayActive() then
            -- console.lzl("Drama_LOG Director 还在播放") --@DEL
            ForceCloseDrama()
        end
    end
    self.actions = {}
    self.count = 0
    if App.scene and App.scene.interaction then
        App.scene.interaction:CancelInput()
    end
end

return Director