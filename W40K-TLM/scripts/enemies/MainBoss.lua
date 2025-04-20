local state = { Idle = 1, Move = 2, Attack = 3, Patrol = 4, Rage = 5 , Shield = 6 }
local currentState = state.Idle

local mainboss = nil
local bossTransf = nil
local bossAnimator = nil
local bossRigidbody = nil
local bossNavmesh = nil

local player = nil
local playerTransf = nil
local playerScript = nil

local waypoint1
local waypoint2
local waypoint3
local currentWaypoint = 1
local currentPathIndex = 1
local waypointPositions = {}

local phase1 = true
local phase2 = false

local fist1 = nil
local fist2 = nil
local fist3 = nil
local fist1Transform = nil
local fist2Transform = nil
local fist3Transform = nil
local fist1Collider = nil
local fist2Collider = nil
local fist3Collider = nil
local fist1Rb = nil
local fist2Rb = nil
local fist3Rb = nil
local fistsPositions = {}
local scalingFists = {}
local scalingLightning = {} 

local ultimate
local ultiTransf = nil
local ultiTimer = 0
local ultimateCollider = nil
local ultimateRb = nil
local ultimateAttackStartTime = 0
local isUltimateDamaging = false


local attackEndTime = 0 
local tpTimer = 0        
local shouldTeleport = false
local attacksToTeleport = {}

local lightning = nil
local lightningTransf = nil
local lightningCollider = nil
local lightningRb = nil

health = 1200
local bossMaxHealth = 1200
shieldHealth = 150
local bossDamage = 25
local moveSpeed = 5

local isAttacking = true
local attackRange = 5
local attackCooldown = 10
local attackTimer = 0

local shield = nil
local shieldTransf = nil
local shieldActive = false
local shieldCooldown = 30
local shieldTimer = 0

local isRaging = false
local rageAttackTimer = 0
local rageAttackCooldown = 10
local rageVulnerableTimer = 0

local damageInterval = 1.0  
local damageDuration = 3   
local isDamaging = false
local damageTimer = 0
local timeSinceLastDamage = 0
local damagePerSecond = 15
local isDead = false

local stateDelayTimer = 0
local stateDelayDuration = 1
local isStateDelaying = false
local globalTime = 0
local lightningAttackStartTime = 0
local isLightningDamaging = false

local invulnerability = 1.0
local timeSinceLastHit = 0.0

local winTimer = 0

function on_ready() 
    -- Get the main boss entity
    bossTransf = self:get_component("TransformComponent")
    bossAnimator = self:get_component("AnimatorComponent")
    bossRigidbody = self:get_component("RigidbodyComponent").rb
    bossNavmesh = self:get_component("NavigationAgentComponent")

    -- Get the player entity
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    ultimate = current_scene:get_entity_by_name("Ultimate")
    ultiTransf = ultimate:get_component("TransformComponent")
    ultimateCollider = ultimate:get_component("RigidbodyComponent")
    ultimateRb = ultimateCollider.rb

    ultimateRb:set_trigger(true)

    ultimateCollider:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            if isUltimateDamaging then
                make_damage()
            end
        end
    end)


    fist1 = current_scene:get_entity_by_name("Fist1")
    fist2 = current_scene:get_entity_by_name("Fist2")
    fist3 = current_scene:get_entity_by_name("Fist3")
    if fist1 and fist2 and fist3 then
        fist1Transform = fist1:get_component("TransformComponent")
        fist2Transform = fist2:get_component("TransformComponent")
        fist3Transform = fist3:get_component("TransformComponent")

        fist1Collider = fist1:get_component("RigidbodyComponent")
        fist2Collider = fist2:get_component("RigidbodyComponent")
        fist3Collider = fist3:get_component("RigidbodyComponent")

        fist1Rb = fist1Collider.rb
        fist2Rb = fist2Collider.rb
        fist3Rb = fist3Collider.rb

        fist1Rb:set_trigger(true)
        fist2Rb:set_trigger(true)
        fist3Rb:set_trigger(true)

        fist1Collider:on_collision_stay(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Player" or nameB == "Player" then
                make_damage()
            end
       end)
       fist2Collider:on_collision_stay(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Player" or nameB == "Player" then
                make_damage()
            end
       end)
       fist3Collider:on_collision_stay(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Player" or nameB == "Player" then
                make_damage()
            end
        end)
        
        if fist1Transform and fist2Transform and fist3Transform then
            fistsPositions[1] = fist1Transform.position
            fistsPositions[2] = fist2Transform.position
            fistsPositions[3] = fist3Transform.position
        end
    end

    lightning = current_scene:get_entity_by_name("Lightning")
    lightningTransf = lightning:get_component("TransformComponent")
    lightningCollider = lightning:get_component("RigidbodyComponent")
    lightningRb = lightningCollider.rb

    lightningRb:set_trigger(true)

    lightningCollider:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            if isLightningDamaging then
                make_damage()
            end
        end
    end)

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
    end

    shield = current_scene:get_entity_by_name("ShieldBoss")
    if shield then
        shieldTransf = shield:get_component("TransformComponent")
    end
    -- Forzar inicialización del primer waypoint
    currentWaypoint = 1
    update_waypoint_path()

    -- Set the initial state
    currentState = state.Patrol
