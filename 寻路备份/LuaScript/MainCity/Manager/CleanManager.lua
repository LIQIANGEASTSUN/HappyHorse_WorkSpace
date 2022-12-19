local opacity = 1 --不透明
local transparency = 0.5 --半透明

local sliderAssetPath = "Prefab/UI/Common/NpcSlider.prefab"
local eCharactorAnimName = {
    ["Shovel"] = "Cleargrass",
    ["Hatchet"] = "Cleartree",
    ["Pickaxe"] = "Chiselstone",
    ["building"] = "Clearbuilding",
    ["box"] = "Clearbox"
}
local animWithNoTool = {"building", "box"}

local eToolAnimName = {
    ["Shovel"] = function(player)
        if player and player.name == "Maleplayer" then
            return "Cleargrass_M_"
        end
        return "Cleargrass_F_"
    end,
    ["Hatchet"] = function(player)
        if player and player.name == "Maleplayer" then
            return "Cleartree_M_"
        end
        return "Cleartree_F_"
    end,
    ["Pickaxe"] = function(player)
        if player and player.name == "Maleplayer" then
            return "Chiselstone_M_"
        end
        return "Chiselstone_F_"
    end
}

local effectNames = {
    ["Shovel"] = "E_CleanupGrass",
    ["Hatchet"] = "E_CleanupTree",
    ["Pickaxe"] = "E_CleanupStone"
}
local PlaySound =
    setmetatable(
    {
        Shovel = function()
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_clear_grass)
        end,
        Hatchet = function()
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_clear_wood)
        end,
        Pickaxe = function()
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_clear_stones)
        end
    },
    {
        __index = function(t, k)
            App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_clear_plants)
        end
    }
)

--障碍物被清除特效表现的延迟时间
local effectDelays = {
    ["Shovel"] = 0.6,
    ["Hatchet"] = 0.8,
    ["Pickaxe"] = 0.9
}

local rewardDelays = {
    ["Shovel"] = 1,
    ["Hatchet"] = 1.6,
    ["Pickaxe"] = 1.6,
    ["building"] = 1.6,
    ["box"] = 1.6
}

local outAnimDelays = {
    ["Shovel"] = 1.4,
    ["Hatchet"] = 1.6,
    ["Pickaxe"] = 1.6,
    ["building"] = 1.6,
    ["box"] = 1.6
}

local cleanMethods = {
    [ItemId.DIAMOND] = CleanMethods.diamond,
    [ItemId.ENERGY] = CleanMethods.player
}

---@type CleanManager
local CleanManager = {
    queue = {},
    queueCleaning = nil,
    state = nil,
    player = nil,
    tool = nil,
    agent = nil,
    cleanEffects = {}
}

function CleanManager:Destory()
    self:StopCleanQueue()
    self.player = nil
    self.agent = nil
    self.tool = nil
    self.cleanEffects = nil
    AppServices.Clean = nil
end

----队列逻辑----
function CleanManager:InsertCleanQueue(agent)
    if agent:IsCleaning() then
        return
    end
    agent:SetCleanState(true)
    agent:SetHighlight(false)
    agent:SetTransparency(transparency)
    table.insert(self.queue, agent)
    if not self.queueCleaning then
        self.queueCleaning = true
        self:SwitchState(CleanAgentState.PopAgent)
    end
end

function CleanManager:SwitchState(state)
    if not self.queueCleaning then
        return
    end
    if not self.state or self.state ~= state then
        self.state = state
    end

    if self.state == CleanAgentState.PopAgent then
        self:PopCleanAgent()
    elseif self.state == CleanAgentState.CleanDirectly then
        self:CleanAgentDirectly() --直接清除
    elseif self.state == CleanAgentState.Prepare then
        self:PrepareBeforeClean()
    elseif self.state == CleanAgentState.ShowClean then
        self:ShowClean()
    elseif self.state == CleanAgentState.showEnd then
        self:PlayCharacterEndCollect()
    elseif self.state == CleanAgentState.Exit then
        self:StopCleanQueue()
    end
