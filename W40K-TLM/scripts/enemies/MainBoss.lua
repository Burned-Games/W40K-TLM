local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

main_boss = enemy:new()

local stats = nil



function on_ready()

    -- Enemy
    main_boss.enemyTransf = self:get_component("TransformComponent")
    main_boss.animator = self:get_component("AnimatorComponent")
    main_boss.enemyRbComponent = self:get_component("RigidbodyComponent")
    main_boss.enemyRb = main_boss.enemyRbComponent.rb
    main_boss.enemyNavmesh = self:get_component("NavigationAgentComponent")

    -- Player
    main_boss.player = current_scene:get_entity_by_name("Player")
    main_boss.playerTransf = main_boss.player:get_component("TransformComponent")
    main_boss.playerScript = main_boss.player:get_component("ScriptComponent")

    -- Shield
    main_boss.shield = current_scene:get_entity_by_name("Shield")
    main_boss.shieldTransf = main_boss.shield:get_component("TransformComponent")

    -- Wrath
    main_boss.wrath = current_scene:get_entity_by_name("Wrath")
    main_boss.wrathTransf = main_boss.wrath:get_component("TransformComponent")
    main_boss.wrathRbComponent = main_boss.wrath:get_component("RigidbodyComponent")
    main_boss.wrathRb = main_boss.wrathRbComponent.rb
    main_boss.wrathRb:set_trigger(true)

    -- Fists
    main_boss.fistTransf = {}
    main_boss.fistRbComponent = {}
    main_boss.fistRbs = {}
    for i = 1, 3 do
        local fistEntity = current_scene:get_entity_by_name("Fist" .. i)

        main_boss.fistTransf[i] = fistEntity:get_component("TransformComponent")
        main_boss.fistRbComponent[i] = fistEntity:get_component("RigidbodyComponent")
        main_boss.fistRbs[i] = main_boss.fistRbComponent[i].rb
        main_boss.fistRbs[i]:set_trigger(true)
    end

    -- Lightning
    main_boss.lightning = current_scene:get_entity_by_name("Lightning")
    main_boss.lightningTransf = main_boss.lightning:get_component("TransformComponent")
    main_boss.lightningRbComponent = main_boss.lightning:get_component("RigidbodyComponent")
    main_boss.lightningRb = main_boss.lightningRbComponent.rb
    main_boss.lightningRb:set_trigger(true)

    -- Ultimate
    main_boss.ultimate = current_scene:get_entity_by_name("Ultimate")
    main_boss.ultimateTransf = main_boss.ultimate:get_component("TransformComponent")

    -- Arena
    main_boss.arena = current_scene:get_entity_by_name("ArenaCenter")
    main_boss.arenaTrasnf = main_boss.arena:get_component("TransformComponent")

    -- Pilar
    main_boss.pillarToDestroy = nil

    -- Attack lists
    main_boss.scalingAttacks = {}
    main_boss.attacksToTeleport = {}



    -- Level
    main_boss.enemy_type = "main_boss"
    stats = stats_data[main_boss.enemy_type] and stats_data[main_boss.enemy_type][main_boss.level]
    -- Debug in case is not working
    if not stats then
        log("No stats for type: " .. main_boss.enemy_type .. " level: " .. main_boss.level)
        return
    end



    -- States
    main_boss.state = {Dead = 1, Idle = 2, Move = 3, Attack = 4, Shield = 5, Rage = 6}

    -- Stats of the Main Boss
    main_boss.health = stats.health
    main_boss.rageHealth = stats.rageHealth
    main_boss.bossShieldHealth = stats.bossShieldHealth
    main_boss.speed = stats.speed
    main_boss.meleeDamage = stats.meleeDamage
    main_boss.rangeDamage = stats.rangeDamage
    main_boss.detectionRange = stats.detectionRange
    main_boss.meleeAttackRange = stats.meleeAttackRange
    main_boss.rangeAttackRange = stats.rangeAttackRange

    -- External Timers
    main_boss.attackCooldown = stats.attackCooldown
    main_boss.meleeAttackDuration = stats.meleeAttackDuration
    main_boss.lightningDuration = stats.lightningDuration
    main_boss.rangeAttackDuration = stats.rangeAttackDuration
    main_boss.fistsDamageCooldown = stats.fistsDamageCooldown
    main_boss.shieldCooldown = stats.shieldCooldown

    -- Internal Timers
    main_boss.pathUpdateTimer = 0.0
    main_boss.pathUpdateInterval = 0.1
    main_boss.attackTimer = 0.0
    main_boss.meleeAttackTimer = 0.0
    main_boss.lightningTimer = 0.0
    main_boss.rangeAttackTimer = 0.0
    main_boss.timeSinceLastFistHit = 0.0
    main_boss.shieldTimer = 0.0
    main_boss.ultiTimer = 0.0
    main_boss.ultiAttackTimer = 0.0
    main_boss.ultiHittingTimer = 0.0
    main_boss.totemTimer = 0.0

    -- Provisional Timers
    main_boss.ultiTimer = 0.0
    main_boss.ultiCooldown = 10.0

    -- Animations
    main_boss.idleAnim = 0
    main_boss.moveAnim = 2
    main_boss.attackAnim = 3
    main_boss.shieldAnim = 3
    main_boss.rageAnim = 3
    main_boss.ultiAnim = 4

    -- Bools
    main_boss.isRaging = false
    main_boss.isAttacking = false
    main_boss.lightningThrown = false
    main_boss.isLightningDamaging = false
    main_boss.hasDealtLightningDamage = false
    main_boss.fistsThrown = false
    main_boss.isFistsDamaging = true
    main_boss.ultimateThrown = false
    main_boss.ultimateCasting = false
    main_boss.isUltimateDamaging = false
    main_boss.shieldActive = false
    main_boss.hasMovedToCenter = false
    main_boss.isReturning = false

    -- Positions
    main_boss.lastTargetPos = main_boss.playerTransf.position

    main_boss.arenaCenter = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)

    -- On Collision functions
    main_boss.wrathRbComponent:on_collision_stay(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            if not main_boss.playerScript.isNeuralInhibitioning then
                main_boss.playerScript.isNeuralInhibitioning = true
            end
        end
    end)

    main_boss.lightningRbComponent:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" and main_boss.isLightningDamaging then
            if not main_boss.hasDealtLightningDamage then
                main_boss:make_damage(main_boss.meleeDamage)
                main_boss.hasDealtLightningDamage = true
            end
        end
    end)

    for i = 1, 3 do
        main_boss.fistRbComponent[i]:on_collision_stay(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Player" or nameB == "Player" and main_boss.isFistsDamaging then
                main_boss:make_damage(main_boss.rangeDamage)
                main_boss.isFistsDamaging = false
            end
        end)
    end

