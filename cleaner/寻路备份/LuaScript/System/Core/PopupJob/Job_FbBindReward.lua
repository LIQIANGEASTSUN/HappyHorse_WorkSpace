---
--- Created by Betta.
--- DateTime: 2022/10/8 17:32
---
local Job_FbBindReward = {}

function Job_FbBindReward:Init(priority)
    self.name = priority
end

function Job_FbBindReward:CheckPop()
    return AppServices.User:GetFbBindReward()
end

function Job_FbBindReward:Do(finishCallback)
    App.loginLogic:ShowLoginReward(finishCallback)
end

return Job_FbBindReward