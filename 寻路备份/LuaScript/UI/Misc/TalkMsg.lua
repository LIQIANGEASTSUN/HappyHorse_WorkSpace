---@class TalkMsg
local TalkMsg = class(nil, 'TalkMsg')

function TalkMsg:ctor()
    self.render = nil
    self.textCom = nil
    self.timerId = nil
    self.isDisposed = false
end

function TalkMsg:Create()
    local inst = TalkMsg.new()
    inst:_Init()
    return inst
end

function TalkMsg:_Init()
    self.render = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_ACTOR_BUBBLE_TEXT)
    self.render:SetActive(false)

    self.render.name = "TalkMsg"
    self.render:SetParentAlign(App.scene.sceneCanvas)

    self.fader = self.render:GetOrAddComponent(typeof(CS.BetaGame.PanelFader))
    --self.fader.BounceBack = false
    --self.fader.StartScale = 0

    self.bubbleText = self.render:GetComponent(typeof(NS.BubbleText))
    self.playing = false
end

function TalkMsg:SetRenderTarget(target)
    self.bubbleText:SetRenderTarget(target)
end

function TalkMsg:Mutter(text, duration, reverse, targetRender, talkOffsetX, talkOffsetY)
    self.playing = true
    self.render:SetActive(true)

    local reverseNum = 1
    if reverse then
        reverseNum = 0
    end
    self.bubbleText:ShowText(text, reverseNum, talkOffsetX, talkOffsetY);

    local function OnFinished()
        self.timerId = WaitExtension.SetTimeout(function()
            self.timerId = nil
            if self.isDisposed then
                return
            end
            local function OnFadeOut()
                self.playing = false
                self.bubbleText:Hide()
            end
            self.fader:FadeOut(0.15, OnFadeOut)
        end, duration or 1.5)
    end
    self.fader:FadeIn(0.15, OnFinished)
end
function TalkMsg:EnableDotsMode(isDots)
    self.bubbleText:EnableDotsMode(isDots)
    if isDots then
        self.fader.FinalScale = 0.7
    else
        self.fader.FinalScale = 1.0
    end
end

function TalkMsg:RemoveMutter()
    if not self.playing then
        return
    end

    self.fader:DOKill()
    if self.timerId then
        WaitExtension.CancelTimeout(self.timerId)
        self.timerId = nil
    end
    self.bubbleText:Hide()
end

function TalkMsg:HideMutter()
    self:RemoveMutter()
    self.render:SetActive(false)
end

function TalkMsg:Destroy()
    self.isDisposed = true
    Runtime.CSDestroy(self.render)
    self.render = nil
end

return TalkMsg