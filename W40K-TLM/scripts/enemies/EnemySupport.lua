local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")

support = enemy:new()

local shieldTimer = 0.0
local shieldCooldown = 5.0
local shieldAnimTimer = 0.0
local shieldAnimDuration = 3.0
local findEnemiesTimer = 0.0
local findEnemiesInterval = 1.5
local pathUpdateTimer = 0.0
local pathUpdateInterval = 1.0
local checkEnemyTimer = 0.0
local checkEnemyInterval = 40.0 

function on_ready() 

    support.LevelGeneratorByPosition = current_scene:get_entity_by_name("LevelGeneratorByPosition"):get_component("TransformComponent")

    support.player = current_scene:get_entity_by_name("Player")
    support.playerTransf = support.player:get_component("TransformComponent")
    support.playerScript = support.player:get_component("ScriptComponent")

    support.enemyTransf = self:get_component("TransformComponent")
    support.animator = self:get_component("AnimatorComponent")
    support.enemyRbComponent = self:get_component("RigidbodyComponent")
    support.enemyRb = support.enemyRbComponent.rb
    support.enemyNavmesh = self:get_component("NavigationAgentComponent")

    support.prefabShield = current_scene:get_entity_by_name("Shield")

    support.waypointsParent = current_scene:get_entity_by_name("WaypointsParent")

    support.scrap = current_scene:get_entity_by_name("Scrap")
    support.scrapTransf = support.scrap:get_component("TransformComponent")

    -- This needs to be done by code, to avoid problems with other support entities
    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "SuppWaypoint1" then
            support.waypoint1 = child
            child:set_parent(support.waypointsParent)
        elseif child:get_component("TagComponent").tag == "SuppWaypoint2" then
            support.waypoint2 = child
            child:set_parent(support.waypointsParent)
        elseif child:get_component("TagComponent").tag == "SuppWaypoint3" then
            support.waypoint3 = child
            child:set_parent(support.waypointsParent)
        end
    end

    set_Waypoints()

    support.currentTarget = nil

    local enemy_type = "support"
    support:set_level()

    local stats = stats_data[enemy_type] and stats_data[enemy_type][support.level]

    -- Stats of the Support
    support.health = stats.health
    support.speed = stats.speed
    support.fleeSpeed = stats.fleeSpeed
    support.enemyShield = stats.enemyShield
    support.damage = stats.damage
    support.detectionRange = stats.detectionRange
    support.shieldRange = stats.shieldRange
    support.attackRange = stats.attackRange

    -- Debug stats
    support.idleAnim = 0
    support.moveAnim = 0
    support.attackAnim = 0
    support.shieldAnim = 1
    support.dieAnim = 2

    support.state.Flee = 5
    support.state.Shield = 6

    support.currentWaypoint = 1

    support.shieldCooldownActive = false
    support.canUseShield = true
    support.allShielded = true

    support.lastTargetPos = Vector3.new(0, 0, 0)

    support.Enemies = {}
    support.waypointPos = {}

    support.waypointPos[1] = support.wp1Transf.position
    support.waypointPos[2] = support.wp2Transf.position
    support.waypointPos[3] = support.wp3Transf.position

end

function on_update(dt)

    if support.isDead then return end

    support:check_effects(dt)
    support:check_pushed(dt)
    if support.isPushed == true then
        return
    end
    change_state()

    findEnemiesTimer = findEnemiesTimer + dt

    if support.shieldCooldownActive then
        shieldTimer = shieldTimer + dt 
        if shieldTimer >= shieldCooldown then
            support.shieldCooldownActive = false
            support.canUseShield = true  
        end
    end

    if support.currentState == support.state.Idle then
        support:idle_state()
        return

    elseif support.currentState == support.state.Move then
        support:move_state(dt)

    elseif support.currentState == support.state.Attack then
        support:attack_state()

    elseif support.currentState == support.state.Flee then
        support:flee_state(dt)

    elseif support.currentState == support.state.Shield then
        support:shield_state(dt)
    end

end