end

-- FSM General
function on_update(dt)

    globalTime = globalTime + dt

    if isDead and winTimer >= 3 then
        --SceneManager.change_scene("levelWin.TeaScene")
    end

    if isDead then
        winTimer = winTimer + dt
        return
    end
    
    update_fist_scaling(dt)
    update_lightning_scaling(dt)

    if #scalingFists > 0 or #scalingLightning > 0 then
        bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
    end

    if health <= 480 then
        phase1 = false
        phase2 = true
    elseif health <= 0 then
        die()
    end

    update_state(dt)
    handle_attack_teleport(dt)

    ultiTimer = math.max(0, ultiTimer - dt)

    if globalTime - lightningAttackStartTime >= 2 then
        isLightningDamaging = true  
    else
        isLightningDamaging = false  
    end

    if globalTime - ultimateAttackStartTime >= 6 then
        isUltimateDamaging = true  
    else
        isUltimateDamaging = false  
    end

    if shieldActive then
        if shieldHealth <= 0 then
            shieldActive = false
        end
        move_shield()
    else
        shieldTimer = shieldTimer + dt
        if shieldTimer >= shieldCooldown then
            shieldHealth = 30
            shieldActive = true
            shieldTimer = 0
            currentState = state.Shield
        end
    end

    if not isAttacking then
        attackTimer = attackTimer + dt
        if attackTimer >= attackCooldown then
            isAttacking = true
        end
    end

    timeSinceLastHit = timeSinceLastHit + dt

    -- Ejecutar el estado principal
    if currentState == state.Idle then
        idle_state(dt)
    elseif currentState == state.Move then
        move_state(dt)
    elseif currentState == state.Patrol then
        patrol_state(dt)
    elseif currentState == state.Attack then
        attack_state(dt)
    elseif currentState == state.Rage and phase2 then
        rage_state(dt)
    elseif currentState == state.Shield then
        shield_state(dt)
    end

end

function update_state(dt)
    if isStateDelaying then
        stateDelayTimer = stateDelayTimer + dt
        if stateDelayTimer >= stateDelayDuration then
            isStateDelaying = false
            stateDelayTimer = 0
        else
            -- Durante el delay, el boss no se mueve
            if bossRigidbody then
                bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
            end
            return
        end
    end
    
    local distance = get_distance(bossTransf.position, playerTransf.position)

    -- if health <= bossMaxHealth * 0.4 and not isRaging then
    --     isRaging = true
    --     set_new_state(state.Rage)
    --     return
    -- end
    
    -- if isRaging then
    --     set_new_state(state.Rage)
    --     return
    -- end
    --print("updating")
    local attackDistance = 25  
    
    if isAttacking and distance <= attackDistance then
        set_new_state(state.Attack)
    else
        if isAttacking and distance > attackDistance then
            isAttacking = false  
            attackTimer = 0     
        end
        set_new_state(state.Patrol)
    end
end

