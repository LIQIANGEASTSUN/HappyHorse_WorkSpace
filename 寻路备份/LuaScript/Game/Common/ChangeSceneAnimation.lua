---@class ChangeSceneAnimation
local ChangeSceneAnimation = class()

local SkeletonGraphicCtrl = CS.BetaGame.SkeletonGraphicCtrl

local friendCityAnimPath = "Prefab/UI/Common/ChangeScene/FriendCityAnim.prefab"

local instance
---@return ChangeSceneAnimation
function ChangeSceneAnimation:Instance()
    if not instance then
        instance = ChangeSceneAnimation.new()
        instance:Init()
    end
    return instance
end

function ChangeSceneAnimation:Init()
    self.canvas = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_CANVAS_CHANGESCENE)
    GameObject.DontDestroyOnLoad(self.canvas)
    self.animObj = nil
    self.curAnimationType = 0
end

function ChangeSceneAnimation:PlayOut(finishCallback)
    if self.curAnimationType == 2 then
        self:EnterCityOut(finishCallback)
    else
        Runtime.InvokeCbk(finishCallback, false)
        Runtime.InvokeCbk(AppServices.Jump.OverJump)
    end
end

function ChangeSceneAnimation:EnterCityIn(finishCallback)
    self.canvas:SetActive(true)
    App.changingScene = true
    local function onLoadFinish()
        PanelManager.closeAllPanels()
        local go = BResource.InstantiateFromAssetName(friendCityAnimPath)
        self.animObj = go
        self.animObj.transform:SetParent(self.canvas.transform, false)
        self.animation = self.animObj:FindComponentInChildren("animation", typeof(SkeletonGraphicCtrl))
        self.animation:SetAnimation("in", finishCallback)
    end
    self.curAnimationType = 2
    App.commonAssetsManager:LoadAssets({friendCityAnimPath}, onLoadFinish)
end

function ChangeSceneAnimation:EnterCityOut(finishCallback)
    if Runtime.CSNull(self.animObj) then
        console.error("Enter friend city animation in has not played!!!") --@DEL
        App.changingScene = nil
        return Runtime.InvokeCbk(finishCallback)
    end
    local function onFinished()
        self.animation = nil
        Runtime.CSDestroy(self.animObj)
        self.animObj = nil
        self.curAnimationType = 0
        self.canvas:SetActive(false)
        Runtime.InvokeCbk(finishCallback, true)
        -- Runtime.InvokeCbk(AppServices.Jump.OverJump)
        App.changingScene = nil
    end
    self.animation:SetAnimation("out", onFinished)
end

return ChangeSceneAnimation