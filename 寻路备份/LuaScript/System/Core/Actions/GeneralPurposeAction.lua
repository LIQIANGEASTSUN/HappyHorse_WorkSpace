require("System.Core.Actions.BaseFrameAction")

GeneralPurposeAction = class(BaseFrameAction)

function GeneralPurposeAction:Create(updateCallback, finishCallback)
    local instance = GeneralPurposeAction.new(updateCallback, finishCallback)
    return instance
end

function GeneralPurposeAction:ctor(updateCallback, finishCallback)
    self.updateCallback = updateCallback
    self:SetFinishCallback(finishCallback)
end

function GeneralPurposeAction:Update()
    self.updateCallback(self)
end