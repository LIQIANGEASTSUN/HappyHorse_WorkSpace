--------------------Job_CheckSaveAnimal
local Job_CheckSaveAnimal = {}

function Job_CheckSaveAnimal:Init(priority)
    self.name = priority
end

function Job_CheckSaveAnimal:CheckPop()
    return AppServices.SaveAnimal:CheckQueue()
end

function Job_CheckSaveAnimal:Do(finishCallback)
    AppServices.SaveAnimal:CheckEndHandle(finishCallback)
end

return Job_CheckSaveAnimal