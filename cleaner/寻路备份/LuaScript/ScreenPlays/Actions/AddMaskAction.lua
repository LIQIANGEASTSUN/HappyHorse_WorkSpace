-- local BezierCurve = require('System.Core.BezierCurve')
---@class AddMaskAction : BaseFrameAction
local AddMaskAction = class(BaseFrameAction, "AddMaskAction")

function AddMaskAction:Create(params, finishCallback)
    local instance = AddMaskAction.new(params, finishCallback)
    return instance
end

function AddMaskAction:ctor(params, finishCallback)
    self.name = "AddMaskAction"
    self.params = params
    self.finishCallback = finishCallback
    self.started = false
end

function AddMaskAction:Awake()
    local objs = {}
    for i = 1, #self.params do
        local person = GetPers(self.params[i])
        if person then
            local obj = person.renderObj
            table.insert(objs, obj)
        else
            console.error("Can't find person: ", self.params[i])
        end
    end
    -- local playerObj = GetPers("Player").renderObj
    -- local crowObj = GetPers("Petdragon").renderObj

    local function onLoadFinish()
        local bookfader = BResource.InstantiateFromAssetName("Prefab/ScreenPlays/bookfader.prefab")
        bookfader.name = "bookfader"
        bookfader:SetParent(Camera.main, false)
        bookfader:SetLocalEulerAngle(0, 0, 0)
        bookfader:SetLocalPositionZ(5)
        local sprite = bookfader:GetComponent(typeof(SpriteRenderer))
        sprite.sortingLayerName = "Map/EditMode"
        sprite:DOFade(0.53, 0.5)

        for i = 1, #objs do
            local sortingGroup = objs[i]:GetComponent(typeof(SortingGroup))
            sortingGroup.sortingLayerName = "Map/EditMode"
            sortingGroup.sortingOrder = 99
        end
        -- local player_sortingGroup = playerObj:GetComponent(typeof(SortingGroup))
        -- player_sortingGroup.sortingLayerName = "Map/EditMode"
        -- player_sortingGroup.sortingOrder = 99

        -- local crow_sortingGroup = crowObj:GetComponent(typeof(SortingGroup))
        -- crow_sortingGroup.sortingLayerName = "Map/EditMode"
        -- crow_sortingGroup.sortingOrder = 99

        WaitExtension.SetTimeout(
            function()
                self:Finish()
            end,
            0.5
        )
    end

    local list = StringList()
    list:AddItem("Prefab/ScreenPlays/bookfader.prefab")
    AssetLoaderUtil.LoadAssets(list, onLoadFinish)
end

function AddMaskAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function AddMaskAction:Finish()
    self.isFinished = true
    Resources.UnloadUnusedAssets()
end

function AddMaskAction:Reset()
    self.started = false
    self.isFinished = false
end

return AddMaskAction