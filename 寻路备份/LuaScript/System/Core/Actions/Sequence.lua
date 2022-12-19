--- @class Sequence:BaseFrameAction
Sequence = class(BaseFrameAction, "Sequence")

function Sequence:Create(finishCallback)
    local instance = Sequence.new(finishCallback)
    return instance
end

function Sequence:ctor(finishCallback)
    self.name = "Sequence"
    self.finishCallback = finishCallback
    self.actions = {}
    self.count = 0
    self.currentIndex = 1
end

function Sequence:Append(action)
    table.insert(self.actions, action)
    self.count = self.count + 1
end

function Sequence:Update()
    if self.count == 0 then
        return
    end
    local currentNode = self.actions[self.currentIndex]
    while currentNode and currentNode:IsFinished() do
        currentNode:CallFinishCallback()
        self.currentIndex = self.currentIndex + 1
        currentNode = self.actions[self.currentIndex]
    end
    if currentNode then
        local ret, info = pcall(currentNode.Update, currentNode)
        if not ret then
            currentNode:SetFinished()
            console.error(info) --@DEL
        end
    else
        self.isFinished = true
    end
end

function Sequence:GetInnerActions()
    return self.actions
end

function Sequence:Reset()
    self.currentIndex = 1
    self.isFinished = false
end
