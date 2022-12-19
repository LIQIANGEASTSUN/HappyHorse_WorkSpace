--insertWidgetsBegin
--    btn_close
--insertWidgetsEnd

--insertRequire
local _GMPanelBase = require "UI.GM.View.UI.Base._GMPanelBase"

---@class GMPanel:_GMPanelBase
local GMPanel = class(_GMPanelBase)

function GMPanel:ctor()
    self.gms = {}
end

function GMPanel:onAfterBindView()

end

function GMPanel:refreshUI()
    self.dropdown:ClearOptions()
    local gms = self:GetAllGms()
    self.dropdown:AddOptions(gms)

    local function onValueChange(index)
        self:SetInputField(index + 1)
    end
    self.dropdown.onValueChanged:AddListener(onValueChange)

    self:SetInputField(1)
end

function GMPanel:SetInputField(index)
    if #self.gms < index then
        return
    end

    local command = self.gms[index]
    self.inputField.text = command
end

function GMPanel:GetAllGms()
    local config = AppServices.Meta:Category("GmTemplate")

    self.gms = {}
    local nameList = StringList()
    for _, data in pairs(config) do
        local showCommand = string.format("%s %s", data.desc, data.name)
        local command = data.name

        if self:IsAppend(data.param1) then
            showCommand = showCommand.." "..data.param1
            command = command.." "..data.param1
        end

        if self:IsAppend(data.param2) then
            showCommand = showCommand.." "..data.param2
            command = command.." "..data.param2
        end

        nameList:AddItem(showCommand)
        table.insert(self.gms, command)
    end

    return nameList
end

function GMPanel:IsAppend(param)
    if type(param) == "string" and param ~= "" then
        return true
    end

    if type(param) == "number" and param > 0 then
        return true
    end
    return false
end

function GMPanel:Split(str, reps)
    local result = {}
    string.gsub(str, '[^'..reps..']+', function(w)
        table.insert(result, w)
    end)
    return result
end

function GMPanel:GmRunClick()
    local gm = self.inputField.text
    local params = self:Split(gm, " ")
    if #params <= 1 then
        return
    end

    local msg = {
        params = params
    }

    AppServices.Net:Send(MsgMap.CSGM, msg)
end

return GMPanel
