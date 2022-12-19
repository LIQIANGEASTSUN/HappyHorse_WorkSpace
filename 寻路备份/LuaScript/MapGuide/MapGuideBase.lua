local MapGuideBase = {}

local optionHandlers = {}
local eventHandles = {}

local mgr = nil

function MapGuideBase.Create(config, indexInSeries, params)
    local instance = {}
    setmetatable(instance, {__index = MapGuideBase})
    instance:Init(config, indexInSeries, params)
    if not config.weak then
        DcDelegates:Log(SDK_EVENT.start_guide, {guideName = config.id, index = indexInSeries})
    end
    return instance
end

function MapGuideBase:Init(config, indexInSeries, params)
    self.id = config.id
    self.config = config
    self.indexInSeries = indexInSeries
    self.stepIndex = 0
    self.params = params
    self.stepIds = {}
    mgr = App.mapGuideManager
    self:HandleStepIds(config.steps)
end

function MapGuideBase:HandleStepIds(steps)
    if not steps then
        return
    end
    for k, v in ipairs(steps) do
        if v.id then
            self.stepIds[v.id] = k
        end
    end
end

function MapGuideBase:GetValue(func, extraParams)
    if func and type(func) == "function" then
        return func(self.params, extraParams)
    end
    return func
end

function MapGuideBase:HandleEvent(eventName, params)
    local configEvent = self.config.configEvent
    if configEvent then
        local value = eventHandles[eventName](self, params, self.config.configEvent)
        if value then
            return
        end
    end
    if not self.currentStep then
        return
    end
    local jumpEvent = self.currentStep.jumpEvent
    if jumpEvent then
        if jumpEvent.name == eventName then
            local jump = eventHandles[eventName](self, params, jumpEvent)
            if jump then
                self.jumpStep = jumpEvent.step
                self:NextStep()
                return
            end
        end
    end
    if self.waitingStartEvent then
        local startEvents = self.currentStep.startEvent
        for k, v in pairs(startEvents) do
            if eventName == v.name then
                print("$$$$$$$$$$$$ handle Start Event", eventName, params) --@DEL
                local stepStart = eventHandles[eventName](self, params, v)
                if stepStart then
                    self.waitingStartEvent = false
                    local ok = self:CheckStep(self.currentStep)
                    if not ok then
                        return
                    end
                    self:SetOptions(self.currentStep.options)
                    if not self.currentStep.finishEvent then
                        self:NextStep()
                    end
                end
                return
            end
        end
    else
        local finishEvent = self.currentStep.finishEvent
        if finishEvent and eventName == finishEvent.name then
            local stepComplete = eventHandles[eventName](self, params, finishEvent)
            if stepComplete then
                print("StepComplete") --@DEL
                self:NextStep()
                return
            end
        end
        local fallback = self.currentStep.fallback
        if fallback and eventName == fallback.name then
            local isfallback = self:GetValue(fallback.value, params)
            if isfallback then
                self.fallback = true
                self:NextStep()
                return
            end
        end
        local stepEvent = self.currentStep.stepEvent
        if stepEvent then
            for _, v in ipairs(stepEvent) do
                if v.name == eventName then
                    local isOk = eventHandles[eventName](self, params, v)
                    if isOk then
                        break
                    end
                end
            end
        end
    end
end

function MapGuideBase:Start()
    mgr:SetCurrentGuide(self)
    if self.config.init then
        Runtime.InvokeCbk(self.config.init, self.params)
    end
    if self.config.delay then
        WaitExtension.SetTimeout(
            function()
                if self.config.disableAll ~= false then
                    mgr:DisableAll()
                end
                self:NextStep()
            end,
            self.config.delay
        )
    else
        if self.config.disableAll ~= false then
            mgr:DisableAll()
        end
        self:NextStep()
    end
end

function MapGuideBase:GetGuideCanvas()
    if Runtime.CSNull(self.guideCanvas) then
        self.guideCanvas = App.scene.canvas
    end

    return self.guideCanvas
end

function MapGuideBase:IsWeakStep()
    if self.currentStep then
        return self.currentStep.weakStep
    end
end

