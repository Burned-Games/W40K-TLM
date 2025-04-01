local bombRbComponent = nil
local bombRb = nil
local bombDamage = 10

local player = nil
local playerTransf = nil
local playerScript = nil

local explosionRadius = 7.0
local explosionForce = 13.0
local explosionUpward = 2.0

function on_ready()
    
    bombRbComponent = self:get_component("RigidbodyComponent")
    bombRb = bombRbComponent.rb
    bombRb:set_trigger(true)

    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    bombRbComponent:on_collision_enter(function(entityA, entityB)         -- Funcion para comprobar colisiones, ahora esta el enemyRb, pero cambiadlo por el que necesiteis
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Sphere1" or nameB == "Sphere1" then
            explosion()
        elseif nameA == "EnemyBullet" or nameB == "EnemyBullet" then
            explosion()
        end
    end)

end

function on_update(dt)
    -- Add update code here
end

function explosion()

    -- Logica de la explosion
    local explosionPos = bombRb:get_position()
    local entities = current_scene:get_all_entities()

        for _, entity in ipairs(entities) do 
            if entity ~= self and entity:has_component("RigidbodyComponent") then 
                local entityRb = entity:get_component("RigidbodyComponent").rb
                local entityPos = entityRb:get_position()

                local direction = Vector3.new(
                    entityPos.x - explosionPos.x,
                    entityPos.y - explosionPos.y,
                    entityPos.z - explosionPos.z
                )

                local distance = math.sqrt(
                    direction.x * direction.x +
                    direction.y * direction.y +
                    direction.z * direction.z
                )

                if distance > 0 then
                    direction.x = direction.x / distance
                    direction.y = direction.y / distance
                    direction.z = direction.z / distance
                end

                if distance < explosionRadius then
                    local forceFactor = (explosionRadius - distance) / explosionRadius
                    direction.y = direction.y + explosionUpward
                    local finalForce = Vector3.new(
                        direction.x * explosionForce * forceFactor,
                        direction.y * explosionForce * forceFactor,
                        direction.z * explosionForce * forceFactor
                    )
                    entityRb:apply_impulse(finalForce)
                end
            end
        end

    check_player_distance(explosionPos)
    die()

end

function check_player_distance(explosionPos)

    if player == nil or playerTransf == nil then
        return
    end

    local playerPos = playerTransf.position
    local dx = playerPos.x - explosionPos.x
    local dy = playerPos.y - explosionPos.y
    local dz = playerPos.z - explosionPos.z
    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

    if distance <= 5 then
        make_damage()
    end

end

function make_damage()

    if player ~= nil then
        if playerScript ~= nil then

            playerScript.playerHealth = playerScript.playerHealth - bombDamage
            --print("PlayerHealth: " .. playerScript.playerHealth)

            return
        end
    end

end

function die()                                      -- !! IMPORTANTE !! Se tendra que cambiar para destruir el enemigo al morir, ahora solo se mueve lejos y se le pone en Idle :)
    bombRb:set_position(Vector3.new(-200, 0, 0))
end

function on_exit()
    -- Add cleanup code here
end