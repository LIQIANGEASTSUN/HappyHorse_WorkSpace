

local FunctionType = {
    Death   = 1,
	Follow  = 2,
	Attack  = 3,
	Pursuit = 4,
	Idle    = 5,
}

--- 宠物/与玩家距离
local DistancePlayer = 0

--- 宠物/到达跟随点
local ArriveFollowPos = false

--- 宠物/有攻击目标
local HasTarget = false

--- 宠物/技能有效
local ValidSkill = false

--- 宠物/目标在攻击范围内
local TargetInAttackDistance = false

--- 宠物/血量
local PetHp = 0

--- 宠物/路径有效
local ValidPath = = false


function DoFunction()

    -- Death -------------------------
    if PetHp <= 0 then
	    reutrn FunctionType.Death
    end
	----------------------------------

	-- Follow ------------------------
	if DistancePlayer > 3 then
	    return FunctionType.Follow
	end
    ----------------------------------

	if HasTarget then
	    if TargetInAttackDistance then
		    return FunctionType.Attack
		else
		    return FunctionType.Pursuit
		end
	else
		if ArriveFollowPos then
			return FunctionType.Idle
		end
		    return FunctionType.Follow
		end
	end
	----------------------------------

end












