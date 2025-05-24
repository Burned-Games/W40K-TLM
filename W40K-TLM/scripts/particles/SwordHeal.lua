local swordHealTransf = nil
playerTransf = nil

local swordHealTimer = 0

local moveSpeed = 2
local acceleration = 4
local swordHealDelay = 1.0
local swordHealLifetime = 2.0

function on_ready()
    swordHealTransf = self:get_component("TransformComponent")
end

function on_update(dt)
    swordHealTimer = swordHealTimer + dt

    if swordHealTimer >= swordHealDelay then
        moveSpeed = moveSpeed + acceleration * dt

        local currentPos = swordHealTransf.position
        local targetPos = Vector3.new(playerTransf.position.x, playerTransf.position.y + 1, playerTransf.position.z)

        local lerpFactor = math.min(moveSpeed * dt, 1)
        swordHealTransf.position = Vector3.lerp(currentPos, targetPos, lerpFactor)
    end

    if swordHealTimer >= swordHealLifetime then
        current_scene:destroy_entity(self)
    end
end

function on_exit() end