function change_state()
    -- Resetear allShielded al inicio
    support.allShielded = true

    if findEnemiesTimer >= findEnemiesInterval then
        find_all_enemies()
        findEnemiesTimer = 0
    end

    if #support.Enemies == 0 then
        support.currentState = support.state.Flee
        return
    end

    for _, enemyData in ipairs(support.Enemies) do
        if not enemyData.haveShield then
            support.allShielded = false
            break
        end
    end
    
    if support.allShielded then
        support.currentState = support.state.Flee
        return
    end

    -- Obtener distancias una sola vez para eficiencia
    local enemyDistances = enemies_distance()
    
    -- Obtener estados de escudo una sola vez
    local shieldStates = update_shield_status()
    
    -- Crear una tabla para buscar rápidamente el estado del escudo
    local shieldLookup = {}
    for _, shield in ipairs(shieldStates) do
        shieldLookup[shield.enemy.name] = shield.haveShield
    end

    local closestUnshieldedEnemy = nil
    local minDistance = math.huge

    for _, distData in ipairs(enemyDistances) do
        local hasShield = shieldLookup[distData.enemy.name] or false
        if not hasShield and distData.distance < minDistance then
            minDistance = distData.distance
            closestUnshieldedEnemy = distData.enemy
        end
    end
    
    if closestUnshieldedEnemy then
        support.currentTarget = closestUnshieldedEnemy
        
        if minDistance <= support.shieldRange and support.canUseShield then
            support.currentState = support.state.Shield
        else
            support.currentState = support.state.Move
        end
    else
        support.currentState = support.state.Flee
    end
end

function support:move_state(dt)
    if support.currentAnim ~= support.moveAnim then
        support.currentAnim = support.moveAnim
        support.animator:set_current_animation(support.currentAnim)
    end 
        
    -- 1. Primero obtenemos todos los enemigos sin escudo
    local validTargets = {}
    for _, enemyData in ipairs(support.Enemies) do
        if not enemyData.haveShield then
            table.insert(validTargets, enemyData)
        end
    end
    
  
    if #validTargets == 0 then
        support.currentTarget = nil
        support.currentState = support.state.Flee
        return
    end

    if #validTargets > 0 then
        -- 2. Ordenamos los enemigos válidos por prioridad (de mayor a menor)
        table.sort(validTargets, function(a, b)
            return a.priority > b.priority
        end)
        
        -- 3. Tomamos los enemigos con la prioridad más alta
        local maxPriority = validTargets[1].priority
        local highestPriorityTargets = {}
        
        for _, enemy in ipairs(validTargets) do
            if enemy.priority == maxPriority then
                table.insert(highestPriorityTargets, enemy)
            end
        end
        
        -- 4. Entre los de máxima prioridad, elegimos el más cercano
        local previousTarget = support.currentTarget
        local closestDist = math.huge
        for _, candidate in ipairs(highestPriorityTargets) do
            if candidate.transform then
                local dist = support:get_distance(support.enemyTransf.position, candidate.transform.position)
                if dist < closestDist then
                    closestDist = dist
                    support.currentTarget = candidate
                end
            end
        end
    end
    
    -- Movement management
    if support.currentTarget and support.currentTarget.transform then
        local targetPos = support.currentTarget.transform
        
        pathUpdateTimer = pathUpdateTimer + dt
        if pathUpdateTimer >= pathUpdateInterval or not support.lastTargetPos or (support.lastTargetPos and support:get_distance(support.lastTargetPos, targetPos.position) > 1.0) then
            support:update_path(targetPos)
            support.lastTargetPos = targetPos.position
            pathUpdateTimer = 0
        end

        support:follow_path() 
        
        local stoppingDistance = support.shieldRange * 0.85  -- Ajusta si es necesario

        local currentDistance = support:get_distance(support.enemyTransf.position, targetPos.position)

        -- Si ya está suficientemente cerca, deja de moverse
        if currentDistance <= stoppingDistance then
            support.enemyRb:set_velocity(Vector3.new(0, 0, 0))  -- Stop movement
            return
        end

        -- Si está a distancia para escudo, lanza el escudo
        if currentDistance <= support.shieldRange and support.canUseShield then
            support.currentState = support.state.Shield
        end
    else
        support.currentState = support.state.Flee
    end
end

