local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

support = enemy:new()

local prefab_path = "prefabs/Misc/Shield.prefab"

function on_ready() 
    -- Scene
    support.sceneName = SceneManager:get_scene_name()

    -- Enemy
    support.enemyTransf = self:get_component("TransformComponent")
    support.animator = self:get_component("AnimatorComponent")
    support.enemyRbComponent = self:get_component("RigidbodyComponent")
    support.enemyRb = support.enemyRbComponent.rb
    support.enemyNavmesh = self:get_component("NavigationAgentComponent")

    -- Player
    support.player = current_scene:get_entity_by_name("Player")
    support.playerTransf = support.player:get_component("TransformComponent")
    support.playerScript = support.player:get_component("ScriptComponent")
    for i = 1, 11 do
        support.playerObjects[i] = current_scene:get_entity_by_name(support.playerObjectsTagList[i]):get_component("TransformComponent")
    end

    -- Shield
    --support.prefabShield = current_scene:get_entity_by_name("Shield")


    -- Target
    support.currentTarget = nil

    -- Audio 
    support.attackSFX = current_scene:get_entity_by_name("SupportAttackSFX"):get_component("AudioSourceComponent")
    support.hurtSFX = current_scene:get_entity_by_name("SupportHurtSFX"):get_component("AudioSourceComponent")
    support.shieldExplosionSFX = current_scene:get_entity_by_name("SupportShieldExplosionSFX"):get_component("AudioSourceComponent")
    support.shieldZapsSFX = current_scene:get_entity_by_name("SupportShieldZapsSFX"):get_component("AudioSourceComponent")
    support.shieldAssignSFX = current_scene:get_entity_by_name("SupportShieldAssignSFX"):get_component("AudioSourceComponent")
    support.dyingSFX = current_scene:get_entity_by_name("SupportDeadSFX"):get_component("AudioSourceComponent")
    support.supportShotSFX = current_scene:get_entity_by_name("SupportShotSFX"):get_component("AudioSourceComponent")
    
    -- Particles
    support.particleSpark = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    support.particleSparkTransf = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")

    -- Level
    support.enemyType = "support"
    support:set_level()

    local stats = stats_data[support.enemyType] and stats_data[support.enemyType][support.level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. support.enemyType .. " level: " .. support.level) return end

    -- State
    support.state = {Dead = 1, Idle = 2, Move = 3, Attack = 4, Shoot = 5, Shield = 6}

    -- Stats of the Support
    support.health = stats.health
    support.defaultHealth = support.health
    support.speed = stats.speed
    support.defaultSpeed = support.speed
    support.enemyShield = stats.enemyShield
    support.damage = stats.damage
    support.detectionRange = stats.detectionRange
    support.shieldRange = stats.shieldRange
    support.attackRange = stats.attackRange
    support.rangeAttackRange = stats.rangeAttackRange
    support.supportDamage = stats.supportDamage 
    support.bulletSpeed = stats.bulletSpeed

    -- External Timers
    support.shieldCooldown = 5.0
    support.checkEnemyInterval = 40.0
    support.maxBurstShots = stats.maxBurstShots 
    support.timeBetweenBursts = stats.timeBetweenBursts
    support.burstCooldown = stats.burstCooldown 

    -- Internal Timers
    support.shieldTimer = 0.0
    support.shieldAnimTimer = 0.0
    support.shieldAnimDuration = 3.4
    support.attackAnimTimer = 0.0
    support.attackAnimDuration = 5.0
    support.findEnemiesTimer = 0.0
    support.findEnemiesInterval = 1.5
    support.pathUpdateTimer = 0.0
    support.pathUpdateInterval = 1.0
    support.checkEnemyTimer = 0.0
    support.timeSinceLastShot = 0.0
    support.burstCooldownTimer = 0.0
    support.updateTargetTimer = 0.0
    support.updateTargetInterval = 0.5

    -- Animation
    support.idleAnim = 3
    support.moveAnim = 6
    support.attackAnim = 0
    support.shieldAnim = 4
    support.dieAnim = 1
    support.hitAnim = 2
    support.stunAnim = 5

    -- Bools
    support.shieldCooldownActive = false
    support.canUseShield = true
    support.allShielded = true
    support.isShootingBurst = false

    -- Ints
    support.currentWaypoint = 1
    support.burstCount = 0
    support.currentBulletIndex = 1
    support.key = 0

    -- Floats
    support.alertDistance = 2.5

    -- Lists
    support.Enemies = {}
    support.waypointPos = {}
    support.bulletPool = {}
    support.bulletTimers = {}

    -- Create bullet pool
    for i = 1, 5 do
        local bulletEntity = current_scene:get_entity_by_name("SupportBullet" .. i)
        
        local bullet = {
            entity = bulletEntity,
            transform = bulletEntity:get_component("TransformComponent"),
            rbComponent = bulletEntity:get_component("RigidbodyComponent"),
            active = false
        }
        
        bullet.rb = bullet.rbComponent.rb
        bullet.rb:set_trigger(true)
        bullet.rb:set_position(Vector3.new(0, -5, 0))
        
        support.bulletPool[i] = bullet
        support.bulletTimers[i] = 0
    end

    -- Positions
    support.lastTargetPos = Vector3.new(0, 0, 0)
    support.waypointPos[1] = support.wp1Transf.position
    support.waypointPos[2] = support.wp2Transf.position
    support.waypointPos[3] = support.wp3Transf.position
    support.delayedPlayerPos = support.playerTransf.position
    support.bulletLifetime = 5.0
