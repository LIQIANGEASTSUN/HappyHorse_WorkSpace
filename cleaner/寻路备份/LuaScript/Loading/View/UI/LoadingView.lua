--insertRequire

---@class LoadingView
local LoadingView = class()

function LoadingView:ctor()
    self.resource = nil
    self.proxy = nil
    --insertCtor
    self.btn_Confirm = nil
    self.onClick_btn_Confirm = nil

    self.resource = GameObject.Find("Canvas/LoginPanel")
    self.isAnima = false
end

function LoadingView:setArguments(args)
end

function LoadingView:setProxy(proxy)
    self.proxy = proxy
    --setProxy
end

--------------Open LoginPanel 的逻辑 ------------
--@params 控制gitTips的显隐
function LoadingView:ShowGiftTips(isShow)
    self.gitTips:SetActive(isShow)
end

--@params 控制ChannelPanel/btn_panel的显隐
function LoadingView:ShowBtnPanel(isShow)
end

function LoadingView:bindView()
    self.sliderBg = find_component(self.resource, "sliderBg")
    self.scb_LoadingProgress = find_component(self.sliderBg, "slider", Image)

    self.loadingCanvas = GameObject.Find("LoadingCanvas")

    self.bundleVersionText = self.resource:FindGameObject("BundleVersion"):GetComponent(typeof(Text))
    self.bundleVersionText.text = RuntimeContext.BUNDLE_VERSION

    self.tips = find_component(self.sliderBg, "Tips", Text)
    self.tips.text = Runtime.Translate("LoadingScene.LoadingView.Tips." .. math.random(1, 6))
    if BCore.IsOpen("SpecialCheck") then
        self.tips:FindGameObject("HealthAdvice"):SetActive(true)
    end
end

function LoadingView:setProgress(val)
    -- val = math.max(0.07, val)

    local function updateCallback(value)
        self.scb_LoadingProgress.fillAmount = value
    end

    local function completeCallback()
        if self.floatSmoothTweener ~= nil then
            self.floatSmoothTweener:Kill()
            self.floatSmoothTweener = nil
        end
    end

    completeCallback()
    self.floatSmoothTweener = LuaHelper.FloatSmooth(self.scb_LoadingProgress.fillAmount, val, 0.3, updateCallback, completeCallback)
end

--隐藏进度条UI
function LoadingView:ShowTitleCartoon()
    self.sliderBg:SetActive(false)
end

return LoadingView