function MapGuideBase:NextStep()
    -- 允许在step结束时设置一些options，为下一个引导做准备
    if self.currentStep then
        if self.currentStep.finishOptions then
            self:SetOptions(self.currentStep.finishOptions)
        end
    end
    self.stepIndex = self.stepIndex + 1
    if self.jumpStep then
        self.stepIndex = self.stepIds[self.jumpStep] or self.jumpStep
        self.jumpStep = nil
    end
    if self.fallback then
        local fallback = self.currentStep.fallback
        self.stepIndex = fallback.step
    end
    local stepConfig = self.config.steps[self.stepIndex]
    if not stepConfig then
        self:Finish()
    else
        -- jump step某些情况下某些step不走
        local jump = stepConfig.jump
        if jump and self:GetValue(jump.value) then
            local step = self:GetValue(jump.step)
            if step then
                self.jumpStep = step
            end
            self.currentStep = stepConfig
            self:NextStep()
        else
            if stepConfig.delayRun then
                WaitExtension.SetTimeout(
                    function()
                        self:RunStep(stepConfig)
                    end,
                    stepConfig.delayRun
                )
            else
                self:RunStep(stepConfig)
            end
        end
    end
end

function MapGuideBase:RunStep(stepConfig)
    console.systrace("running step", self.stepIndex) --@DEL
    if not stepConfig.weakStep then
        DcDelegates:Log(SDK_EVENT.start_guide, {guideName = self.id, stepId = self.stepIndex})
    end
    self:ClearCurrentStep()
    self.currentStep = stepConfig

    if stepConfig.stepCondition then
        local val = self:GetValue(stepConfig.stepCondition)
        if not val then
            self:Finish()
            return
        end
    end

    if stepConfig.beforeRunOptions then
        self:SetOptions(stepConfig.beforeRunOptions)
    end
    local flag = true
    local checkEvent = stepConfig.checkEvent ---检查开始事件或者结束事件是否有效，有效则等待事件
    if checkEvent and checkEvent.name == "startEvent" then
        flag = self:GetValue(checkEvent.value)
    end
    if flag and self.currentStep.startEvent and not self.fallback then
        self.waitingStartEvent = true
        return
    elseif stepConfig.options then
        self:SetOptions(stepConfig.options)
        self.fallback = nil
    end
    if not self.waitingStartEvent then
        local ok = self:CheckStep(stepConfig)
        if not ok then
            return
        end
    end
    if not self.currentStep.finishEvent then
        self:NextStep()
    end
end

function MapGuideBase:CheckStep(stepConfig)
    local checkStep = stepConfig.checkStep
    if checkStep then
        local val = self:GetValue(checkStep.value)
        if not val then
            self.config.dontMarkComplete = checkStep.dontMarkComplete
            self:Finish()
        end
        return val
    end
    return true
end

function MapGuideBase:SetOptions(options)
    if not options then
        return
    end
    for k, v in pairs(options) do
        print("$$$$$$$", "SetOptions:", k, v) --@DEL
        optionHandlers[k](self, v)
    end
end

function MapGuideBase:ClearCurrentStep()
    if self.timerId then
        WaitExtension.CancelTimeout(self.timerId)
        self.timerId = nil
    end
    if self.handActionId then
        if self.sequence then
            self.sequence:Kill()
            self.sequence = nil
        end
        WaitExtension.CancelTimeout(self.handActionId)
        self.handActionId = nil
    end
    if self.setHandTid then
        WaitExtension.CancelTimeout(self.setHandTid)
        self.setHandTid = nil
    end
    if self.handTweenTrans then
        DOTween.Kill(self.handTweenTrans)
    end
    Runtime.CSDestroy(self.hand)
    Runtime.CSDestroy(self.mask)
    Runtime.CSDestroy(self.skipButton)

    self.hand = nil
    self.mask = nil
    self.handTweenTrans = nil
    self.skipButton = nil
    self.waitingStartEvent = false
end