end

function on_update(dt)

    if main_boss.isDead then return end

    main_boss:check_effects(dt)

    change_state()

    if main_boss.currentState == main_boss.state.Idle then return end

    if main_boss.health <= 0 then
        main_boss:die_state()
    end

    main_boss.attackTimer = main_boss.attackTimer + dt
    main_boss.shieldTimer = main_boss.shieldTimer + dt
    main_boss.pathUpdateTimer = main_boss.pathUpdateTimer + dt

    if main_boss.isRaging then
        main_boss.ultiTimer = main_boss.ultiTimer + dt
        main_boss.totemTimer = main_boss.totemTimer + dt
    end

    if main_boss.isReturning and not main_boss.hasMovedToCenter then
        if main_boss:get_distance(main_boss.enemyTransf.position, main_boss.arenaTrasnf.position) < 0.5 then
            main_boss.hasMovedToCenter = true
            main_boss.currentState = main_boss.state.Rage
        end
    end

    if main_boss.ultimateThrown then
        main_boss.ultiAttackTimer = main_boss.ultiAttackTimer + dt

        if main_boss.ultiAttackTimer >= main_boss.ultiAttackDuration then
            main_boss.ultimateCasting = true
        end

        if main_boss.ultimateCasting then
            if not main_boss.isUltimateDamaging then
                main_boss.isUltimateDamaging = true
            end

            main_boss.ultiHittingTimer = main_boss.ultiHittingTimer + dt

            check_ulti_collision()
            if main_boss.ultiHittingTimer >= main_boss.ultiHittingDuration then
                main_boss.ultimateTransf.position = Vector3.new(-500, 0, -150)

                main_boss.ultimateThrown = false
                main_boss.ultimateCasting = false
                main_boss.isUltimateDamaging = false
                main_boss.ultiAttackTimer = 0.0
                main_boss.ultiHittingTimer = 0.0
                main_boss.ultiTimer = 0.0

                check_ulti_collision()

                if main_boss.pillarToDestroy ~= nil then
                    manage_destroyed_pillar()
                end
            end
        end
    end

    if main_boss.fistsThrown then
        main_boss.rangeAttackTimer = main_boss.rangeAttackTimer + dt

        if not main_boss.isFistsDamaging then
            main_boss.timeSinceLastFistHit = main_boss.timeSinceLastFistHit + dt
            if main_boss.timeSinceLastFistHit > main_boss.fistsDamageCooldown then
                main_boss.isFistsDamaging = true
                main_boss.timeSinceLastFistHit = 0.0
            end
        elseif main_boss.rangeAttackTimer >= main_boss.rangeAttackDuration then
            -- Send them back
            main_boss.fistRbs[1]:set_position(Vector3.new(-500, 0, -150))
            main_boss.fistRbs[2]:set_position(Vector3.new(-500, 0, -150))
            main_boss.fistRbs[3]:set_position(Vector3.new(-500, 0, -150))

            main_boss.fistsThrown = false
        end
    end

    if main_boss.lightningThrown then
        if not main_boss.isLightningDamaging then
            main_boss.meleeAttackTimer = main_boss.meleeAttackTimer + dt
            if main_boss.meleeAttackTimer >= main_boss.meleeAttackDuration then
                main_boss.isLightningDamaging = true
                main_boss.lightningTimer = 0.0
            end
        else
            main_boss.lightningTimer = main_boss.lightningTimer + dt
            if main_boss.lightningTimer >= main_boss.lightningDuration then
                main_boss.isLightningDamaging = false
                main_boss.hasDealtLightningDamage = false
                main_boss.lightningRb:set_position(Vector3.new(-500, 0, -500))

                main_boss.lightningThrown = false
            end
        end
    end

    update_scaling_attacks(dt)

    if not main_boss.isRaging then
        local currentTargetPos = main_boss.playerTransf.position
        if main_boss.pathUpdateTimer >= main_boss.pathUpdateInterval or main_boss:get_distance(main_boss.lastTargetPos, currentTargetPos) > 1.0 then
            main_boss.lastTargetPos = currentTargetPos
            if main_boss.playerDetected then
                main_boss:update_path(main_boss.playerTransf)
            end
            main_boss.pathUpdateTimer = 0
        end
    end

    if main_boss.ultimateThrown or main_boss.ultimateCasting then
        main_boss.currentState = main_boss.state.Idle
        main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    end


    if main_boss.currentState == main_boss.state.Idle then
        main_boss:idle_state()
    elseif main_boss.currentState == main_boss.state.Move then
        main_boss:move_state()
    elseif main_boss.currentState == main_boss.state.Attack then
        main_boss:attack_state()
    elseif main_boss.currentState == main_boss.state.Shield then
        main_boss:shield_state()
    elseif main_boss.currentState == main_boss.state.Rage then
        main_boss:rage_state()
    end
