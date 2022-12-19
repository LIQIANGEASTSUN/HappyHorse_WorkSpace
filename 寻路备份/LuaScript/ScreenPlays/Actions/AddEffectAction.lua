
local AddEffectAction = class(BaseFrameAction, "AddEffectAction")

function AddEffectAction:Create(params, finishCallback)
    local instance = AddEffectAction.new(params, finishCallback)
    return instance
end

function AddEffectAction:ctor(params, finishCallback)
    self.name = "AddEffectAction"
    self.finishCallback = finishCallback
    self.started = false

    self.person = params.Person
    self.join = params.Join
    self.goName = params.Name
    self.delay = params.Delay or 0
    self.prefab = params.Prefab
    self.inTrigger = params.InTrigger
    self.position = params.Position
    self.animation = params.Animation
    self.animationType = params.AnimationType
    self.loop = params.Loop or false
end

function AddEffectAction:Awake()
    local function start()
        local function onLoadFinish()
            local go = BResource.InstantiateFromAssetName(self.prefab)
            App.scene.director:AddActor(self.goName, go)
            go:SetActive(true)
            go.name = self.goName
            if self.person then
                local host = GetPers(self.person)
                local transform
                if self.join == "" then
                    transform = host.renderObj.transform
                else
                    transform = host.renderObj.transform:FindInDeep(self.join)
                end
                go.transform:SetParent(transform, false)
            end

            if self.position then
                go.transform.position = Vector3(self.position.x or 0, self.position.y or 0, self.position.z or 0)
            end

            if self.inTrigger then
                AnimatorEx.SetTrigger(go, self.inTrigger)
            end

            if self.animation then
                if self.animationType == "spine" then
                    GameUtil.PlaySpineAnimation(go, self.animation, self.loop)
                else
                    AnimatorEx.SetTrigger(go, self.animation)
                end
            end

            self.isFinished = true
        end
        local list = StringList()
        list:AddItem(self.prefab)
        AssetLoaderUtil.LoadAssets(list, onLoadFinish)
    end

    if self.delay > 0 then
        WaitExtension.SetTimeout(start, self.delay)
    else
        start()
    end
end

function AddEffectAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function AddEffectAction:Reset()
    self.started = false
    self.isFinished = false
end

return AddEffectAction