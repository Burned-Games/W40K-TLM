enemyHealth = 10
local enemyDamage = 10
local moveSpeed = 6
local enemyTransf = nil
local enemyNavmesh = nil
local enemyRbComponent = nil
local enemyRb = nil
local hasExploded = false
local isDead = false

local detectDistance = 25
local bombDistance = 2

local animator = nil
local currentAnim = 0

local bomb = nil
local bombRb = nil

local player = nil
local playerTransf = nil
local playerScript = nil
local playerDetected = false
local playerDistance = nil

local state = { Idle = 1, Move = 2, Attack = 3}
local currentState = state.Idle

local pathUpdateTimer = 0                                               -- Los timers se tendran que cambiar con los que hay en el LuaBackend
local pathUpdateInterval = 1.0
local lastTargetPos = nil

local invulnerability = 0.1                                             -- La invulnerabilidad es para la funcion de make_damage, para que no este aplicando el damage constantemente
local timeSinceLastHit = 0                                              -- Este timer tambien hay que quitarlo en un futuro

local currentPathIndex = 1

local explosionRadius = 6.0
local explosionForce = 13.0
local explosionUpward = 2.0

local attackTimer = 0
local attackDelay = 0.75

haveShield = false
shieldHealth = 0

local isExploding = false

zoneNumber = 0
local zone_set = false

function on_ready() 
    enemyTransf = self:get_component("TransformComponent")
    enemyNavmesh = self:get_component("NavigationAgentComponent")
    enemyRbComponent = self:get_component("RigidbodyComponent")
    enemyRb = enemyRbComponent.rb

    animator = self:get_component("AnimatorComponent")

    bomb = current_scene:get_entity_by_name("Bomb")
    bombRb = bomb:get_component("RigidbodyComponent").rb

    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")
    
    enemyRbComponent:on_collision_enter(function(entityA, entityB)         -- Funcion para comprobar colisiones, ahora esta el enemyRb, pero cambiadlo por el que necesiteis
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            if currentState ~= state.Attack then
                print("Player en contacto con el Kamikaze! Cambiando a Attack.")
                currentState = state.Attack
            end
        end
    end)

    if player ~= nil then
        playerDistance = get_distance(enemyTransf.position, playerTransf.position)
        lastTargetPos = playerTransf.position
        update_path()
    end

end

-- FSM Kamikaze
function on_update(dt)
    if player == nil or isDead == true then                             -- Comprueba si el player existe o si el enemigo esta muerto para evitar entrar en el update 
        return                                                          -- (poned las variables, ahora no tienen referencia)
    end
    if zone_set ~= true then
        check_zone()
        zone_set = true
    end

    if isExploding then
        attackTimer = attackTimer + dt
        attack_state(dt)
        return
    end



    if not hasExploded and enemyHealth <= 0 then
        drop_bomb()
        die()
    elseif hasExploded and enemyHealth <= 0 then
        die()
    end

    player_distance()                                                  

    if haveShield and shieldHealth <= 0 then
        haveShield = false
        shield_destroyed=true
    end

    -- Actualiza el path hacia el player con el navmesh
    pathUpdateTimer = pathUpdateTimer + dt
    local currentTargetPos = playerTransf.position

    if pathUpdateTimer >= pathUpdateInterval or get_distance(lastTargetPos, currentTargetPos) > 1.0 then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end

    -- Para que mire al player
    if playerDetected then
        rotate_enemy(playerTransf.position)
    end

    -- FSM { Idle -> Move -> Attack}
    if currentState == state.Idle then
        idle_state(dt)

    elseif currentState == state.Move then
        move_state(dt)
    
    elseif currentState == state.Attack then
        attack_state(dt)
    end

end



-- Deteccion del Player con raycast y cambio de estados.
function player_distance()

    if playerDetected == false then
        detect_area()
    else
        single_raycast()
    end

    if not playerDetected and playerDistance <= detectDistance then
        print("Player detectado! Pasando de Idle a Move.")
        currentState = state.Move
        playerDetected = true
    end

    if playerDetected and playerDistance <= bombDistance then
        isExploding = true
        currentState = state.Attack

    end