function MapGuideBase:Finish()
    self:ClearCurrentStep()
    -- 允许引导不清除flags，保证下一步引导开始前，一些东西继续不能操作
    if not self.config.dontClearFlags then
        mgr:ClearFlags()
    end
    mgr:SetCurrentGuide(nil)
    if self.config.afterSeriesFinishOptions then
        self:SetOptions(self.config.afterSeriesFinishOptions)
    end
    if not self.config.dontInvokeCallback then
        mgr:CallGuideFinishCallback()
    end
    if not self.config.dontMarkComplete then
        mgr:MarkGuideComplete(self.id)
        DcDelegates:Log(SDK_EVENT.complete_guide, {guideName = self.id, stepId = self.stepIndex})
    end
    if self.config.nextGuide then
        local next = self:GetValue(self.config.nextGuide)
        mgr:StartSeries(next)
    end
    self.params = nil
    MessageDispatcher:SendMessage(MessageType.Global_Guide_Finish, self.id)
end

function MapGuideBase:Skip()
    DcDelegates:Log("map_guide_skip", {id = self.id})
    self:ClearCurrentStep()
    -- skip前面几步不会标记为完成
    console.systrace("onSkip") --@DEL
    if self.stepIndex >= #self.config.steps then
        console.systrace("real skip") --@DEL
        mgr:MarkGuideComplete(self.id)
    end
    mgr:SetCurrentGuide(nil)
    mgr:ClearFlags()

    if self.currentStep.skipOptions then
        self:SetOptions(self.currentStep.skipOptions)
    end
    mgr:CallGuideFinishCallback(true)
end

function MapGuideBase:HandleInterrupt(params, stepEvent)
    local isFinish = self:GetValue(stepEvent.value, params)
    if isFinish then
        if not stepEvent.markGuideComplete then
            self.config.dontMarkComplete = true
        end
        self:Finish()
        if stepEvent.cleanHandle then
            stepEvent.cleanHandle()
        end
    end
end

function MapGuideBase:SetMovingHand(value)
    if not value then
        return
    end
    local mask = self.mask
    if not mask then
        mask = self:GetGuideCanvas()
    end
    local from, to = self:GetValue(value.position)
    local trans = self:CreateHand(value.handType).transform
    from = GameUtil.WorldToUISpace(mask.transform, from)
    from = Vector2(from.x, from.y)
    to = GameUtil.WorldToUISpace(mask.transform, to)
    to = Vector2(to.x, to.y)
    local img = find_component(trans.gameObject, "icon", Image)
    local function onStart()
        if self.sequence then
            self.sequence:Kill()
        end
        trans.anchoredPosition = from
        local sequence = DOTween.Sequence()
        sequence:Append(img:DOFade(1, 0.1))
        sequence:Append(trans:DOAnchorPos(to, value.time):SetEase(Ease.Linear))
        sequence:Append(img:DOFade(0, 0.1))
        sequence:Play()
        self.sequence = sequence
    end
    local delay = value.delay or 0
    local interval = value.interval or 1
    self.hand = trans.gameObject
    self.handActionId = WaitExtension.InvokeRepeating(onStart, delay, value.time + interval + 0.2)
end

function MapGuideBase:SetHand(params)
    local function create()
        local position = self:GetValue(params.position)
        local handType = params.handType
        local parent = self:GetValue(params.handParent)
        local hand = self:CreateHand(handType, parent)
        if params.handOffset then
            position = position + params.handOffset
        end
        if params.isLocalPos then
            hand:SetLocalPosition(position)
        else
            hand:SetPosition(position)
        end
        self.hand = hand
        self.setHandTid = nil
    end
    local delay = self:GetValue(params.delay)
    if delay and delay > 0 then
        self.setHandTid = WaitExtension.SetTimeout(create, delay)
    else
        create()
    end
end

function MapGuideBase:CreateHand(handType, parent)
    local hand
    if handType == HandType.DownPress then
        hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_POINT2)
    elseif handType == HandType.Click then
        hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_POINT)
    elseif handType == HandType.LongPress then
        hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_SPINE_GUIDE_HAND)
        GameUtil.PlaySpineAnimation(hand, "scene_click", true)
    elseif handType == HandType.Moving then
        hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_MOVING_HAND)
    end
    local mask = self.mask
    if not mask then
        mask = self:GetGuideCanvas()
    end
    if Runtime.CSValid(parent) then
        hand:SetParent(parent.transform, false)
    else
        hand:SetParent(mask.transform, false)
    end
    return hand
