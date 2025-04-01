local state = { Idle = 1, Move = 2, Chase = 3, Attack = 4, Tackle = 5 }
local currentState = state.Idle

local player
local playerTransf
local playerScript
local playerDetected = false
local playerDistance = nil

local tackleDistance = 10
local IsCharging = false
local chargeTime = 0
local meleeDistance = 3

local tankTransform = nil
local tankRigidbody = nil
local tankNavmesh = nil

local defaultVelocity = 2
local tackleVelocity = 13
local tankVelocity = defaultVelocity

local isDead = false
local tankDamage = 10  -- Daño de ataque melee
local AttackCooldown = 3
local tankHealth = 75
local tackleCooldown = 8  -- Unificamos este valor
local tackleTimer = 0       
local canTackle = true      

local currentAnim = 0
local animator
local attackTimer = 0

local pathUpdateTimer = 0                                        
local pathUpdateInterval = 1.0
local lastTargetPos = nil

haveShield = false
shieldHealth = 0
local tackleHasDamaged = false

zoneNumber = 0
local zone_set = false

function on_ready()
    tankTransform = self:get_component("TransformComponent")
    tankRigidbody = self:get_component("RigidbodyComponent").rb
    tankScript = self:get_component("ScriptComponent")
    tankNavmesh = self:get_component("NavigationAgentComponent")

    animator = self:get_component("AnimatorComponent")

    player = current_scene:get_entity_by_name("Player")
    if player then
        playerTransf = player:get_component("TransformComponent")
        playerScript = player:get_component("ScriptComponent")
        playerDistance = get_distance(tankTransform.position, playerTransf.position)
    end
end

function on_update(dt)

    if zone_set ~= true then
        check_zone()
        zone_set = true
    end

    -- Update timer for path updates
    pathUpdateTimer = pathUpdateTimer + dt
    
    -- Update tackle cooldown timer
    if not canTackle then
        tackleTimer = tackleTimer + dt
        if tackleTimer >= tackleCooldown then  -- Usamos la variable tackleCooldown
            canTackle = true
            tackleTimer = 0
        end
    end

    if haveShield and shieldHealth <= 0 then
        haveShield = false
        shield_destroyed = true
    end

    -- Check player existence
    if player and playerTransf then
        change_state() -- Function to change states based on raycast
    else
        -- Try to find player in case it was not found before
        player = current_scene:get_entity_by_name("Player")
        if player then
            playerTransf = player:get_component("TransformComponent")
            playerScript = player:get_component("ScriptComponent")
        else
            currentState = state.Idle
        end
    end

    -- Handle death condition
    if tankHealth <= 0 then
        die()
        return
    end

    -- Update path if needed
    local currentTargetPos = playerTransf and playerTransf.position or nil
    if currentTargetPos and (pathUpdateTimer >= pathUpdateInterval or 
        (lastTargetPos and get_distance(lastTargetPos, currentTargetPos) > 1.0)) then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end

    if playerDetected then
        rotate_tank(playerTransf.position)
    end

    -- FSM { Idle -> Move -> Chase -> Attack -> Tackle}
    if currentState == state.Idle then
        idle_state(dt)
    elseif currentState == state.Move or currentState == state.Chase then
        chase_state(dt)
    elseif currentState == state.Attack then
        attack_state(dt)
    elseif currentState == state.Tackle then
        tackle_state(dt)
    end
end

function update_path()
    if tankNavmesh == nil or player == nil or playerTransf == nil then 
        return 
    end

    tankNavmesh.path = tankNavmesh:find_path(tankTransform.position, playerTransf.position)
    currentPathIndex = 1
end

function follow_path(dt)
    if tankNavmesh == nil or #tankNavmesh.path == 0 then 
        tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
        return 
    end
    
    -- Verificar que el índice es válido
    if currentPathIndex > #tankNavmesh.path then
        currentPathIndex = 1
        if #tankNavmesh.path == 0 then
            tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
            return
        end
    end

    local nextPoint = tankNavmesh.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - tankTransform.position.x,
        0,
        nextPoint.z - tankTransform.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            0,
            direction.z / distance
        )

        local velocity = Vector3.new(
            normalizedDirection.x * tankVelocity, 
            0, 
            normalizedDirection.z * tankVelocity
        )
        
        tankRigidbody:set_velocity(velocity)

        rotate_tank(nextPoint)
    else
        if currentPathIndex < #tankNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        else
            -- Llegamos al final del camino
            tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
        end
    end
end

function change_state()
    if not playerDetected then
        detect_area()
    else
        single_raycast()
    end

    if playerDetected then
        playerDistance = get_distance(tankTransform.position, playerTransf.position)
    end

    if player and playerTransf then 
        if playerDetected and playerDistance <= meleeDistance then
            -- Close enough to attack
            if currentState ~= state.Attack then
                currentState = state.Attack
                attackTimer = 0 -- Reset attack timer
            end
        elseif playerDistance <= tackleDistance and canTackle then
            -- Within tackle range but not attack range AND tackle is not on cooldown
            if currentState ~= state.Tackle and currentState ~= state.Attack then
                currentState = state.Tackle
                IsCharging = true
            end
        elseif playerDetected then
            -- Player detected but not close enough for attack or tackle
            if currentState ~= state.Chase and currentState ~= state.Attack and currentState ~= state.Tackle then
                currentState = state.Chase
            end
        else
            -- Out of range, go idle
            if currentState ~= state.Idle then
                currentState = state.Idle
            end
        end
    else
        -- No player detected, go idle
        if currentState ~= state.Idle then
            currentState = state.Idle
        end
    end