end

function detect_player(rayHit)

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity == player

end

function detect_area()

    local direction = Vector3.new(
        math.sin(math.rad(enemyTransf.rotation.y)), 
        0, 
        math.cos(math.rad(enemyTransf.rotation.y))
    )

    -- Normalizar dirección para evitar distancias erróneas
    local distance = math.sqrt(direction.x^2 + direction.z^2)
    if distance > 0 then
        direction.x = direction.x / distance
        direction.z = direction.z / distance
    end

    -- Ángulo de separación en radianes (~30 grados)
    local angleOffset = math.rad(15)  
    local intermediateAngleOffset = math.rad(7.5)

    -- Rotar la dirección hacia la izquierda y derecha
    local leftDirection = Vector3.new(
        direction.x * math.cos(angleOffset) - direction.z * math.sin(angleOffset),
        0,
        direction.x * math.sin(angleOffset) + direction.z * math.cos(angleOffset)
    )

    local rightDirection = Vector3.new(
        direction.x * math.cos(-angleOffset) - direction.z * math.sin(-angleOffset),
        0,
        direction.x * math.sin(-angleOffset) + direction.z * math.cos(-angleOffset)
    )

    local intermediateLeftDirection = Vector3.new(
        direction.x * math.cos(intermediateAngleOffset) - direction.z * math.sin(intermediateAngleOffset),
        0,
        direction.x * math.sin(intermediateAngleOffset) + direction.z * math.cos(intermediateAngleOffset)
    )

    local intermediateRightDirection = Vector3.new(
        direction.x * math.cos(-intermediateAngleOffset) - direction.z * math.sin(-intermediateAngleOffset),
        0,
        direction.x * math.sin(-intermediateAngleOffset) + direction.z * math.cos(-intermediateAngleOffset)
    )

    local origin = enemyTransf.position
    local maxDistance = 20.0

    -- Dibujar los tres rayos para depuración
    Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
    Physics.DebugDrawRaycast(origin, intermediateLeftDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1)) 
    Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    Physics.DebugDrawRaycast(origin, intermediateRightDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1))
    Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))

    -- Lanzar los rayos
    local centerHit = Physics.Raycast(origin, direction, maxDistance)
    local intermediateLeftHit = Physics.Raycast(origin, intermediateLeftDirection, maxDistance)
    local leftHit = Physics.Raycast(origin, leftDirection, maxDistance)
    local intermediateRightHit = Physics.Raycast(origin, intermediateRightDirection, maxDistance)
    local rightHit = Physics.Raycast(origin, rightDirection, maxDistance)

    if detect_player(centerHit) then

        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, centerHit.hitPoint)

    elseif detect_player(intermediateLeftHit) then
        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, intermediateLeftHit.hitPoint)

    elseif detect_player(leftHit) then

        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, leftHit.hitPoint)

    elseif detect_player(intermediateRightHit) then
        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, intermediateRightHit.hitPoint)

    elseif detect_player(rightHit) then

        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, rightHit.hitPoint)
        
    end
end

function single_raycast()
    
    local direction = Vector3.new(
        playerTransf.position.x - enemyTransf.position.x,
        playerTransf.position.y - enemyTransf.position.y,
        playerTransf.position.z - enemyTransf.position.z
    )

    local origin = enemyTransf.position
    local maxDistance = 20.0

    Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))

    local rayHit = Physics.Raycast(origin, direction, maxDistance)

    if detect_player(rayHit) then
        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, rayHit.hitPoint)
    end

end

-- Funciones para los distintos estados.
function idle_state(dt)

    if currentAnim ~= 3 then
        currentAnim = 3
        animator:set_current_animation(currentAnim)
    end

end

function move_state(dt)

    if currentAnim ~= 5 then
        currentAnim = 5
        animator:set_current_animation(currentAnim)
    end

	-- Movimiento
    follow_path(dt)

end