end

function change_state()

    local distance = main_boss:get_distance(main_boss.enemyTransf.position, main_boss.playerTransf.position)

    if not main_boss.isRaging and main_boss.health <= main_boss.rageHealth then
        main_boss.currentState = main_boss.state.Rage
        return
    end

    if not main_boss.isAttacking then
        if main_boss.attackTimer >= main_boss.attackCooldown then
            main_boss.isAttacking = true
        end
    end

    if main_boss.shieldActive then
        if main_boss.shieldHealth <= 0 then
            main_boss.shieldActive = false
        end
        move_shield()
    else
        if main_boss.shieldTimer >= main_boss.shieldCooldown then
            main_boss.shieldHealth = main_boss.bossShieldHealth
            main_boss.shieldActive = true
            main_boss.currentState = main_boss.state.Shield
            main_boss.shieldTimer = 0
        end
    end

    if distance <= main_boss.rangeAttackRange and main_boss.isAttacking then
        main_boss.currentState = main_boss.state.Attack
    elseif distance <= main_boss.detectionRange then
        main_boss.playerDetected = true
        main_boss.currentState = main_boss.state.Move
    end

end

function main_boss:rage_state()

    if not main_boss.hasMovedToCenter and not main_boss.isReturning then
        log("Boss entering Rage and moving to center of arena")
        main_boss:update_path(main_boss.arenaTrasnf)
        main_boss:follow_path()
        main_boss.isReturning = true
    end

    if not main_boss.isRaging then
        main_boss.level = 2

        stats = stats_data[main_boss.enemy_type] and stats_data[main_boss.enemy_type][main_boss.level]
        -- Debug in case is not working
        if not stats then
            log("No stats for type: " .. main_boss.enemy_type .. " level: " .. main_boss.level)
            return
        end

        main_boss.bossShieldHealth = stats.bossShieldHealth
        main_boss.totemHealth = stats.totemHealth
        main_boss.speed = stats.speed
        main_boss.meleeDamage = stats.meleeDamage
        main_boss.rangeDamage = stats.rangeDamage
        main_boss.ultimateDamage = stats.ultimateDamage
        main_boss.detectionRange = stats.detectionRange
        main_boss.meleeAttackRange = stats.meleeAttackRange
        main_boss.rangeAttackRange = stats.rangeAttackRange
        main_boss.ultimateRange = stats.ultimateRange
        main_boss.totemRange = stats.totemRange

        main_boss.ultiCooldown = stats.ultiCooldown
        main_boss.ultiAttackDuration = stats.ultiAttackDuration
        main_boss.ultiHittingDuration = stats.ultiHittingDuration
        main_boss.totemCooldown = stats.totemCooldown

        log("New stats setted")
        main_boss.isRaging = true
    end

    if main_boss.currentAnim ~= main_boss.idleAnim then
        main_boss.currentAnim = main_boss.idleAnim
        main_boss.animator:set_current_animation(main_boss.currentAnim)
    end

