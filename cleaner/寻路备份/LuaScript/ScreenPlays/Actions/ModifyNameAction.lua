local ModifyNameAction = class(BaseFrameAction, "ModifyNameAction")

function ModifyNameAction:Create(finishCallback)
    local instance = ModifyNameAction.new(finishCallback)
    return instance
end

function ModifyNameAction:ctor(finishCallback)
    self.name = "ModifyNameAction"
    self.finishCallback = finishCallback
    self.started = false

end

function ModifyNameAction:Awake()

    local function closePanelCallback()
        self.isFinished = true
    end
    PanelManager.showPanel(GlobalPanelEnum.TownNamePanel,{callback = closePanelCallback,isFirstTime = true})
end

function ModifyNameAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function ModifyNameAction:Reset()
    self.started = false
    self.isFinished = false
end

return ModifyNameAction