end

function MapGuideBase:HandleCallFunc(value)
    if type(value) == "function" then
        value(self.params)
    end
end

function MapGuideBase:HandleTriggerEvent(value)
    mgr:OnGuideFinishEvent(value.name, value.value)
end

function MapGuideBase:HandleCameraMoveWithSize(value)
    local CameraMoveWithCameraSizeByTimeAction = require "ScreenPlays.Actions.CameraMoveWithCameraSizeByTimeAction"
    local action =
        CameraMoveWithCameraSizeByTimeAction:Create(
        {
            Point = value.Point,
            CameraSizeFreezeTime = value.CameraSizeFreezeTime,
            Duration = value.Duration,
            CameraSize = value.CameraSize,
            TargetCameraSize = value.TargetCameraSize
        },
        function()
            self:HandleEvent(GuideEvent.CameraMoveWithSize, "Finish")
        end
    )
    App.scene.director:AppendFrameAction(action)
end

function MapGuideBase:HandleCameraFocus(value)
    local pos
    if value.type == CameraFocusType.Agent then
        local objMgr = App.scene.objectManager
        local agt = objMgr:GetAgent(value.value.id)
        if not agt then
            agt = objMgr:GetAgentByType(value.value.agentType)
        end
        if agt then
            pos = agt:GetCenterPostion()
        end
    elseif value.type == CameraFocusType.WorldCoordinate then
        pos = self:GetValue(value.value.position)
    else
        if RuntimeContext.VERSION_DEVELOPMENT then
            print("Not Supported", table.tostring(value)) --@DEL
        end
    end

    local onReached = function()
        self:HandleEvent(GuideEvent.CameraMove, "Finish")
    end
    pos = pos or Camera.main.transform.position
    if value.value.moveType == 2 then
        MoveCameraLogic.Instance():MoveCameraToLook2(pos, value.value.time or 0.3, value.value.size, onReached, true)
    else
        MoveCameraLogic.Instance():SetFocusOnPoint(
            pos,
            value.value.smoothMove,
            value.value.time or 0.3,
            value.value.size,
            onReached
        )
    end
end

function MapGuideBase:HandleGIF(value)
    local pth
    if value.path then
        pth = value.path
    else
        pth = "Prefab/UI/Guide/" .. value.name .. ".prefab"
    end
    local function onLoaded()
        local go = BResource.InstantiateFromAssetName(pth)
        local mask = self.mask or self:GetGuideCanvas()
        go:SetParent(mask.transform, false)
        go.transform.localPosition = value.localPosition
    end
    App.uiAssetsManager:LoadAssets({pth}, onLoaded)
end

function ConvertScreenPointTo1280X720(pos)
    local screenWidth, screenHeight = Screen.width, Screen.height
    return Vector2(pos.x / screenWidth * 1280, pos.y / screenHeight * 720)
end

