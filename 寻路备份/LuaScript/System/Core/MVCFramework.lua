local package_name = 'System.Core.PureMVC.lua.multicore'
require(package_name .. '.help.oop')

should = {}
should.equal = function(msg, act, exp)
	if act == exp then
		print('OK :' .. msg)
	else
		print('Error:' .. msg .. ', the act is ' .. tostring(act))
	end
end

should.equalNil = function(msg, act)
	if act == nil then
		print('OK :' .. msg)
	else
		print('Error:' .. msg .. ', the act is ' .. tostring(act))
	end
end

should.equalNotNil = function(msg, act)
	if act ~= nil then
		print('OK :' .. msg)
	else
		print('Error:' .. msg .. ', the act is nil')
	end
end

pureMVC = pureMVC or {}
pureMVC.VERSION = '1.0.1'
pureMVC.FRAMEWORK_NAME = 'pureMVC lua'
pureMVC.PACKAGE_NAME = package_name
pureMVC.Facade = importMVC(pureMVC.PACKAGE_NAME .. '.patterns.facade.Facade')
pureMVC.Mediator = importMVC(pureMVC.PACKAGE_NAME .. '.patterns.mediator.Mediator')
pureMVC.Proxy = importMVC(pureMVC.PACKAGE_NAME .. '.patterns.proxy.Proxy')
pureMVC.SimpleCommand = importMVC(pureMVC.PACKAGE_NAME .. '.patterns.command.SimpleCommand')
pureMVC.MacroCommand = importMVC(pureMVC.PACKAGE_NAME .. '.patterns.command.MacroCommand')
pureMVC.Notifier = importMVC(pureMVC.PACKAGE_NAME .. '.patterns.observer.Notifier')
pureMVC.Notification = importMVC(pureMVC.PACKAGE_NAME .. '.patterns.observer.Notification')

require "UI.Base.BaseMediator"

--[[
  *Facade存储多个facade实例
]]

facade = pureMVC.Facade.getInstance("MAIN")
--[[
*notificationName  消息名字
*body 消息数据
*type 消息类型
tip:默认使用facade("MAIN"),若将来真要使用别的facade,此方法也可继续使用
]]
function sendNotification(notificationName, body, type)
	facade:sendNotification(notificationName or "unknow", body, type)
end

-- body 必须是k,v 形式table
--local dictEmpty = ObjectDictionary()
function sendNotification2cs(notificationName, body)
--[[
	local p = nil
	if not body then
		p = dictEmpty
	else
		p = ObjectDictionary()
		for k,v in pairs(body) do
			p:SetValue(k,v)
		end
	end
		EventManager.Instance:Dispatch(CupidEvent(notificationName,p))
--]]
end

--"ui.starNotice.mediator.NoticeMainPanelMediator"
function registerMediator(path,view)
	local NoticeMainPanelMediator = require(path)
	facade:registerMediator(NoticeMainPanelMediator.new(path,view))
	print("registerMediator: name: "..path)
end

function removeMediator(name)
	facade:removeMediator(name)
end

