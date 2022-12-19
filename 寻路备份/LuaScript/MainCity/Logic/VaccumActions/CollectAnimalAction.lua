---@type EffectManager
local EffectManager = require "Cleaner.Effect.EffectManager"
local ParticleSystemRenderer = CS.UnityEngine.ParticleSystemRenderer
local Texture2D = CS.UnityEngine.Texture2D

local Base = require("MainCity.Logic.VaccumActions.VaccumActionBase")
---@class CollectAnimalAction:VaccumActionBase
local CollectAnimalAction = class(Base, "CollectAnimalAction")
local Renderer = CS.UnityEngine.Renderer
local DURATION = 0.6 --从进入到结束的总时长
local DELAY = 0.2 --开始表现吸入的延迟
function CollectAnimalAction:ctor()
    self.renders = {}
end

---@param agent BaseAgent
function CollectAnimalAction:Init(agent)
    self.agent = agent
    self.type = agent:GetType()
    self.gameObject = self.agent:GetGameObject()
    if Runtime.CSNull(self.gameObject) then
        return
    end
    self.gameObject.transform:DOKill(true)
    local tween = self.gameObject.transform:DOPunchRotation(Vector3.one * 10, DURATION - DELAY, 20, 1.0)
    tween:SetDelay(DELAY)
    self.active = true
    self.time = 0
    self.begin = false
end

function CollectAnimalAction:Begin()
    self.begin = true
    local meshs = self.gameObject:GetComponentsInChildren(typeof(Renderer))
    self.renders = {}
    for i = 0, meshs.Length - 1, 1 do
        local render = meshs[i]
        local mat = render.material
        local render = {
            mat = mat,
            shader = mat.shader and mat.shader.name
        }
        GameUtil.SetShader(mat, "MapEffect/Cleaner")
        mat:SetFloat("_Radius", 0)
        mat:SetFloat("_Hardness", 2.5)
        mat:SetFloat("_RotateScale", 0)
        -- mat:SetFloat("_EdgeLength", 20)
        -- mat:SetFloat("_TessPhongStrength", 1)
        mat:SetColor("_Color", Color(1, 1, 1, 1))
        table.insert(self.renders, render)
    end
end

function CollectAnimalAction:Tick(deltaTime)
    if not self.active then
        return
    end
    if Runtime.CSNull(self.gameObject) then
        self:Destroy()
        return
    end
    self.time = self.time + deltaTime
    if self.time > DURATION then
        self:SendRequest()
        self.agent:Clean()
        self:Destroy()
    elseif self.time > DELAY then
        if not self.begin then
            self:Begin()
        end
        local fromPos = self.vaccum:GetPortPosition()
        local vector = Vector4(fromPos.x, fromPos.y, fromPos.z)
        local dis = Vector3.Distance(fromPos, self.agent:GetWorldPosition())
        for _, render in pairs(self.renders) do
            render.mat:SetVector("_TargetPostion", vector)
            local value = math.lerp(0, dis + 1, self.time / DURATION)
            render.mat:SetFloat("_Radius", value)
        end
    end
end

function CollectAnimalAction:IsActive()
    return self.active
end

function CollectAnimalAction:SendRequest()
    AppServices.BuildingModifyManager:SendClean(self.agent)
end

function CollectAnimalAction:CanStop()
    if not self.active or not self.time then
        return true
    end
    return self.time < DELAY
end
function CollectAnimalAction:Stop()
    if Runtime.CSValid(self.gameObject) then
        self.gameObject.transform:DOKill(true)
    end
    for _, render in pairs(self.renders) do
        if Runtime.CSValid(render.mat) then
            GameUtil.SetShader(render.mat, render.shader)
        end
    end
end

function CollectAnimalAction:Destroy()
    self:Stop()
    self.active = false
    self.agent = nil
    self.renders = {}
    self.gameObject = nil
end

return CollectAnimalAction
