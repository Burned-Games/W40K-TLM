local enemies
local enemyTransf 
local enemyWorldTransf
local enemyRangeEntity
local enemyRangeTransf
local rangeScript
local rangecanUseShield = false
local enemyTankEntity
local enemyTankTransf
local tankScript
local tankcanUseShield = false
local enemyKamikazeEntity
local enemyKamikazeTransf
local kamikazeScript
local kamikazecanUseShield = false
local enemySuppEntity
local enemySuppTransf
local forwardVector
local enemyRb 

local moveSpeed = 5
enemyHealth = 50
shieldHealth = 0
local allEnemieswithShield = false
local shieldCooldown = 3  -- 30 segundos de cooldown
local canUseShield = true
haveShield =false
local shieldCooldownTimer = 0


local player
local playerTransf
local transformShield
local transformActualShield
local actualshield = nil
local prefabShield = nil

local sphere = nil

local detectDistance = 20  -- Detection distance 
local shieldDistance = 4.5       
local meleeDistance = 1
local chaseDistance = 7
local alianceEnemies = {}
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
local currentShieldTarget = nil

-- Inicialización del índice de navegación
local currentPathIndex = 1

function on_ready() 
    enemyTransf = self:get_component("TransformComponent")
    enemyWorldTransf = enemyTransf:get_world_transform()
    forwardVector = Vector3.new(1,0,0)
    
    find_enemies()
    check_enemies_shield_status()

    enemyRb = self:get_component("RigidbodyComponent").rb


    enemyRangeEntity = current_scene:get_entity_by_name("EnemyOrk")
    if enemyRangeEntity then
        enemyRangeTransf = enemyRangeEntity:get_component("TransformComponent")
        rangeScript = enemyRangeEntity:get_component("ScriptComponent")
    end

    enemyTankEntity = current_scene:get_entity_by_name("TankOrk")
    if enemyTankEntity then
        enemyTankTransf = enemyTankEntity:get_component("TransformComponent")
        tankScript = enemyTankEntity:get_component("ScriptComponent")
    end

    enemyKamikazeEntity = current_scene:get_entity_by_name("EnemyKamikaze")
    if enemyKamikazeEntity then
        enemyKamikazeTransf = enemyKamikazeEntity:get_component("TransformComponent")
        kamikazeScript = enemyKamikazeEntity:get_component("ScriptComponent")
    end

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

            -- Configurar transformación
            if transformActualShield then
                transformActualShield.scale = Vector3.new(1, 1, 1)
            end
        end
        transformShield = actualshield:get_component("TransformComponent")
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
            create_new_shield()  
        end
    end

    -- Verificar si el escudo actual fue destruido
    if currentShieldTarget and currentShieldTarget.entity then
        local targetScript = currentShieldTarget.entity:get_component("ScriptComponent")
        if targetScript.shieldHealth <= 0 then
            canUseShield = false
            shieldCooldownTimer = 0
            currentShieldTarget = nil
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

    pathUpdateTimer = pathUpdateTimer + dt
    -- Update path always, not just in Chase state
    if pathUpdateTimer >= pathUpdateInterval then
        update_path()
        pathUpdateTimer = 0
    end
    
    -- Check if the enemies existsl
    if enemyRangeEntity and enemyRangeTransf  and enemyKamikazeEntity and enemyKamikazeTransf and enemyTankEntity and enemyTankTransf then
        enemies_Distance()
    else
        -- If enemies doesn't exist, change to flee_state if we're not already in that state
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

    -- Determine chase target with priority
    local chaseTarget = nil
    local targetDistance = math.huge -- Initialize with infinity
    
    -- Check Kamikaze first (highest priority)
    if enemyKamikazeEntity and enemyKamikazeTransf then
        local kamikazeDistance = get_distance(enemyTransf.position, enemyKamikazeTransf.position)
        if kamikazeDistance <= detectDistance and kamikazeDistance < targetDistance then
            chaseTarget = enemyKamikazeTransf.position
            targetDistance = kamikazeDistance
            
            -- Check if in shield range
            if kamikazeDistance <= shieldDistance and not kamikazeScript.haveShield then
                currentState = state.Shield
                print ("Cambiando a Shield del kamikaze")
                return
            end
        end
    end
    
    -- Then check Tank
    if enemyTankEntity and enemyTankTransf then
        local tankDistance = get_distance(enemyTransf.position, enemyTankTransf.position)
        if tankDistance <= detectDistance and tankDistance < targetDistance then
            chaseTarget = enemyTankTransf.position
            targetDistance = tankDistance
            
            -- Check if in shield range
            if tankDistance <= shieldDistance and not tankScript.haveShield then
                currentState = state.Shield
                print ("Cambiando a Shield del tank")
                return
            end
        end
    end
    
    -- Finally check Range
    if enemyRangeEntity and enemyRangeTransf then
        local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
        if rangeDistance <= detectDistance and rangeDistance < targetDistance then
            chaseTarget = enemyRangeTransf.position
            targetDistance = rangeDistance
            
            -- Check if in shield range
            if rangeDistance <= shieldDistance and not rangeScript.haveShield then
                currentState = state.Shield
                print ("Cambiando a Shield del range")
                return
            end
        end
    end

    -- If no target found, go to flee state
    if chaseTarget == nil then
        currentState = state.Flee
        return
    end
    
    -- Perform chase
    if enemyNavmesh and chaseTarget then
        if #enemyNavmesh.path == 0 or get_distance(lastTargetPos, chaseTarget) > 1.0 then
            enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, chaseTarget)
            lastTargetPos = chaseTarget
            currentPathIndex = 1
        end
        follow_path(dt)
    else
        move_towards_physics(chaseTarget, dt)
    end