end

function on_update(dt)
    if support.zoneSet ~= true then
        support:check_spawn()
        support.zoneSet = true
    end

    if support.isDead then return end

    support:check_effects(dt)
    support:check_pushed(dt)
    if support.isPushed == true then
        return
    end
    if support.isGranadePushed then return end
    
    update_bullets(dt)
    change_state()

    support.findEnemiesTimer = support.findEnemiesTimer + dt
    support.updateTargetTimer = support.updateTargetTimer + dt

    if support.updateTargetTimer >= support.updateTargetInterval then
        support.delayedPlayerPos = Vector3.new(support.playerTransf.position.x, support.playerTransf.position.y, support.playerTransf.position.z)
        support.updateTargetTimer = 0
    end

    if support.shieldCooldownActive then
        support.shieldTimer = support.shieldTimer + dt 
        if support.shieldTimer >= support.shieldCooldown then
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

    elseif support.currentState == support.state.Shoot then
        support:shoot_state(dt)

    elseif support.currentState == support.state.Shield then
        support:shield_state(dt)
    end
end

-- Function to check shield status of all enemies
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

function change_state()
    support.allShielded = true

    local distanceToPlayer = support:get_distance(support.enemyTransf.position, support.playerTransf.position)
    
    if distanceToPlayer > 35 then   
        support.currentState = support.state.Idle
        return
    end

    if support.findEnemiesTimer >= support.findEnemiesInterval then
        find_all_enemies()
        support.findEnemiesTimer = 0
    end

    if #support.Enemies == 0 then
        support.currentState = support.state.Shoot
        return
    end

    local filteredEnemies = {}
    local suppPos = support.enemyTransf.position

    for _, enemy in ipairs(support.Enemies) do
        if enemy.transform then
            local dist = support:get_distance(suppPos, enemy.transform.position)
            if dist <= 20 then
                table.insert(filteredEnemies, enemy)
                if not enemy.haveShield then
                    support.allShielded = false
                end
            end
        end
    end

    support.Enemies = filteredEnemies

    if #support.Enemies == 0 or support.allShielded then
        support.currentState = support.state.Shoot
        return
    end

    local distances = enemies_distance()
    local shieldStates = update_shield_status()
    local shieldLookup = {}
    for _, s in ipairs(shieldStates) do
        shieldLookup[s.enemy.name] = s.haveShield
    end

    local closest, minD = nil, math.huge
    for _, d in ipairs(distances) do
        if not shieldLookup[d.enemy.name] and d.distance < minD then
            minD = d.distance
            closest = d.enemy
        end
    end

    support.currentTarget = closest
    if closest then
        if minD <= support.shieldRange and support.canUseShield then
            support.currentState = support.state.Shield
        else
            support.currentState = support.state.Move
        end
    else
        support.currentState = support.state.Shoot
    end
end

function support:move_state(dt)
    if support.currentAnim ~= support.moveAnim then
        support.currentAnim = support.moveAnim
        support.animator:set_current_animation(support.currentAnim)
    end 
    
    local validTargets = {}
    for _, enemyData in ipairs(support.Enemies) do
        if not enemyData.haveShield then
            table.insert(validTargets, enemyData)
        end
    end
    
    if #validTargets == 0 then
        support.currentTarget = nil
        support.currentState = support.state.Shoot
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
        
        support.pathUpdateTimer = support.pathUpdateTimer + dt
        if support.pathUpdateTimer >= support.pathUpdateInterval or not support.lastTargetPos or (support.lastTargetPos and support:get_distance(support.lastTargetPos, targetPos.position) > 1.0) then
            support:update_path(targetPos)
            support.lastTargetPos = targetPos.position
            support.pathUpdateTimer = 0.0
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
        support.currentState = support.state.Shoot
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
    support.shieldAnimTimer = support.shieldAnimTimer + dt 
    
    if support.shieldAnimTimer >= support.shieldAnimDuration then
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
                support.shieldTimer = 0  
                support.shieldAnimTimer = 0  
                support.shieldAssignSFX:play()

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

