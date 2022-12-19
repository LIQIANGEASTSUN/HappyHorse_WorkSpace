local defaultSkin = {
    ["Petdragon"] = "27100",
    ["Femaleplayer"] = "27200",
}

---@class CharacterItem
local CharacterItem = class("CharacterItem")

function CharacterItem:ctor(name, camera, rawView, rtSize)
    self.name = name

    self.rawView = rawView
    self.camera = camera
    local size = rtSize or 512
    local rTexture = GameUtil.CreateUIRenderTexture(size, size)
    self.rawView.texture = rTexture
    self.camera.targetTexture = rTexture
    self.renderTexture = rTexture
    self.rawView.color = Color.white

    self.camera.enabled = true
    self.camera.fieldOfView = 20
    local trans = self.camera.transform
    trans.localPosition = Vector3(0, 0.48, -4.2)
    trans.localEulerAngles = Vector3.zero
    trans.localScale = Vector3.one

    local defaultId = defaultSkin[name]
    self.defaultRolePath = AppServices.SkinLogic:GetSkinMeta(defaultId).model
    --modelCamera参数受mainCamSize(缩放)影响所以打开界面前先设置好mainCamSize
    MoveCameraLogic.Instance():SetCameraSize(3)
end

function CharacterItem:CreateWithGameObject(gameObject)
    self.renderObj = gameObject
    self.animatorCtrl = self.renderObj:GetOrAddComponent(typeof(CS.DynamicAnimatorCtrl))
    self.transform = self.renderObj.transform
end

---@param skin SkinMeta
function CharacterItem:Show(skins, localPos, animName, onFinish)
    local assetPaths = {}
    local function onLoaded()
        Util.BlockAll(0, "CharacterItem:ChangeSkin")
        local go = BResource.InstantiateFromAssetName(assetPaths[1])
        if Runtime.CSValid(go) then
            local renderObj = self.renderObj
            self:CreateWithGameObject(go)
            self:SetAnim(animName)
            local j = string.len(go.name) - string.len("(Clone)")
            local name = string.sub(go.name,1, j)
            self.model = find_component(go, name)
            self:RenderTexture()
            self.transform.localPosition = localPos
            local renderAry = self.renderObj:GetComponentsInChildren(typeof(CS.UnityEngine.Renderer))
            for index = 1, renderAry.Length do
                local render = renderAry[index - 1]
                render.gameObject.layer = CS.UnityEngine.LayerMask.NameToLayer("Dragon")
            end
            Runtime.CSDestroy(renderObj)
            Runtime.InvokeCbk(onFinish)
        else
            Runtime.InvokeCbk(onFinish)
        end
    end

    local function onLoadParts()
        Util.BlockAll(0, "CharacterItem:ChangeSkin")
        --默认角色
        local role = self.renderObj--self.defaultRoleGo
        local controller = nil
        local createNew = false
        if Runtime.CSValid(role) then
            controller = find_component(role, "", CS.MarkupRoleController)
            if not controller then
                Runtime.CSDestroy(role)
                createNew = true
            end
        else
            createNew = true
        end
        if createNew then
            role = BResource.InstantiateFromAssetName(self.defaultRolePath)
            role:SetLayerRecursively(CS.UnityEngine.LayerMask.NameToLayer("Dragon"))
            controller = find_component(role, "", CS.MarkupRoleController)
            self.defaultRoleShowed = true
        end
        self:CreateWithGameObject(role)
        self:SetAnim(animName)
        local j = string.len(role.name) - string.len("(Clone)")
        local name = string.sub(role.name,1, j)
        self.model = find_component(role, name)
        self:RenderTexture()
        self.transform.localPosition = localPos
        -- self.defaultRoleGo = role

        ---部件
        if not self.defaultRoleShowed then
            controller:ResetAllPart()
            self.defaultRoleShowed = true
            role:SetActive(true)
        end
        for _, skin in pairs(skins) do
            local part = nil
            if skin.getWay ~= 0 then
                part = BResource.InstantiateFromAssetName(skin.model)
                part:SetLayerRecursively(CS.UnityEngine.LayerMask.NameToLayer("Dragon"))
            end
            if part then
                controller:ChangePart(skin.type, part)
            else
                controller:RemovePart(skin.type)
            end
        end
        Runtime.InvokeCbk(onFinish)
    end
    local isSetSkin

    for _, meta in pairs(skins) do
        local mType = meta.type
        if mType == SkinType.Pet or mType == SkinType.FemalePlayer then
            isSetSkin = true
        end
        table.insertIfNotExist(assetPaths, meta.model)
    end

    Util.BlockAll(-1, "CharacterItem:ChangeSkin")
    if isSetSkin then
        if Runtime.CSValid(self.defaultRoleGo) then
            if self.defaultRoleShowed then
                self.defaultRoleShowed = false
                self.defaultRoleGo:SetActive(false)
            end
        end
        App.dramaAssetManager:LoadAssets(assetPaths, onLoaded)
    else
        table.insert(assetPaths, self.defaultRolePath)
        App.dramaAssetManager:LoadAssets(assetPaths, onLoadParts)
    end
end

function CharacterItem:RenderTexture()
    if Runtime.CSValid(self.rawView) or Runtime.CSValid(self.camera) then
        self.rawView:DOFade(1,0.1)
        self.renderObj:SetParent(self.rawView.transform, false)
        self.transform.localScale = Vector3.one
        self.transform.localEulerAngles = Vector3(0, 180, 0)
    end
end

--拖动开关 ，传nil关闭
function CharacterItem:SetDragMask(go)
    self.dragMask = go
    self:InitDragEvent()
end

function CharacterItem:InitDragEvent()
    if Runtime.CSValid(self.dragMask) then
        local function onDrag(pointData)
            if not pointData then
                return
            end
            if Runtime.CSNull(self.dragMask) then
                return
            end
            self.transform.localEulerAngles = Vector3(0, self.transform.localEulerAngles.y - pointData.delta.x, 0)
        end

        Util.UGUI_AddEventListener(self.dragMask, UIEventName.onDrag, onDrag, false)
    end
end

--nil则播放默认动画
function CharacterItem:SetAnim(animName)
    if not animName then
        return
    end
    WaitExtension.InvokeDelay(function()
        if Runtime.CSValid(self.renderObj) then
            self.animatorCtrl:Play(animName, 0, false)
        end
    end)
end

function CharacterItem:SetCameraPosition(vt3)
    self.camera.transform.localPosition = vt3
end

function CharacterItem:SetCameraFov(size)
    self.camera.fieldOfView = size
end

function CharacterItem:SetCameraRotation(vt3)
    self.camera.transform.localEulerAngles = vt3
end

function CharacterItem:SetActive(state)
    if Runtime.CSValid(self.renderObj) then
        self.renderObj:SetActive(state)
    end
end

function CharacterItem:Destory()
    if Runtime.CSValid(self.renderObj) then
        Runtime.CSDestroy(self.renderObj)
    end
    if Runtime.CSValid(self.camera) then
        Runtime.CSDestroy(self.camera)
        self.camera = nil
    end
    if Runtime.CSValid(self.rawView) then
        self.rawView:SetActive(false)
    end
    if Runtime.CSValid(self.renderTexture) then
        GameUtil.RecycleUIRenderTexture(self.renderTexture)
        self.renderTexture = nil
    end
end

return CharacterItem
