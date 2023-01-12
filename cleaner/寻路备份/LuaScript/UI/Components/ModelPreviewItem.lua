---用于动态显示某个模型
---@class ModelPreviewItem
local ModelPreviewItem = {}
local globalIndex = 1
---@return ModelPreviewItem
function ModelPreviewItem.Create(parent, rtSize, enableRotate)
    local itm = {}
    setmetatable(itm, {__index = ModelPreviewItem})
    itm:_Init(parent, rtSize)
    if enableRotate then
        itm:InitHandRotate()
    end
    return itm
end
local ModelPreviewPoints = nil
function ModelPreviewItem:_Init(parent, rtSize)
    self.alive = true
    self.rtSize = rtSize or 256
    local go = BResource.InstantiateFromAssetName(CONST.ASSETS.G_MODEL_PREVIEW_ITEM)
    if Runtime.CSValid(go) then
        self:_BindView(go)
        self.gameObject:SetParent(parent, false)
    end
    self.actionQueue = {}
    self.dragonRequestId = 0
    self.modelRequestId = 0
end

function ModelPreviewItem:_BindView(go)
    self.point = find_component(go, "point").transform
    self.rtCamera = find_component(go, "point/rtCamera", Camera)
    self.rtView = find_component(go, "rtView", RawImage)
    self.rtexture = GameUtil.CreateUIRenderTexture(self.rtSize, self.rtSize)
    self.rtView.texture = self.rtexture
    self.rtCamera.targetTexture = self.rtexture
    self.gameObject = go
    self.transform = go.transform
    self.rtCamTrans = self.rtCamera.transform
    if not Runtime.CSValid(ModelPreviewPoints) then
        ModelPreviewPoints = GameObject("ModelPreviewPoints").transform
        ModelPreviewPoints.localScale = Vector3.one * 0.00833
    end
    self.point:SetParent(ModelPreviewPoints, false)
end

function ModelPreviewItem:InitHandRotate()
    self.rtView.raycastTarget = true
    self.axis = self.rtCamTrans.up
    local function onBeginDrag(pointData)
        local trans = self.rtCamTrans
        self.start = pointData.position
        self.startAngle = trans.localEulerAngles.y
        self.startPos = trans.localPosition
    end
    local function onDrag(pointData)
        local trans = self.rtCamTrans
        local pos = pointData.position
        local offset = pos.x - self.start.x
        pos = GameUtil.RotateVector(self.startPos, self.axis, offset)
        trans.localPosition = pos
        local vt3 = trans.localEulerAngles
        vt3.y = self.startAngle + offset
        trans.localEulerAngles = vt3
    end
    Util.UGUI_AddEventListener(self.rtView.gameObject, UIEventName.onBeginDrag, onBeginDrag, false)
    Util.UGUI_AddEventListener(self.rtView.gameObject, UIEventName.onDrag, onDrag, false)
end

function ModelPreviewItem:SetClickEnable(callback)
    self.clickEnabled = true
    self.rtView.raycastTarget = true
    local function onClick()
        if callback then
            Runtime.InvokeCbk(callback, self)
        else
            if self.isPlayingAni then
                return
            end
            self.isPlayingAni = true
            AnimatorEx.CallbackTrigger(self.animator,"happy_1",function()
                self.isPlayingAni = false
            end)
        end
    end
    Util.UGUI_AddButtonListener(self.rtView.gameObject, onClick)
end

function ModelPreviewItem:ClearDragonWearedSkin()
    if Runtime.CSValid(self.modelTrans) then
        AppServices.SkinEquipManager:RemoveAllDragonSkinModels(self.modelTrans.gameObject)
    end
end

function ModelPreviewItem:ShowSkinModel(skintplId)
    if not skintplId then
        return
    end
    self:SetDragonSkins({{tplId = skintplId}}, true)
    self:SetDefaultDragonModel()
end

function ModelPreviewItem:SetDefaultDragonModel(callback)
    self:SetDragonModel("dragon_argil_lv1", callback)
end

function ModelPreviewItem:SetCreature(creatureId)
    if not creatureId then
        return
    end
    local data = AppServices.MagicalCreatures:GetCreatureByCreatureId(creatureId)
    if data then
        local conf = data:GetConfig()
        self:SetDragonModel(conf.model)
        self:SetDragonSkins(data.skins, true)
    end