function support:shield_state(dt)
    if support.currentAnim ~= support.shieldAnim then
        support.currentAnim = support.shieldAnim
        support.animator:set_current_animation(support.currentAnim)
    end

    if not support.currentTarget or not support.currentTarget.transform then
        support.currentState = support.state.Move
        return
    end

    local targetPos = support.currentTarget.transform.position
    local distance = support:get_distance(support.enemyTransf.position, targetPos)

    support.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    shieldAnimTimer = shieldAnimTimer + dt 
    
    if shieldAnimTimer >= shieldAnimDuration then
        if distance <= support.shieldRange and not support.currentTarget.script.haveShield then
            local shieldEntity = create_new_shield(support.currentTarget)
            if shieldEntity then
                local shieldScript = shieldEntity:get_component("ScriptComponent")
                shieldScript.targetEnemy = support.currentTarget
                shieldScript.isActive = true

                support.currentTarget.script.shieldHealth = support.enemyShield
                support.currentTarget.script.haveShield = true
                support.canUseShield = false
                support.shieldCooldownActive = true  
                shieldTimer = 0 
                shieldAnimTimer = 0 

                -- Actualizamos el estado del enemigo en nuestra lista de enemigos
                for i, enemyData in ipairs(support.Enemies) do
                    if enemyData.name == support.currentTarget.name then
                        enemyData.haveShield = true
                        break
                    end
                end
            end
        end
    end

    support.currentState = support.state.Move
end

function support:flee_state(dt)

    if support.currentAnim ~= support.moveAnim then
        support.currentAnim = support.moveAnim
        support.animator:set_current_animation(support.currentAnim)
    end 

    support.currentTarget = support.waypointPos[support.currentWaypoint]
    
    if support:get_distance(support.lastTargetPos, support.currentTarget) > 1.0 then
        update_waypoint_path()
    end

    support:follow_path()

    local distance = support:get_distance(support.enemyTransf.position, support.currentTarget)

    if distance <= 1.0 then
        support.currentWaypoint = support.currentWaypoint % #support.waypointPos + 1
        support.currentTarget = support.waypointPos[support.currentWaypoint]
        update_waypoint_path()
    end

    checkEnemyTimer = checkEnemyTimer + dt
    if checkEnemyTimer >= checkEnemyInterval then
        checkEnemyTimer = 0
        
        -- Update the enemy list when the support is on flee state
        find_all_enemies()
        
        local allEnemiesWithShield = true
        
        -- Check if all enemies have shields
        for _, shieldData in ipairs(update_shield_status()) do
            if not shieldData.haveShield then
                allEnemiesWithShield = false
                break
            end
        end
        
        -- If not all enemies have shields, we can move
        if not allEnemiesWithShield then
            support.currentState = support.state.Move
        end
    end

end

function set_Waypoints()
    -- Obtener componentes Transform de los waypoints
    support.wp1Transf = support.waypoint1:get_component("TransformComponent")
    support.wp2Transf = support.waypoint2:get_component("TransformComponent")
    support.wp3Transf = support.waypoint3:get_component("TransformComponent")

    local suppPos = support.enemyTransf.position
    local radius = 8.0  -- Radio alrededor del support
    
    -- Generar posiciones aleatorias para cada waypoint
    local waypointTransforms = {
        support.wp1Transf,
        support.wp2Transf,
        support.wp3Transf
    }

    for _, wpTransf in ipairs(waypointTransforms) do
        -- Generar ángulo aleatorio en radianes (0 a 2π)
        local randomAngle = math.random() * 2 * math.pi
        
        -- Calcular posición alrededor del support
        local x = suppPos.x + radius * math.cos(randomAngle)
        local z = suppPos.z + radius * math.sin(randomAngle)
        local newPos = Vector3.new(x, 0, z)
        
        -- Asignar nueva posición al waypoint (CORRECCIÓN AQUÍ)
        wpTransf.position = newPos  -- Asignación directa en lugar de método
    end
end

function find_all_enemies()
    -- Reset all enemy tables
    support.EnemyRange = {}
    support.EnemyTank = {}
    support.EnemyKamikaze = {}
    support.Enemies = {}
    
    -- Find all enemies of each type
    find_all_entities_of_type("EnemyRange", support.EnemyRange, "range")
    find_all_entities_of_type("EnemyTank", support.EnemyTank, "tank")
    find_all_entities_of_type("EnemyKamikaze", support.EnemyKamikaze, "kamikaze")
    
    -- Combine all enemy types into the main Enemies table
    for _, enemy in ipairs(support.EnemyRange) do
        table.insert(support.Enemies, enemy)
    end
    
    for _, enemy in ipairs(support.EnemyTank) do
        table.insert(support.Enemies, enemy)
    end
    
    for _, enemy in ipairs(support.EnemyKamikaze) do
        table.insert(support.Enemies, enemy)
    end
    
    -- Asegurar que la información de escudos está actualizada
    update_shield_status()
    
    -- Aumentar el intervalo entre detecciones
    findEnemiesInterval = 4.0
