---@class PlayerJoystickManager
local PlayerJoystickManager = {
    rockGo = nil,
    isCreating = false,

    sceneRockGo = nil,

    useScene = false,
}

function PlayerJoystickManager:GetJoyStick(callBack)
    if self.useScene then
        self:GetSceneJoystick(callBack)
    else
        self:GetLoadJoystick(callBack)
    end
end

function PlayerJoystickManager:GetSceneJoystick(callBack)
    if not self.joyStick then
        self.rockGo = GameObject.Find("VirtualJoystickCanvas")
        self.joyStick = find_component(self.rockGo, "InputPanel", CS.VirtualJoystick.VirtualJoystick)

        if Runtime.CSValid(self.rockGo) then
            self:SetActiveRock(self.show)
        end
    end

    if callBack then
        callBack(self.joyStick)
    end
end

function PlayerJoystickManager:GetLoadJoystick(callBack)
    -- 场景中如果有摇杆，隐藏掉
    if not self.sceneRockGo then
        self.sceneRockGo = GameObject.Find("VirtualJoystickCanvas")
        if Runtime.CSValid(self.sceneRockGo) then
            self.sceneRockGo:SetActive(false)
        end
    end

    if self.isCreating then
        return
    end

    local function onLoaded()
        self.rockGo = BResource.InstantiateFromAssetName(CONST.ASSETS.G_UI_VIRTUAL_JOYSTICK)
        local canvas = self.rockGo:GetComponent(typeof(Canvas))
        canvas.worldCamera = App.scene:GetSceneCamer()

        self.joyStick = find_component(self.rockGo, "InputPanel", CS.VirtualJoystick.VirtualJoystick)
        self.isCreating = false

        if Runtime.CSValid(self.rockGo) then
            self:SetActiveRock(self.show)
        end
        if callBack then
            callBack(self.joyStick)
        end
    end

    self.isCreating = true
    App.buildingAssetsManager:LoadAssets({CONST.ASSETS.G_UI_VIRTUAL_JOYSTICK}, onLoaded)
end

-- 显示隐藏摇杆
function PlayerJoystickManager:SetActiveRock(value)
    self.show = value

    if not Runtime.CSValid(self.rockGo) then
        self:GetJoyStick()
    else
        self.rockGo:SetActive(value)
    end
end

return PlayerJoystickManager