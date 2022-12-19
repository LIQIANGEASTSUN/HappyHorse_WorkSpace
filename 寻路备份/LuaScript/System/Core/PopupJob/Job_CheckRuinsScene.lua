---
--- Created by Betta.
--- DateTime: 2022/7/20 13:28
---
local Job_CheckRuinsScene = {}

function Job_CheckRuinsScene:Init(priority)
    self.name = priority
end

function Job_CheckRuinsScene:CheckPop()
    return SceneServices.RuinsSceneManager:PopCheck()
end

function Job_CheckRuinsScene:Do(finishCallback)
    SceneServices.RuinsSceneManager:PopDo(finishCallback)
end

return Job_CheckRuinsScene