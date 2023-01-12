--------------------Job_GuideEvent_EnterCity
local Job_GuideEvent_EnterCity = {}

function Job_GuideEvent_EnterCity:Init(priority)
    self.name = priority
end

function Job_GuideEvent_EnterCity:CheckPop()
    if not App.mapGuideManager:HasRunningGuide() or App.mapGuideManager:IsWeakStep() then
        return false
    end

    return true
end

function Job_GuideEvent_EnterCity:Do(finishCallback)
    App.mapGuideManager:SetGuideFinishCallback(finishCallback)
    App.mapGuideManager:OnGuideFinishEvent(
        GuideEvent.CityEntered,
        {sceneId = App.scene.params.sceneId, sceneMode = App.scene.sceneMode}
    )
end

return Job_GuideEvent_EnterCity