end

function CleanManager:PopCleanAgent()
    if #self.queue == 0 then
        return self:SwitchState(CleanAgentState.Exit)
    end

    self.agent = table.remove(self.queue, 1)
    if not self.agent or not self.agent.alive then
        return self:SwitchState(CleanAgentState.PopAgent)
    end

    return self:CleanAgent()
end

--开始对目标agent进行清除
function CleanManager:CleanAgent()
    console.lh("CleanAgent") --@DEL
    local itemId = self.agent:GetCurrentCost()
    local userItemCnt = AppServices.User:GetItemAmount(itemId)
    --道具不足直接结束整个清除过程
    if itemId ~= 0 and userItemCnt < 1 then
        local description = Runtime.Translate("errorcode_2001")
        AppServices.UITextTip:Show(description)
        return self:SwitchState(CleanAgentState.Exit)
    end
    local playerNeeded = self.agent:NeedPlayer()
    self.agent:SetPrune(false)
    if not playerNeeded then
        self:SwitchState(CleanAgentState.CleanDirectly)
    else
        self:SwitchState(CleanAgentState.Prepare)
    end
end

function CleanManager:CleanAgentDirectly()
    local itemId = self.agent:GetCurrentCost()
    self.agent:StartClean(
        cleanMethods[tostring(itemId)],
        function()
            if self.state == CleanAgentState.Exit then
                return
            end
            self.agent:SetCleanState(false)
            if self.agent.alive then
                self.agent:SetTransparency(opacity)
            end
            self:SwitchState(CleanAgentState.PopAgent)
        end
    )
end

function CleanManager:PrepareBeforeClean()
    --角色移动
    self:MovePlayer(
        function(standPos, lookAtPos)
            if not self.queueCleaning then
                return
            end

            self.agent:StartClean(
                CleanMethods.player,
                function(refreshAgentCbk, response)
                    if not self.queueCleaning then
                        Runtime.InvokeCbk(refreshAgentCbk, response)
                    else
                        self.refreshAgentCbk = refreshAgentCbk
                        self.cleanResponse = response
                    end
                end
            )

            --Get tool and set position and direction
            self:PrepareCleanTool(standPos, lookAtPos)

            local cnt = 2
            local function afterPrepare()
                if cnt > 0 then
                    return
                end
                self:SwitchState(CleanAgentState.ShowClean)
            end

            self:CreateCleanEffect(
                function()
                    cnt = cnt - 1
                    Runtime.InvokeCbk(afterPrepare)
                end
            )

            if Runtime.CSValid(self.goSlider) then
                self.goSlider:SetActive(true)
                self:SetBoneFollow()
                cnt = cnt - 1
                Runtime.InvokeCbk(afterPrepare)
            else
                local function onLoaded()
                    cnt = cnt - 1
                    if not self.player or Runtime.CSNull(self.player.renderObj) then
                        return Runtime.InvokeCbk(afterPrepare)
                    end
                    local go = BResource.InstantiateFromAssetName(sliderAssetPath)
                    if Runtime.CSValid(go) then
                        self.goSlider = go
                        self.slider = find_component(self.goSlider, "canvas/slider", Slider)
                        self.slider.value = 0
                        self:SetBoneFollow()
                    end
                    Runtime.InvokeCbk(afterPrepare)
                end
                App.buildingAssetsManager:LoadAssets({sliderAssetPath}, onLoaded)
            end
        end
    )
end

function CleanManager:ShowClean()
    console.lh("start show clean anim") --@DEL
    self:PlayCleanAnim()
    local animName = eCharactorAnimName[self.toolName] .. "_idle"
    local idle_duration = AnimatorEx.GetClipLength(self.player.renderObj, animName)
    self:TryRefreshAgent()
    if self.tool then
        self:RepeatCleanEffect(idle_duration)
    end
    self:TryRepeatSlider(idle_duration)
end

