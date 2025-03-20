local enemies
local enemiesScript
local enemyTransf 
local enemyWorldTransf
local enemyRangeEntity
local enemyRangeTransf
local forwardVector
local enemyRb 

local moveSpeed = 5
enemyHealth = 50
shieldLive = 50
local allEnemieswithShield = false
local shieldCooldown = 3  -- 30 segundos de cooldown
local canUseShield = true
local shieldCooldownTimer = 0


local player
local playerTransf
local transformShield
local transformActualShield
local actualshield = nil
local prefabShield = nil

local sphere = nil

local detectDistance = 30  -- Detection distance 
local shieldDistance = 9       
local meleeDistance = 1
local chaseDistance = 3
local rangeEnemies = {}
local checkEnemyTimer = 0
local checkEnemyInterval = 2.0

local currentAnim = 0
local animator
local movingForward = false

-- Waypoints for flee_state
local waypoint1
local waypoint2
local waypoint3
local currentWaypoint = 1
local waypointPositions = {}

state = { Idle = 1, Attack = 2, Chase = 3, Shield = 4, Flee = 5 }
local currentState = state.Idle

local idleTimer = 0
local idleDuration = 3
local shieldActive = false
local shieldTimer = 0
local AttackTimer = 0
local AttackCooldown = 3  

local pathUpdateTimer = 0
local pathUpdateInterval = 1.0  -- Increased from 0.5 to 1.0
local lastTargetPos = nil

-- Inicialización del índice de navegación
local currentPathIndex = 1

function on_ready() 
    enemyTransf = self:get_component("TransformComponent")
    enemyWorldTransf = enemyTransf:get_world_transform()
    forwardVector = Vector3.new(1,0,0)
    
    find_range_enemies()
    check_enemies_shield_status()

    enemyRb = self:get_component("RigidbodyComponent").rb


    enemyRangeEntity = current_scene:get_entity_by_name("EnemyOrk")
    if enemyRangeEntity then
        enemyRangeTransf = enemyRangeEntity:get_component("TransformComponent")
    end
    
    enemiesScript = enemyRangeEntity:get_component("ScriptComponent")

    enemyNavmesh = self:get_component("NavigationAgentComponent")


    player = current_scene:get_entity_by_name("Player")
    if player then
        playerTransf = player:get_component("TransformComponent")
    end

    prefabShield = current_scene:get_entity_by_name("Shield")
    if prefabShield then
        actualshield = current_scene:duplicate_entity(prefabShield)
        if actualshield then
            transformActualShield = actualshield:get_component("TransformComponent")
            local rendererComp = actualshield:get_component("Mesh")

            if rendererComp then
                rendererComp.enabled = true
                rendererComp.visible = true
                local prefabRenderer = prefabShield:get_component("MeshRendererComponent")
                if prefabRenderer then
                    rendererComp.mesh = prefabRenderer.mesh
                    rendererCmop.material = prefabRenderer.material
                end
            end
            
            -- Configurar transformación
            if transformActualShield then
                transformActualShield.scale = Vector3.new(1, 1, 1)
            end
        end
    end


    animator = self:get_component("AnimatorComponent")

    -- Initialize waypoints for flee_state
    waypoint1 = current_scene:get_entity_by_name("Waypoint1")
    waypoint2 = current_scene:get_entity_by_name("Waypoint2")
    waypoint3 = current_scene:get_entity_by_name("Waypoint3")
    
    if waypoint1 and waypoint2 and waypoint3 then
        local wp1Transform = waypoint1:get_component("TransformComponent")
        local wp2Transform = waypoint2:get_component("TransformComponent")
        local wp3Transform = waypoint3:get_component("TransformComponent")
        
        if wp1Transform and wp2Transform and wp3Transform then
            waypointPositions[1] = wp1Transform.position
            waypointPositions[2] = wp2Transform.position
            waypointPositions[3] = wp3Transform.position
        end
    else
        waypointPositions[1] = Vector3.new(10, 0, 10)
        waypointPositions[2] = Vector3.new(-10, 0, 10)
        waypointPositions[3] = Vector3.new(0, 0, -10)
    end

    if enemyRangeEntity ~= nil and enemyRangeTransf ~= nil then
        lastTargetPos = enemyRangeTransf.position
        update_path()
    end
end

