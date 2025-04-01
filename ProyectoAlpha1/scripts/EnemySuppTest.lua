local state = { Idle = 1, Move = 2, Shield = 3, Flee = 4, Attack = 5}
local currentState = state.Idle

local suppEnemyWorldTransf
local suppEnemyTransf
local suppEnemyNav
local suppEnemyRb
local suppAnimator
local forwardVector
suppEnemyHealth = 50
shieldHealth = 35
local suppVelocity = 5
local suppVelocityFlee = 7

local canUseShield=true
local shieldCooldown = 5
local detectDistance = 20
local shieldDistance = 5
local findEnemiesTimer = 0
local findEnemiesInterval = 1.5

local waypoint1
local waypoint2
local waypoint3
local currentWaypoint = 1
local waypointPositions = {}

local currentPathIndex = 1
local pathUpdateTimer = 0
local pathUpdateInterval = 1.0  
local lastTargetPos = nil

local Enemies = {}

local player
local playerTransf


function on_ready() 

    suppEnemyTransf = self:get_component("TransformComponent")
    suppEnemyWorldTransf = suppEnemyTransf:get_world_transform()
    forwardVector = Vector3.new(1,0,0)
    suppEnemyRb = self:get_component("RigidbodyComponent").rb
    suppEnemyNav = self:get_component("NavigationAgentComponent")
    suppAnimator = self:get_component("AnimatorComponent")

    find_all_enemies()

    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")


    waypoint1 = current_scene:get_entity_by_name("SuppWaypoint1")
    waypoint2 = current_scene:get_entity_by_name("SuppWaypoint2")
    waypoint3 = current_scene:get_entity_by_name("SuppWaypoint3")
    
    if waypoint1 and waypoint2 and waypoint3 then
        local wp1Transform = waypoint1:get_component("TransformComponent")
        local wp2Transform = waypoint2:get_component("TransformComponent")
        local wp3Transform = waypoint3:get_component("TransformComponent")
        
        if wp1Transform and wp2Transform and wp3Transform then
            waypointPositions[1] = wp1Transform.position
            waypointPositions[2] = wp2Transform.position
            waypointPositions[3] = wp3Transform.position
        else
            print("Error: Could not get transformation components of waypoints")
        end
    end
end

-- FSM General
function on_update(dt)

    change_state(dt) -- Funcion para cambiar de estados

    -- FSM { Idle -> Move -> Attack}
    if currentState == state.Idle then
        idle_state(dt)

    elseif currentState == state.Move then
        move_state(dt)
    
    elseif currentState == state.Shield then
        shield_state(dt)
    
    elseif currentState == state.Flee then
        flee_state(dt)

    elseif currentState == state.Attack then
        attack_state(dt)
    end

end

function change_state(dt)


    findEnemiesTimer = findEnemiesTimer + dt
    if findEnemiesTimer >= findEnemiesInterval then
        find_all_enemies()
        findEnemiesTimer = 0
    end
    
    -- Si no hay enemigos cercanos, pasar a estado Flee
    if #Enemies == 0 then
        currentState = state.Flee
        return
    end
    
    -- Obtener estados de escudo de los enemigos
    local shieldStatuses = update_shield_status()
    
    -- Comprobar si todos los enemigos tienen escudo activo
    local allShielded = false
    for _, shieldData in ipairs(shieldStatuses) do
        if  shieldData.haveShield then
            allShielded = true
            break
        end
    end
    
    -- Si todos tienen escudo, ir a Flee
    if allShielded then
        currentState = state.Flee
        return
    end
    
    -- Obtener las distancias de los enemigos
    local enemyDistances = enemies_distance()
    
    -- Buscar el enemigo sin escudo más cercano
    local closestUnshieldedEnemy = nil
    local minDistance = math.huge
    
    for _, distData in ipairs(enemyDistances) do
        -- Buscar el estado de escudo correspondiente a este enemigo
        local hasShield = false
        for _, shieldData in ipairs(shieldStatuses) do
            if shieldData.enemy.name == distData.enemy.name then
                hasShield = shieldData.haveShield
                break
            end
        end
        
        if not hasShield and distData.distance < minDistance then
            minDistance = distData.distance
            closestUnshieldedEnemy = distData.enemy
        end
    end
    
    -- Determinar estado basado en la distancia al enemigo más cercano sin escudo
    if closestUnshieldedEnemy then
        if minDistance <= shieldDistance and canUseShield then
            currentState = state.Shield
        else
            currentState = state.Move
        end
    else
        currentState = state.Flee
    end
