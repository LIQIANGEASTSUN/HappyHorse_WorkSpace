--[[
---@class Bubble_base
Bubble_base = class(nil)
function Bubble_base:ctor()
end

---interface 创建模型
function Bubble_base:CreateObj(parent)
    return nil
end

---interface 绑定模型
function Bubble_base:Bind(go)
end

---interface 初始化数据
function Bubble_base:Init(param)
end

---interface 显示
function Bubble_base:Show()
end

---interface 销毁
function Bubble_base:Destroy()
end
]]
---@class Bubble_Interface
Bubble_Interface = class(nil, "Bubble_Interface")

function Bubble_Interface:ctor()
    --必须设置的参数
    self.type = 0
    self.callCache = {}
    self.isInited = false
    self.canClick = false
    self.alive = true
end

-----------override parent-------------
function Bubble_Interface:CreateObj(parent, prefabName)
    local path = string.format("Prefab/UI/CollectionBubble/templates/%s.prefab", prefabName)
    local paths = { path }
    local extFile = self:GetExtLoadFile()
    if extFile then
        table.insert(paths, extFile)
    end
    local function onLoaded()
        if not self.alive then
            return
        end
        local go = BResource.InstantiateFromAssetName(path)
        if Runtime.CSValid(go) then
            self.isInited = true
            local trans = go.transform
            trans:SetParent(parent, false)
            trans.localScale = Vector3.zero
            trans.localEulerAngles = Vector3.zero
            self:Bind(go)
            for _,v in ipairs(self.callCache) do
                v.method(self,v.param)
            end
            self.callCache = nil
        end
    end
    App.uiAssetsManager:LoadAssets(paths, onLoaded)
end

function Bubble_Interface:Bind(go)
    self.gameObject = go
    self.rectTransform = go.transform
    self.bg = find_component(go, "bg")
    self:BindView(go)
end

function Bubble_Interface:Init(param)
    if not self.isInited then
        self.callCache[#self.callCache + 1] = {method = self.Init, param = param}
        return
    end
    self:InitData(param)

    if self.canClick then
        Util.UGUI_AddButtonListener(
            self.bg,
            function()
                if App.mapGuideManager:IsMapBubbleClickDisabled() then
                    return
                end
                self:onBubbleClick()
                -- App.audioManager:PlayEffectAudio(CONST.AUDIO.Interface_sound_story_bounce_bubbles)
            end
        )
    end
end

--接口
function Bubble_Interface:Show()
    if not self.isInited then
        self.callCache[#self.callCache + 1] = {method = self.Show}
        return
    end
    if Runtime.CSValid(self.gameObject) then
        if not self.gameObject.activeSelf then
            self.gameObject:SetActive(true)
        end
        self:ShowStart()
    end
end
function Bubble_Interface:Close()
    if not self.isInited then
        self.callCache[#self.callCache + 1] = {method = self.Close}
        return
    end
    if Runtime.CSValid(self.gameObject) then
        if self.gameObject.activeSelf then
            self.gameObject:SetActive(false)
        end
    end
end
------------default function---------
--初始化transform

function Bubble_Interface:SetScale(scale)
    if Runtime.CSValid(self.rectTransform) then
        self.rectTransform.localScale = Vector3.one * scale
    end
end

function Bubble_Interface:GetPosition()
    if Runtime.CSValid(self.rectTransform) then
        return self.rectTransform.position
    end
end

function Bubble_Interface:SetPosition(vt3)
    if Runtime.CSValid(self.rectTransform) then
        self.rectTransform.position = vt3
        -- local anchorPos = self.rectTransform.anchoredPosition
        -- self.rectTransform.anchoredPosition = anchorPos
    end
end

function Bubble_Interface:SetPosition2D(vt2)
    if Runtime.CSValid(self.rectTransform) then
        self.rectTransform.anchoredPosition = vt2
    end
end

function Bubble_Interface:IsExpandHeight()
    return true
end

function Bubble_Interface:SetParent(parent)
    if Runtime.CSValid(self.rectTransform) then
        self.rectTransform:SetParent(parent, false)
    end
end
---interface 显示动画
function Bubble_Interface:ShowStart()
    local size = self:GetSize() or 1
    local tween = self.rectTransform:DOScale(size, 0.2):SetEase(Ease.OutBack)
    if App.mapGuideManager:HasRunningGuide() then
        tween:OnComplete(
            function()
                App.mapGuideManager:OnGuideFinishEvent(GuideEvent.CustomEvent, "BubbleAppear")
            end
        )
    end
end

---interface 设置显示动画尺寸参数，默认适配尺寸
function Bubble_Interface:GetSize()
    local cameraBaseSize = self:GetCameraBaseSize()
    return Camera.main.orthographicSize / cameraBaseSize
end

---interface 获取显示动画尺寸参数
function Bubble_Interface:GetCameraBaseSize()
    local cameraBaseSize = 3
    return cameraBaseSize
end

function Bubble_Interface:CopyComponent(go, parentGo, num)
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

function Bubble_Interface:DisposeCopyComponents()
    self.copyComponents = nil
end


----------interface for children--------
---interface 点击事件
function Bubble_Interface:onBubbleClick()
    -- body
end
function Bubble_Interface:BindView(go)
    -- body
end
function Bubble_Interface:InitData(data)
end
---回收时清理气泡
function Bubble_Interface:ClearState()
    -- body
end

---扩展加载
function Bubble_Interface:GetExtLoadFile()
end

function Bubble_Interface:Destroy()
    self.alive = false
    self:ClearState()
    if Runtime.CSValid(self.gameObject) then
        Runtime.CSDestroy(self.gameObject)
        self.gameObject = nil
    end
    self:DisposeCopyComponents()
end