function CleanManager:MovePlayer(callback)
    if self.tool and Runtime.CSValid(self.tool.renderObj) then
        self.tool.renderObj:SetActive(false)
        self.tool = nil
    end
    self.player = AppServices.Task:GetInteractivePlayer()
    self.player:SetBusyState(true)
    local position = self:CalcPlayerPos()
    position = position:Flat()
    local afterMoveFinished = function(canMove)
        if self.state == CleanAgentState.Exit then
            return
        end
        if not canMove then
            self.player = AppServices.Task:GetInteractivePlayer()
            self.player.renderObj.transform:LookAt(position)
            console.lh("clean player Posiiton:", position[0], position[1], position[2]) --@DEL
            self.player:SetIdlePaused(true)
            self.player.renderObj:SetPosition(position)
        end

        local agentPos = self.agent:GetWorldPosition()
        local targetPos = Vector3(agentPos[0], 0, agentPos[2])
        self.player.transform:LookAt(targetPos)
        Runtime.InvokeCbk(callback, position, targetPos)
    end
    console.lh("MovePlayer: StartMove") --@DEL
    self.player:StartMove(position, afterMoveFinished)
end

function CleanManager:PrepareCleanTool(position, lookAtPos)
    local name = self.agent:GetCleanToolName()
    self.toolName = name == "" and "Shovel" or name
    if table.exists(animWithNoTool, name) then
        return
    end
    self.tool = CharacterManager.Instance():Get(self.toolName)
    self.tool.renderObj:SetPosition(self.player:GetPosition())
    self.tool.renderObj:SetActive(true)
    self.tool:DoFade(1, 0.2)
    self.tool.renderObj:SetPosition(position)
    self.tool.transform:LookAt(lookAtPos)
end

function CleanManager:CalcPlayerPos()
    local mapMgr = App.scene.mapManager

    local function canGridStand(grid_x, grid_z)
        local isPassable = mapMgr:IsPassable(grid_x, grid_z)
        if not isPassable then
            return -1
        end
        local unlockState = mapMgr:GetState(grid_x, grid_z)
        if unlockState == CleanState.cleared then
            return 2
        end
        if unlockState == CleanState.clearing then
            return 1
        end
        return 0
    end

    local agentPos = self.agent:GetWorldPosition()
    local halfSize = self.agent:GetRender().collider.bounds.extents[0] --获取碰撞体在x轴上一半的长度
    local offset = self.toolName == "Hatchet" and 0.3 or halfSize --角色采集站立点与障碍物世界坐标在坐标轴上的偏移量

    --获取障碍物周围一圈的格子
    local grids = {} --存储格子坐标
    local count = 0
    local x, z = mapMgr:ToLocal(agentPos)
    local sx, sz = self.agent:GetSize()
    for i = z + sz - 1, z, -1 do
        count = count + 1
        grids[count] = {x = x + sx, z = i, direction = "right", canStand = 0}
    end
    for i = z, z + sz - 1 do
        count = count + 1
        grids[count] = {x = x - 1, z = i, direction = "left", canStand = 0}
    end
    for i = x + sx - 1, x, -1 do
        count = count + 1
        grids[count] = {x = i, z = z - 1, direction = "bottom", canStand = 0}
    end
    for i = x, x + sx - 1 do
        count = count + 1
        grids[count] = {x = i, z = z + sz, direction = "top", canStand = 0}
    end

    for _, g in ipairs(grids) do
        local state = canGridStand(g.x, g.z)
        g.canStand = state
    end

    --计算最佳位置
    for k = 2, 1, -1 do
        local standGrids = {}
        for _, g in ipairs(grids) do
            if g.canStand == k then
                table.insert(standGrids, g)
            end
        end
        if #standGrids > 0 then
            local minDistance
            local bestPos
            local playerPos = self.player:GetPosition()
            for _, g in pairs(standGrids) do
                local pos = mapMgr:ToWorld(g.x, g.z)
                local distance = Vector3.Distance(playerPos, pos)
                if not minDistance or distance < minDistance then
                    minDistance = distance
                    bestPos = pos
                end
            end
            local dir = (bestPos - agentPos).normalized
            return agentPos + dir * offset
        end
    end

    for _, g in ipairs(grids) do
        local type = mapMgr:GetGridType(g.x, g.z)
        if type == TileType.ROAD then
            local pos = mapMgr:ToWorld(g.x, g.z)
            local dir = (pos - agentPos).normalized
            return agentPos + dir * offset
        end
    end

    console.print(nil, "障碍物周围竟然没找到合适的格子！") --@DEL
    return Vector3(agentPos[0] - 0.2, 0, agentPos[2] + 0.2) --没找到合适的格子也不让站障碍物上，只能强站偏上一点点。。。