function on_update(dt) 
    -- Update timers
    AttackTimer = AttackTimer + dt
    
    if shieldActive then
        shieldTimer = shieldTimer + dt
        if shieldTimer >= shieldCooldown then
            shieldActive = false
            shieldTimer = 0
        end
    end

    if not canUseShield then
        shieldCooldownTimer = shieldCooldownTimer + dt
        if shieldCooldownTimer >= shieldCooldown then
            canUseShield = true
            shieldCooldownTimer = 0

            if actualshield== nil then
                create_new_shield()
            end
        end
    end

    if enemyHealth <= 0 then
        Die()
    end
    
    checkEnemyTimer = checkEnemyTimer + dt
    if checkEnemyTimer >= checkEnemyInterval then
        checkEnemyTimer = 0
        check_enemies_shield_status()
    end

    if enemiesScript.shield_destroyed then
        Shield_CoolDown()
        currentState = state.Flee
        return
    end

    pathUpdateTimer = pathUpdateTimer + dt
    -- Update path always, not just in Chase state
    if pathUpdateTimer >= pathUpdateInterval then
        update_path()
        pathUpdateTimer = 0
    end

    -- Check distances
    if player and playerTransf then
        player_distance()
    end
    
    -- Check if the EnemyOrk exists
    if enemyRangeEntity and enemyRangeTransf then
        enemyRange_distance()
    else
        -- If EnemyOrk doesn't exist, change to flee_state if we're not already in that state
        if currentState ~= state.Flee and currentState ~= state.Attack then
            currentState = state.Flee
        end
    end

    if shieldActive and transformShield and enemyRangeTransf then
        transformShield.position = enemyRangeTransf.position
    end

    -- Reset velocity when idle
    if currentState == state.Idle and enemyRb then
        enemyRb:set_velocity(Vector3.new(0, 0, 0))
    end

    -- Execute current state
    if currentState == state.Idle then
        idle_state(dt)
    elseif currentState == state.Shield then
        shield_state(dt)
    elseif currentState == state.Chase then
        chase_state(dt)
    elseif currentState == state.Flee then
        flee_state(dt)
    end
    
end

function get_state_name(stateNum)
    if stateNum == state.Idle then return "Idle"
    elseif stateNum == state.Attack then return "Attack"
    elseif stateNum == state.Chase then return "Chase"
    elseif stateNum == state.Shield then return "Shield"
    elseif stateNum == state.Flee then return "Flee"
    else return "Unknown"
    end
end

function chase_state(dt)
    -- Chase animation
    if currentAnim ~= 2 then
        animator:set_current_animation(2)
        currentAnim = 2
    end

 

    -- Determine chase target
    local chaseTarget = nil
    if player and playerTransf and enemyRangeEntity and enemyRangeTransf then
        local playerDistance = get_distance(enemyTransf.position, playerTransf.position)
        local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
        
        -- Prioritize closest target
        if playerDistance <= chaseDistance and playerDistance <= rangeDistance then
            chaseTarget = playerTransf.position
        else
            chaseTarget = enemyRangeTransf.position
        end
        
        -- Check if in shield range for EnemyOrk
        if rangeDistance <= shieldDistance then
            currentState = state.Shield
            return
        end

    elseif enemyRangeEntity and enemyRangeTransf then
        chaseTarget = enemyRangeTransf.position
    else
        currentState = state.Flee 
        return
    end
    
    -- Perform chase
    if enemyNavmesh and chaseTarget then
        if #enemyNavmesh.path == 0 or get_distance(lastTargetPos, chaseTarget) > 1.0 then
            lastTargetPos = chaseTarget
            enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, chaseTarget)
            currentPathIndex = 1
        end
        
        follow_path(dt)
    else
        if chaseTarget then
            move_towards_physics(chaseTarget, dt)
        end
    end
end

function player_distance()
    local playerDistance = get_distance(enemyTransf.position, playerTransf.position)
    
    if playerDistance <= chaseDistance then
        if currentState ~= state.Chase and currentState ~= state.Attack then
            currentState = state.Chase
            lastTargetPos = playerTransf.position
            update_path() -- Update the path immediately
            -- Reset el índice del camino
            currentPathIndex = 1
        end
    end
end

function enemyRange_distance()
    -- Use enemyRangeTransf.position directly
    local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
    
    if rangeDistance <= shieldDistance - 1.0 then  -- Added buffer to prevent oscillation
        if currentState ~= state.Shield then
            currentState = state.Shield
        end
    elseif rangeDistance <= detectDistance - 2.0 then  -- Added buffer
        if currentState ~= state.Chase and currentState ~= state.Shield then
            currentState = state.Chase
            lastTargetPos = enemyRangeTransf.position
            update_path() -- Update the path immediately
            -- Reset el índice del camino
            currentPathIndex = 1
        end
    elseif currentState ~= state.Flee and currentState  then
        currentState = state.Flee
    end
end