function set_new_state(newState)
    if newState == state.Attack or newState == state.Shield or newState == state.Rage then
        isStateDelaying = true
        stateDelayTimer = 0
    end
    currentState = newState
end


function patrol_state(dt)
    if bossAnimator then
        if currentAnim ~= 2 then
            bossAnimator:set_current_animation(2)
            currentAnim = 2
        end
    end

    -- Get current waypoint
    local currentTarget = waypointPositions[currentWaypoint]
    
    -- Seguridad
    if not currentTarget then
        return
    end
    
    -- Update path to current waypoint if needed
    if not lastTargetPos or get_distance(lastTargetPos, currentTarget) > 1.0 then
        update_waypoint_path()
    end
    
    update_fist_scaling(dt)

    -- Follow the path
    follow_path(dt)
    
    -- Calculate distance to current waypoint
    local distance = get_distance(bossTransf.position, currentTarget)
    
    if distance <= 2.0 then
        currentWaypoint = currentWaypoint % #waypointPositions + 1
        update_waypoint_path()
    end
end

function update_waypoint_path()
    if bossNavmesh then
        local currentTarget = waypointPositions[currentWaypoint]
        
        -- Verificación de seguridad
        if not currentTarget then
            return
        end
        
        bossNavmesh.path = bossNavmesh:find_path(bossTransf.position, currentTarget)
        
        -- Verificar si se generó el path
        if not bossNavmesh.path or #bossNavmesh.path == 0 then
            return
        end
        
        lastTargetPos = currentTarget
        currentPathIndex = 1
    end
end

function follow_path(dt)
    -- Verificaciones de seguridad
    if bossNavmesh == nil or #bossNavmesh.path == 0 then 
        if bossRigidbody then
            bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
        end
        return 
    end
    
    -- Verificar índice de path
    if currentPathIndex > #bossNavmesh.path then
        currentPathIndex = 1
    end

    local nextPoint = bossNavmesh.path[currentPathIndex]

    local direction = Vector3.new(
        nextPoint.x - bossTransf.position.x,
        0, -- Ignoramos la Y para movimiento en plano
        nextPoint.z - bossTransf.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            0,
            direction.z / distance
        )

        -- Usar física para el movimiento
        if bossRigidbody then
            local velocity = Vector3.new(
                normalizedDirection.x * moveSpeed, 
                0, 
                normalizedDirection.z * moveSpeed
            )
            bossRigidbody:set_velocity(velocity)
        end

        rotate_enemy(nextPoint)
    else
        if currentPathIndex < #bossNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        else
            -- Llegamos al final del camino, detener movimiento
            if bossRigidbody then
                bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
            end
        end
    end
end
-- Funciones para los distintos estados.
function idle_state(dt) end

function shield_state(dt)

    if currentAnim ~= 3 then
        bossAnimator:set_current_animation(3)
        currentAnim = 3
    end

    bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
    shieldTransf.position = Vector3.new(bossTransf.position.x, bossTransf.position.y, bossTransf.position.z)
    shieldTransf.scale = Vector3.new(2.5, 2.5, 2.5)

    --log("Shield Health: " .. shieldHealth)
end

function move_shield()
    if shieldActive then
        shieldTransf.position = Vector3.new(bossTransf.position.x, bossTransf.position.y, bossTransf.position.z)
    else
        shieldTransf.position = Vector3.new(-500, 10, -200)
    end
end

function handle_attack_teleport(dt)
    for i = #attacksToTeleport, 1, -1 do
        local attack = attacksToTeleport[i]
        
        -- Si la animación del ataque terminó
        if globalTime >= attack.endTime then
            if not attack.teleportTimer then
                attack.teleportTimer = 0  -- Iniciar temporizador
            else
                attack.teleportTimer = attack.teleportTimer + dt
                
                -- Pasados 3 segundos, teletransportar
                if attack.teleportTimer >= 3 then
                    local rb = attack.entity:get_component("RigidbodyComponent").rb
                    rb:set_position(Vector3.new(-500, 0, -500))
                    table.remove(attacksToTeleport, i)
                end
            end
        end
    end
end

function move_state(dt) end