end

function CleanManager:PlayCleanAnim()
    local trigger_P = eCharactorAnimName[self.toolName] .. "_in"
    self.player:PlayAnimation(trigger_P)
    if self.tool then
        local getToolAnim = eToolAnimName[self.toolName]
        if getToolAnim then
            local trigger_T = getToolAnim(self.player) .. "in"
            self.tool:PlayAnimation(trigger_T)
        end
    end
end

function CleanManager:SetBoneFollow()
    self.comFollow = self.goSlider:AddComponent(typeof(BoneFollower))
    self.comFollow.target = self.player.renderObj
    self.comFollow.offset = Vector3(0, 1, 0)
    self.comFollow.distance = 0
end

local function refreshAgent(mgr)
    mgr.hadRefresh = true

    if mgr.agent and mgr.agent.alive then
        mgr.agent:SetCleanState(false)
        mgr.agent:SetTransparency(opacity)
    end

    local refreshAgentCbk, cleanResponse = mgr.refreshAgentCbk, mgr.cleanResponse
    mgr.refreshAgentCbk, mgr.cleanResponse = nil, nil
    Runtime.InvokeCbk(refreshAgentCbk, cleanResponse)
end

function CleanManager:TryRefreshAgent()
    local refreshAgentTime = 0
    local duration = rewardDelays[self.toolName]
    if not self.refreshAgentId then
        self.refreshAgentId =
            WaitExtension.InvokeRepeating(
            function()
                refreshAgentTime = refreshAgentTime + 0.1
                if refreshAgentTime >= duration then
                    WaitExtension.CancelTimeout(self.refreshAgentId)
                    self.refreshAgentId = nil
                    if self.refreshAgentCbk then
                        Runtime.InvokeCbk(refreshAgent, self)
                    end
                end
            end,
            0,
            0.1
        )
    end
end

function CleanManager:TryRepeatSlider(idle_duration)
    local value = 0
    self:SetSliderValue(0)
    local duration = outAnimDelays[self.toolName]
    if not self.sliderDelayId then
        self:PlaySound(self.toolName)
        self.sliderDelayId =
            WaitExtension.InvokeRepeating(
            function()
                value = value + Time.deltaTime
                self:SetSliderValue(value / duration)
                if value >= duration then
                    WaitExtension.CancelTimeout(self.sliderDelayId)
                    self.sliderDelayId = nil
                    if not self.hadRefresh then
                        if not self.sliderRepeatId then
                            value = 0
                            self.sliderRepeatId =
                                WaitExtension.InvokeRepeating(
                                function()
                                    if value == 0 then
                                        self:PlaySound(self.toolName)
                                    end
                                    value = value + Time.deltaTime
                                    self:SetSliderValue(value / idle_duration)
                                    if value >= idle_duration then
                                        if self.refreshAgentCbk then
                                            Runtime.InvokeCbk(refreshAgent, self)
                                        end
                                        if self.hadRefresh then
                                            if self.sliderRepeatId then
                                                WaitExtension.CancelTimeout(self.sliderRepeatId)
                                                self.sliderRepeatId = nil
                                            end
                                            self:SwitchState(CleanAgentState.showEnd)
                                        else
                                            value = 0
                                        end
                                    end
                                end,
                                0,
                                0
                            )
                        end
                    else
                        self:SwitchState(CleanAgentState.showEnd)
                    end
                end
            end,
            0,
            0
        )
    end