end

function ModelPreviewItem:SetDragonModel(modelName, callback, isPath)
    if Runtime.CSValid(self.modelTrans) then
        Runtime.CSDestroy(self.modelTrans.gameObject)
    end
    self.modelTrans = nil
    self:_GetDragonModel(modelName, callback, isPath)
end

function ModelPreviewItem:SetModel(path)
    if Runtime.CSValid(self.modelTrans) then
        Runtime.CSDestroy(self.modelTrans.gameObject)
    end
    self.modelTrans = nil
    self:_GetModel(path)
end

function ModelPreviewItem:SetRtAlpha(alpha)
    if Runtime.CSValid(self.modelTrans) then
        local col = self.rtView.color
        col.a = alpha
        DOTween.Kill(self.rtView)
        self.rtView.color = col
    else
        self.rtAlpha = alpha
    end
end

function ModelPreviewItem:SetPosition(vt2)
    self.transform.anchoredPosition = vt2
end

function ModelPreviewItem:SetSize(size)
    self.transform.sizeDelta = Vector2.one * size
end

function ModelPreviewItem:SetRtSize(size)
    self.rtView.transform.sizeDelta = Vector2.one * size
end

function ModelPreviewItem:SetModelPosition(vt3)
    if not self.modelTrans then
        self.actionQueue[#self.actionQueue+1] = {requestId = self.modelRequestId, method = self.SetModelPosition, param = {vt3}}
        return
    end
    self.modelTrans.localPosition = vt3
end

function ModelPreviewItem:SetModelSize(size)
    if not self.modelTrans then
        self.actionQueue[#self.actionQueue+1] = {requestId = self.modelRequestId, method = self.SetModelSize, param = {size}}
        return
    end
    self.modelTrans.localScale = Vector3.one * size
end

function ModelPreviewItem:SetModelRotation(vt3)
    if not self.modelTrans then
        self.actionQueue[#self.actionQueue+1] = {requestId = self.modelRequestId, method = self.SetModelRotation, param = {vt3}}
        return
    end
    self.modelTrans.localEulerAngles = vt3
end

function ModelPreviewItem:SetCameraPosition(vt3)
    self.camPos = vt3
    self.rtCamTrans.localPosition = vt3
end

function ModelPreviewItem:SetCameraBackgroundColor(val)
    self.rtCamera.backgroundColor = Runtime.HexToRGB(val or '#98989800')
end

function ModelPreviewItem:SetCameraRotation(vt3)
    self.rtCamTrans.localEulerAngles = vt3
end

function ModelPreviewItem:SetCameraFov(size)
    self.rtCamera.fieldOfView = size
end

function ModelPreviewItem:SetDragonSkins(skins, isSetLayer)
    if not skins then
        return
    end
    if not self.modelTrans then
        self.actionQueue[#self.actionQueue+1] = {requestId = self.modelRequestId, method = self.SetDragonSkins, param = {skins, isSetLayer}}
        return
    end
    if self.clickEnabled and Runtime.CSValid(self.animator) then
        if self.transitionId then
            WaitExtension.CancelTimeout(self.transitionId)
            self.transitionId = nil
        end
        if AnimatorEx.IsAnimatorStateName(self.animator,"idle") then
            AppServices.SkinEquipManager:HandleDragonSkin(self.modelTrans.gameObject, skins, isSetLayer)
            return
        end
        self.animator:SetTrigger("idle")
        local duration = AnimatorEx.GetAnimatorDefaultTransitionTime(self.animator)
        self.transitionId = WaitExtension.SetTimeout(function()
            self.transitionId = nil
            if not Runtime.CSValid(self.modelTrans.gameObject) then
                return
            end
            AppServices.SkinEquipManager:HandleDragonSkin(self.modelTrans.gameObject, skins, isSetLayer)
        end, duration)
    else
        AppServices.SkinEquipManager:HandleDragonSkin(self.modelTrans.gameObject, skins, isSetLayer)
    end
end

function ModelPreviewItem:PlayAnim(animName)
    if Runtime.CSValid(self.animator) then
        self.isPlayingAni = true
        AnimatorEx.CallbackTrigger(self.animator,animName,function()
            self.isPlayingAni = false
        end)
    end
end

function ModelPreviewItem:_GetModel(path)
    if not path then
        return
    end
    self.modelRequestId = self.modelRequestId + 1
    local curRequestId = self.modelRequestId
    local function onLoaded()
        if not Runtime.CSValid(self.gameObject) then
            return
        end
        if curRequestId ~= self.modelRequestId then
            return
        end
        local go = BResource.InstantiateFromAssetName(path)
        if go then
            local trans = go.transform
            trans:SetParent(self.point, false)
            trans.localScale = Vector3.one * 10
            trans.localEulerAngles = Vector3(0, 0, 0)
            trans.localPosition = Vector3.zero
            local layer = CS.UnityEngine.LayerMask.NameToLayer("UIModel")
            go:SetLayerRecursively(layer)
            self.rtCamera.enabled = true
            local alpha = self.rtAlpha or 1
            self.rtView:DOFade(alpha, 0.2)
            self.modelTrans = trans
            if not self.camPos then
                self.rtCamTrans.localPosition = Vector3(0, 0, -45.2)
            end
            self.point.localPosition = Vector3(100*globalIndex, 0, 0)
            globalIndex = globalIndex + 1
            if #self.actionQueue > 0 then
                for _, v in ipairs(self.actionQueue) do
                    if v.requestId == curRequestId then
                        v.method(self, table.unpack(v.param))
                    end
                end
                self.actionQueue = {}
            end
        end
    end
    App.uiAssetsManager:LoadAssets({path}, onLoaded)
end

function ModelPreviewItem:_GetDragonModel(modelName, callback, isPath)
    if not modelName then
        return Runtime.InvokeCbk(callback)
    end
    self.dragonRequestId = self.dragonRequestId + 1
    local curRequestId = self.dragonRequestId
    local path
    if isPath then
        path = modelName
    else
        path = string.format("Prefab/MagicalCreatures/%s.prefab", modelName)
    end
    local function onLoaded()
        if not self.alive then
            return Runtime.InvokeCbk(callback)
        end
        if not Runtime.CSValid(self.gameObject) then
            return Runtime.InvokeCbk(callback)
        end

        if curRequestId ~= self.dragonRequestId then
            return Runtime.InvokeCbk(callback)
        end

        local go = BResource.InstantiateFromAssetName(path)
        if Runtime.CSNull(go) then
            return Runtime.InvokeCbk(callback)
        end

        local layer = CS.UnityEngine.LayerMask.NameToLayer("UIModel")
        go:SetLayerRecursively(layer)
        go:AddComponent(typeof(CS.RTAdditiveShader))
        local trans = go.transform
        trans:SetParent(self.point, false)
        trans.localScale = Vector3.one * 10
        trans.localEulerAngles = Vector3(0, 210, 0)
        trans.localPosition = Vector3.zero
        local canvas = find_component(go, "Canvas")
        if Runtime.CSValid(canvas) then
            Runtime.CSDestroy(canvas)
        end
        self.rtCamera.enabled = true
        local alpha = self.rtAlpha or 1
        self.rtView:DOFade(alpha, 0.2)
        local camTrans = self.rtCamTrans
        if not self.camPos then
            camTrans.localPosition = Vector3(-0.5, 11.2, -45.2)
        end
        camTrans.localEulerAngles = Vector3(9.217, 0, 0)
        self.modelTrans = trans
        self.animator = find_component(go, "render", Animator)
        self.point.localPosition = Vector3(100*globalIndex, 0, 0)
        globalIndex = globalIndex + 1
        if #self.actionQueue > 0 then
            for _, v in ipairs(self.actionQueue) do
                v.method(self, table.unpack(v.param))
            end
            self.actionQueue = {}
        end
        Runtime.InvokeCbk(callback)
    end
    App.uiAssetsManager:LoadAssets({path}, onLoaded)
end

function ModelPreviewItem:Dispose()
    self.alive = nil
    self.go_sub = nil
    self._subGoAdded = nil
    DOTween.Kill(self.rtView)
    if Runtime.CSValid(self.point) then
        Runtime.CSDestroy(self.point.gameObject)
    end
    if Runtime.CSValid(self.rtexture) then
        GameUtil.RecycleUIRenderTexture(self.rtexture)
        self.rtexture = nil
    end
    if Runtime.CSValid(self.gameObject) then
        Runtime.CSDestroy(self.gameObject)
    end
end

return ModelPreviewItem