function attack_state(dt)
    if not isAttacking then
        return
    end

    local distance = get_distance(bossTransf.position, playerTransf.position)
    local attackChance = math.random()

    if attackChance < 0.3 then
        lightning_attack()
        fists_attack()
    elseif phase2 and ultiTimer <= 0 then 
        ulti_attack()
    else
        if distance <= 10 then
            lightning_attack()
        else
            fists_attack()
        end
    end

    isAttacking = false
    attackTimer = 0

end

function rage_state(dt)
    rageAttackTimer = rageAttackTimer + dt

    if rageAttackTimer >= rageAttackCooldown then
        rageAttackTimer = 0
        waaaagh_ray()
        rageVulnerableTimer = 5
    end

    if rageVulnerableTimer > 0 then
        rageVulnerableTimer = rageVulnerableTimer - dt
    end
end

function lightning_attack()
    local attackDuration = 7 
    attackEndTime = math.max(attackEndTime, globalTime + attackDuration)

    if lightningTransf and bossTransf and playerTransf then
        lightningRb:set_position(Vector3.new(bossTransf.position.x, bossTransf.position.y, bossTransf.position.z))
        bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
        lightningTransf.position = Vector3.new(
            bossTransf.position.x,
            bossTransf.position.y,
            bossTransf.position.z
        )

        local dx = playerTransf.position.x - bossTransf.position.x
        local dz = playerTransf.position.z - bossTransf.position.z

        local angle = math.deg(math.atan(dx, dz))

        if dz < 0 then
            angle = angle + 180
        end

        lightningTransf.rotation.y = angle

        lightningTransf.scale = Vector3.new(1, 1, 1)
        table.insert(scalingLightning, {
            transform = lightningTransf,
            elapsed = 0,
            duration = 7,
            startScale = Vector3.new(0.4, 1, 0.2),
            targetScale = Vector3.new(3, 1, 0.8) 
        })

        local attackDuration = 7  
        table.insert(attacksToTeleport, {
            entity = lightning,
            endTime = globalTime + attackDuration
        })

        lightningAttackStartTime = globalTime 
        isLightningDamaging = false
    end
end

function update_lightning_scaling(dt)
    for i = #scalingLightning, 1, -1 do
        local data = scalingLightning[i]
        data.elapsed = data.elapsed + dt

        if data.elapsed <= data.duration then
            local t = data.elapsed / data.duration
            local newScale = Vector3.new(
                data.startScale.x + (data.targetScale.x - data.startScale.x) * t,
                data.startScale.y + (data.targetScale.y - data.startScale.y) * t,
                data.startScale.z + (data.targetScale.z - data.startScale.z) * t
            )
            
            if data.transform then
                data.transform.scale = newScale
            end
        else
            if data.transform then
                data.transform.scale = data.targetScale
            end
            table.remove(scalingLightning, i)
        end
    end
end

function fists_attack()

    local playerPos = playerTransf.position
    bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
    -- Calculate positions around the player (equidistant points in a circle)
    local radius = 3.5  -- Distance from player
    local fistPositions = {
        Vector3.new(playerPos.x + radius, 0, playerPos.z),  -- Right
        Vector3.new(playerPos.x - radius/2, 0, playerPos.z + radius * 0.866),  -- Bottom left
        Vector3.new(playerPos.x - radius/2, 0, playerPos.z - radius * 0.866)   -- Top left
    }
    
    -- Set positions and prepare scaling for each fist
    local fistTransforms = {fist1Transform, fist2Transform, fist3Transform}
    local fistRbs = {fist1Rb, fist2Rb, fist3Rb}
    
    -- Clear previous scaling operations      
    scalingFists = {}
    
    for i = 1, 3 do
        if fistRbs[i] and fistTransforms[i] then
            -- Set initial position
            fistRbs[i]:set_position(fistPositions[i])
            
            -- Reset scale
            fistTransforms[i].scale = Vector3.new(1, 1, 1)
            
            -- Add to scaling list with reference to the specific fist transform
            table.insert(scalingFists, {
                transform = fistTransforms[i],
                elapsed = 0,
                duration = 3,
                startScale = Vector3.new(1, 1, 1),
                targetScale = Vector3.new(1.7, 1.7, 1.7)
            })
        end
    end

    local attackDuration = 3
    table.insert(attacksToTeleport, {
        entity = fist1,
        endTime = globalTime + attackDuration
    })
    table.insert(attacksToTeleport, {
        entity = fist2,
        endTime = globalTime + attackDuration
    })
    table.insert(attacksToTeleport, {
        entity = fist3,
        endTime = globalTime + attackDuration
    })
