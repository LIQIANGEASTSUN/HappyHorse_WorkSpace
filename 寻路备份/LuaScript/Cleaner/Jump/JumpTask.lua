---@class JumpTask 跳转任务
local JumpTask = {}

JumpTask.JumpCondition = {
    [TaskEnum.LevelUp] = function()
        local str = "探索小岛可获得角色经验"
        AppServices.UITextTip:Show(str)
    end,
    [TaskEnum.GetPet] = function()
        local str = "探索小岛即可获得宠物"
        AppServices.UITextTip:Show(str)
    end,
    [TaskEnum.HavePet] = function()
        local str = "探索小岛即可获得宠物"
        AppServices.UITextTip:Show(str)
    end,
    [TaskEnum.PetLevel] = function()
        PanelManager.showPanel(GlobalPanelEnum.PetInfoPanel)
    end,
    [TaskEnum.ProductItem] = function(cfg)
        local itemId = cfg.args and cfg.args[1]
        AppServices.Jump.JumpFactoryByItemId(itemId)
    end,
    [TaskEnum.ProductDecoration] = function()
        AppServices.Jump.JumpDecorationFactory()
    end,
    [TaskEnum.LinkIsland] = function()
        AppServices.Jump.JumpLinkIsland()
    end,
    [TaskEnum.RecycleItem] = function()
        AppServices.Jump.JumpRecycle()
    end,
    [TaskEnum.GetItem] = function()
        local str = '探索小岛可获得'
        AppServices.UITextTip:Show(str)
    end,
    [TaskEnum.FindAgent] = function(cfg)
        --探索小岛即可发现{factoryName}
        local str = '探索小岛即可发现工厂'
        AppServices.UITextTip:Show(str)
    end,
}

function JumpTask.JumpByTaskSn(taskSn)
    local cfg = AppServices.Task:GetConfigBySn(taskSn)
    local taskEnum = cfg.taskEnum
    return JumpTask.JumpCondition[taskEnum](cfg)
end

return JumpTask