end

function enemies_Distance()
    local rangeDistance = get_distance(enemyTransf.position, enemyRangeTransf.position)
    local tankDistance = get_distance(enemyTransf.position, enemyTankTransf.position)
    local kamikazeDistance = get_distance(enemyTransf.position, enemyKamikazeTransf.position)

    -- Comprobar primero el estado de persecución antes que el escudo
    if rangeDistance <= detectDistance - 2.0 or 
       tankDistance <= detectDistance - 2.0 or 
       kamikazeDistance <= detectDistance - 2.0 then  
        if currentState ~= state.Shield then  -- Solo cambiar si no está dando escudo
            currentState = state.Chase
            
            if kamikazeDistance <= detectDistance - 2.0 and kamikazeDistance < rangeDistance and kamikazeDistance < tankDistance then
                lastTargetPos = enemyKamikazeTransf.position
            elseif tankDistance <= detectDistance - 2.0 and tankDistance < rangeDistance then
                lastTargetPos = enemyTankTransf.position
            else
                lastTargetPos = enemyRangeTransf.position
            end
            update_path()
            currentPathIndex = 1
        end
    -- Comprobar el rango de escudo después
    elseif kamikazeDistance <= shieldDistance - 1.0 and not kamikazeScript.haveShield then
        currentState = state.Shield
        kamikazecanUseShield = true
    elseif tankDistance <= shieldDistance - 1.0 and not tankScript.haveShield then
        currentState = state.Shield
        tankcanUseShield = true
    elseif rangeDistance <= shieldDistance - 1.0 and not rangeScript.haveShield then
        currentState = state.Shield
        rangecanUseShield = true
    elseif currentState ~= state.Shield then  -- Solo cambiar a Flee si no está dando escudo
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
    -- Definir prioridades de escudo
    local priorityTargets = {
        {entity = enemyKamikazeEntity, script = kamikazeScript, type = "Kamikaze"},
        {entity = enemyTankEntity, script = tankScript, type = "Tank"},
        {entity = enemyRangeEntity, script = rangeScript, type = "Range"}
    }

    -- Filtrar objetivos sin escudo
    local availableTargets = {}
    for _, target in ipairs(priorityTargets) do
        if target.entity and target.script and not target.script.haveShield then
            table.insert(availableTargets, target)
        end
    end

    -- Si no hay objetivos sin escudo, cambiar a Flee
    if #availableTargets == 0 then
        currentState = state.Flee
        return
    end

    -- Seleccionar objetivo según prioridad (primer objetivo sin escudo)
    local targetToShield = availableTargets[1]
    local targetTransf = targetToShield.entity:get_component("TransformComponent")
    local targetScript = targetToShield.entity:get_component("ScriptComponent")

    -- Crear escudo si no existe
    if actualshield == nil then
        create_new_shield()
    end

    -- Posicionar escudo
    if transformShield and targetTransf then
        transformShield.position = targetTransf.position
        
        -- Asegurar visibilidad del escudo
        local rendererComp = actualshield:get_component("MeshRendererComponent")
        if rendererComp then
            rendererComp.visible = true
            rendererComp.enabled = true
        end
    end

    -- Verificar distancia para aplicar escudo
    local distance = get_distance(enemyTransf.position, targetTransf.position)
    
    if distance <= shieldDistance then
        -- Aplicar escudo al objetivo
        if not targetScript.haveShield then
            targetScript.haveShield = true
            targetScript.shieldHealth = 25  -- Salud del escudo
            canUseShield = false
            shieldCooldownTimer = 0

            print("Escudo aplicado a " .. targetToShield.type)
        end
        
        -- Volver a estado de persecución
        currentState = state.Chase
    else
        -- Perseguir al objetivo para aplicar escudo
        if enemyNavmesh then
            enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, targetTransf.position)
            follow_path(dt)
        end
    end