end

function main_boss:shield_state()

    if main_boss.currentAnim ~= main_boss.shieldAnim then
        main_boss.currentAnim = main_boss.shieldAnim
        main_boss.animator:set_current_animation(main_boss.currentAnim)
    end

    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    main_boss.shieldTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)
    main_boss.wrathRb:set_position(Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z))

    main_boss.currentState = main_boss.state.Move

end

function main_boss:attack_state()

    if not main_boss.isAttacking then return end

    if main_boss.ultimateThrown or main_boss.ultimateCasting then
        main_boss.isAttacking = false
        main_boss.attackTimer = 0.0
        return
    end

    if main_boss.currentAnim ~= main_boss.attackAnim then
        main_boss.currentAnim = main_boss.attackAnim
        main_boss.animator:set_current_animation(main_boss.currentAnim)
    end

    local distance = main_boss:get_distance(main_boss.enemyTransf.position, main_boss.playerTransf.position)
    local attackChance = math.random()

    if main_boss.ultiTimer >= main_boss.ultiCooldown then
        ultimate_attack()
    elseif attackChance < 0.3 then
        lightning_attack()
        fists_attack()
    else
        if distance <= main_boss.meleeAttackRange then
            lightning_attack()
        else
            fists_attack()
        end
    end

    main_boss.isAttacking = false
    main_boss.attackTimer = 0.0

end

function move_shield()

    if main_boss.shieldActive then
        main_boss.shieldTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)
        main_boss.wrathRb:set_position(Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z))
    else
        main_boss.shieldTransf.position = Vector3.new(-500, 10, -200)
        main_boss.wrathRb:set_position(Vector3.new(-500, 10, -200))
    end

end

