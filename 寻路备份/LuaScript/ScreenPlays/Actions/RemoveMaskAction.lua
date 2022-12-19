-- local BezierCurve = require('System.Core.BezierCurve')
---@class RemoveMaskAction : BaseFrameAction
local RemoveMaskAction = class(BaseFrameAction, "RemoveMaskAction")

function RemoveMaskAction:Create(params, finishCallback)
    local instance = RemoveMaskAction.new(params, finishCallback)
    return instance
end

function RemoveMaskAction:ctor(params, finishCallback)
    self.name = "RemoveMaskAction"
    self.params = params
    self.finishCallback = finishCallback
    self.started = false
end

function RemoveMaskAction:Awake()
    for i = 1, #self.params do
        local person = GetPers(self.params[i])
        if person then
            local obj = person.renderObj
            local sortingGroup = obj:GetComponent(typeof(SortingGroup))
            sortingGroup.sortingLayerName = "Map/Building"
            sortingGroup.sortingOrder = 0
        else
            console.error("Can't find person: ", self.params[i])
        end
    end
    -- local playerObj = GetPers("Player").renderObj
    -- local crowObj = GetPers("Petdragon").renderObj

    -- local player_sortingGroup = playerObj:GetComponent(typeof(SortingGroup))
    -- player_sortingGroup.sortingLayerName = "Map/Building"
    -- player_sortingGroup.sortingOrder = 0

    -- local crow_sortingGroup = crowObj:GetComponent(typeof(SortingGroup))
    -- crow_sortingGroup.sortingLayerName = "Map/Building"
    -- crow_sortingGroup.sortingOrder = 0

    local bookfader = Camera.main:FindGameObject("bookfader")
    if Runtime.CSValid(bookfader) then
        bookfader:GetComponent(typeof(SpriteRenderer)):DOFade(0, 0.5)
    end

    WaitExtension.SetTimeout(
        function()
            Runtime.CSDestroy(bookfader)
            bookfader = nil
            self:Finish()
        end,
        0.5
    )
end

function RemoveMaskAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function RemoveMaskAction:Finish()
    self.isFinished = true
end

function RemoveMaskAction:Reset()
    self.started = false
    self.isFinished = false
end

return RemoveMaskAction