function idle_state(dt)

    idleTimer = idleTimer + dt

    -- Animation
    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
    end

    if idleTimer >= idleDuration then
        idleTimer = 0

        
        if enemyRangeEntity and enemyRangeTransf then
            local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
            if rangeDistance <= detectDistance then
                currentState = state.Chase
                lastTargetPos = enemyRangeTransf.position
                update_path()
                currentPathIndex = 1
                return
            end
        end

    end
end

function flee_state(dt)
    if animator then
        if currentAnim ~= 2 then
            animator:set_current_animation(2)
            currentAnim = 2
        end
    end

    -- Get current waypoint
    local currentTarget = waypointPositions[currentWaypoint]
    
    -- Update path to current waypoint if needed
    if lastTargetPos == nil or get_distance(lastTargetPos, currentTarget) > 1.0 then
        update_waypoint_path()
    end
    
    -- Follow the path
    follow_path(dt)
    
    -- Calculate distance to current waypoint
    local distance = get_distance(enemyTransf.position, currentTarget)
    
    -- If we're close enough, change to next waypoint
    if distance <= 1.0 then
        currentWaypoint = currentWaypoint % #waypointPositions + 1
        update_waypoint_path()
    end
    
    -- Check if any enemy has lost shield
    if checkEnemyTimer >= checkEnemyInterval then
        checkEnemyTimer = 0
        if not check_enemies_shield_status() then
            -- If we found an enemy without shield, we should leave flee state
            if not allEnemieswithShield then
                currentState = state.Chase
            end
        end
    end
end

function update_waypoint_path()
    if enemyNavmesh then
        local currentTarget = waypointPositions[currentWaypoint]
        enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, currentTarget)
        lastTargetPos = currentTarget
        currentPathIndex = 1
    end
end

function shield_state(dt)

    if actualshield== nil or transformShield == nil then
        if canUseShield then
            create_new_shield()
        else
            currentState = state.Flee
            return
        end
    end

    if actualshield~= nil and transformShield ~= nil and canUseShield then
        -- Animation
        if currentAnim ~= 4 then
            animator:set_current_animation(4)
            currentAnim = 4
        end

        local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
        
        -- Add a buffer to prevent oscillation
        local minDistance = shieldDistance - 1.0
        local maxDistance = shieldDistance + 1.0

        if rangeDistance < minDistance then
            local direction = Vector3.new(
                enemyTransf.position.x - enemyRangeTransf.position.x,
                0,
                enemyTransf.position.z - enemyRangeTransf.position.z
            )
            local distance = math.sqrt(direction.x^2 + direction.z^2)
            if distance > 0 and enemyRb then
                direction.x = direction.x / distance
                direction.z = direction.z / distance
                enemyRb:set_velocity(Vector3.new(direction.x * moveSpeed * 0.5, 0, direction.z * moveSpeed * 0.5))
            end
        elseif rangeDistance > maxDistance then
            if enemyNavmesh then
                if #enemyNavmesh.path == 0 or pathUpdateTimer >= pathUpdateInterval then
                    enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, enemyRangeTransf.position)
                    lastTargetPos = enemyRangeTransf.position
                    pathUpdateTimer = 0
                    currentPathIndex = 1
                end
                follow_path(dt)
            else
                move_towards_physics(enemyRangeTransf.position, dt)
            end
        else

            if enemyRb then
                enemyRb:set_velocity(Vector3.new(0, 0, 0))
            end
            
            if canUseShield then
                if transformShield ~= nil then
                    transformShield.position = enemyRangeTransf.position
                    if enemyRangeEntity ~= nil and not enemiesScript.shield_state  then
                        if enemiesScript ~= nil then
                            enemiesScript.shield_state = true
                            enemiesScript.shieldHealth = enemiesScript.shieldHealth + 25
                            shieldTimer = 0
                            find_range_enemies()
                            check_enemies_shield_status()
                        end
                    end
                end
            end
        end
    else  
        currentState = state.Flee
    end
end

function Shield_CoolDown()
    if enemiesScript ~= nil and enemiesScript.shield_destroyed then
        enemiesScript.shield_state = false
        current_scene:destroy_entity(actualshield)
        actualshield= nil 
        transformShield = nil 
        enemiesScript.shield_destroyed = false
        canUseShield = false  
        shieldCooldownTimer = 0
        currentState = state.Chase
    elseif not canUseShield then
        currentState = state.Chase
    end
end

function create_new_shield()
    actualshield = current_scene:duplicate_entity(prefabShield)
    if actualshield then
        transformShield = actualshield:get_component("TransformComponent")
        
        -- Asegura que el escudo sea visible
        local rendererComp = actualshield:get_component("MeshRendererComponent")
        if rendererComp then
            rendererComp.visible = true
        end
        
        -- Ajusta la escala si es necesario
        transformShield.scale = Vector3.new(1, 1, 1) -- Ajusta según sea necesario
        
        -- Posiciona el escudo correctamente
        if enemyRangeTransf then
            transformShield.position = enemyRangeTransf.position
        end
    end
