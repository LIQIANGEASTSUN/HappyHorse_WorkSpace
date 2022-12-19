
local AttachGameObjectAction = class(BaseFrameAction, "AttachGameObjectAction")

function AttachGameObjectAction:Create(person, object, join,params, finishCallback)
    local instance = AttachGameObjectAction.new(person, object, join , params or {}, finishCallback)
    return instance
end

function AttachGameObjectAction:ctor(person, object, join,params, finishCallback)
    self.name = "AttachGameObjectAction"
    self.finishCallback = finishCallback
    self.started = false

    self.person = person
    self.object = object
    self.join = join
	self.bindPosition = params["bindPosition"]
    self.bindRotation = params["bindRotation"]
    self.bindScale = params["bindScale"] or Vector3(1,1,1)
end

function AttachGameObjectAction:Awake()
    local prefabName = string.format("Prefab/Art/Characters/%s.prefab", self.object)
    local instance = BResource.InstantiateFromAssetName(prefabName)
    instance.name = self.object
    local host = GetPers(self.person)
    local transform
    if self.join == "" then
        transform = host.renderObj.transform
    else
        transform = host.renderObj.transform:FindInDeep(self.join)
    end

    console.assert(transform, self.join .. " not found in " .. self.person)
    instance.transform:SetParent(transform, false)

	if self.bindPosition then
		instance.transform.localPosition = self.bindPosition;
	end

	if self.bindRotation then
		instance.transform.localEulerAngles = self.bindRotation;
    end

    if self.bindScale then
		instance.transform.localScale = self.bindScale;
	end
    -- XGE.EffectExtension.FbxFadeIn(instance.renderObj, FBX_FADE_DURATION)
    CharacterManager.Instance():RegisterAttached(self.person, self.object)

    self.isFinished = true
end

function AttachGameObjectAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function AttachGameObjectAction:Reset()
    self.started = false
    self.isFinished = false
end

return AttachGameObjectAction