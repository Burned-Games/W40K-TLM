local enemies
local enemiesScript
local enemyTransf 
local enemyWorldTransf
local enemyRangeEntity
local enemyRangeTransf
local forwardVector
local enemyRb 

local moveSpeed = 3
enemyLife = 50
shieldLive = 50

local player
local playerTransf
local transformShield

local sphere = nil

local detectDistance = 30  -- Detection distance 
local shieldDistance = 7.5       
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
local shieldCooldown = 8
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
    if not enemyRb then
        print("Error: RigidbodyComponent not found on Support Enemy")
    end

    enemyRangeEntity = current_scene:get_entity_by_name("EnemyOrk")
    if enemyRangeEntity then
        enemyRangeTransf = enemyRangeEntity:get_component("TransformComponent")
    else
        print("Error: EnemyOrk entity not found")
    end
    
    enemiesScript = enemyRangeEntity:get_component("ScriptComponent")

    enemyNavmesh = self:get_component("NavigationAgentComponent")
    if not enemyNavmesh then
        print("Error: NavigationAgentComponent not found")
    end

    player = current_scene:get_entity_by_name("Player")
    if player then
        playerTransf = player:get_component("TransformComponent")
    else
        print("Error: Player entity not found")
    end

    shield = current_scene:get_entity_by_name("Shield")
    if shield then
        transformShield = shield:get_component("TransformComponent")
    else
        print("Error: Shield entity not found")
    end

    animator = self:get_component("AnimatorComponent")
    if animator then
        print("DEBUG: Animator component initialized successfully")
    else
        print("ERROR: Failed to get animator component")
    end


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
            print("Waypoints successfully initialized for flee_state")
        else
            print("Error: Could not get transformation components of waypoints")
        end
    else
        print("Warning: Not all waypoints found, using default positions")
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
            print("SHIELD: Shield deactivated, ready to apply another")
        end
    end
    
    checkEnemyTimer = checkEnemyTimer + dt
    if checkEnemyTimer >= checkEnemyInterval then
        checkEnemyTimer = 0
        check_enemies_shield_status()
    end

    
    pathUpdateTimer = pathUpdateTimer + dt
    -- Update path always, not just in Chase state
    if pathUpdateTimer >= pathUpdateInterval then
        update_path()
        pathUpdateTimer = 0
    end

    -- Print current state and timers
    print("STATE: " .. get_state_name(currentState) .. 
          ", SHIELD: " .. (shieldActive and "Active " .. math.floor(shieldCooldown - shieldTimer) .. "s" or "Inactive"))
    
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
            print("TRIGGER: EnemyOrk not found, changing to Flee")
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
    elseif currentState == state.Attack then
        attack_state(dt)
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
        print("ANIM: Changed to Chase")
    end

    -- Determine chase target
    local chaseTarget = nil
    if player and playerTransf and enemyRangeEntity and enemyRangeTransf then
        local playerDistance = get_distance(enemyTransf.position, playerTransf.position)
        local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
        
        -- Prioritize closest target
        if playerDistance <= chaseDistance and playerDistance <= rangeDistance then
            chaseTarget = playerTransf.position
            print("CHASE: Main target - Player")
        else
            chaseTarget = enemyRangeTransf.position
            print("CHASE: Main target - EnemyOrk")
        end
        
        -- Check if in attack range
        if playerDistance <= meleeDistance * 0.5 then
            print("CHASE: Player in attack range, changing to Attack")
            currentState = state.Attack
            return
        end
        
        -- Check if in shield range for EnemyOrk
        if rangeDistance <= shieldDistance then
            print("CHASE: EnemyOrk in shield range, changing to Shield")
            currentState = state.Shield
            return
        end
        
        -- Check if we leave chase
        if playerDistance > detectDistance and rangeDistance > detectDistance then
            print("CHASE: Targets out of range, returning to Idle")
            currentState = state.Idle
            return
        end
    elseif player and playerTransf then
        chaseTarget = playerTransf.position
        print("CHASE: Only Player available as target")
    elseif enemyRangeEntity and enemyRangeTransf then
        chaseTarget = enemyRangeTransf.position
        print("CHASE: Only EnemyOrk available as target")
    else
        print("CHASE: No chase target")
        currentState = state.Flee  -- Change to Flee when no targets
        return
    end
    
    -- Perform chase
    if enemyNavmesh and chaseTarget then
        if #enemyNavmesh.path == 0 or get_distance(lastTargetPos, chaseTarget) > 1.0 then
            lastTargetPos = chaseTarget
            enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, chaseTarget)
            print("CHASE: Path updated with " .. #enemyNavmesh.path .. " points")
            -- Reset el índice del camino
            currentPathIndex = 1
        end
        
        follow_path(dt)
    else
        print("CHASE: FALLBACK - Using direct movement because there's no NavMesh")
        if chaseTarget then
            move_towards_physics(chaseTarget, dt)
        end
    end
end

function player_distance()
    local playerDistance = get_distance(enemyTransf.position, playerTransf.position)
    
    if playerDistance <= chaseDistance then
        if currentState ~= state.Chase and currentState ~= state.Attack then
            print("TRIGGER: Player detected, changing to Chase")
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
    
    -- Add debug print
    print("DEBUG: Distance to EnemyOrk: " .. rangeDistance)

    if rangeDistance <= shieldDistance - 1.0 then  -- Added buffer to prevent oscillation
        if currentState ~= state.Shield then
            print("TRIGGER: EnemyOrk in shield range, changing to Shield")
            currentState = state.Shield
        end
    elseif rangeDistance <= detectDistance - 2.0 then  -- Added buffer
        if currentState ~= state.Chase and currentState ~= state.Shield then
            print("TRIGGER: EnemyOrk detected, changing to Chase")
            currentState = state.Chase
            lastTargetPos = enemyRangeTransf.position
            update_path() -- Update the path immediately
            -- Reset el índice del camino
            currentPathIndex = 1
        end
    elseif currentState ~= state.Idle and currentState ~= state.Attack then
        print("TRIGGER: No nearby targets, returning to Idle")
        currentState = state.Idle
    end
end

function idle_state(dt)

    if animator then
        if currentAnim ~= 2 then
            animator:set_current_animation(2)
            currentAnim = 2
            print("ANIM: Changed to Flee")
        end
    else
        print("ERROR: animator is nil in flee_state")
    end

    idleTimer = idleTimer + dt

    -- Animation
    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
        print("ANIM: Changed to Idle")
    end

    if idleTimer >= idleDuration then
        print("TIMER: Idle completed, checking for targets")
        idleTimer = 0

        
        if enemyRangeEntity and enemyRangeTransf then
            local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
            if rangeDistance <= detectDistance then
                print("TRIGGER: EnemyOrk in range after idle, changing to Chase")
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
            print("ANIM: Changed to Flee")
        end
    else
        print("ERROR: animator is nil in flee_state")
    end

    -- Verify we have waypoints
    if #waypointPositions == 0 then
        print("ERROR: No waypoints for flee_state")
        currentState = state.Idle
        return
    end

    -- Get current waypoint
    local currentTarget = waypointPositions[currentWaypoint]
    
    -- Calculate distance to current waypoint
    local distance = get_distance(enemyTransf.position, currentTarget)
    print("FLEE: Distance to waypoint " .. currentWaypoint .. ": " .. distance)
    
    -- If we're close enough, change to next waypoint
    if distance <= 1.0 then
        currentWaypoint = currentWaypoint % #waypointPositions + 1
        print("FLEE: Waypoint reached, changing to waypoint " .. currentWaypoint)
        currentPathIndex = 1
        lastTargetPos = nil
    end
    
    -- Move toward current waypoint
    if enemyNavmesh then
        if #enemyNavmesh.path == 0 or lastTargetPos == nil or get_distance(lastTargetPos, currentTarget) > 1.0 then
            lastTargetPos = currentTarget
            enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, currentTarget)
            print("FLEE: Path updated with " .. #enemyNavmesh.path .. " points")
            currentPathIndex = 1
        end
        follow_path(dt)
    else
        move_towards_physics(currentTarget, dt)
    end
    
    -- Check if EnemyOrk has reappeared
    enemyRangeEntity = current_scene:get_entity_by_name("EnemyOrk")
    if enemyRangeEntity then
        enemyRangeTransf = enemyRangeEntity:get_component("TransformComponent")
        if enemyRangeTransf then
            print("FLEE: EnemyOrk found, checking states again")
            enemyRange_distance()
        end
    end
end

function shield_state(dt)
    if shield ~= nil and transformShield ~= nil then
        -- Animation
        if currentAnim ~= 4 then
            animator:set_current_animation(4)
            currentAnim = 4
            print("ANIM: Changed to Shield")
        end

        local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
        
        -- Add a buffer to prevent oscillation
        local minDistance = shieldDistance - 1.0
        local maxDistance = shieldDistance + 1.0

        if rangeDistance < minDistance then
            -- Move away slightly using physics
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
                print("POSITION: Moving away to maintain optimal distance")
            end
        elseif rangeDistance > maxDistance then
            -- Move closer - use path following instead of direct position update
            if enemyNavmesh then
                if #enemyNavmesh.path == 0 or pathUpdateTimer >= pathUpdateInterval then
                    enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, enemyRangeTransf.position)
                    lastTargetPos = enemyRangeTransf.position
                    pathUpdateTimer = 0
                    print("SHIELD: Path updated to get closer")
                    -- Reset el índice del camino
                    currentPathIndex = 1
                end
                follow_path(dt)
            else
                move_towards_physics(enemyRangeTransf.position, dt)
            end
            print("POSITION: Moving closer to reach optimal distance")
        else
            -- At the correct distance, apply shield if not active and stop movement
            if enemyRb then
                enemyRb:set_velocity(Vector3.new(0, 0, 0))
            end
            
            print("POSITION: Optimal distance reached")
            if not shieldActive then
                shieldActive = true
                if transformShield ~= nil then
                    transformShield.position = enemyRangeTransf.position
                    if enemyRangeEntity ~= nil then
                        local enemyScript = enemyRangeEntity:get_component("ScriptComponent")
                        if enemyScript ~= nil then
                            enemyScript.shield_state = true
                            print("EnemyHealth: " .. tostring(enemyScript.shield_state))
                            shieldTimer = 0
                        end
                    end
                end
            end
        end
    else
        print("ERROR: Shield not found")
        currentState = state.Idle
    end