end

function Shield_CoolDown()
    if rangeScript ~= nil and rangeScript.shield_destroyed then
        rangeScript.haveShield = false
        current_scene:destroy_entity(actualshield)
        actualshield= nil 
        transformShield = nil 
        rangeScript.shield_destroyed = false
        canUseShield = false  
        shieldCooldownTimer = 0
        currentState = state.Chase
    elseif not canUseShield then
        currentState = state.Chase
    end
end

function create_new_shield()
    -- Buscar prefab de escudo
    if prefabShield == nil then
        prefabShield = current_scene:get_entity_by_name("Shield")
    end

    if prefabShield then
        -- Duplicar el prefab de escudo
        actualshield = current_scene:duplicate_entity(prefabShield)
        
        if actualshield then
            transformShield = actualshield:get_component("TransformComponent")
            
            -- Configurar renderizado
            local rendererComp = actualshield:get_component("MeshRendererComponent")
            if rendererComp then
                rendererComp.visible = true
                rendererComp.enabled = true
            end

            -- Configurar escala
            transformShield.scale = Vector3.new(1, 1, 1)

            print("Escudo creado para soporte")
        end
    end
end

function check_enemies_shield_status()
    -- Resetear objetivo de escudo
    currentShieldTarget = nil

    -- Prioridades: Kamikaze > Tank > Range
    local priorityTargets = {
        {entity = enemyKamikazeEntity, script = kamikazeScript, type = "Kamikaze"},
        {entity = enemyTankEntity, script = tankScript, type = "Tank"},
        {entity = enemyRangeEntity, script = rangeScript, type = "Range"}
    }

    -- Buscar primer objetivo sin escudo
    for _, target in ipairs(priorityTargets) do
        if target.entity and target.script and not target.script.haveShield then
            currentShieldTarget = {entity = target.entity, type = target.type}
            break
        end
    end

    -- Actualizar estado de todos los escudos
    allEnemieswithShield = (currentShieldTarget == nil)
    return not allEnemieswithShield
end

function update_path()
    if enemyNavmesh == nil then 
        return 
    end
    
    -- Determine target based on state
    local targetPos = nil
    
    if currentState == state.Chase then
        if enemyRangeEntity and enemyRangeTransf then
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

function find_enemies()
    alianceEnemies = {}
    
    -- Buscar todos los enemigos con el patrón de nombre "EnemyOrk"
    local baseEnemy = current_scene:get_entity_by_name("EnemyOrk")
    local tankEnemy = current_scene:get_entity_by_name("TankOrk")
    local kamikazeEnemy = current_scene:get_entity_by_name("EnemyKamikaze")

    if baseEnemy then
        table.insert(alianceEnemies, baseEnemy)
    end
    if tankEnemy then
        table.insert(alianceEnemies, tankEnemy)
    end
    if kamikazeEnemy then
        table.insert(alianceEnemies, kamikazeEnemy)
    end

    for i = 1, 10 do
        local numberedBase = current_scene:get_entity_by_name("EnemyOrk" .. i)
        local numberedTank = current_scene:get_entity_by_name("TankOrk" .. i)
        local numberedKamikaze = current_scene:get_entity_by_name("EnemyKamikaze" .. i)

        
        if numberedBase then table.insert(alianceEnemies, numberedBase) end
        if numberedTank then table.insert(alianceEnemies, numberedTank) end
        if numberedKamikaze then table.insert(alianceEnemies, numberedKamikaze) end
    end
    
    return #alianceEnemies > 0
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