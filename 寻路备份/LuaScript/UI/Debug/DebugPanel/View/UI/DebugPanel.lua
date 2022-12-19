--insertWidgetsBegin
--	btn_level	go_level	go_mission	btn_mission
--  btn_close	btn_gc	go_ip
--insertWidgetsEnd

--insertRequire
local _DebugPanelBase = require "UI.Debug.DebugPanel.View.UI.Base._DebugPanelBase"

local DebugPanel = class(_DebugPanelBase)

function DebugPanel:ctor()

end

function DebugPanel:onAfterBindView()
    self.level_text = self.go_level.transform:Find("Text").gameObject:GetComponent(typeof(Text))
    self.mission_text = self.go_mission:GetComponent(typeof(CS.UnityEngine.UI.InputField))
    self.digdis_text = self.go_autodigdis:GetComponent(typeof(CS.UnityEngine.UI.InputField))
    self:initTasks()
end

function DebugPanel:refreshUI()

end

function DebugPanel:SwitchNoDrama(isNoDrama)
    if Runtime.CSValid(self.label_NoDrama) then
        self.label_NoDrama.text = isNoDrama and "屏蔽Drama(已屏蔽)"  or "屏蔽Drama(未屏蔽)"
    end
end

function DebugPanel:initTasks()
    local sceneNames = CONST.GAME.SCENE_NAMES
    local nameList = StringList()
    self.Dropdown_Map:ClearOptions()
    for i, name in ipairs(sceneNames) do
        nameList:AddItem(name)
    end
    self.Dropdown_Map:AddOptions(nameList)
    local function onValueChange(index)
        console.lzl('onValueChange', index) --@DEL
        local sceneId = sceneNames[index + 1]
        self:changeSelectMap(sceneId)
    end
    self.Dropdown_Map.onValueChanged:AddListener(onValueChange)
    self:changeSelectMap(sceneNames[1])
end

function DebugPanel:changeSelectMap(sceneId)
    self.Dropdown_Task:ClearOptions()
    local taskIds = AppServices.Task:GetUnFinishTasks(sceneId)
    if taskIds then
        local nameList = StringList()
        for i, taskId in ipairs(taskIds) do
            nameList:AddItem(taskId)
        end
        self.Dropdown_Task:AddOptions(nameList)
        local function onValueChange(index)
            console.lzl('taskIds onValueChange', index) --@DEL
            self.selectTaskId = taskIds[index+1]
            self.label_taskName.text = AppServices.Task:GetTaskName(self.selectTaskId)
            self.mission_text.text = self.selectTaskId
        end
        if Runtime.CSValid(self.Dropdown_Task) then
            self.Dropdown_Task.onValueChanged:RemoveAllListeners()
            self.Dropdown_Task.onValueChanged:AddListener(onValueChange)
        else
            console.lzl('-Dropdown_Task error--')
        end
        self.Dropdown_Task.value = 0
        onValueChange(0)
    else
        -- self.Dropdown_Task.captionText.text = sceneId.."的任务已全部完成"
        self.label_taskName.text = sceneId.."的任务已全部完成"
    end
end

return DebugPanel
