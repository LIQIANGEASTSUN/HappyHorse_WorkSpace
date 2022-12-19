---@class BezierCurve
local BezierCurve = class(nil, "BezierCurve", true)

--二阶贝塞尔曲线
function BezierCurve.SecondOrder(p0, p1, p2, t)
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local targetPos = p0 * uu + 2 * t * u * p1 + tt * p2
    return targetPos
end

function BezierCurve.ThirdOrder(p0, p1, p2, p3, t)
    t = math.clamp(t, 0, 1)
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t
    local targetPos = p0 * uuu
    targetPos = targetPos + 3 * uu * t * p1
    targetPos = targetPos + 3 * u * tt * p2
    targetPos = targetPos + ttt * p3
    return targetPos
end

function BezierCurve.BezierTangentThirdOrder(p0, p1, p2, p3, t)
    local u = 1 - t
    local uu = u * u
    local tu = t * u
    local tt = t * t

    local P = p0 * 3 * uu * (-1.0)
    P = P + p1 * 3 * (uu - 2 * tu)
    P = P + p2 * 3 * (2 * tu - tt)
    P = P + p3 * 3 * tt
    return P.normalized
end

function BezierCurve.GetSecondOrderList(p0, p1, p2, num)
    local ret = Vector3List()
    for i = 1, num do
        local p = BezierCurve.SecondOrder(p0, p1, p2, i / num)
        ret:AddItem(p)
    end
    return ret
end

function BezierCurve.GetThirdOrderList(p0, p1, p2, p3, num)
    local ret = Vector3List()
    for i = 1, num do
        local p = BezierCurve.ThirdOrder(p0, p1, p2, p3, i / num)
        ret:AddItem(p)
    end
    return ret
end

return BezierCurve
