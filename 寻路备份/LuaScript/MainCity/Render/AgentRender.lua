local BoxColliderType = typeof(BoxCollider)
local AnimatorType = typeof(Animator)
local SpineType = typeof(SkeletonAnimation)
local SpriteRendererType = typeof(SpriteRenderer)
local MeshRendererType = typeof(MeshRenderer)
local RendererType = typeof(CS.UnityEngine.Renderer)

local RenderHandlers = {
    ---spine
    {
        GetRender = function(gameObject)
            local render = gameObject:GetComponentInChildren(SpineType)
            if Runtime.CSNull(render) then
                return
            end
            return render
        end,
        PlayAnimation = function(render, trigger, loop, callback)
            GameUtil.PlaySpineAnimation(
                render.gameObject,
                trigger,
                loop,
                function(success)
                    Runtime.InvokeCbk(callback, success)
                end
            )
        end,
        SetTransparency = function(render, toValue)
            if Runtime.CSValid(render) then
                render.Skeleton.A = toValue
            end
        end,
        TweenTransparency = function(render, toValue)
            return GameUtil.DoFade(render, toValue, 0.5)
        end
    },
    ---skinnedMesh
    {
        GetRender = function(gameObject)
            local render = gameObject:GetComponentInChildren(MeshRendererType)
            if Runtime.CSNull(render) then
                return
            end
            return {
                animator = gameObject:GetComponentInChildren(AnimatorType),
                material = render.material
            }
        end,
        PlayAnimation = function(render, trigger, loop, callback)
            Util.CALLBACKTRIGGER(render.animator, trigger, callback)
        end,
        SetTransparency = function(render, toValue)
            -- local mat = render.material
            -- GameUtil.SetShader(mat, "HomeLand/FbxTransparency")
            -- mat:SetFloat("_Alpha", toValue)
        end,
        TweenTransparency = function(render, toValue)
            -- local mat = render.material
            -- if Runtime.CSNull(mat) then
            --     return
            -- end
            -- GameUtil.SetShader(mat, "HomeLand/FbxTransparency")
            -- local from = mat:GetFloat("_Alpha")
            -- return LuaHelper.FloatSmooth(
            --     from,
            --     toValue,
            --     0.5,
            --     function(value)
            --         mat:SetFloat("_Alpha", value)
            --     end
            -- )
        end
    },
    ---animator
    {
        GetRender = function(gameObject)
            local render = gameObject:GetComponentInChildren(AnimatorType)
            return render
        end,
        PlayAnimation = function(render, trigger, loop, callback)
            Util.CALLBACKTRIGGER(render, trigger, callback)
        end,
        SetTransparency = function(render, toValue)
            if Runtime.CSNull(render) then
                return
            end
            if toValue == 1 then
                Util.CALLBACKTRIGGER(render, "opacity")
            else
                Util.CALLBACKTRIGGER(render, "transparency")
            end
        end,
        TweenTransparency = function(render, toValue)
            if Runtime.CSNull(render) then
                return
            end
            if toValue == 1 then
                Util.CALLBACKTRIGGER(render, "opacity")
            else
                Util.CALLBACKTRIGGER(render, "transparency")
            end
        end
    },
    ---sprite
    {
        GetRender = function(gameObject)
            local render = gameObject:GetComponentInChildren(SpriteRendererType)
            if Runtime.CSNull(render) then
                return
            end
            return render
        end,
        PlayAnimation = function(render, trigger, loop, callback)
            console.hjs(render, "error:普通图片! 无任何动画") --@DEL
            Runtime.InvokeCbk(callback, true)
        end,
        SetTransparency = function(render, toValue)
            if Runtime.CSNull(render) then
                return
            end
            local color = render.color
            color.a = toValue
            render.color = color
        end,
        TweenTransparency = function(render, toValue)
            if Runtime.CSNull(render) then
                return
            end
            local tween = GameUtil.DoFade(render, toValue, 0.5)
            return tween
        end
    }
}
local Id2Type = {
}
local function GetRenderType(gameObject, templateId)
    local renderType = Id2Type[templateId]
    if renderType then
        return renderType, RenderHandlers[renderType].GetRender(gameObject)
    end

    for renderType, handle in ipairs(RenderHandlers) do
        local render = handle.GetRender(gameObject)
        if render then
            Id2Type[templateId] = renderType
            return renderType, render
        end
    end
    console.warn(gameObject, "Undefined RenderType:", gameObject.name) --@DEL