end
-- Funciones para los distintos estados.
function idle_state(dt) end

function move_state(dt)
    -- Animación
    if suppAnimator and currentAnim ~= 1 then
        suppAnimator:set_current_animation(1)
        currentAnim = 1
    end
    
    local enemyDistances = enemies_distance()
    local shieldStatuses = update_shield_status()
    
    local validTargets = {}
    for _, distData in ipairs(enemyDistances) do
        local hasShield = false
        for _, shieldData in ipairs(shieldStatuses) do
            if shieldData.enemy and distData.enemy and shieldData.enemy.name == distData.enemy.name then
                hasShield = shieldData.haveShield
                break
            end
        end
        if not hasShield and distData.enemy then
            table.insert(validTargets, distData.enemy)
        end
    end

    local bestTarget = nil
    if #validTargets > 0 then
        -- Encontrar máxima prioridad
        local maxPriority = -math.huge
        for _, enemy in ipairs(validTargets) do
            if enemy.priority and enemy.priority > maxPriority then
                maxPriority = enemy.priority
            end
        end

        local candidates = {}
        for _, enemy in ipairs(validTargets) do
            if enemy.priority and enemy.priority == maxPriority then
                table.insert(candidates, enemy)
            end
        end

        local closestDist = math.huge
        for _, candidate in ipairs(candidates) do
            if candidate.transform then
                local dist = get_distance(suppEnemyTransf.position, candidate.transform.position)
                if dist < closestDist then
                    closestDist = dist
                    bestTarget = candidate
                end
            end
        end
    end
    
    -- Manejo del movimiento
    if bestTarget and bestTarget.transform then
        local targetPos = bestTarget.transform.position
        
        -- Actualización de ruta optimizada
        pathUpdateTimer = pathUpdateTimer + dt
        if pathUpdateTimer >= pathUpdateInterval or not lastTargetPos 
            or get_distance(lastTargetPos, targetPos) > 1.0 then
            
            suppEnemyNav.path = suppEnemyNav:find_path(suppEnemyTransf.position, targetPos)
            lastTargetPos = targetPos
            pathUpdateTimer = 0
            currentPathIndex = 1
        end

        follow_path(dt) 
        
        -- Transición a escudo - adding nil checks
        if shieldDistance ~= nil and get_distance(suppEnemyTransf.position, targetPos) <= shieldDistance and canUseShield then
            currentState = state.Shield
        end
    else
        currentState = state.Flee
    end
end

function attack_state(dt) end

function shield_state(dt) end

function flee_state(dt)
    if suppAnimator then
        if currentAnim ~= 2 then
            suppAnimator:set_current_animation(2)
            currentAnim = 2
        end
    end

    local currentTarget = waypointPositions[currentWaypoint]
    
    if lastTargetPos == nil or get_distance(lastTargetPos, currentTarget) > 1.0 then
        update_waypoint_path()
    end

    follow_path(dt)

    -- Fix: Use suppEnemyTransf instead of enemyTransf
    local distance = get_distance(suppEnemyTransf.position, currentTarget)

    if distance <= 1.0 then
        currentWaypoint = currentWaypoint % #waypointPositions + 1
        update_waypoint_path()
    end

    checkEnemyTimer = (checkEnemyTimer or 0) + dt
    if (checkEnemyTimer >= (checkEnemyInterval or 2.0)) then
        checkEnemyTimer = 0
        local allEnemiesWithShield = true
        
        -- Check if all enemies have shields
        local shieldStatuses = update_shield_status()
        for _, shieldData in ipairs(shieldStatuses) do
            if not shieldData.haveShield then
                allEnemiesWithShield = false
                break
            end
        end
        
        -- If not all enemies have shields, we can move
        if not allEnemiesWithShield then
            currentState = state.Move
        end
    end
end

function find_all_enemies()
    -- Clear existing enemies table to avoid duplicates
    Enemies = {}
    
    enemyNames = { "EnemyOrk", "TankOrk", "EnemyKamikaze" }
    local suppPos = suppEnemyTransf.position

    for _, name in ipairs(enemyNames) do
        local entity = current_scene:get_entity_by_name(name)
        if entity then
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")

            if script and entityTransform then
                -- Access script properties safely with defaults
                local health = script.enemyHealth or 100
                local priority = script.priority or 1
                local haveShield = script.haveShield or false 
                local distance = get_distance(suppPos, entityTransform.position)

                if distance <= detectDistance then
                    local enemyData = {
                        name = name,
                        transform = entityTransform,
                        script = script,
                        health = health,
                        priority = priority,
                        haveShield = haveShield
                    }

                    table.insert(Enemies, enemyData)
                end
            end
        end
    end
    
    if #Enemies > 0 then
        get_priority_enemy()
    end
