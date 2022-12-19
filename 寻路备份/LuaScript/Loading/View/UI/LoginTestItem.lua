
local LoginTestItem = {}

local StateText = {
    [1] = "取消测试账号",
    [2] = "点击使用测试账号"
}
local NetWork = require("System.Core.Network.NetWork")
function LoginTestItem:Create(Root,name)
    self.gameObject = Root:FindGameObject(name)
    self.InputField = self.gameObject:FindGameObject("InputField"):GetComponent(typeof(CS.UnityEngine.UI.InputField))

    self.isTest = true
    self:SetInfo()
    -- NetWork:Setup("10.0.60.182", 59999)
    -- WaitExtension.InvokeRepeating(function ()
    --     NetWork:Tick(0.5)
    -- end, 0, 0.5)--[[]]
    Util.UGUI_AddEventListener(self.gameObject, "onClick", function()
        self.isTest = not self.isTest
        self:SetInfo()
        -- NetWork:Send(1001,{channelId = "test",userIdentity = "1233",token = "dfsf",deviceId = "sfsdf",version = "dfsdf"})
        -- NetWork:Route(2002,function(id,data)
        --     console.lj(table.tostring(data))
        -- end)
    end)
end

function LoginTestItem:SetInfo()
    local text = self.isTest and StateText[1] or StateText[2]
    Runtime.Localize(self.gameObject:FindGameObject("Text"), text)

    self.InputField:SetActive(self.isTest)
    App.loginLogic:SetTestMode(self.isTest)

    if not self.isTest then
        return
    end

    if not RuntimeContext.CACHES.TEST_ACCOUNT then
        RuntimeContext.CACHES.TEST_ACCOUNT = AppServices.AccountData:GetLastAccount() or ""
    end
    self.InputField.text = RuntimeContext.CACHES.TEST_ACCOUNT
end

function LoginTestItem:Hide()
    self.gameObject:SetActive(false)


end

function LoginTestItem:CheckAccountConfirm()
    RuntimeContext.CACHES.TEST_ACCOUNT = self.InputField.text
    if RuntimeContext.CACHES.TEST_ACCOUNT and string.len(RuntimeContext.CACHES.TEST_ACCOUNT) == 0 then
        RuntimeContext.CACHES.TEST_ACCOUNT = nil
    end

    if not RuntimeContext.CACHES.TEST_ACCOUNT then
        local message = "测试账号模式下测试账号不能为空"
        AppServices.UITextTip:Show(message)
        return
    end

    if RuntimeContext.CACHES.TEST_ACCOUNT == RuntimeContext.DEVICE_ID then
        local message = "当前账号是正式账号，不能再测试模式中使用"
        AppServices.UITextTip:Show(message)
        return
    end

    return true
end

return LoginTestItem