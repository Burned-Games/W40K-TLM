local state = { Idle = 1, Chase = 2, Attack = 3, Tackle = 4 } 
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
enemyHealth = 275
local tackleCooldown = 8  -- Unificamos este valor
local tackleTimer = 0       
local canTackle = true      

local currentAnim = 0
local animator
local attackTimer = 0

local pathUpdateTimer = 0                                        
local pathUpdateInterval = 1.0
local lastTargetPos = nil
local currentPathIndex = 1

haveShield = false
shieldHealth = 0
local tackleHasDamaged = false

zoneNumber = 0
local zone_set = false

priority = 2
local targetPosition = nil 

local collisionWithPlayer = false

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

    local rbComponent = self:get_component("RigidbodyComponent")
    rbComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if (nameA == "Player" or nameB == "Player") then
            collisionWithPlayer = true
            if currentState == state.Tackle or currentState == state.Chase then
                tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
                IsCharging = false
                canTackle = false
                tackleTimer = 0
                currentState = state.Attack
            end
        else
            if currentState == state.Tackle then
                tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
                IsCharging = false
                canTackle = false
                tackleTimer = 0
                currentState = state.Chase
            end
        end
    end)
    local rbComponent = self:get_component("RigidbodyComponent")
    rbComponent:on_collision_exit(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
    
        if (nameA == "Player" or nameB == "Player") then
            collisionWithPlayer = false
        end
    end)
end

function on_update(dt)
    -- if zone_set ~= true then
    --     check_zone()
    --     zone_set = true
    -- end

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
    end

    -- Handle death condition
    if enemyHealth <= 0 then
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

    -- FSM { Idle -> Chase -> Attack -> Tackle}
    if currentState == state.Idle then
        idle_state(dt)
    elseif currentState == state.Chase then 
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

    -- Asegurarnos de que playerDistance esté inicializado
    if playerDetected and playerTransf then
        playerDistance = get_distance(tankTransform.position, playerTransf.position)
    else
        playerDistance = math.huge -- Usamos un valor muy grande para evitar comparaciones inválidas
    end

    if player and playerTransf then
        if collisionWithPlayer then
            if currentState == state.Tackle or currentState == state.Chase then
                currentState = state.Attack -- Cambiar a estado Attack si está en Tackle o Chase
            elseif currentState == state.Attack and playerDistance > meleeDistance then
                currentState = state.Chase -- Cambiar a Chase si el jugador está fuera de rango
            end
            return
        end

        -- Si el jugador está detectado y puede hacer Tackle, cambiar a Tackle
        if playerDetected and canTackle then
            if currentState ~= state.Tackle then
                currentState = state.Tackle
                IsCharging = true
                local direction = Vector3.new(
                    playerTransf.position.x - tankTransform.position.x,
                    0,
                    playerTransf.position.z - tankTransform.position.z
                )
                local distance = math.sqrt(direction.x^2 + direction.z^2)
                if distance > 0 then
                    direction.x = direction.x / distance
                    direction.z = direction.z / distance
                end
                targetDirection = direction 
                print("Direccion hacia el jugador:", targetDirection.x, targetDirection.z)
            end
            return
        end

        -- Si el jugador está detectado pero no puede hacer Tackle, cambiar a Chase
        if playerDetected then
            if currentState ~= state.Chase then
                currentState = state.Chase
            end
            return
        end
    end

    -- Si ninguna condición se cumple, cambiar a Idle
    if currentState ~= state.Idle then
        currentState = state.Idle
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
    --Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
    --Physics.DebugDrawRaycast(origin, intermediateLeftDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1)) 
    --Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    --Physics.DebugDrawRaycast(origin, intermediateRightDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1))
    --Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))

    -- Lanzar los rayos
    local centerHit = Physics.Raycast(origin, direction, maxDistance)
    local intermediateLeftHit = Physics.Raycast(origin, intermediateLeftDirection, maxDistance)
    local leftHit = Physics.Raycast(origin, leftDirection, maxDistance)
    local intermediateRightHit = Physics.Raycast(origin, intermediateRightDirection, maxDistance)
    local rightHit = Physics.Raycast(origin, rightDirection, maxDistance)
    
    if detect_player(centerHit) or detect_player(intermediateLeftHit) or detect_player(leftHit) or 
       detect_player(intermediateRightHit) or detect_player(rightHit) then
        currentState = state.Chase 
        playerDetected = true
        playerDistance = get_distance(origin, centerHit.hitPoint)
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

    --Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))

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

        if collisionWithPlayer then
            print("Volviendo al estado Attack desde Idle")
            currentState = state.Attack
        end
    end