end

function get_priority_enemy()

    local priorityEnemy = {}

    for _, enemyData in ipairs(Enemies) do
        if enemyData.priority then
            local enemyPriority = enemyData.priority
            table.insert(priorityEnemy,{
                enemy= enemyData,
                priority = enemyPriority
            })
        end
    end

    enemies_distance()
    return priorityEnemy

end

function enemies_distance()
    local distances = {}
    local suppPos = suppEnemyTransf.position
    
    for _, enemyData in ipairs(Enemies) do
        if enemyData.transform then
            local enemyPos = enemyData.transform.position
            local dist = get_distance(suppPos, enemyPos)
            table.insert(distances, {
                enemy = enemyData,
                distance = dist
            })
        end
    end

    update_shield_status()  
    return distances

end

function update_shield_status()

    local shieldState = {}

    for _, enemyData in ipairs(Enemies) do
        if enemyData.haveShield then
            local enemyHaveShield = enemyData.haveShield
            table.insert(shieldState,{
                enemy= enemyData,
                haveShield = enemyHaveShield
            })
        end
    end

    return shieldState
end

function update_path()
    if enemyNavmesh == nil then 
        return 
    end
    
    -- Determine target based on state
    local targetPos = nil
    
    if currentState == state.Move then
        if player and playerTransf and get_distance(enemyTransf.position, playerTransf.position) <= MoveDistance then
            targetPos = playerTransf.position
        elseif enemyRangeEntity and enemyRangeTransf then
            targetPos = enemyRangeTransf.position
        end
    elseif currentState == state.Shield and enemyRangeEntity and enemyRangeTransf then
        targetPos = enemyRangeTransf.position
    elseif currentState == state.Flee and #waypointPositions > 0 then
        targetPos = waypointPositions[currentWaypoint]
    end
    
    -- Update path if we have a target
    if targetPos ~= nil then
        enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, targetPos)
        lastTargetPos = targetPos
        -- Reset el índice del camino
        currentPathIndex = 1
    end
end

function update_waypoint_path()
    if suppEnemyNav == nil then 
        return 
    end
    
    if #waypointPositions > 0 then
        local targetPos = waypointPositions[currentWaypoint]
        suppEnemyNav.path = suppEnemyNav:find_path(suppEnemyTransf.position, targetPos)
        lastTargetPos = targetPos
        currentPathIndex = 1
    end
end

function follow_path(dt)
    if suppEnemyNav == nil or #suppEnemyNav.path == 0 then 
        if suppEnemyRb then
            suppEnemyRb:set_velocity(Vector3.new(0, 0, 0))
        end
        return 
    end
    
    -- Check if index is valid
    if currentPathIndex > #suppEnemyNav.path then
        currentPathIndex = 1
        if #suppEnemyNav.path == 0 then
            if suppEnemyRb then
                suppEnemyRb:set_velocity(Vector3.new(0, 0, 0))
            end
            return
        end
    end

    local nextPoint = suppEnemyNav.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - suppEnemyTransf.position.x,
        0, -- Ignore Y for movement on plane
        nextPoint.z - suppEnemyTransf.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            0,
            direction.z / distance
        )

        -- Use physics for movement
        if suppEnemyRb then
            local moveSpeed = 5.0  -- Define moveSpeed if not already defined
            local velocity = Vector3.new(normalizedDirection.x * moveSpeed, 0, normalizedDirection.z * moveSpeed)
            suppEnemyRb:set_velocity(velocity)
        end

        rotate_enemy(nextPoint)
    else
        if currentPathIndex < #suppEnemyNav.path then
            currentPathIndex = currentPathIndex + 1
        else
            -- We've reached the end of the path, stop movement
            if suppEnemyRb then
                suppEnemyRb:set_velocity(Vector3.new(0, 0, 0))
            end
        end
    end
end

function rotate_enemy(targetPosition)
    local dx = targetPosition.x - suppEnemyTransf.position.x
    local dz = targetPosition.z - suppEnemyTransf.position.z

    local angleRotation = math.atan(dx, dz)
    suppEnemyTransf.rotation.y = math.deg(angleRotation)
end

function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = 0 -- Ignore height difference for pathfinding
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function die()
    currentState = state.Idle
    enemyRb:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end