---@class PanelCallbacks
PanelCallbacks = class(nil, "PanelCallbacks")

---@return PanelCallbacks
function PanelCallbacks:Create(closeCallback)
    local instance = PanelCallbacks.new()
    instance:Init()
    instance:onAfterDestroyPanel(closeCallback)
    return instance
end

function PanelCallbacks:Init()
    self.callbacks = {}
end

function PanelCallbacks:onEvent(eventName)
    local callback = self.callbacks[eventName]
    Runtime.InvokeCbk(callback, self)
end

function PanelCallbacks:onInitPanel(func)
    self.callbacks.onInitPanel = func
end

function PanelCallbacks:onAfterSetViewComponent(func)
    self.callbacks.onAfterSetViewComponent = func
end

function PanelCallbacks:onBeforeLoadAssets(func)
    self.callbacks.onBeforeLoadAssets = func
end

function PanelCallbacks:onLoadAssetsFinish(func)
    self.callbacks.onLoadAssetsFinish = func
end

function PanelCallbacks:onBeforeShowPanel(func)
    self.callbacks.onBeforeShowPanel = func
end

function PanelCallbacks:onAfterShowPanel(func)
    self.callbacks.onAfterShowPanel = func
end

function PanelCallbacks:onBeforeHidePanel(func)
    self.callbacks.onBeforeHidePanel = func
end
function PanelCallbacks:onAfterHidePanel(func)
    self.callbacks.onAfterHidePanel = func
end

function PanelCallbacks:onBeforeReshowPanel(func)
    self.callbacks.onBeforeReshowPanel = func
end
function PanelCallbacks:onAfterReshowPanel(func)
    self.callbacks.onAfterReshowPanel = func
end

function PanelCallbacks:onBeforeDestroyPanel(func)
    self.callbacks.onBeforeDestroyPanel = func
end

function PanelCallbacks:onAfterDestroyPanel(func)
    self.callbacks.onAfterDestroyPanel = func
end


function PanelCallbacks:onBeforePausePanel(func)
    self.callbacks.onBeforePausePanel = func
end
function PanelCallbacks:onAfterResumePanel(func)
    self.callbacks.onAfterResumePanel = func
end

return PanelCallbacks
