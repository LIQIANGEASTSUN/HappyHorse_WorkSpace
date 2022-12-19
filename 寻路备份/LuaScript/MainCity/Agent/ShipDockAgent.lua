---@type NormalAgent
local NormalAgent = require("MainCity.Agent.NormalAgent")
---@class ShipDockAgent:NormalAgent 探索船
local ShipDockAgent = class(NormalAgent, "ShipDockAgent")

-- 食品工厂 Agent
function ShipDockAgent:ctor(id, data)
    self.data = data
    self.init = false
end

function ShipDockAgent:InitRender(callback)
    NormalAgent.InitRender(self, callback)
    self.render:AddInstantiateListener(
        function(result)
            self:RenderInstantiateCallBack(result)
        end
    )
end

function ShipDockAgent:RenderInstantiateCallBack(result)
    if not result then
        return
    end

    if self.init then
        return
    end
    self.init = true
    self:SendShipDockLevel()
    self:CreateShip()
end

function ShipDockAgent:SetLevel(level)
    NormalAgent.SetLevel(self, level)
    self:SendShipDockLevel()
end

-- 临时创建方法
function ShipDockAgent:CreateShip()
    local config = AppServices.Meta:Category("ShipTemplate")
    local id = ""
    for _, data in pairs(config) do
        if data then
            id = tostring(data.sn)
            break
        end
    end
    AppServices.EntityManager:CreateEntity(id, EntityType.Ship)
end

function ShipDockAgent:SendShipDockLevel()
    local sn = self.data:GetTemplateId()
    local level = self:GetLevel()
    MessageDispatcher:SendMessage(MessageType.ShipDockLevel, self.id, sn, level)
end

-- 处理点击
function ShipDockAgent:ProcessClick()
    NormalAgent.ProcessClick(self)
    local state = self:GetState()

    if state == CleanState.cleared then
        --TODO  障碍物完全清除后点击仍需显示一些东西
        --local arguments = {DMapObj = 建筑数据}
        local arguments = {id = self.id, sn = self.data:GetTemplateId()}
        PanelManager.showPanel(GlobalPanelEnum.ShipDockPanel, arguments)
    end
end

function ShipDockAgent:Destroy()
    NormalAgent.Destroy(self)
end

return ShipDockAgent