end

function chase_state(dt)
    -- Animation for chase
    if currentAnim ~= 2 then
        animator:set_current_animation(2)
        currentAnim = 2
    end

    tankVelocity = defaultVelocity
    follow_path(dt)
end

function tackle_state(dt)
    -- Animation for tackle
    if currentAnim ~= 3 then
        animator:set_current_animation(3)
        currentAnim = 3
    end

    -- Si el tanque está cargando, moverse hacia la última posición detectada del jugador
    if IsCharging and targetDirection then
        local velocity = Vector3.new(
            targetDirection.x * tackleVelocity,
            0,
            targetDirection.z * tackleVelocity
        )
        tankRigidbody:set_velocity(velocity)
        rotate_tank(Vector3.new(
            tankTransform.position.x + targetDirection.x,
            tankTransform.position.y,
            tankTransform.position.z + targetDirection.z
        ))
    else
        tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
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
                playerScript.playerHealth = playerScript.playerHealth - tankDamage
                print("Player health after attack: " .. playerScript.playerHealth)
            end
        end
        attackTimer = 0

        local attackDistance = get_distance(tankTransform.position, playerTransf.position)
        if collisionWithPlayer then
            print("Ataque completado, cambiando a estado Idle")
            currentState = state.Idle
        elseif attackDistance > meleeDistance then
            print("Jugador fuera de alcance, cambiando a estado Chase")
            currentState = state.Chase
        end
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

-- function check_zone()
--     if zoneNumber == 0 then
--         local zone1 = current_scene:get_entity_by_name("Zone1")
--         local zone2 = current_scene:get_entity_by_name("Zone2")
--         local zone3 = current_scene:get_entity_by_name("Zone3")
--         local zone1RbComponent = zone1:get_component("RigidbodyComponent")
--         local zone2RbComponent = zone2:get_component("RigidbodyComponent")
--         local zone3RbComponent = zone3:get_component("RigidbodyComponent")

--         local zone1Rb = zone1RbComponent.rb
--         local zone2Rb = zone2RbComponent.rb
--         local zone3Rb = zone3RbComponent.rb
--         zone1Rb:set_trigger(true)
--         zone2Rb:set_trigger(true)
--         zone3Rb:set_trigger(true)

--         zone1RbComponent:on_collision_enter(function(entityA, entityB)
--             local nameA = entityA:get_component("TagComponent").tag
--             local nameB = entityB:get_component("TagComponent").tag

--             if nameA == "Zone1" or nameB == "Zone1" then
--                 zoneNumber = 1
--             end
--         end)
--         zone2RbComponent:on_collision_enter(function(entityA, entityB)
--             local nameA = entityA:get_component("TagComponent").tag
--             local nameB = entityB:get_component("TagComponent").tag

--             if nameA == "Zone2" or nameB == "Zone2" then
--                 zoneNumber = 2
--             end
--         end)
--         zone3RbComponent:on_collision_enter(function(entityA, entityB)
--             local nameA = entityA:get_component("TagComponent").tag
--             local nameB = entityB:get_component("TagComponent").tag

--             if nameA == "Zone3" or nameB == "Zone3" then
--                 zoneNumber = 3
--             end
--         end)
--     end

--     if zoneNumber < playerScript.zonePlayer then
--         tankRigidbody:set_position(Vector3.new(-500, 0, 0))
--         self:set_active(false)
--     end
-- end

function on_exit() 
    -- Clean up code here
end