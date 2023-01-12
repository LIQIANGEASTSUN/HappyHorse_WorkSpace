local Character = require 'MainCity.Character.Base.Character'
local SetPositionToPointAction = class(BaseFrameAction, "SetPositionToPointAction")

function SetPositionToPointAction:Create(params, finishCallback)
    local instance = SetPositionToPointAction.new(params, finishCallback)
    return instance
end

function SetPositionToPointAction:ctor(params, finishCallback)
    self.name = "SetPositionToPointAction"
    local point = params["Point"]
    local arrow = params["Angle"]
    local smartwalk = params["SmartWalk"] or false
    local speed = params["Speed"] or 1.0
    local person = params.person
    local walkName = params["WalkName"]

	if point then
		if arrow == nil or arrow == -1 then
			arrow = point.arrow
		end
	end

    self.person = person
    self.smartwalk = smartwalk
    self.arrow = arrow
    self.speed = speed
    self.finishCallback = finishCallback
    self.started = false
    self.walkName = walkName
    self.doNotIdle = params["DontIdle"]
    if params.PathConfig then
        self.pathConfig =  CONST.RULES.LoadPath(params.PathConfig)
    else
        self.destination = Vector3(point.x or 0, point.y or 0, point.z or 0)
    end
end

function SetPositionToPointAction:Awake()
    self.time = Time.time
    if self.smartwalk then
        local function OnDestination()
            if not self.doNotIdle then
                GetPers(self.person):PlayAnimation(Character.defaultIdleName)
            end
            self.isFinished = true
        end
        if self.pathConfig then
            if self.person == 'Owl' or self.person == 'Bat' then
                local pathConfig = CS.BetaGame.CrowPathConfig.Deserialize(table.serialize(self.pathConfig))
                local script = GetPers(self.person).renderObj:GetComponent(typeof(NS.CrowFly))
                console.assert(script, self.person)  --@DEL
                script:StartWithPath(pathConfig, OnDestination)
            else
                local pathConfig = CS.BetaGame.BasicPathConfig.Deserialize(table.serialize(self.pathConfig))
                local script = GetPers(self.person).renderObj:GetComponent(typeof(NS.NpcPathMove))
                script:StartWithPath(pathConfig, OnDestination)
                GetPers(self.person):PlayAnimation(self.walkName, true)
                --AnimatorEx.SetFloat(self.renderObj, 'walk_speed', self.speed)
            end
            --GetPers(self.person):MoveToDirect(self.pathConfig.WayPoints, OnDestination, nil, self.walkName, self.doNotIdle, self.pathConfig.Speed)
        else
            GetPers(self.person):MoveToDirect({self.destination}, OnDestination, nil, self.walkName, self.doNotIdle, self.speed)
        end
    else
        GetPers(self.person):SetPosition(self.destination)
        GameUtil.SetEulerAnglesY(GetPers(self.person).renderObj, self.arrow)
        self.isFinished = true
    end
end

function SetPositionToPointAction:Update()
    if not self.started then
        self.started = true
        self:Awake()
    end
end

function SetPositionToPointAction:Reset()
    self.started = false
    self.isFinished = false
end

return SetPositionToPointAction