end

function find_all_entities_of_type(typeName, resultTable, scriptField)
    local suppPos = support.enemyTransf.position
    
    -- Obtener todas las entidades en la escena
    local all_entities = current_scene:get_all_entities()
    
    if not all_entities then
        return resultTable
    end
    
    local count = 0
    
    -- Iterar a través de todas las entidades
    for _, entity in ipairs(all_entities) do
        -- Comprobar si esta entidad tiene el nombre o tag correcto
        local tag = entity:get_component("TagComponent")
        local name = entity:get_component("TagComponent").tag
        
        if name == typeName or (tag and tag.tag == typeName) then
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")
            
            if entityTransform and script then
                local distance = support:get_distance(suppPos, entityTransform.position)
                
                if distance <= support.detectionRange then
                    local enemyScriptInstance = nil
                    
                    if scriptField == "range" then
                        enemyScriptInstance = script.range
                    elseif scriptField == "tank" then
                        enemyScriptInstance = script.tank
                    elseif scriptField == "kamikaze" then
                        enemyScriptInstance = script.kamikaze
                    end
                    
                    if enemyScriptInstance then
                        local enemyData = {
                            name = typeName .. "_" .. count,  -- Añadir un índice para diferenciar
                            transform = entityTransform,
                            script = enemyScriptInstance,
                            health = enemyScriptInstance.health or (scriptField == "tank" and 275 or 100),
                            priority = enemyScriptInstance.priority or (scriptField == "kamikaze" and 3 or (scriptField == "tank" and 2 or 1)),
                            haveShield = enemyScriptInstance.haveShield or false
                        }
                        
                        table.insert(resultTable, enemyData)
                        count = count + 1
                    end
                end
            end
        end
    end
    return resultTable
end

function get_priority_enemy()
    local priorityEnemies = {}
    
    -- Obtener prioridades y enemigos
    for _, enemyData in ipairs(support.Enemies) do
        if enemyData.priority then
            table.insert(priorityEnemies, {
                enemy = enemyData,
                priority = enemyData.priority
            })
        end
    end
    
    -- Ordenar descendientemente por prioridad (mayor primero)
    table.sort(priorityEnemies, function(a, b)
        return a.priority > b.priority
    end)
    enemies_distance()
    return priorityEnemies
end

function enemies_distance()
    local distances = {}
    local suppPos = support.enemyTransf.position
    
    for _, enemyData in ipairs(support.Enemies) do
        if enemyData.transform then
            local enemyPos = enemyData.transform.position
            local dist = support:get_distance(suppPos, enemyPos)
            table.insert(distances, {
                enemy = enemyData,
                distance = dist
            })
        end
    end

    return distances
end

function update_shield_status()
    local shieldState = {}
    
    for _, enemyData in ipairs(support.Enemies) do
        table.insert(shieldState, {
            enemy = enemyData,
            haveShield = enemyData.haveShield or false
        })
    end

    return shieldState
end

function create_new_shield(targetEnemy)
    if not targetEnemy then
        log("Error: No target enemy provided for shield")
        return nil
    end

    local newShield = current_scene:duplicate_entity(support.prefabShield)
    local shieldTransform = newShield:get_component("TransformComponent")
    local shieldScript = newShield:get_component("ScriptComponent")
    shieldTransform.scale = Vector3.new(1.8, 1.8, 1.8)
    
    return newShield
end

function update_waypoint_path()
    
    if #support.waypointPos > 0 then
        local targetPos = support.waypointPos[support.currentWaypoint]
        support.enemyNavmesh.path = support.enemyNavmesh:find_path(support.enemyTransf.position, targetPos)
        support.lastTargetPos = targetPos
        support.currentPathIndex = 1
    end

end

function on_exit() end