end

function CleanManager:PlaySound(toolName)
    if self.soundTimer then
        WaitExtension.CancelTimeout(self.soundTimer)
        self.soundTimer = nil
    end
    self.soundTimer =
        WaitExtension.SetTimeout(
        function()
            self.soundTimer = nil
            local soundHandler = PlaySound[toolName]
            Runtime.InvokeCbk(soundHandler)
        end,
        0.5
    )
end
function CleanManager:StopSound()
    if self.soundTimer then
        WaitExtension.CancelTimeout(self.soundTimer)
        self.soundTimer = nil
    end
end

function CleanManager:RepeatCleanEffect(idle_duration)
    local cleanEffectTime = 0
    local duration = effectDelays[self.toolName]
    if not self.cleanEffectDelayId then
        self.cleanEffectDelayId =
            WaitExtension.InvokeRepeating(
            function()
                cleanEffectTime = cleanEffectTime + 0.1
                if cleanEffectTime >= duration then
                    WaitExtension.CancelTimeout(self.cleanEffectDelayId)
                    self.cleanEffectDelayId = nil
                    self:ShowCleanEffect()
                    self.cleanEffectRepeatId =
                        WaitExtension.InvokeRepeating(
                        function()
                            self:ShowCleanEffect()
                        end,
                        0,
                        idle_duration
                    )
                end
            end,
            0,
            0.1
        )
    end
end

function CleanManager:SetSliderValue(value)
    if Runtime.CSValid(self.slider) then
        self.slider.value = value
    end
end

function CleanManager:CreateCleanEffect(callback)
    local effectName = effectNames[self.toolName]
    if not effectName or Runtime.CSValid(self.cleanEffects[effectName]) then
        return Runtime.InvokeCbk(callback)
    end
    local path = string.format("Prefab/ScreenPlays/DragonEffect/%s.prefab", effectName)
    local function onLoadFinish()
        local go = BResource.InstantiateFromAssetName(path)
        go:SetActive(false)
        self.cleanEffects[effectName] = go
        Runtime.InvokeCbk(callback)
    end
    App.commonAssetsManager:LoadAssets({path}, onLoadFinish)
end

function CleanManager:ShowCleanEffect()
    local effectName = effectNames[self.toolName]
    if not effectName or Runtime.CSNull(self.cleanEffects[effectName]) then
        return
    end
    local render = self.agent:GetRender()
    if not render or Runtime.CSNull(render.gameObject) then
        return
    end

    self.cleanEffects[effectName]:SetParent(render.gameObject, false)
    if self.toolName == "Hatchet" then
        render.gameObject.transform:DOPunchPosition(Vector3(0.01, 0, 0.01), 0.2, 16, 1)
        self.cleanEffects[effectName]:SetLocalPosition(Vector3(0, 0.6, 0)) --砍树特效位置要跟砍点对上
    end
    self.cleanEffects[effectName]:SetActive(false)
    self.cleanEffects[effectName]:SetActive(true)
end

function CleanManager:PlayCharacterEndCollect()
    if self.tool and Runtime.CSValid(self.tool.renderObj) then
        local trigger_T = eToolAnimName[self.toolName](self.player) .. "out"
        self.tool:PlayAnimation(trigger_T)
        local tween = self.tool:DoFade(0, 0.2)
        tween:OnComplete(
            function()
                if self.tool and Runtime.CSValid(self.tool.renderObj) then
                    self.tool.renderObj:SetActive(false)
                    self.tool = nil
                end
            end
        )
    end
    if Runtime.CSValid(self.goSlider) then
        self.goSlider:SetActive(false)
    end
    if Runtime.CSValid(self.comFollow) then
        Runtime.CSDestroy(self.comFollow)
        self.comFollow = nil
    end

    if self.cleanEffectRepeatId then
        WaitExtension.CancelTimeout(self.cleanEffectRepeatId)
        self.cleanEffectRepeatId = nil
    end
    self.hadRefresh = nil

    if self.player and Runtime.CSValid(self.player.renderObj) then
        local trigger_P = eCharactorAnimName[self.toolName] .. "_out"
        local out_duration = AnimatorEx.GetClipLength(self.player.renderObj, trigger_P)
        self.player:PlayAnimation(trigger_P)
        if not self.endCollectId then
            self.endCollectId =
                WaitExtension.SetTimeout(
                function()
                    self.endCollectId = nil
                    self:SwitchState(CleanAgentState.PopAgent)
                end,
                out_duration
            )
        end
    else
        self:SwitchState(CleanAgentState.PopAgent)
    end