end

function update_fist_scaling(dt)
    for i = #scalingFists, 1, -1 do
        local data = scalingFists[i]
        data.elapsed = data.elapsed + dt

        if data.elapsed <= data.duration then
            -- Calculate scale based on elapsed time (linear interpolation)
            local t = data.elapsed / data.duration
            local newScale = Vector3.new(
                data.startScale.x + (data.targetScale.x - data.startScale.x) * t,
                data.startScale.y + (data.targetScale.y - data.startScale.y) * t,
                data.startScale.z + (data.targetScale.z - data.startScale.z) * t
            )
            
            -- Apply scale to the specific fist transform
            if data.transform then
                data.transform.scale = newScale
            end
        else
            -- Scaling complete, set to final scale
            if data.transform then
                data.transform.scale = data.targetScale
            end
            table.remove(scalingFists, i)
        end
    end
end

function ulti_attack()
    if currentAnim ~= 4 then
        bossAnimator:set_current_animation(4)
        currentAnim = 4
    end

    local playerPos = playerTransf.position
    bossRigidbody:set_velocity(Vector3.new(0, 0, 0))

    local radius = 3.5
    local ultiPosition = Vector3.new(
        playerPos.x - radius/2, 
        0, 
        playerPos.z + radius * 0.866
    )

    -- Actualizar posición del Transform y Rigidbody de la ultimate
    ultiTransf.position = ultiPosition
    ultimateRb:set_position(ultiPosition)  -- Usar set_position() del Rigidbody

    -- Configurar el escalado
    table.insert(scalingLightning, {
        transform = ultiTransf, 
        elapsed = 0,
        duration = 15,
        startScale = Vector3.new(1, 1, 1),
        targetScale = Vector3.new(20, 20, 20) 
    })

    -- Registrar para teletransporte después de 3s
    local attackDuration = 15  
    table.insert(attacksToTeleport, {
        entity = ultimate,
        endTime = globalTime + attackDuration
    })

    ultiTimer = 40
end

function make_damage()
    if timeSinceLastHit < invulnerability then
        return
    end

    if player ~= nil then
        if playerScript ~= nil then
            local damage = 10

            if playerScript.health > 0 then
                particle_spark_transform.position = playerScript.playerTransf.position
                particle_spark:emit(5) 
                playerScript.health = playerScript.health - damage
                print(playerScript.health)
                --log("PlayerHealth " .. playerScript.playerHealth)
            end

            --audioDanoPlayerMusic:pause()
            --audioDanoPlayerMusic:play()
            timeSinceLastHit = 0
        end
    end

end

function take_damage_boss(damage)

    if shieldHealth > 0 then
        shieldHealth = shieldHealth - (damage)
        print(shieldHealth)
    else
        health = health - damage
        print(health)
    end

    if health <= 0 then
        die()
    end

end


function waaaagh_ray()
    --log("Steel Claw desata el Rayo de Waaaagh!")
end

local currentRotationY = 0

function rotate_enemy(targetPosition)

	local dx = targetPosition.x - bossTransf.position.x
	local dz = targetPosition.z - bossTransf.position.z

    local targetAngle = math.deg(math.atan(dx / dz))
    if dz < 0 then
        targetAngle = targetAngle + 180
    end

    targetAngle = (targetAngle + 180) % 360 - 180
    local currentAngle = (currentRotationY + 180) % 360 - 180
    local deltaAngle = (targetAngle - currentAngle + 180) % 360 - 180

    currentRotationY = currentAngle + deltaAngle * 0.1
    bossTransf.rotation.y = currentRotationY

end

function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = 0 -- Ignore height difference for pathfinding
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function die()
    currentState = state.Idle
    bossRigidbody:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end