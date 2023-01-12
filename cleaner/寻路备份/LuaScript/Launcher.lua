print("---------------welcome to logic script-------------") --@DEL
package.path = './?.lua'

require "Game.Const.PredefinedGlobals"
require "Utils.TableExtension"
require "System.Core.dictionary"
require "Game.RuntimeContext"

RuntimeContext.CURRENT_DATATIME = 0

require("Game.Const.Channels." ..RuntimeContext.CHANNEL_ID)
App = require "Application"

require("MainCity.Character.AI.Base.BDFacade")
RuntimeContext.DEVICE_ID = require("Utils.UdidUtil"):getUdid()

function Start()
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 170)
    App:Awake()
end

-- C# interface
function gameInit(fixedFPS)
end

function gameRelease()
    if RuntimeContext.UNITY_EDITOR then
        require("System.Debug.LuaPanda.LuaPanda"):disconnect()
    end
    print("#### Application quit") --@DEL
    App:OnGameRelease()
end

-- 应用暂停
function gamePause()
    print("#### Application pause") --@DEL
    App:OnPause()
end

-- 应用进入前台
function gameFocus()
    print("#### Application focus") --@DEL
    App:OnResume()
end

function gameKeyEvent(val)
    print("#### KeyEvent:" ..val) --@DEL
    App:OnKeyEvent(val)
end

function gameDestroy()
    --App:OnGameRelease()
end

function gameUpdate(dt)
    App:Update(dt)
end

function gameLateUpdate(dt)
    App:LateUpdate(dt)
end

function DrawGizmos()
    App:DrawGizmos()
end

function OnGUI()
    App:OnGUI()
end

function I_ShotcutDown(code)
    --sendNotification(CONST.GLOBAL_NOFITY.SYS_SHORTCUT, {param = code})
    code = math.floor(code)
    if code == 108 then
        local name = "Configs.GuideTest"
        include(name)()
    end
end

function ReenterGame(autoLogin)
    App:Quit()
end