function lightning_attack()

    if main_boss.lightningThrown then return end

    log("Lightning Attack")
    main_boss.lightningRb:set_position(Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z))
    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    local dx = main_boss.playerTransf.position.x - main_boss.enemyTransf.position.x
    local dz = main_boss.playerTransf.position.z - main_boss.enemyTransf.position.z

    local angle = math.deg(math.atan(dx, dz))
    if dz < 0 then
        angle = angle + 180
    end
    main_boss.lightningRb:set_rotation(Vector3.new(main_boss.lightningTransf.rotation.x, -90 + angle, main_boss.lightningTransf.rotation.z))

    main_boss.lightningThrown = true
    main_boss.isLightningDamaging = false
    main_boss.meleeAttackTimer = 0.0
    main_boss.lightningTimer = 0.0

    main_boss.currentState = main_boss.state.Move

end

function fists_attack()

    if main_boss.fistsThrown then return end

    log("Fists Attack")
    local playerPos = main_boss.playerTransf.position
    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    -- Calculate positions around the player (equidistant points in a circle)
    local radius = 3.5
    local fistPositions = {
        Vector3.new(playerPos.x + radius, 0, playerPos.z),  -- Right
        Vector3.new(playerPos.x - radius/2, 0, playerPos.z + radius * 0.866),  -- Bottom left
        Vector3.new(playerPos.x - radius/2, 0, playerPos.z - radius * 0.866)   -- Top left
    }

    -- Clear previous scaling operations
    main_boss.scalingAttacks = {}

    for i = 1, 3 do
        if main_boss.fistRbs[i] and main_boss.fistTransf[i] then
            -- Set initial position
            main_boss.fistRbs[i]:set_position(fistPositions[i])
            
            -- Reset scale
            main_boss.fistTransf[i].scale = Vector3.new(1, 1, 1)
            
            -- Add to scaling list with reference to the specific fist transform
            table.insert(main_boss.scalingAttacks, {
                transform = main_boss.fistTransf[i],
                elapsed = 0,
                duration = main_boss.rangeAttackDuration,
                startScale = Vector3.new(1, 1, 1),
                targetScale = Vector3.new(10, 10, 10)
            })
        end
    end

    main_boss.fistsThrown = true
    main_boss.rangeAttackTimer = 0.0

end

function ultimate_attack()

    log("Ultimate Attack")
    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    main_boss.ultimateTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)
    main_boss.ultimateTransf.scale = Vector3.new(1, 1, 1)

    -- Configurar el escalado
    table.insert(main_boss.scalingAttacks, {
        transform = main_boss.ultimateTransf, 
        elapsed = 0,
        duration = main_boss.ultiAttackDuration,
        startScale = Vector3.new(1, 1, 1),
        targetScale = Vector3.new(20, 20, 20) 
    })

    main_boss.ultimateThrown = true
    main_boss.ultiTimer = 0.0
    main_boss.ultiAttackTimer = 0.0

end

function check_ulti_collision()

    local origin = main_boss.ultimateTransf.position
    local direction = Vector3.new(
        main_boss.playerTransf.position.x - origin.x,
        0,
        main_boss.playerTransf.position.z - origin.z
    )
    local rayLength = 40
    local tag = "Pilar"

    local rayHit = Physics.Raycast(origin, direction, rayLength)

    if main_boss:detect(rayHit, main_boss.player) then
        if main_boss.isUltimateDamaging then
            log("Player hit with ultimate")
            main_boss:make_damage(main_boss.ultimateDamage)
            main_boss.isUltimateDamaging = false
        end
    elseif main_boss:detect_by_tag(rayHit, tag) then
        log("Pillar hit with ultimate")
        main_boss.pillarToDestroy = rayHit.hitEntity
    end

    if main_boss.playerScript.godMode then
        Physics.DebugDrawRaycast(origin, direction, rayLength, Vector4.new(1, 0, 0, 1), Vector4.new(1, 1, 0, 1))
    end

end

function update_scaling_attacks(dt)
    for i = #main_boss.scalingAttacks, 1, -1 do
        local data = main_boss.scalingAttacks[i]
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
            table.remove(main_boss.scalingAttacks, i)
        end
    end
end

function manage_destroyed_pillar()
    local pillarRb = main_boss.pillarToDestroy:get_component("RigidbodyComponent").rb
    pillarRb:set_position(Vector3.new(-800, 0, -800))

    main_boss.pillarToDestroy = nil
end

function on_exit()

end