end

function update_path()
    -- Check required components
    if enemyNavmesh == nil then 
        print("ERROR: No NavMesh to update")
        return 
    end
    
    -- Determine target based on state
    local targetPos = nil
    
    if currentState == state.Chase then
        if player and playerTransf and get_distance(enemyTransf.position, playerTransf.position) <= chaseDistance then
            targetPos = playerTransf.position
            print("PATH: Updating path to Player")
        elseif enemyRangeEntity and enemyRangeTransf then
            targetPos = enemyRangeTransf.position
            print("PATH: Updating path to EnemyOrk")
        end
    elseif currentState == state.Shield and enemyRangeEntity and enemyRangeTransf then
        targetPos = enemyRangeTransf.position
        print("PATH: Updating path to EnemyOrk for Shield")
    elseif currentState == state.Flee and #waypointPositions > 0 then
        targetPos = waypointPositions[currentWaypoint]
        print("PATH: Updating path to waypoint " .. currentWaypoint)
    end
    
    -- Update path if we have a target
    if targetPos ~= nil then
        enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, targetPos)
        print("PATH: Updated with " .. #enemyNavmesh.path .. " points")
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
    
    print("SUPPORT: Found " .. #rangeEnemies .. " range enemies")
    return #rangeEnemies > 0
end

function check_enemies_shield_status()
    -- First check if we need to find enemies
    if #rangeEnemies == 0 then
        if not find_range_enemies() then
            print("SUPPORT: No range enemies found to protect")
            return false
        end
    end

    -- Check which enemies need shield
    local enemiesNeedingShield = {}
    for i, enemy in ipairs(rangeEnemies) do
        -- Verify enemy is valid
        if enemy and type(enemy) == "userdata" then
            -- Safe way to get enemy name
            local enemyName = ""
            pcall(function()
                enemyName = enemy:get_name() or "Unknown"
            end)
            
            -- Get script component safely
            local enemyScript = enemy:get_component("LuaScriptComponent") -- Changed to LuaScriptComponent
            if enemyScript then
                -- Safe way to check shield state
                local hasShield = false
                pcall(function()
                    hasShield = enemyScript.shield_state or false
                end)
                
                if not hasShield then
                    table.insert(enemiesNeedingShield, enemy)
                    print("SUPPORT: Enemy " .. enemyName .. " needs shield")
                end
            else
                print("SUPPORT: Enemy " .. enemyName .. " has no script component")
            end
        else
            print("SUPPORT: Invalid enemy in rangeEnemies table")
            table.remove(rangeEnemies, i)
        end
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
            
            print("SUPPORT: Targeting " .. targetName .. " to provide shield")
            return true
        end
    end
    
    print("SUPPORT: All enemies have shields or no valid enemies found")
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
            print("MOVE: Moving with velocity " .. velocity.x .. ", " .. velocity.z)
        else
            print("ERROR: No RigidBodyComponent for movement")
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

function die()
    local AFK = Vector3.new(100, 0, 100)
    if enemyRb then
        enemyRb:set_position(AFK)
    else
        enemyTransf.position = AFK
    end
    currentState = state.Idle
end

function on_exit() end