function attack_state(dt)

    enemyRb:set_velocity(Vector3.new(0, 0, 0))

    if currentAnim ~= 7 then
        currentAnim = 7
        animator:set_current_animation(currentAnim)
    end

    if attackTimer >= attackDelay then
        -- Logica de la explosion
        local explosionPos = enemyRb:get_position()
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

                        make_damage()
                    end
                end
            end

        die()

        health = 0
        hasExploded = true
    end

end

function drop_bomb()

    if bomb == nil then
        return
    end

    bombRb:set_position(Vector3.new(enemyTransf.position.x, 0.4, enemyTransf.position.z))

end



-- Funciones para calcular cosas.    :)
function make_damage()

    if player ~= nil then
        if playerScript ~= nil then

            playerScript.playerHealth = playerScript.playerHealth - enemyDamage
            print("PlayerHealth: " .. playerScript.playerHealth)

            return
        end
    end

end

function update_path()

    if player == nil or enemyNavmesh == nil then 
        return 
    end

    enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, playerTransf.position)
    currentPathIndex = 1

end

function follow_path(dt)

    if enemyNavmesh == nil or #enemyNavmesh.path == 0 then 
        return 
    end

    local nextPoint = enemyNavmesh.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - enemyTransf.position.x,
        nextPoint.y - enemyTransf.position.y,
        nextPoint.z - enemyTransf.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.y^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            direction.y / distance,
            direction.z / distance
        )

        local velocity = Vector3.new(normalizedDirection.x * moveSpeed, 0, normalizedDirection.z * moveSpeed)
        enemyRb:set_velocity(velocity)

        rotate_enemy(nextPoint)
    else
        if currentPathIndex < #enemyNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        else
            currentState = state.Attack
        end
    end

end

local currentRotationY = 0

function rotate_enemy(targetPosition)

	local dx = targetPosition.x - enemyTransf.position.x
	local dz = targetPosition.z - enemyTransf.position.z

    local targetAngle = math.deg(math.atan(dx / dz))
    if dz < 0 then
        targetAngle = targetAngle + 180
    end

    targetAngle = (targetAngle + 180) % 360 - 180
    local currentAngle = (currentRotationY + 180) % 360 - 180
    local deltaAngle = (targetAngle - currentAngle + 180) % 360 - 180

    currentRotationY = currentAngle + deltaAngle * 0.1
    enemyTransf.rotation.y = currentRotationY

end

function get_distance(pos1, pos2)

    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)

end

function die()                                      -- !! IMPORTANTE !! Se tendra que cambiar para destruir el enemigo al morir, ahora solo se mueve lejos y se le pone en Idle :)

    currentState = state.Idle
    enemyRb:set_position(Vector3.new(-500, 0, 0))
    isDead = true

end

function check_zone()
    if zoneNumber == 0 then
        local zone1 = current_scene:get_entity_by_name("Zone1")
        local zone2 = current_scene:get_entity_by_name("Zone2")
        local zone3 = current_scene:get_entity_by_name("Zone3")
        local zone1RbComponent = zone1:get_component("RigidbodyComponent")
        local zone2RbComponent = zone2:get_component("RigidbodyComponent")
        local zone3RbComponent = zone3:get_component("RigidbodyComponent")

        local zone1Rb = zone1RbComponent.rb
        local zone2Rb = zone2RbComponent.rb
        local zone3Rb = zone3RbComponent.rb
        zone1Rb:set_trigger(true)
        zone2Rb:set_trigger(true)
        zone3Rb:set_trigger(true)

        zone1RbComponent:on_collision_enter(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Zone1" or nameB == "Zone1" then
                zoneNumber = 1
            end
        end)
        zone2RbComponent:on_collision_enter(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Zone2" or nameB == "Zone2" then
                zoneNumber = 2
            end
        end)
        zone3RbComponent:on_collision_enter(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Zone3" or nameB == "Zone3" then
                zoneNumber = 3
            end
        end)
    end

    if zoneNumber < playerScript.zonePlayer then
        enemyRb:set_position(Vector3.new(-500, 0, 0))
        self:set_active(false)
    end
end

function on_exit() end