end

---@class AgentRender
local AgentRender = class(nil, "AgentRender")

function AgentRender:ctor(resourceName)
    self.isAlive = true
    self.gameObject = nil
    self.collider = nil
    self.render = nil
    self.renderType = nil
    self.prune = false

    self.initialized = false
    self.initializing = false

    self.createCallbacks = {}
    self.modelName = resourceName
    self:SetResource(resourceName)
end

function AgentRender:GetModelName()
    return self.modelName
end

function AgentRender:SetModelName(modelName, callback)
    self.modelName = modelName
    self:SetResource(modelName, callback)
end

function AgentRender:SetResource(resourceName, callback)
    local path = "Prefab/BindingObject/" .. resourceName .. ".prefab"
    if not App.buildingAssetsManager:AssetExist(path) then
        return Runtime.InvokeCbk(callback, false)
    end
    if path == self.sourcePath then
        return Runtime.InvokeCbk(callback, true)
    end
    self.sourcePath = path
    self:ChangeSkin(self.sourcePath, callback)
end

---@param data AgentData 物体信息
---@param position Vector3 @创建后的建筑世界坐标
---@param callback function @创建结果回调
function AgentRender:Init(data, callback)
    if callback then
        table.insert(self.createCallbacks, callback)
    end

    if self.initialized and Runtime.CSValid(self.gameObject) then
        self:Trigger(true)
        return
    end
    if self.initializing then
        return
    end

    if Runtime.CSValid(self.gameObject) then
        self:Trigger(true)
        return
    end

    self.name = data:GetId()
    self.tId = data:GetTemplateId()
    self.position = data:GetPosition()
    self.rawEuler = data:GetRawEulerAngle()
    self.rawScale = data:GetRawLocalScale()
    self.idleAnimaName = data:GetIdleAnimaName()
    self:CreateGameObject(self.sourcePath)
end

function AgentRender:CreateGameObject(assetPath)
    self.initializing = true
    if string.isEmpty(assetPath) then
        console.error('障碍物资源路径为空', self.tId, self.name) --@DEL
    end
    local function OnLoadFinished()
        if not self.isAlive then
            self:Trigger(false)
            return
        end

        self.initialized = true
        self.initializing = false

        self.gameObject = BResource.InstantiateFromAssetName(assetPath)
        if Runtime.CSValid(self.gameObject) then
            local BuildingRootGo = App.scene.objectManager:GetRoot()
            self.gameObject:SetParent(BuildingRootGo)
            self.collider = self.gameObject:GetComponentInChildren(BoxColliderType)

            self:GenRenderType(self.tId)
            self:SetName(self.name)
            self:SetLocalScale(self.rawScale)
            self:SetPosition(self.position)
            self:SetEulerAngles(self.rawEuler)
            self:SetClickable(self.clickable)
            if self.alpha then
                self:SetTransparency(self.alpha)
            end
            if self.isVisible ~= nil then
                local isVisible = self.isVisible
                self.isVisible = nil
                self:SetVisible(isVisible)
            end
            if self.editing then
                self:OnEnterEditMode()
            end

            WaitExtension.InvokeDelay(
                function()
                    self:InitDefaultAnimation(self.idleAnimaName)
                end
            )
            self:Trigger(true)
        else
            self:Trigger(false)
        end
        if self.loadedCallback then
            WaitExtension.InvokeDelay(
                function()
                    self.loadedCallback(self.gameObject)
                    self.loadedCallback = nil
                end
            )
        end
        App.mapGuideManager:OnGuideFinishEvent(GuideEvent.ObstacleValid, self.name)
    end

    App.buildingAssetsManager:LoadAssets({assetPath}, OnLoadFinished)