function MapGuideBase:HandleMask(value)
    local guideCanvas = self:GetGuideCanvas()
    local mask = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_MASK)
    mask.transform:SetParent(guideCanvas.transform, false)
    local img = find_component(mask, "", Image)
    -- local mat = CS.UnityEngine.Material(Shader.Find("HomeLand/GuideMaskHole"))
    -- mat.name = "guideMask"
    -- img.material = mat
    local imageMaskHoles = mask:GetComponent(typeof(CS.ImageMaskHoles))
    if value.opacity then
        imageMaskHoles:SetMaskOpacity(value.opacity / 255)
    end
    local guidMaskComponent = find_component(mask, "", NS.GuideMaskComponent)
    if value.clickToContinue and type(value.clickToContinue) == "number" and value.clickType == ClickType.TapScreen then
        guidMaskComponent:ShowText(value.clickToContinue)
    end

    local text = self:GetValue(value.key)
    local position = value.tipPosition
    local tipType = value.tipType
    local tips
    if text and string.len(text) > 0 then
        local tipPrefab
        if not tipType or tipType == TipType.Default then
            tipPrefab = CONST.ASSETS.G_UI_GUIDE_TIPS
        elseif tipType == TipType.TopRight then
            tipPrefab = CONST.ASSETS.G_UI_GUIDE_TIPS_TOP_RIGHT
        elseif tipType == TipType.BottomLeft then
            tipPrefab = CONST.ASSETS.G_UI_GUIDE_TIPS_BOTTOM_LEFT
        else
            tipPrefab = CONST.ASSETS.G_UI_GUIDE_TIPS_BOTTOM_RIGHT
        end
        tips = BResource.InstantiateFromAssetName(tipPrefab)
        if value.noPhoto then
            local npc = find_component(tips, "ui_guide_npc_bg")
            if Runtime.CSValid(npc) then
                npc:SetActive(false)
            end
        -- else
            -- GameUtil.PlaySpineAnimation(tips, "idle", true)
        end
        if value.noTipArrow then
            local arr = find_component(tips, "Item/ImgArrow")
            if Runtime.CSValid(arr) then
                arr:SetActive(false)
            end
        end
        tips.transform:SetParent(mask.transform, false)
        local txt = tips:FindComponentInChildren("text_content", typeof(Text))
        if value.keyParam then
            local keyParam = self:GetValue(value.keyParam)
            txt.text = Runtime.Translate(text, {name = Runtime.Translate(keyParam)})
        else
            txt.text = Runtime.Translate(text)
        end
        tips.transform.anchoredPosition = Vector2(position.x, position.y)
        if value.tipHeight then
            local bg = tips.transform:Find("Item")
            local currentSize = bg.sizeDelta
            bg.sizeDelta = Vector2(currentSize.x, value.tipHeight)
        end
    end

    if value.holes then
        for k, v in pairs(value.holes) do
            local pos
            local screenPoint
            local size = self:GetValue(v.size)
            if v.shape == HoleShape.Rect then
                local val = Screen.height / 720
                size = {width = size.width, height = size.height}
                size.width, size.height = size.width * val, size.height * val
            end
            local target = self:GetValue(v.value)
            local targetPos
            if v.type == HoleType.UI or v.type == HoleType.Region then
                if v.raycast == nil then
                    v.raycast = true
                end
                img.raycastTarget = v.raycast
                targetPos = target:GetPosition()
            elseif v.type == HoleType.Obstacle then
                targetPos = target:GetCenterPostion()
            else
                targetPos = target
            end
            screenPoint = Camera.main:WorldToScreenPoint(targetPos)
            pos = ConvertScreenPointTo1280X720(screenPoint)
            local hand
            if v.hand then
                if v.hand == HandType.DownPress then
                    hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_POINT2)
                elseif v.hand == HandType.Click then
                    hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_POINT)
                elseif v.hand == HandType.LongPress then
                    hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_SPINE_GUIDE_HAND)
                    GameUtil.PlaySpineAnimation(hand, "scene_click", true)
                elseif v.hand == HandType.Arrow then
                    hand = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_GUIDE_ARROW)
                    local trans = find_component(hand, "icon").transform
                    trans:DOAnchorPosY(10, 0.3):SetEase(Ease.InOutSine):SetLoops(-1, LoopType.Yoyo)
                    self.handTweenTrans = trans
                end
                local handParent = self:GetValue(v.handParent)
                if Runtime.CSValid(handParent) then
                    hand.transform:SetParent(handParent.transform, false)
                    self.hand = hand
                else
                    hand.transform:SetParent(mask.transform, false)
                end
                if v.handOffset then
                    local off = Camera.main:WorldToScreenPoint(targetPos + v.handOffset)
                    hand.transform.position = Camera.main:ScreenToWorldPoint(off)
                elseif v.handScreenOffset then
                    hand.transform.position = Camera.main:ScreenToWorldPoint(screenPoint + v.handScreenOffset)
                else
                    hand.transform.position = Camera.main:ScreenToWorldPoint(screenPoint)
                end
                if v.handLocalOffset then
                    hand.transform.localPosition = hand.transform.localPosition + v.handLocalOffset
                end
                if v.handRotate then
                    hand.transform.localEulerAngles = self:GetValue(v.handRotate)
                end
                if v.handTarget then
                    local handTarget = self:GetValue(v.handTarget)
                    hand.transform.position =
                        Camera.main:ScreenToWorldPoint(Camera.main:WorldToScreenPoint(handTarget:GetPosition()))
                end
            end
            if v.offset then
                local offset = self:GetValue(v.offset)
                pos = pos + offset
            end
            if v.type == HoleType.UI or v.type == HoleType.Region then
                local region = Vector2.zero
                -- local value = self:GetValue(v.value)
                if v.shape == HoleShape.Circle then
                    region.x = size
                    -- imageMaskHoles:AddTransform(value.transform, size, hand)
                    imageMaskHoles:AddHole(pos.x, pos.y, size or 100)
                else
                    region.x = size.width
                    region.y = size.height
                    -- imageMaskHoles:AddTransformRect(value.transform, size.width, size.height, hand)
                    imageMaskHoles:AddRect(pos.x, pos.y, size.width, size.height)
                end
                if v.regionCenter then
                    screenPoint = Camera.main:WorldToScreenPoint(v.regionCenter)
                end
                if v.type == HoleType.Region then
                    guidMaskComponent:SetClickRegion(
                        v.shape,
                        screenPoint,
                        region,
                        function(strValid)
                            local valid = false
                            if strValid == "valid" then
                                valid = true
                            end
                            self:HandleEvent(GuideEvent.RegionClick, valid)
                        end
                    )
                else
                    guidMaskComponent:SetClickRegion(v.shape, screenPoint, region)
                end
            else
                if v.shape == HoleShape.Circle then
                    imageMaskHoles:AddHole(pos.x, pos.y, size or 100)
                else
                    imageMaskHoles:AddRect(pos.x, pos.y, size.width, size.height)
                end
            end
        end
    end

    if value.delay and value.delay > 0 then
        WaitExtension.SetTimeout(
            function()
                if not mask or Runtime.CSNull(mask) then
                    return
                end
                mask:GetComponent(typeof(CS.BetaGame.BaseFader)):FadeIn(0.3)
            end,
            value.delay
        )
    else
        mask:GetComponent(typeof(CS.BetaGame.BaseFader)):FadeIn(0.3)
    end

    self.mask = mask

    if value.clickable then
        local clickObj
        if value.clickType and value.clickType == ClickType.TapScreen then
            clickObj = mask
        else
            clickObj = tips:FindGameObject("btn_next")
            clickObj:FindComponentInChildren("Text", typeof(Text)).text =
                Runtime.Translate("guide.text.tip.next.button")
            clickObj:SetActive(true)
            mask:SetTimeOut(
                function()
                    clickObj:FindGameObject("GuidePoint"):SetActive(true)
                end,
                2
            )
        end

        if value.delay and value.delay > 0 then
            WaitExtension.SetTimeout(
                function()
                    if not clickObj or Runtime.CSNull(clickObj) then
                        return
                    end
                    Util.UGUI_AddEventListener(
                        clickObj,
                        "onClick",
                        function()
                            mgr:OnGuideFinishEvent(GuideEvent.ClickAnywhere, "")
                        end
                    )
                end,
                value.delay
            )
        else
            if value.clickDelay and value.clickDelay > 0 then
                WaitExtension.SetTimeout(
                    function()
                        if not clickObj or Runtime.CSNull(clickObj) then
                            return
                        end
                        Util.UGUI_AddEventListener(
                            clickObj,
                            "onClick",
                            function()
                                mgr:OnGuideFinishEvent(GuideEvent.ClickAnywhere, "")
                            end
                        )
                    end,
                    value.clickDelay
                )
            else
                Util.UGUI_AddEventListener(
                    clickObj,
                    "onClick",
                    function()
                        mgr:OnGuideFinishEvent(GuideEvent.ClickAnywhere, "")
                    end
                )
            end
        end
        img.raycastTarget = true
    end

    if value.gif then
        self:HandleGIF(value.gif)
    end
