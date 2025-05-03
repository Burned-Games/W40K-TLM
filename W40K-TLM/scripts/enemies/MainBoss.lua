local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

main_boss = enemy:new()

local stats = nil
local fistMaxNumbers = 3

--Prefabs locations
local fistPrefabLocation = "prefabs/Enemies/BossFist.prefab"
local fistAttackIndicatorPrefabLocation = "prefabs/Enemies/BossFistIndicator.prefab"

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

    -- Audio
    main_boss.bossChargeUltimateSFX = current_scene:get_entity_by_name("BossChargeUltimateSFX"):get_component("AudioSourceComponent")
    main_boss.bossConeAtackSFX = current_scene:get_entity_by_name("BossConeAtackSFX"):get_component("AudioSourceComponent")
    main_boss.bossFaseTwoChangeSFX = current_scene:get_entity_by_name("BossFaseTwoChangeSFX"):get_component("AudioSourceComponent")
    main_boss.bossHurtSFX = current_scene:get_entity_by_name("BossHurtSFX"):get_component("AudioSourceComponent")
    main_boss.bossShieldExplosioneSFX = current_scene:get_entity_by_name("BossShieldExplosionSFX"):get_component("AudioSourceComponent")
    main_boss.bossShieldZapSFX = current_scene:get_entity_by_name("BossSmashDescentSFX"):get_component("AudioSourceComponent")
    main_boss.bossSmashImpactSFX = current_scene:get_entity_by_name("BossSmashImpactSFX"):get_component("AudioSourceComponent")
    main_boss.bossSmashDescendSFX = current_scene:get_entity_by_name("BossSmashDescendSFX"):get_component("AudioSourceComponent")
    main_boss.bossSmashImpactSFX = current_scene:get_entity_by_name("BossSmashImpactSFX"):get_component("AudioSourceComponent")
    main_boss.bossUltimateExplosionSFX = current_scene:get_entity_by_name("BossUltimateExplosionSFX"):get_component("AudioSourceComponent")

    for i = 1, fistMaxNumbers do

        --local fistEntity = instantiate_prefab(fistPrefabLocation) --No funcionan las fisicas de los prefabs aun

        local fistEntity = current_scene:get_entity_by_name("Fist" .. i)

        main_boss.fistTransf[i] = fistEntity:get_component("TransformComponent")
        main_boss.fistRbComponent[i] = fistEntity:get_component("RigidbodyComponent")
        main_boss.fistRbs[i] = main_boss.fistRbComponent[i].rb
        main_boss.fistRbs[i]:set_trigger(true)
    end


    --Indicator attacks

    ----Indicator attacks -> Fists
    main_boss.fistIndicators = {}
    main_boss.fistIndicatorsScript = {}
    main_boss.fistIndicatorsTransform = {}

    for i = 1, fistMaxNumbers do
        local fistIndicator = instantiate_prefab(fistAttackIndicatorPrefabLocation)
        main_boss.fistIndicators[i] = fistIndicator
        main_boss.fistIndicatorsScript[i] = main_boss.fistIndicators[i]:get_component("ScriptComponent")
        main_boss.fistIndicatorsTransform[i] = main_boss.fistIndicators[i]:get_component("TransformComponent")
        main_boss.fistIndicatorsTransform[i].position = Vector3.new(-1000, 0, -1000)
        main_boss.fistIndicatorsTransform[i].scale = Vector3.new(4, 0, 4)
        main_boss.fistIndicatorsScript[i]:on_ready()
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
    main_boss.fistPositions = {}



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
    main_boss.defaultSpeed = main_boss.speed
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
    main_boss.fistsAttackDelay = 2.0

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
    main_boss.fistsAttackDelayTimer = 0.0
    main_boss.colliderUpdateInterval = 0.1

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
    main_boss.fistsAttackPending = false

    -- Ints
    main_boss.radius = 6

    -- Vector3
    main_boss.ultimateVibration = Vector3.new(1, 1, 200)

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

        if (nameA == "Player" or nameB == "Player") and main_boss.isLightningDamaging then
            if not main_boss.hasDealtLightningDamage then
                main_boss:make_damage(main_boss.meleeDamage)
                main_boss.hasDealtLightningDamage = true
            end
        end
    end)

    for i = 1, fistMaxNumbers do
        main_boss.fistRbComponent[i]:on_collision_stay(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if (nameA == "Player" or nameB == "Player") and main_boss.isFistsDamaging then
                log("Player in fist")
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
            Input.send_rumble(main_boss.ultimateVibration.x, main_boss.ultimateVibration.y, main_boss.ultimateVibration.z)
            
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

    if main_boss.fistsAttackPending then
        main_boss.fistsAttackDelayTimer = main_boss.fistsAttackDelayTimer + dt
        if main_boss.fistsAttackDelayTimer >= main_boss.fistsAttackDelay then
            execute_fists_attack()
            main_boss.fistsAttackPending = false
            main_boss.fistsAttackDelayTimer = 0.0
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
        main_boss.defaultSpeed = main_boss.speed
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

    if main_boss.fistsThrown or main_boss.fistsAttackPending then return end
    log("Fists Indicator ")

    main_boss.fistsAttackPending = true
    main_boss.fistsAttackDelayTimer = 0.0

    local playerPos = main_boss.playerTransf.position
    main_boss.fistPositions = {
        Vector3.new(playerPos.x + main_boss.radius, 0, playerPos.z),  -- Right
        Vector3.new(playerPos.x - main_boss.radius / 2, 0, playerPos.z + main_boss.radius * 0.866),  -- Bottom left
        Vector3.new(playerPos.x - main_boss.radius / 2, 0, playerPos.z - main_boss.radius * 0.866)   -- Top left
    }

    for i = 1, fistMaxNumbers do
        if main_boss.fistIndicatorsTransform[i] then
            main_boss.fistIndicatorsTransform[i].position = main_boss.fistPositions[i]
            main_boss.fistIndicatorsTransform[i].position.y = 0.1
        end
        if main_boss.fistIndicatorsScript[i] then
            main_boss.fistIndicatorsScript[i]:startIndicator()
        end
    end

end

function execute_fists_attack()

    if main_boss.fistsThrown then return end

    log("Fists Attack")
    local playerPos = main_boss.playerTransf.position
    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    -- Clear previous scaling operations
    main_boss.scalingAttacks = {}

    for i = 1, fistMaxNumbers do
        if main_boss.fistRbs[i] and main_boss.fistTransf[i] then
            -- Set initial position
            main_boss.fistRbs[i]:set_position(main_boss.fistPositions[i])

            -- Reset scale
            main_boss.fistTransf[i].scale = Vector3.new(1, 1, 1)
            main_boss.fistRbComponent[i].rb:get_collider():set_sphere_radius(1.0)
            main_boss.fistRbComponent[i].rb:set_trigger(true)
            
            -- Add to scaling list with reference to the specific fist transform
            table.insert(main_boss.scalingAttacks, {
                transform = main_boss.fistTransf[i],
                transformRb = main_boss.fistRbComponent[i],
                elapsed = 0,
                duration = main_boss.rangeAttackDuration,
                startScale = Vector3.new(1, 1, 1),
                targetScale = Vector3.new(10, 10, 10),
                colliderTimer = 0.0
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
        data.colliderTimer = (data.colliderTimer or 0) + dt

        local t = math.min(data.elapsed / data.duration, 1.0)
        local newScale = Vector3.new(
            data.startScale.x + (data.targetScale.x - data.startScale.x) * t,
            data.startScale.y + (data.targetScale.y - data.startScale.y) * t,
            data.startScale.z + (data.targetScale.z - data.startScale.z) * t
        )

        if data.transform then
            data.transform.scale = newScale
        end

        if data.colliderTimer >= main_boss.colliderUpdateInterval then
            if data.transformRb then
                data.transformRb.rb:get_collider():set_sphere_radius(newScale.x * 0.5)
                data.transformRb.rb:set_trigger(true)
            end
            data.colliderTimer = 0.0
        end

        if data.elapsed >= data.duration then
            if data.transform then
                data.transform.scale = data.targetScale
            end
            if data.transformRb then
                data.transformRb.rb:get_collider():set_sphere_radius(data.targetScale.x * 0.5)
                data.transformRb.rb:set_trigger(true)
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