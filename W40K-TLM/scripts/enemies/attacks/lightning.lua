local stats_data = require("scripts/utils/enemy_stats")

local enemyTransf = nil
local enemyScript = nil
local playerTransf = nil
local lightningTransf = nil

local lightningTimer = 0.0
local meleeAttackTimer = 0.0
lightningDuration = 0.5
meleeAttackDuration = 2.0


local lightningThrown = false
local isLightningDamaging = false
local hasDealtLightningDamage = false

local lightningColliders = {}
local lightningRbComponent = {}
local lightningRbs = {}

meleeDamage = nil
angle = nil

function on_ready()

    -- Main Boss
    enemyTransf = current_scene:get_entity_by_name("MainBoss"):get_component("TransformComponent")
    enemyScript = current_scene:get_entity_by_name("MainBoss"):get_component("ScriptComponent")

    -- Player
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")

    -- Lightning
    lightningTransf = self:get_component("TransformComponent")

    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "RayCollision1" then
            lightningColliders[1] = child
        elseif child:get_component("TagComponent").tag == "RayCollision2" then
            lightningColliders[2] = child
        elseif child:get_component("TagComponent").tag == "RayCollision3" then
            lightningColliders[3] = child
        elseif child:get_component("TagComponent").tag == "RayCollision4" then
            lightningColliders[4] = child
        elseif child:get_component("TagComponent").tag == "RayCollision5" then
            lightningColliders[5] = child
        elseif child:get_component("TagComponent").tag == "RayCollision6" then
            lightningColliders[6] = child
        elseif child:get_component("TagComponent").tag == "RayCollision7" then
            lightningColliders[7] = child
        elseif child:get_component("TagComponent").tag == "RayCollision8" then
            lightningColliders[8] = child
        elseif child:get_component("TagComponent").tag == "RayCollision9" then
            lightningColliders[9] = child
        elseif child:get_component("TagComponent").tag == "RayCollision10" then
            lightningColliders[10] = child
        end
    end

    for i = 1, 10 do
        lightningRbComponent[i] = lightningColliders[i]:get_component("RigidbodyComponent")
        lightningRbs[i] = lightningRbComponent[i].rb
        lightningRbs[i]:set_trigger(true)
    end



    -- Level
    local enemy_type = "main_boss"
    local level = 1
    stats = stats_data[enemy_type] and stats_data[enemy_type][level]
    -- Debug in case is not working
    if not stats then
        log("No stats for type: " .. enemy_type .. " level: " .. level)
        return
    end

    lightningDuration = stats.lightningDuration



    for i = 1, #lightningRbs do
        lightningRbComponent[i]:on_collision_stay(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if (nameA == "Player" or nameB == "Player") and isLightningDamaging then
                log("Entering Collision")
                if not hasDealtLightningDamage then
                    enemyScript.main_boss:make_damage(meleeDamage)
                    log("Damage dealt")
                    hasDealtLightningDamage = true
                end
            end
        end)
    end
end



function on_update(dt)

    if lightningThrown then
        if not isLightningDamaging then
            meleeAttackTimer = meleeAttackTimer + dt
            if meleeAttackTimer >= meleeAttackDuration then
                --bossConeAtackSFX:play()
                isLightningDamaging = true
                lightningTimer = 0.0
            end
        else
            lightningTimer = lightningTimer + dt
            if lightningTimer >= lightningDuration then
                isLightningDamaging = false
                hasDealtLightningDamage = false
                lightningTransf.position = Vector3.new(-500, 0, -500)
                for i = 1, #lightningRbs do
                    lightningRbs[i]:set_position(Vector3.new(-500, 0, -500))
                end

                lightningThrown = false
            end
        end
    end

end



function lightning()
    if lightningThrown then return end

    local direction = unitary_direction(playerTransf.position.x, enemyTransf.position.x, playerTransf.position.z, enemyTransf.position.z)
    local basePos = Vector3.new(enemyTransf.position.x + (direction.x * -12), enemyTransf.position.y, enemyTransf.position.z + (direction.z * -12))
    local colliderSpacing = 1.1 -- Base distance between colliders

    for i = 1, #lightningRbs do
        local offset = (i - 1) * colliderSpacing
        local pos = Vector3.new(basePos.x + direction.x * offset, basePos.y, basePos.z - 0.5 + direction.z * offset)

        lightningRbs[i]:set_position(pos)
        lightningRbs[i]:set_rotation(Vector3.new(90 + angle, 0, 90))
    end

    lightningTransf.position = basePos
    lightningTransf.rotation = Vector3.new(90 + angle, 0, 90)

    lightningThrown = true
    isLightningDamaging = false
    meleeAttackTimer = 0.0
    lightningTimer = 0.0

end

function unitary_direction(x1, x2, z1, z2)

    local dx = x2 - x1
    local dz = z2 - z1
    local magnitud = math.sqrt(dx * dx + dz * dz)

    angle = math.deg(math.atan(dx, dz))

    if magnitud == 0 then
        return Vector3.new(0, 0, 0)
    else
        return Vector3.new(dx / magnitud, 0, dz / magnitud)
    end

end



function on_exit()

end