end

function MapGuideBase:HandleTargetButtonClickEvent(params, eventConfig)
    local val = self:GetValue(eventConfig.value, params)
    print("HandleTargetButtonClickEvent", params, val) --@DEL
    if params == val then
        return true
    elseif val then
        if Runtime.CSNull(params) or Runtime.CSNull(params.gameObject) then
            return false
        end
        if params.gameObject == val.gameObject then
            return true
        end
    end
    return false
end

function MapGuideBase:HandlePanelClosedEvent(params, eventConfig)
    print("HandlePanelClosedEvent") --@DEL
    if type(eventConfig.value) == "table" then
        if table.indexOf(eventConfig.value, params) then
            return true
        end
    else
        if params == eventConfig.value then
            return true
        end
    end
    return false
end

function MapGuideBase:HandleAfterPanelClosed(params, eventConfig)
    print("HandleAfterPanelClosed") --@DEL
    if params == eventConfig.value then
        return true
    end
    return false
end

function MapGuideBase:HandlePanelPoppedOut(params, eventConfig)
    print("HandlePanelPoppedOut") --@DEL
    local val = self:GetValue(eventConfig.value, params)
    if params == val then
        return true
    end
    return false
end

function MapGuideBase:HandleClickAnywhere(params, eventConfig)
    print("HandleClickAnywhere") --@DEL
    return true