function support:shoot_state(dt)

    -- Turn towards player
    support:rotate_enemy(support.playerTransf.position)
    support.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    -- Shoot in bursts
    local shouldTargetExplosive = false
    if support.explosiveDetected then
        local playerToExplosive = support:get_distance(support.playerTransf.position, support.explosiveTransf.position)
        if playerToExplosive <= 5.0 then
            shouldTargetExplosive = true
        end
    end

    if support.currentAnim ~= support.attackAnim then
        support.currentAnim = support.attackAnim
        support.animator:set_current_animation(support.currentAnim)
    end

    support.attackAnimTimer = support.attackAnimTimer + dt 
    
    if support.attackAnimTimer >= support.attackAnimDuration then
        if support.isShootingBurst then

            support.timeSinceLastShot = support.timeSinceLastShot + dt

            if support.timeSinceLastShot >= support.burstCooldown and support.burstCount < support.maxBurstShots then
                shoot_projectile(shouldTargetExplosive)
                support.burstCount = support.burstCount + 1
                support.timeSinceLastShot = 0
                --support.supportShotSFX:play()

                if support.burstCount >= support.maxBurstShots then
                    support.isShootingBurst = false
                    support.burstCooldownTimer = 0
                end
            end
        else
            if support.currentAnim ~= support.idleAnim then
                support.currentAnim = support.idleAnim
                support.animator:set_current_animation(support.currentAnim)
            end

            support.burstCooldownTimer = support.burstCooldownTimer + dt

            if support.burstCooldownTimer >= support.timeBetweenBursts then
                support.isShootingBurst = true
                support.burstCount = 0
                support.timeSinceLastShot = 0
            end
        end
    end
    -- Periodic enemy check
    support.checkEnemyTimer = support.checkEnemyTimer + dt
    if support.checkEnemyTimer >= support.checkEnemyInterval then
        support.checkEnemyTimer = 0
        
        -- Update the enemy list
        find_all_enemies()
        
        local allEnemiesWithShield = true
        
        -- Check if all enemies have shields
        local shieldStatus = update_shield_status()
        for _, shieldData in ipairs(shieldStatus) do
            if not shieldData.haveShield then
                allEnemiesWithShield = false
                break
            end
        end
        
        -- If not all enemies have shields and can use shield, change to move state
        if not allEnemiesWithShield and support.canUseShield then
            support.currentState = support.state.Move
        end
    end
end


function update_bullets(dt)
    for i, bullet in ipairs(support.bulletPool) do
        if bullet and bullet.active then
            support.bulletTimers[i] = support.bulletTimers[i] + dt
            if support.bulletTimers[i] >= support.bulletLifetime then
                deactivate_bullet(i)
            end
        end
    end
end

function deactivate_bullet(index)
    local bullet = support.bulletPool[index]
    
    bullet.active = false

    bullet.rb:set_position(Vector3.new(0, 0, 0))
    bullet.rb:set_velocity(Vector3.new(0, 0, 0))

    support.bulletTimers[index] = 0
end

function shoot_projectile(targetExplosive)

    local bullet = support.bulletPool[support.currentBulletIndex]
    
    local startPos = Vector3.new(
        support.enemyTransf.position.x - 1,
        support.enemyTransf.position.y + 0.982,
        support.enemyTransf.position.z - 0.1
    )
    bullet.rb:set_position(startPos)
    
    -- Target position
    local targetPos = support.delayedPlayerPos -- Default to player
    if targetExplosive and support.explosiveDetected and support.level == 2 then -- Switch to explosive if detected
        targetPos = support.explosiveTransf.position 
    end

    -- Calculate normalized direction
    local dx = targetPos.x - startPos.x
    local dz = targetPos.z - startPos.z
    
    -- Set velocity and activate bullet
    bullet.rb:set_velocity(Vector3.new(
        dx * support.bulletSpeed,
        0,
        dz * support.bulletSpeed
    ))
    bullet.active = true
    support.bulletTimers[support.currentBulletIndex] = 0

    -- Collision handling for current bullet
    bullet.rbComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            support.particleSparkTransf.position = support.playerTransf.position
            support.particleSpark:emit(5) 
            support:make_damage(support.supportDamage) 
        end
        
        deactivate_bullet(support.currentBulletIndex)
    end)

    -- Update bullet index
    support.currentBulletIndex = support.currentBulletIndex + 1
    if support.currentBulletIndex > 5 then
        support.currentBulletIndex = 1
    end

end

function set_waypoints()
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
        
        -- Asignar nueva posición al waypoint
        wpTransf.position = newPos
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
    
    -- Aumentar el intervalo entre detecciones
    support.findEnemiesInterval = 4.0
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
    
    
    for _, enemyData in ipairs(support.Enemies) do
        if enemyData.priority then
            table.insert(priorityEnemies, {
                enemy = enemyData,
                priority = enemyData.priority
            })
        end
    end
    
    
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

function create_new_shield(targetEnemy)
    if not targetEnemy or not targetEnemy.transform then
        log("Error: No se proporcionó un enemigo válido para el escudo")
        return nil
    end

    local pos = targetEnemy.transform.position

    local transform = Mat4.identity():translate(pos)
  
    local newShield = instantiate_prefab(prefab_path, transform)
    if not newShield or not newShield:is_valid() then
        log("Error: instantiate_prefab falló al crear el escudo")
        return nil
    end

    local shieldTransf = newShield:get_component("TransformComponent")
    shieldTransf.scale = Vector3.new(2.5, 2.5, 2.5)

    return newShield
end

function on_exit() end