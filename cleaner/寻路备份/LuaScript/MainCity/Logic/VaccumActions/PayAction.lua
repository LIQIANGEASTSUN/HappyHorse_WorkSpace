local Base = require("MainCity.Logic.VaccumActions.VaccumActionBase")
---@class PayAction : VaccumActionBase
local PayAction = class(Base, "PayAction")
-- local Renderer = CS.UnityEngine.Renderer
local DURATION = 2
local DELAY = 0.5
local INTERVAL = 0.1
function PayAction:ctor()
    -- self.renders = {}
end

---@param agent BaseAgent
function PayAction:Init(agent)
    self.agent = agent
    self.type = agent:GetType()
    self.gameObject = self.agent:GetGameObject()
    if Runtime.CSNull(self.gameObject) then
        return
    end
    -- self.gameObject.transform:DOKill(true)
    local id, cost = self.agent:GetCurrentCost()
    self.payed = 0
    self.payId = id
    if cost <= 0 then
        return
    end
    local userCount = AppServices.User:GetItemAmount(id)
    if userCount <= 0 then
        AppServices.SceneTextTip:Show("Not Enough Materials!", self.agent:GetAnchorPosition())
        return
    end
    -- self.gameObject.transform:DOPunchRotation(Vector3.one * 10, DURATION, 20, 1.0)
    self.active = true
    self.time = 0
    self.begin = false

    self.maxPay = math.min(cost, userCount)
    local max_count = math.round((DURATION - DELAY) / INTERVAL)
    --消耗动画次数
    local cost_count = math.min(max_count, self.maxPay)
    --每一次消耗动画的扣除费用
    self.perPayCost = self.maxPay / cost_count
    --总时长
    self.duration = cost_count * INTERVAL + DELAY
    self.payCount = 0
end

function PayAction:GetPayItem(callback)
    if Runtime.CSValid(self.consumePrefab) then
        return Runtime.InvokeCbk(callback, self.consumePrefab)
    end

    local assetPath = CONST.ASSETS.G_UI_CONSUME_ITEM
    App.commonAssetsManager:LoadAssets(
        {assetPath},
        function()
            self.consumePrefab = BResource.InstantiateFromAssetName(assetPath)
            Runtime.InvokeCbk(callback, self.consumePrefab)
        end
    )
end

function PayAction:Begin()
    self.begin = true
    -- local meshs = self.gameObject:GetComponentsInChildren(typeof(Renderer))
    -- self.renders = {}
    -- for i = 0, meshs.Length - 1, 1 do
    --     local render = meshs[i]
    --     local mat = render.material
    --     local render = {
    --         mat = mat,
    --         shader = mat.shader and mat.shader.name
    --     }
    --     GameUtil.SetShader(mat, "MapEffect/Cleaner")
    --     mat:SetFloat("_Radius", 0)
    --     mat:SetFloat("_Hardness", 2.5)
    --     mat:SetFloat("_RotateScale", 0)
    --     -- mat:SetFloat("_EdgeLength", 20)
    --     -- mat:SetFloat("_TessPhongStrength", 1)
    --     mat:SetColor("_Color", Color(1, 1, 1, 1))
    --     table.insert(self.renders, render)
    -- end
end

function PayAction:Tick(deltaTime)
    if not self.active then
        return
    end
    if Runtime.CSNull(self.gameObject) then
        self:Destroy()
        return
    end
    self.time = self.time + deltaTime
    if self.time > self.duration then
        local delta = self.maxPay - self.payed
        self.payed = self.maxPay
        if delta > 0 then
            local fromPos = self.vaccum:GetPosition()
            self:Pay(fromPos, delta)
        end
        self:Destroy()
    elseif self.time > DELAY then
        if not self.begin then
            self:Begin()
        end

        self.lastPayTs = self.lastPayTs or DELAY
        if self.time - self.lastPayTs > INTERVAL then
            self.lastPayTs = self.lastPayTs + INTERVAL
            self.payCount = self.payCount + 1
            local pay = math.round(self.payCount * self.perPayCost)
            local delta = pay - self.payed
            self.payed = pay
            console.hjs("pay count:", delta) --@DEL
            local fromPos = self.vaccum:GetPosition()
            self:Pay(fromPos, delta)
        end
    end
end

function PayAction:Pay(fromPos, payCount)
    -- local coin = GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Cube)
    -- local box = coin:GetComponent(typeof(BoxCollider))
    -- box.enabled = false
    -- coin:SetLocalScale(0.1, 0.1, 0.1)
    self:GetPayItem(
        function(prefab)
            if not self.active then
                return
            end
            if not self.agent.alive then
                return
            end
            if Runtime.CSNull(prefab) then
                return
            end
            self.agent:OnConsume(self.payed)

            local coin = GameObject.Instantiate(prefab)
            coin.transform.position = fromPos
            coin:SetLocalScale(0.45, 0.45, 0.45)
            coin:SetActive(true)
            local position = self.agent:GetWorldPosition()
            position = position + Vector3(Random.Range(-0.5, 0.5), Random.Range(-0.5, 0.5), Random.Range(-0.5, 0.5))
            coin.transform:DOJump(position, 1.3, 3, 0.65)
            local spriteRenderer = coin:GetComponentInChildren(typeof(SpriteRenderer))
            spriteRenderer.sprite = AppServices.ItemIcons:GetSprite(self.payId)
            -- coin.transform:DOBlendableRotateBy(
            --     Vector3(Random.Range(-360, 360), Random.Range(-360, 360), Random.Range(-360, 360)),
            --     0.65
            -- )
            Runtime.CSDestroy(coin, 0.7)
        end
    )
end

function PayAction:IsActive()
    return self.active
end

function PayAction:SendRequest()
    if self.isSending then
        return
    end
    self.isSending = true

    if self.payed > 0 and self.agent.alive then
        local info = {
            id = self.agent:GetId(),
            cost = {{key = self.payId, value = self.payed}}
        }
        self.agent:Clean(self.payed)
        AppServices.Net:Send(MsgMap.CSUnlockBuildings, info)
        -- 建筑的完成需要发送清除协议给服务器 2022年12月13日12:05:26
        AppServices.NetBuildingManager:SendRemoveBuilding(self.agent.id)
    end
end

function PayAction:Stop()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject.transform:DOKill(true)
    end
    -- 金币动画结束生成地格才向服务器推送消息；
    -- 动画中撤销本地不会生成地格，服务器会记录，
    -- 重新登录，地格已开启
    if self.time >= self.duration then
        self:SendRequest()
    end
    -- for _, render in pairs(self.renders) do
    --     if Runtime.CSValid(render.mat) then
    --         GameUtil.SetShader(render.mat, render.shader)
    --     end
    -- end
end

function PayAction:Destroy()
    self:Stop()
    self.lastPayTs = nil
    self.active = false
    self.agent = nil
    -- self.renders = {}
    self.gameObject = nil
    self.isSending = nil
end

return PayAction