end

function AgentRender:GenRenderType(templateId)
    self.renderType, self.render = GetRenderType(self.gameObject, templateId)
end

function AgentRender:Trigger(success)
    local cbs = self.createCallbacks
    if not cbs or #cbs == 0 then
        return
    end

    self.createCallbacks = {}
    for _, call in ipairs(cbs) do
        Runtime.InvokeCbk(call, success)
    end
end

---@param position Vector3 @设置模型的世界坐标
function AgentRender:SetPosition(position)
    self.position = position
    if not position then
        return
    end
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetPosition(position)
    end
end
---@param position Vector3 获取模型的世界坐标
function AgentRender:GetPosition()
    return self.position
end

function AgentRender:ResetAnchorPosition()
    if Runtime.CSNull(self.collider) or not self.collider.enabled then
        return self:GetPosition()
    end
    local min = self.collider.bounds.min
    local max = self.collider.bounds.max
    self.anchorPosition = Vector3((min.x + max.x) * 0.5, max.y, (min.z + max.z) * 0.5)
    return self.anchorPosition
end
function AgentRender:GetAnchorPosition()
    if not self.anchorPosition then
        return self:ResetAnchorPosition()
    end
    return self.anchorPosition
end

---@param euler table @设置模型的旋转
function AgentRender:SetEulerAngles(euler)
    self.rawEuler = euler
    if not euler then
        return
    end
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetLocalEulerAngle(euler[1], euler[2], euler[3])
    end
end

---@param scale table @设置模型的缩放
function AgentRender:SetLocalScale(scale)
    self.rawScale = scale
    if not scale then
        return
    end
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetLocalScale(scale[1], scale[2], scale[3])
    end
end

---@param name string @设置模型碰撞框的名字
function AgentRender:SetName(name)
    self.name = name
    if not name then
        return
    end
    if Runtime.CSValid(self.collider) then
        self.collider.name = name
    end
end

function AgentRender:VisibleInCamera()
    if Runtime.CSValid(self.gameObject) then
        return self.gameObject:GetVisible()
    end
end

function AgentRender:SetTransparency(toValue)
    self.alpha = toValue
    local handler = RenderHandlers[self.renderType]
    if handler then
        handler.SetTransparency(self.render, toValue)
    else
        console.hjs(self.render, "error:未知物体类型!") --@DEL
    end
end
function AgentRender:TweenTransparency(alpha)
    self.alpha = alpha
    local handler = RenderHandlers[self.renderType]
    if handler then
        return handler.TweenTransparency(self.render, alpha)
    else
        console.hjs(self.render, "error:未知物体类型!") --@DEL
    end
end
function AgentRender:SetHighlight(active)
    --console.hjs(self.gameObject, "SetHighlight: ", active)
    if active then
        if self.highlightTweens then
            return
        end
        self.highlightTweens = {}
        self.cachePrune = self.prune
        --console.hjs(self.gameObject, self.cachePrune)
        self:SetPrune(false)
        if Runtime.CSValid(self.gameObject) then
            local renders = self.gameObject:GetComponents(RendererType)
            local toValue = Color(94.0 / 255, 94.0 / 255, 94.0 / 255, 1.0)
            for i = 1, renders.Length do
                local render = renders[i - 1]
                local highlightTween = GameUtil.DoColor(render.gameObject, toValue, 0.75)
                highlightTween:SetLoops(-1, LoopType.Yoyo)
                highlightTween:SetEase(Ease.Linear)
                table.insert(self.highlightTweens, highlightTween)
            end
        end
    else
        if self.highlightTweens then
            self:SetPrune(self.cachePrune)
            for _, highlightTween in pairs(self.highlightTweens) do
                highlightTween:Rewind()
                highlightTween:Kill(false)
            end
            self.highlightTweens = nil
        end
    end
    if self.alpha then
        self:SetTransparency(self.alpha)
    end
end

function AgentRender:SetPrune(prune)
    if self.prune == prune then
        return
    end
    self.prune = prune
    if self.prune then
        self:SetResource(self.modelName .. "_prune")
    else
        self:SetResource(self.modelName)
    end
