---@type BehaviorTreeInfo
local BehaviorTreeInfo = require "Cleaner.BehaviorTree.BehaviorTreeInfo"

---@class NodeBase
local NodeBase = class(nil, "NodeBase")

function NodeBase:ctor()
    self.NodeIndex = 0
    self.NodeId = 0
    self.EntityId = 0

    self.nodeType = 0
    self.Priority = 0
    self.nodeStatus = BehaviorTreeInfo.NODE_STATUS.READY
end

--- Node entry, which executes the first method of a node
function NodeBase:OnEnter()

end

function NodeBase:Execute()
    return BehaviorTreeInfo.ResultType.Fail
end

--- Node exit, which is called when the node exits execution
function NodeBase:OnExit()

end

--- Called on the first line of the Execute() method
function NodeBase:Preposition()
    if (self.nodeStatus == BehaviorTreeInfo.NODE_STATUS.READY) then
        self.nodeStatus = BehaviorTreeInfo.NODE_STATUS.RUNNING
        self:OnEnter()
    end
end

---  Called before returen of the Execute() method
--- ResultType resultType
function NodeBase:Postposition(resultType)
    if resultType == BehaviorTreeInfo.ResultType.Running then
        return
    end

    if self.nodeStatus == BehaviorTreeInfo.NODE_STATUS.READY then
        return
    end

    self.nodeStatus = BehaviorTreeInfo.NODE_STATUS.READY
    self:OnExit()
end

--- NODE_TYPE nodeType
function NodeBase:SetNodeType( nodeType)
    self.nodeType = nodeType
end

function NodeBase:NodeType()
    return self.nodeType
end

return NodeBase