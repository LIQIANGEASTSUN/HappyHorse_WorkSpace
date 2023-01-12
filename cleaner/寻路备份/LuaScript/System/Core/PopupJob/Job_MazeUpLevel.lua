---
--- Created by Betta.
--- DateTime: 2022/9/13 15:36
---
local Job_MazeUpLevel = {}

function Job_MazeUpLevel:Init(priority)
    self.name = priority
end

function Job_MazeUpLevel:CheckPop()
    return AppServices.DragonMaze:CheckMazeUpLevelPop()
end

function Job_MazeUpLevel:Do(finishCallback)
    AppServices.DragonMaze:OnMazeUpLevelPop(finishCallback)
end

return Job_MazeUpLevel