--------------------Job_LevelMapActivity
local Job_LevelMapActivity = {}

function Job_LevelMapActivity:Init(priority)
    self.name = priority
end

function Job_LevelMapActivity:CheckPop()
    return true
end

function Job_LevelMapActivity:Do(finishCallback)
    ActivityServices.LevelMapActivity:CheckActivity(finishCallback)
end

return Job_LevelMapActivity