
local cameraTransform

local shakeOffset = nil

local smoothPos = Vector3.new(0, 0, 0)

--Shake
local shakeAmount = 0
local shakeDuration = 0
local shakeDecay = 3

function on_ready()
    -- Add initialization code here

    cameraFirstTransform = Vector3.new(0.182, 0.776, 18.772)
    cameraTransform = self:get_component("TransformComponent")

    startShake(0.1,300)
end

function on_update(dt)

    if shakeDuration > 0 then
        local shakeOffset = Vector3.new(
            (math.random() * 2 - 1) * shakeAmount,
            (math.random() * 2 - 1) * shakeAmount,
            (math.random() * 2 - 1) * shakeAmount
        )
        local currentPos = cameraFirstTransform
        smoothPos = Vector3.new(currentPos.x + shakeOffset.x, currentPos.y + shakeOffset.y, currentPos.z + shakeOffset.z) 

        shakeDuration = shakeDuration - dt
        cameraTransform.position = smoothPos

        
    end
end


function startShake(amount, duration)
    shakeAmount = amount
    shakeDuration = duration
end

function cameraBoss(self, bool)

    if bool == true then
        zoom = bossZoom
    else
        zoom = baseZoom
    end

    cameraBossActivated = bool
end

function cameraColisseum(self, activate)

    if activate == true then
        zoom = coliseumZoom
    else
        zoom = baseZoom
    end

    
    cameraBossActivated = activate

end

function IsPointInPolygon(x, z, polygon)
    local inside = false
    local j = #polygon
    for i = 1, #polygon do
        local xi, zi = polygon[i].x, polygon[i].z
        local xj, zj = polygon[j].x, polygon[j].z

        local intersect = ((zi > z) ~= (zj > z)) and
                          (x < (xj - xi) * (z - zi) / ((zj - zi) + 0.0001) + xi)
        if intersect then
            inside = not inside
        end
        j = i
    end
    return inside
end

function GetClosestPointInPolygon(x, z, polygon)
    local closest = {x = polygon[1].x, z = polygon[1].z}
    local minDistSq = math.huge

    for i = 1, #polygon do
        local a = polygon[i]
        local b = polygon[(i % #polygon) + 1]

        local proj = ProjectPointOnSegment(x, z, a.x, a.z, b.x, b.z)
        local dx = x - proj.x
        local dz = z - proj.z
        local distSq = dx * dx + dz * dz

        if distSq < minDistSq then
            minDistSq = distSq
            closest = proj
        end
    end

    return closest
end

function ProjectPointOnSegment(px, pz, ax, az, bx, bz)
    local abx = bx - ax
    local abz = bz - az
    local apx = px - ax
    local apz = pz - az
    local abLenSq = abx * abx + abz * abz
    if abLenSq == 0 then
        return {x = ax, z = az}
    end
    local t = (apx * abx + apz * abz) / abLenSq
    t = math.max(0, math.min(1, t))
    return {x = ax + t * abx, z = az + t * abz}
end



function on_exit()
    -- Add cleanup code here
end
