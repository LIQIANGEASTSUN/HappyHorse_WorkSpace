---@type BehaviorTreeInfo
local BehaviorTreeInfo = require "Cleaner.BehaviorTree.BehaviorTreeInfo"

---@type NodeComposite
local NodeComposite = require "Cleaner.BehaviorTree.Node.Base.NodeComposite"

---@class NodeSelect
local NodeSelect = class(NodeComposite, "NodeSelect")

function NodeSelect:ctor()
    self:SetNodeType(BehaviorTreeInfo.NODE_TYPE.SELECT)
    self.lastRunningNode = nil
end

function NodeSelect:OnEnter()
    NodeComposite.OnEnter(self)
end

--- NodeDescript.GetDescript(NODE_TYPE)
function NodeSelect:Execute()
    local index = 1
    if (self.lastRunningNode ~= nil) then
        index = self.lastRunningNode.NodeIndex + 1
    end
    self.lastRunningNode = nil

    local resultType = BehaviorTreeInfo.ResultType.Fail
    for i = index, #self.nodeChildList do
        ---@type NodeBase
        local nodeBase = self.nodeChildList[i]

        nodeBase:Preposition()
        resultType = nodeBase:Execute()
        nodeBase:Postposition(resultType)

        if (resultType == BehaviorTreeInfo.ResultType.Fail) then
        elseif (resultType == BehaviorTreeInfo.ResultType.Success) then
            break
        elseif (resultType == BehaviorTreeInfo.ResultType.Running) then
            self.lastRunningNode = nodeBase
            break
        end
    end

    --NodeNotify.NotifyExecute(EntityId, NodeId, (int)resultType, Time.realtimeSinceStartup);
    return resultType
end

function NodeSelect:OnExit()
    NodeComposite.OnExit(self)

    if (nil ~= self.lastRunningNode) then
        self.lastRunningNode:Postposition(BehaviorTreeInfo.ResultType.Fail)
        self.lastRunningNode = nil
    end
end

return NodeSelect