local DataBase = require "data.DataBase"
---@class AccountData
local AccountData = class(DataBase, 'AccountData')

local instance
---@return AccountData

function AccountData.Instance()
    if not instance then
        instance = AccountData.new()
        instance:Init()
    end
    return instance
end

--@override value:读取文件路径
function AccountData:GetFilePath()
    return FileUtil.GetPersistentPath() .. "/" .. "uid.dat"
end

--@override value:默认值
function AccountData:GetDefaul()
    return {Map = {}, LastAccount = nil}
end

--通用接口
--GetKeyValue
--SetKeyValue
--GetData
--SetData

--账号库接口
--@interface fuc：有新账号登陆变化时保存账号数据
function AccountData:SetLastAccount(account, uid, type, email, fbFirstBind)
    if uid and type then
        self.data.Map[account] = {Uid = uid, AccountType = type, Email = email, fbFirstBind = fbFirstBind}
    end
    self.data.LastAccount = account
    self.isSave = true
end

--@interface fuc：(未登录)上次登陆的账号/(已登陆)当前玩家账号
function AccountData:GetLastAccount()
    return self.data.LastAccount
end

function AccountData:GetLastLoginAccount()
    if self.data.LastAccount then
        local info = self.data.Map[self.data.LastAccount]
        if info.Uid and info.AccountType then
            return self.data.LastAccount,info.Uid,info.AccountType,info.Email
        end
    end
    return nil,nil,0,nil
end

--@interface fuc：状态如上，账号对应UID
function AccountData:GetLastUid()
    local info = self.data.Map[self.data.LastAccount]
    return info.Uid
end
--@interface fuc：状态如上，账号对应登陆渠道（位运算）：游客，谷歌，苹果
function AccountData:GetLastAccountType()
    if not self.data or not self.data.LastAccount then
        return 0
    end

    local info = self.data.Map[self.data.LastAccount]
    return info.AccountType
end

function AccountData:GetFbFirstBind()
    if not self.data or not self.data.LastAccount then
        return nil
    end

    local info = self.data.Map[self.data.LastAccount]
    if info.fbFirstBind ~= nil then
        return info.fbFirstBind == 1
    end
    return nil
end

function AccountData:ClearAllData()
    self.data = {Map = {}}
    self.isSave = true
end

return AccountData.Instance()