end

function update_path()
    if enemyNavmesh == nil then 
        return 
    end
    
    -- Determine target based on state
    local targetPos = nil
    
    if currentState == state.Chase then
        if player and playerTransf and get_distance(enemyTransf.position, playerTransf.position) <= chaseDistance then
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

function find_range_enemies()
    rangeEnemies = {}
    
    -- Buscar todos los enemigos con el patrón de nombre "EnemyOrk"
    local baseEnemy = current_scene:get_entity_by_name("EnemyOrk")
    if baseEnemy then
        table.insert(rangeEnemies, baseEnemy)
    end
    
    -- Buscar enemigos adicionales con nombres como "EnemyOrk1", "EnemyOrk2", etc.
    for i = 1, 10 do  
        local enemy = current_scene:get_entity_by_name("EnemyOrk" .. i)
        if enemy then
            table.insert(rangeEnemies, enemy)
        end
    end
    
    return #rangeEnemies > 0
end

function check_enemies_shield_status()
    -- First check if we need to find enemies
    if #rangeEnemies == 0 then
        if not find_range_enemies() then
            return false
        end
    end

    -- Check which enemies need shield
    local enemiesNeedingShield = {}
    local allHaveShield = true -- Flag to track if all enemies have shields

    for i, enemy in ipairs(rangeEnemies) do
        -- Verify enemy is valid
        if enemy and type(enemy) == "userdata" then
            -- Safe way to get enemy name
            local enemyName = ""
            pcall(function()
                enemyName = enemy:get_name() or "Unknown"
            end)
            
            if enemiesScript then
                -- Safe way to check shield state
                local hasShield = false
                pcall(function()
                    hasShield = enemiesScript.shield_state or false
                end)
                
                if not hasShield then
                    table.insert(enemiesNeedingShield, enemy)
                    allHaveShield = false -- Found an enemy without shield
                end
            else
                allHaveShield = false -- If enemiesScript is nil, consider as no shield
            end
        else
            table.remove(rangeEnemies, i)
        end
    end
    
    -- Update global state based on shield status
    allEnemieswithShield = allHaveShield

    -- If all enemies have shields, change to flee state
    if allEnemieswithShield then
        currentState = state.Flee
        return false
    end
    
    -- If there are enemies without shield, choose the first one
    if #enemiesNeedingShield > 0 then
        currentTargetEnemy = enemiesNeedingShield[1]
        if currentTargetEnemy then
            enemyRangeEntity = currentTargetEnemy
            enemyRangeTransf = currentTargetEnemy:get_component("TransformComponent")
            
            -- Safe way to get target name
            local targetName = "Unknown"
            pcall(function()
                targetName = currentTargetEnemy:get_name() or "Unknown"
            end)
            
            return true
        end
    end
    
    return false
end

function follow_path(dt)
    if enemyNavmesh == nil or #enemyNavmesh.path == 0 then 
        if enemyRb then
            enemyRb:set_velocity(Vector3.new(0, 0, 0))
        end
        return 
    end
    
    -- Verificar que el índice es válido
    if currentPathIndex > #enemyNavmesh.path then
        currentPathIndex = 1
        if #enemyNavmesh.path == 0 then
            if enemyRb then
                enemyRb:set_velocity(Vector3.new(0, 0, 0))
            end
            return
        end
    end

    local nextPoint = enemyNavmesh.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - enemyTransf.position.x,
        0, -- Ignoramos la Y para movimiento en plano
        nextPoint.z - enemyTransf.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            0,
            direction.z / distance
        )

        -- Usar física para el movimiento
        if enemyRb then
            local velocity = Vector3.new(normalizedDirection.x * moveSpeed, 0, normalizedDirection.z * moveSpeed)
            enemyRb:set_velocity(velocity)
        end

        rotate_enemy(nextPoint)
    else
        if currentPathIndex < #enemyNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        else
            -- Llegamos al final del camino, detener movimiento
            if enemyRb then
                enemyRb:set_velocity(Vector3.new(0, 0, 0))
            end
        end
    end
end

function rotate_enemy(targetPosition)
    local dx = targetPosition.x - enemyTransf.position.x
    local dz = targetPosition.z - enemyTransf.position.z

    local angleRotation = math.atan(dx, dz)
    enemyTransf.rotation.y = math.deg(angleRotation)
end

function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = 0 -- Ignore height difference for pathfinding
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Die()
    currentState = state.Idle
    enemyRb:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end