end

function CleanManager:StopCleanQueue()
    console.lh("StopCleanQueue：queueCleaning is ", self.queueCleaning) --@DEL
    if not self.queueCleaning then
        return
    end
    self.queueCleaning = false

    if self.refreshAgentCbk then
        Runtime.InvokeCbk(self.refreshAgentCbk, self.cleanResponse)
        self.refreshAgentCbk = nil
        self.cleanResponse = nil
    end

    if self.agent.alive then
        self.agent:SetCleanState(false)
        self.agent:SetTransparency(opacity)
    end

    if #self.queue > 0 then
        for _, agent in pairs(self.queue) do
            agent:SetCleanState(false)
            if agent.alive then
                agent:SetTransparency(opacity)
            end
        end
        self.queue = {}
    end

    local players = AppServices.Task:GetAllInteractivePlayers()
    for _, player in pairs(players) do
        player:SetBusyState(false)
        player:SetIdlePaused(false)
        if Runtime.CSValid(player:GetGameObject()) then
            player:PlayAnimation("defaultIdle")
        end
    end

    if self.endCollectId then
        WaitExtension.CancelTimeout(self.endCollectId)
        self.endCollectId = nil
    end

    if self.tool and Runtime.CSValid(self.tool.renderObj) then
        self.tool.renderObj:SetActive(false)
        self.tool = nil
    end

    if Runtime.CSValid(self.goSlider) then
        self.goSlider:SetActive(false)
    end

    if self.cleanEffectDelayId then
        WaitExtension.CancelTimeout(self.cleanEffectDelayId)
        self.cleanEffectDelayId = nil
    end

    if self.cleanEffectRepeatId then
        WaitExtension.CancelTimeout(self.cleanEffectRepeatId)
        self.cleanEffectRepeatId = nil
    end
    self:StopSound()

    if self.refreshAgentId then
        WaitExtension.CancelTimeout(self.refreshAgentId)
        self.refreshAgentId = nil
    end

    if self.sliderDelayId then
        WaitExtension.CancelTimeout(self.sliderDelayId)
        self.sliderDelayId = nil
    end

    if self.sliderRepeatId then
        WaitExtension.CancelTimeout(self.sliderRepeatId)
        self.sliderRepeatId = nil
    end

    self.agent = nil
    self.hadRefresh = nil
end

---@param sceneId string 当前场景ID
---@param plantId string 当前障碍物ID
---@param requestCbk function 请求回调
function CleanManager:RequestObjectClean(sceneId, plantId, requestCbk)
    local function onSuccess(response)
        local msg = Net.Converter.ConvertClearPlantResponse(response)
        if msg.creatures then
            AppServices.DragonMaze.powerChangeInfo =
                AppServices.MagicalCreatures:SyncDragonDataWithServer(msg.creatures)
        end
        Runtime.InvokeCbk(requestCbk, msg)
    end
    local function onFailed(eCode)
        Runtime.InvokeCbk(requestCbk)
        ErrorHandler.ShowErrorPanel(eCode)
    end
    Net.Scenemodulemsg_25302_ClearPlant_Request({sceneId = sceneId, plantId = plantId}, onFailed, onSuccess, nil, false)
end

return CleanManager
