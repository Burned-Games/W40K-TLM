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

    support.wp1Transf = support.waypoint1:get_component("TransformComponent")
    support.wp2Transf = support.waypoint2:get_component("TransformComponent")
    support.wp3Transf = support.waypoint3:get_component("TransformComponent")

    support.currentTarget = nil



    local enemy_type = "support"
    support.level = 1

    local stats = stats_data[enemy_type] and stats_data[enemy_type][support.level]
    -- Debug in case is not working
    if not stats then
        log("No stats for type: " .. enemy_type .. " level: " .. support.level)
        return
    end



    -- Stats of the Support
    support.health = stats.health
    support.speed = stats.speed
    support.fleeSpeed = stats.fleeSpeed
    support.enemyShield = stats.enemyShield
    support.damage = stats.damage
    support.detectionRange = stats.detectionRange
    support.shieldRange = stats.shieldRange
    support.attackRange = stats.attackRange



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

    local closestUnshieldedEnemy = nil
    local minDistance = math.huge

    for _, distData in ipairs(enemies_distance()) do

        local hasShield = false
        for _, shieldData in ipairs(update_shield_status()) do
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
    
    if closestUnshieldedEnemy then
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
    
    
    local validTargets = {}
    for _, distData in ipairs(enemies_distance()) do
        local hasShield = false
        for _, shieldData in ipairs(update_shield_status()) do
            if shieldData.enemy and distData.enemy and shieldData.enemy.name == distData.enemy.name then
                hasShield = shieldData.haveShield
                break
            end
        end
        if not hasShield and distData.enemy then
            table.insert(validTargets, distData.enemy)
        end
    end


    -- Reset current target
    support.currentTarget = nil

    if #validTargets > 0 then
        -- Find max priority
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
                local dist = support:get_distance(support.enemyTransf.position, candidate.transform.position)
                if dist < closestDist then
                    closestDist = dist
                    support.currentTarget = candidate  -- Store the selected target
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
        
        if support:get_distance(support.enemyTransf.position, targetPos.position) <= support.shieldRange and support.canUseShield then
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

                support.currentTarget = nil
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

    if #support.Enemies > 0 then
        get_priority_enemy()
    end
    
    -- Aumentar el intervalo entre detecciones
    findEnemiesInterval = 4.0  -- Cambiado de 1.5 a 4.0 segundos
end

-- Nueva función que busca todas las entidades de un tipo específico
function find_all_entities_of_type(typeName, resultTable, scriptField)
    local suppPos = support.enemyTransf.position
    
    -- Obtener todas las entidades en la escena
    local all_entities = current_scene:get_all_entities()
    
    if not all_entities then
        log("No entities found in the scene")
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
                            name = typeName,
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

function find_all_Range()
    local enemyNames = {"EnemyRange"}
    local suppPos = support.enemyTransf.position

    for _, name in ipairs(enemyNames) do
        local entity = current_scene:get_entity_by_name(name)
        if entity then 
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")

            if entityTransform then
                local distance = support:get_distance(suppPos, entityTransform.position)

                if distance <= support.detectionRange then
                    local enemyScriptInstance = script.range
                    
                    local enemyData = {
                        name = name,
                        transform = entityTransform,
                        script = enemyScriptInstance,
                        health = enemyScriptInstance.health or 100,
                        priority = enemyScriptInstance.priority or 1,
                        haveShield = enemyScriptInstance.haveShield or false
                    }
                
                    table.insert(support.EnemyRange, enemyData)
                end
            end
        end
    end

    return support.EnemyRange
end

function find_all_Tank()
    local enemyNames = {"EnemyTank"}
    local suppPos = support.enemyTransf.position

    for _, name in ipairs(enemyNames) do
        local entity = current_scene:get_entity_by_name(name)
        if entity then
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")

            if entityTransform then
                local distance = support:get_distance(suppPos, entityTransform.position)

                if distance <= support.detectionRange then
                    local enemyScriptInstance = script.tank
                    
                    local enemyData = {
                        name = name,
                        transform = entityTransform,
                        script = enemyScriptInstance,
                        health = enemyScriptInstance.health or 275,
                        priority = enemyScriptInstance.priority or 2,
                        haveShield = enemyScriptInstance.haveShield or false
                    }
                
                    table.insert(support.EnemyTank, enemyData)
                end
            end
        end
    end

    return support.EnemyTank
end

function find_all_Kamikaze()
    local enemyNames = {"EnemyKamikaze"}
    local suppPos = support.enemyTransf.position

    for _, name in ipairs(enemyNames) do
        local entity = current_scene:get_entity_by_name(name)
        if entity then
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")

            if entityTransform then
                local distance = support:get_distance(suppPos, entityTransform.position)

                if distance <= support.detectionRange then
                    local enemyScriptInstance = script.kamikaze
                    
                    local enemyData = {
                        name = name,
                        transform = entityTransform,
                        script = enemyScriptInstance,
                        health = enemyScriptInstance.health,
                        priority = enemyScriptInstance.priority or 3,
                        haveShield = enemyScriptInstance.haveShield or false
                    }
                
                    table.insert(support.EnemyKamikaze, enemyData)
                end
            end
        end
    end
    
    return support.EnemyKamikaze
end

function get_priority_enemy()

    local priorityEnemy = {}

    for _, enemyData in ipairs(support.Enemies) do
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

    update_shield_status()  
    return distances

end

function update_shield_status()

    local shieldState = {}

    for _, enemyData in ipairs(support.Enemies) do
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

function create_new_shield(targetEnemy)
    if not targetEnemy then
        log("Error: No target enemy provided for shield")
        return nil
    end

    local newShield = current_scene:duplicate_entity(support.prefabShield)
    local shieldTransform = newShield:get_component("TransformComponent")
    local shieldScript = newShield:get_component("ScriptComponent")
    shieldTransform.scale = Vector3.new(1.3, 1.3, 1.3)

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