end

---@param cbk function
function AgentRender:SetObjLoadedCallback(cbk)
    self.loadedCallback = cbk
end

function AgentRender:SetClickable(clickable)
    self.clickable = clickable and true or false
    if Runtime.CSValid(self.collider) then
        self.collider.enabled = self.clickable
    end
end

function AgentRender:AddInstantiateListener(listener)
    if listener then
        if self.initialized then
            local suc = Runtime.CSValid(self.gameObject)
            Runtime.InvokeCbk(listener, suc)
            return
        end
        table.insert(self.createCallbacks, listener)
    end
end

function AgentRender:PlayAnimation(trigger, loop, callback)
    if not self.isAlive then
        Runtime.InvokeCbk(callback, false)
        return
    end
    loop = loop and true or false
    local handler = RenderHandlers[self.renderType]
    if handler then
        handler.PlayAnimation(self.render, trigger, loop, callback)
    else
        console.hjs("error:未知物体类型!") --@DEL
        Runtime.InvokeCbk(callback, true)
    end
end

---设置默认动画
function AgentRender:InitDefaultAnimation(animaName)
    if not animaName then
        return
    end
    self:PlayAnimation(animaName, true)
end

---更新默认动画
function AgentRender:UpdateDefaultAnima(newAnimaName, loop, callback)
    if newAnimaName == self.idleAnimaName then
        return
    end
    self.idleAnimaName = newAnimaName
    self:PlayAnimation(newAnimaName, loop, callback)
end

function AgentRender:ChangeSkin(assetPath, callback)
    local function afterInitialCreated()
        if not self.isAlive then
            return Runtime.InvokeCbk(callback, false)
        end
        local orgRenderObj = self.gameObject
        local function onCreated()
            if Runtime.CSValid(orgRenderObj) then
                Runtime.CSDestroy(orgRenderObj)
                orgRenderObj = nil
            end
            self:ResetAnchorPosition()
            Runtime.InvokeCbk(callback, true)
        end

        self.initialized = false
        self:AddInstantiateListener(onCreated)

        self:CreateGameObject(assetPath)
    end

    --- 判断是否初始创建完成或者正在创建中
    if self.initialized then
        afterInitialCreated()
    elseif self.initializing then
        self:AddInstantiateListener(afterInitialCreated)
    end
end

---设置显隐
function AgentRender:SetVisible(isVisible)
    if self.isVisible == isVisible then
        return
    end
    self.isVisible = isVisible
    if Runtime.CSValid(self.gameObject) then
        self.gameObject:SetActive(isVisible)
    end
end

function AgentRender:OnEnterEditMode()
    if not self.isAlive then
        return
    end
    self.editing = true
    if Runtime.CSNull(self.gameObject) then
        return
    end
    local child = self.gameObject.transform
    if self.gameObject.transform.childCount > 0 then
        child = self.gameObject.transform:GetChild(0)
    end
    child:DOKill(true)
    local tween = child:DOMoveY(1, 0.7)
    tween:SetEase(Ease.InOutSine)
    tween:SetLoops(-1, LoopType.Yoyo)
end
function AgentRender:OnExitEditMode()
    if not self.isAlive then
        return
    end
    self.editing = false
    if Runtime.CSNull(self.gameObject) then
        return
    end
    local child = self.gameObject.transform
    if self.gameObject.transform.childCount > 0 then
        child = self.gameObject.transform:GetChild(0)
    end
    child:DOKill(true)
    local tween = child:DOMoveY(0, 0.45)
    tween:SetEase(Ease.OutBounce)
end

function AgentRender:OnDestroy()
    self.isAlive = nil

    Runtime.CSDestroy(self.gameObject)
    self.gameObject = nil
    self.collider = nil
    self.render = nil

    self.position = nil
    self.name = nil
    self.rawScale = nil
    self.rawEuler = nil

    self.initialized = false
    self.initializing = false

    self.createCallbacks = {}
end

return AgentRender
