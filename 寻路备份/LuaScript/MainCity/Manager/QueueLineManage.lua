QueueNode = class()

function QueueNode:Create(nodeName,action)
    local instance = QueueNode.new()
    instance:Init(nodeName,action)
    return instance
end

function QueueNode:Init(nodeName,action)
    self.name = nodeName
    self.state = QueueLineNodeState.Unactive
    self.action = action
    self.left = nil
    self.right = nil
    self.parent = nil
    self.startTime = TimeUtil.ServerTime()
end

function QueueNode:SetChild(node,dir)
    --返回最左边节点
    local function FindLeft(nd)
        if not nd then
            return nil
        end

        if not nd.left then
            return nd
        else
            -- body
            return FindLeft(nd.left)
        end
    end

    --返回最右边边节点
    local function FindRight(nd)
        if not nd then
            return nil
        end
        if not nd.right then
            return nd
        else
            return FindRight(nd.right)
        end
    end

    dir = (dir == nil and true or dir)
    if dir then
        local targetNode = FindLeft(self)
        targetNode.left = node
        node.parent = targetNode
    else
        local targetNode = FindRight(self)
        targetNode.right = node
        node.parent = targetNode
    end
end

---@class QueueLineManage
QueueLineManage = class(nil, "QueueLineManage")

local instance
---@return QueueLineManage
function QueueLineManage.Instance()
    if not instance then
        instance = QueueLineManage.new()
    end
    return instance
end
function QueueLineManage.Destroy()
    if not instance then
        return
    end
    instance:OnDestroy()
    instance = nil
end
function QueueLineManage.Exists()
    return instance
end

function QueueLineManage:ctor()
end

function QueueLineManage:InitLog()
    self.log = ""
    self.startTime = TimeUtil.ServerTime()
end
function QueueLineManage:ShowLog()
    if not self.curNode then
        console.print("当前没有正在执行的序列流水线")
        return
    end
    console.print(self.log)
end

--创建一个节点
QueueLineNodeState = {
    Unactive = 1,
    Start = 2,
    Finish = 3
}

QueueLineNodeOrder = {
    Left = true,
    Right = false
}

function QueueLineManage:ShowFlow()
    local function GetState(node)
        if node.state == QueueLineNodeState.Unactive then
            return "未激活"
        elseif node.state == QueueLineNodeState.Start then
            return "进行中"
        elseif node.state == QueueLineNodeState.Finish then
            return "已完成"
        end
    end

    local function GetTabSpace(layer)
        local str = ""
        if layer > 0 then
            for i = 1, layer do
                str = str.."\t"
            end
        end
        return str
    end
    local function FindNext(node,count)
        self.flowLog =self.flowLog..GetTabSpace(count).. node.name..":"..GetState(node).."\n"
        --左节点
        if node.left then
            FindNext(node.left,count + 1)
        end
        --右节点
        if node.right then
            FindNext(node.right,count + 1)
        end
    end

    FindNext(self.rootNode,0)
    console.print("QueueLineManage~Flow: "..self.flowLog)
end

---true leftNode;false rightNode
function QueueLineManage:CreateNode(nodeName,action,dir)
    local node = QueueNode:Create(nodeName,action)
    if self.curNode then
        self.curNode:SetChild(node,dir)
    end

    return node
end

function QueueLineManage:CreateNodeByParent(nodeName,action,dir,parentNode)
    local node = QueueNode:Create(nodeName,action)
    if parentNode then
        parentNode:SetChild(node,dir)
    end

    return node
end

--创建根节点和左子节点，开始执行
function QueueLineManage:Start(childname,action,finish)
    if not self.curNode then
        self.rootNode =  self:CreateNode("Root")
        self:CreateNodeByParent(childname, action, QueueLineNodeOrder.Left,self.rootNode)
        self:CreateNodeByParent(childname.."End",finish,QueueLineNodeOrder.Right,self.rootNode)
        self.log = childname.."流水线："
        self.flowLog = ""
        self:Execute(self.rootNode)
    else
        local subNode =  self:CreateNode(childname.."SubRoot",nil,self.curNode)
        self:CreateNodeByParent(childname, action, QueueLineNodeOrder.Left, subNode)
        self:CreateNodeByParent(childname.."End", finish, QueueLineNodeOrder.Right,subNode)
        self:FinishNode()
    end
end

--执行节点,如果是根节点则结束当前节点
function QueueLineManage:Execute(node)
    node.state = QueueLineNodeState.Start
    self.curNode = node
    self.log = self.log ..node.name..":start =>"  --@DEL
    if node.name == "Root" then
        self:FinishNode()
        return
    end

    if node.action then
        Runtime.InvokeCbk(node.action)
    end
end

--完成一个节点
function QueueLineManage:FinishNode()
    local node = self.curNode
    node.state = QueueLineNodeState.Finish
    self.log = self.log ..node.name..":Finish ".."time:"..tostring(TimeUtil.ServerTime() - node.startTime).."\n"  --@DEL

    --找到下一个节点
    local next = self:FindNextNode(node)
    if not next or self.forceEnd then
        self:close()
    else
        self:Execute(next)
    end
end

--找到下一个节点
function QueueLineManage:FindNextNode(node)
    -- body
    if node.left and node.left.state == QueueLineNodeState.Unactive then
        return node.left
    end


    if node.right and node.right.state == QueueLineNodeState.Unactive then
        return node.right
    end

    if node.parent then
        return self:FindNextNode(node.parent)
    end
    return nil
end

--
function QueueLineManage:EndingNode()
    self.forceEnd = true
end
--关闭序列
function QueueLineManage:close()
    self.log = self.log .."close\n"  --@DEL
    self:ShowLog() --@DEL
    self:ShowFlow()
    self:clear()
end

function QueueLineManage:clear()
    self.log = ""
    self.name = ""
    self.state = false
    self.actionList = {}
    self.root = nil
    self.finishCb = nil
    self.curNode = nil
    self.forceEnd = false
end