end

-------------通用事件------------
function MapGuideBase:HandleCommonEvent(params, eventConfig)
    if self:GetValue(eventConfig.value, params) then
        return true
    end
    return false
end

optionHandlers.setMovingHand = MapGuideBase.SetMovingHand
optionHandlers.setHand = MapGuideBase.SetHand
optionHandlers.mask = MapGuideBase.HandleMask
optionHandlers.cameraFocus = MapGuideBase.HandleCameraFocus
optionHandlers.cameraMoveWithSize = MapGuideBase.HandleCameraMoveWithSize
optionHandlers.callFunc = MapGuideBase.HandleCallFunc
optionHandlers.jump = MapGuideBase.HandleJumpStep
optionHandlers.gif = MapGuideBase.HandleGIF

-------------------------这里不要再往MapGuideBase里添加了，直接写成匿名方法如下--------------------------------------
optionHandlers.disableUI = function(target, val)
    mgr:DisableUI(val)
end
optionHandlers.disableDrag = function(target, val)
    mgr:DisableDragScreen(val)
end
optionHandlers.disableMapBubble = function(target, val)
    mgr:DisableMapBubbleClick(val)
end
optionHandlers.disableScaleScreen = function(target, val)
    mgr:DisableScaleScreen(val)
end
optionHandlers.disableAgentClick = function(target, val)
    mgr:DisableAgentClick(val)
end
optionHandlers.markComplete = function(target, val)
    if val then
        mgr:MarkGuideComplete(target.id)
    end
end
optionHandlers.disableClickDragon = function(target, val)
    mgr:DisableClickDragon(val)
end
optionHandlers.disableDoubleClick = function(target, val)
    mgr:DisableDoubleClick(val)
end
optionHandlers.disableDragDragon = function(target, val)
    mgr:DisableDragDragon(val)
end
optionHandlers.disableAll = function(target, val)
    if val then
        mgr:DisableAll()
    end
end

--register common event
for _, v in pairs(GuideEvent) do
    eventHandles[v] = MapGuideBase.HandleCommonEvent
end
eventHandles[GuideEvent.TargetButtonClicked] = MapGuideBase.HandleTargetButtonClickEvent
eventHandles[GuideEvent.OnPanelClose] = MapGuideBase.HandlePanelClosedEvent
eventHandles[GuideEvent.PanelPoppedOut] = MapGuideBase.HandlePanelPoppedOut
eventHandles[GuideEvent.ClickAnywhere] = MapGuideBase.HandleClickAnywhere
eventHandles[GuideEvent.AfterPanelClosed] = MapGuideBase.HandleAfterPanelClosed
eventHandles[GuideEvent.PanelCloseFadeFinish] = MapGuideBase.HandlePanelPoppedOut
eventHandles[GuideEvent.Interrupt] = MapGuideBase.HandleInterrupt

return MapGuideBase