end

function detect_player(rayHit)
    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity == player
end

function detect_area()
    local direction = Vector3.new(
        math.sin(math.rad(tankTransform.rotation.y)), 
        0, 
        math.cos(math.rad(tankTransform.rotation.y))
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

    local origin = tankTransform.position  
    local maxDistance = 20.0

    -- Dibujar los rayos para depuración
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
    if not playerTransf then return end

    local direction = Vector3.new(
        playerTransf.position.x - tankTransform.position.x, 
        playerTransf.position.y - tankTransform.position.y,
        playerTransf.position.z - tankTransform.position.z
    )

    -- Normalizar dirección
    local distance = math.sqrt(direction.x^2 + direction.y^2 + direction.z^2)
    if distance > 0 then
        direction.x = direction.x / distance
        direction.y = direction.y / distance
        direction.z = direction.z / distance
    end

    local origin = tankTransform.position 
    local maxDistance = 20.0

    Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))

    local rayHit = Physics.Raycast(origin, direction, maxDistance)

    if detect_player(rayHit) then
        playerDetected = true
        playerDistance = get_distance(origin, rayHit.hitPoint)
    else
        -- Si el raycast no detecta al jugador, actualizar distancia directamente
        playerDistance = get_distance(tankTransform.position, playerTransf.position)
    end
end

-- Idle state - tank is static and looking for player
local idleTimer = 0
local idleDuration = 1.0

function idle_state(dt) 
    idleTimer = idleTimer + dt

    -- Animation
    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
    end

    -- Stop movement
    tankRigidbody:set_velocity(Vector3.new(0, 0, 0))

    -- Periodic scan for player
    if idleTimer >= idleDuration then
        idleTimer = 0
        
        -- Try to find player if not already found
        if not player then
            player = current_scene:get_entity_by_name("Player")
            if player then
                playerTransf = player:get_component("TransformComponent")
                playerScript = player:get_component("ScriptComponent")
            end
        end
    end
end

function chase_state(dt)
    -- Animation for chase
    if currentAnim ~= 2 then
        animator:set_current_animation(2)
        currentAnim = 2
    end
    
    -- Asegurar que la velocidad es la normal durante chase
    tankVelocity = defaultVelocity
    
    follow_path(dt)
end

function tackle_state(dt)
    -- Animation for tackle
    if currentAnim ~= 3 then
        animator:set_current_animation(3)
        currentAnim = 3
    end

    if IsCharging == true then
        local directPath = {}
        local startPos = tankTransform.position
        local targetPos = playerTransf.position
        
        table.insert(directPath, startPos)
        table.insert(directPath, targetPos)
        
        tankNavmesh.path = directPath
        currentPathIndex = 1
        
        chargeTime = 0
        IsCharging = false
        tackleHasDamaged = false
        tankVelocity = tackleVelocity  -- Usar tackleVelocity en lugar de hardcodear 13
    end

    chargeTime = chargeTime + dt
    if chargeTime < 1.5 then
        follow_path(dt)
        
        if player and playerTransf and playerScript and not tackleHasDamaged then
            local playerDistance = get_distance(tankTransform.position, playerTransf.position)
            
            if playerDistance <= meleeDistance then  -- Cambio a meleeDistance para mejor detección
                local damage = 50
                playerScript.playerHealth = playerScript.playerHealth - damage
                tackleHasDamaged = true
            end
        end
    else
        -- Finalizar tackle
        tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
        
        -- Restablecer variables
        canTackle = false  -- Activar cooldown
        tackleTimer = 0
        tankVelocity = defaultVelocity
        
        -- Cambiar estado a Chase después del tackle
        currentState = state.Chase
    end
end

-- Attack state - tank performs a slow melee attack
function attack_state(dt)
    -- Animation for attack
    if currentAnim ~= 4 then
        animator:set_current_animation(4)
        currentAnim = 4
    end

    tankRigidbody:set_velocity(Vector3.new(0, 0, 0))

    if player and playerTransf then
        rotate_tank(playerTransf.position)
    end
    
    attackTimer = attackTimer + dt
    
    if attackTimer >= AttackCooldown then
        if player and playerTransf and playerScript then
            local attackDistance = get_distance(tankTransform.position, playerTransf.position)
            
            if attackDistance <= meleeDistance then
                local damage = tankDamage  -- Usar tankDamage en lugar de hardcodear 10
                playerScript.playerHealth = playerScript.playerHealth - damage
            end
        end

        attackTimer = 0
        currentState = state.Chase
    end
end

-- Helper function to rotate the tank to face a target position
local currentRotationY = 0

function rotate_tank(targetPosition)
    local dx = targetPosition.x - tankTransform.position.x
    local dz = targetPosition.z - tankTransform.position.z

    local targetAngle = math.deg(math.atan(dx / dz))
    if dz < 0 then
        targetAngle = targetAngle + 180
    end

    targetAngle = (targetAngle + 180) % 360 - 180
    local currentAngle = (currentRotationY + 180) % 360 - 180
    local deltaAngle = (targetAngle - currentAngle + 180) % 360 - 180

    currentRotationY = currentAngle + deltaAngle * 0.1
    tankTransform.rotation.y = currentRotationY
end

-- Helper function to calculate distance between two positions
function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Function to handle death
function die()
    currentState = state.Idle
    tankRigidbody:set_position(Vector3.new(-500, 0, 0))
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
        tankRigidbody:set_position(Vector3.new(-500, 0, 0))
        self:set_active(false)
    end
end

function on_exit() 
    -- Clean up code here
end