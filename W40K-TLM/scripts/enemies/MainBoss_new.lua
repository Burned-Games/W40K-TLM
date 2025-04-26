local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

main_boss = enemy:new()

local stats = nil

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.5

local shieldTimer = 0.0
local shieldCooldown = 15.0

local attackTimer = 0.0
local attackCooldown = 10.0

local meleeAttackTimer = 0.0
local meleeAttackDuration = 2.0
local lightningTimer = 0.0
local lightningDuration = 0.5

local rangeAttackTimer = 0.0
local rangeAttackDuration = 10.0
local timeSinceLastFistHit = 0.0
local fistsDamageCooldown = 1.0

local ultiTimer = 0.0
local ultiAttackTimer = 0.0
local ultiAttackDuration = 15.0
local ultiCooldown = 15.0

local totemTimer = 0.0
local totemCooldown = 20.0

function on_ready()

    main_boss.player = current_scene:get_entity_by_name("Player")
    main_boss.playerTransf = main_boss.player:get_component("TransformComponent")
    main_boss.playerScript = main_boss.player:get_component("ScriptComponent")

    main_boss.enemyTransf = self:get_component("TransformComponent")
    main_boss.animator = self:get_component("AnimatorComponent")
    main_boss.enemyRbComponent = self:get_component("RigidbodyComponent")
    main_boss.enemyRb = main_boss.enemyRbComponent.rb
    main_boss.enemyNavmesh = self:get_component("NavigationAgentComponent")

    main_boss.shield = current_scene:get_entity_by_name("Shield")
    main_boss.shieldTransf = main_boss.shield:get_component("TransformComponent")

    main_boss.wrath = current_scene:get_entity_by_name("Wrath")
    main_boss.wrathTransf = main_boss.wrath:get_component("TransformComponent")
    main_boss.wrathRbComponent = main_boss.wrath:get_component("RigidbodyComponent")
    main_boss.wrathRb = main_boss.wrathRbComponent.rb
    main_boss.wrathRb:set_trigger(true)

    main_boss.fist1 = current_scene:get_entity_by_name("Fist1")
    main_boss.fist2 = current_scene:get_entity_by_name("Fist2")
    main_boss.fist3 = current_scene:get_entity_by_name("Fist3")
    main_boss.fist1Transform = main_boss.fist1:get_component("TransformComponent")
    main_boss.fist2Transform = main_boss.fist2:get_component("TransformComponent")
    main_boss.fist3Transform = main_boss.fist3:get_component("TransformComponent")
    main_boss.fist1RbComponent = main_boss.fist1:get_component("RigidbodyComponent")
    main_boss.fist2RbComponent = main_boss.fist2:get_component("RigidbodyComponent")
    main_boss.fist3RbComponent = main_boss.fist3:get_component("RigidbodyComponent")
    main_boss.fist1Rb = main_boss.fist1RbComponent.rb
    main_boss.fist2Rb = main_boss.fist2RbComponent.rb
    main_boss.fist3Rb = main_boss.fist3RbComponent.rb
    main_boss.fist1Rb:set_trigger(true)
    main_boss.fist2Rb:set_trigger(true)
    main_boss.fist3Rb:set_trigger(true)

    main_boss.lightning = current_scene:get_entity_by_name("Lightning")
    main_boss.lightningTransf = main_boss.lightning:get_component("TransformComponent")
    main_boss.lightningRbComponent = main_boss.lightning:get_component("RigidbodyComponent")
    main_boss.lightningRb = main_boss.lightningRbComponent.rb
    main_boss.lightningRb:set_trigger(true)

    main_boss.ultimate = current_scene:get_entity_by_name("Ultimate")
    main_boss.ultimateTransf = main_boss.ultimate:get_component("TransformComponent")


    local enemy_type = "main_boss"

    stats = stats_data[enemy_type] and stats_data[enemy_type][main_boss.level]
    -- Debug in case is not working
    if not stats then
        log("No stats for type: " .. enemy_type .. " level: " .. main_boss.level)
        return
    end



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

    main_boss.state.Shield = 4
    main_boss.state.Rage = 5

    main_boss.idleAnim = 0
    main_boss.moveAnim = 2
    main_boss.attackAnim = 3
    main_boss.shieldAnim = 3
    main_boss.rageAnim = 3
    main_boss.ultiAnim = 4

    main_boss.isRaging = false
    main_boss.isAttacking = false
    main_boss.lightningThrown = false
    main_boss.isLightningDamaging = false
    main_boss.hasDealtLightningDamage = false
    main_boss.fistsThrown = false
    main_boss.isFistsDamaging = true
    main_boss.ultimateThrown = false
    main_boss.shieldActive = false

    main_boss.lastTargetPos = main_boss.playerTransf.position

    main_boss.fistTransforms = {main_boss.fist1Transform, main_boss.fist2Transform, main_boss.fist3Transform}
    main_boss.fistRbs = {main_boss.fist1Rb, main_boss.fist2Rb, main_boss.fist3Rb}
    main_boss.scalingAttacks = {}
    main_boss.attacksToTeleport = {}

    main_boss.wrathRbComponent:on_collision_stay(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            --log("Wrath hit the player")
        end
    end)

    main_boss.lightningRbComponent:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" and main_boss.isLightningDamaging then
            if not main_boss.hasDealtLightningDamage then
                main_boss:make_damage(1)
                main_boss.hasDealtLightningDamage = true
            end
        end
    end)

    main_boss.fist1RbComponent:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" and main_boss.isFistsDamaging then
            main_boss:make_damage(10)
            main_boss.isFistsDamaging = false
        end
    end)

    main_boss.fist2RbComponent:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" and main_boss.isFistsDamaging then
            main_boss:make_damage(10)
            main_boss.isFistsDamaging = false
        end
    end)

    main_boss.fist3RbComponent:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" and main_boss.isFistsDamaging then
            main_boss:make_damage(10)
            main_boss.isFistsDamaging = false
        end
    end)

end

function on_update(dt)

    if main_boss.isDead then return end

    main_boss:check_effects(dt)

    change_state()

    if main_boss.currentState == main_boss.state.Idle then return end

    if main_boss.health <= 0 then
        main_boss:die_state()
    end

    attackTimer = attackTimer + dt
    shieldTimer = shieldTimer + dt
    pathUpdateTimer = pathUpdateTimer + dt

    if main_boss.isRaging then
        ultiTimer = ultiTimer + dt
        totemTimer = totemTimer + dt
    end

    if main_boss.ultimateThrown then
        ultiAttackTimer = ultiAttackTimer + dt

        if ultiAttackTimer >= ultiAttackDuration then
            check_ulti_collision()
            main_boss.ultimateTransf.position = Vector3.new(-500, 0, -150)

            main_boss.ultimateThrown = false
        end
    end

    if main_boss.fistsThrown then
        rangeAttackTimer = rangeAttackTimer + dt

        if not main_boss.isFistsDamaging then
            timeSinceLastFistHit = timeSinceLastFistHit + dt
            if timeSinceLastFistHit > fistsDamageCooldown then
                main_boss.isFistsDamaging = true
                timeSinceLastFistHit = 0.0
            end
        elseif rangeAttackTimer >= rangeAttackDuration then
            -- Send them back
            main_boss.fistRbs[1]:set_position(Vector3.new(-500, 0, -150))
            main_boss.fistRbs[2]:set_position(Vector3.new(-500, 0, -150))
            main_boss.fistRbs[3]:set_position(Vector3.new(-500, 0, -150))

            main_boss.fistsThrown = false
        end
    end

    if main_boss.lightningThrown then
        if not main_boss.isLightningDamaging then
            meleeAttackTimer = meleeAttackTimer + dt
            if meleeAttackTimer >= meleeAttackDuration then
                main_boss.isLightningDamaging = true
                lightningTimer = 0.0
            end
        else
            lightningTimer = lightningTimer + dt
            if lightningTimer >= lightningDuration then
                main_boss.isLightningDamaging = false
                main_boss.hasDealtLightningDamage = false
                main_boss.lightningRb:set_position(Vector3.new(-500, 0, -500))

                main_boss.lightningThrown = false
            end
        end
    end

    update_scaling_attacks(dt)


    local currentTargetPos = main_boss.playerTransf.position
    if pathUpdateTimer >= pathUpdateInterval or main_boss:get_distance(main_boss.lastTargetPos, currentTargetPos) > 1.0 then
        main_boss.lastTargetPos = currentTargetPos
        if main_boss.playerDetected then
            main_boss:update_path(main_boss.playerTransf)
        end
        pathUpdateTimer = 0
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
        main_boss.isRaging = true
        main_boss.currentState = main_boss.state.Rage
        return
    end

    if not main_boss.isAttacking then
        if attackTimer >= attackCooldown then
            main_boss.isAttacking = true
        end
    end

    if main_boss.shieldActive then
        if main_boss.shieldHealth <= 0 then
            main_boss.shieldActive = false
        end
        move_shield()
    else
        if shieldTimer >= shieldCooldown then
            main_boss.shieldHealth = main_boss.bossShieldHealth
            main_boss.shieldActive = true
            main_boss.currentState = main_boss.state.Shield
            shieldTimer = 0
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

    log("New stats setted")

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

    if main_boss.currentAnim ~= main_boss.attackAnim then
        main_boss.currentAnim = main_boss.attackAnim
        main_boss.animator:set_current_animation(main_boss.currentAnim)
    end

    local distance = main_boss:get_distance(main_boss.enemyTransf.position, main_boss.playerTransf.position)
    local attackChance = math.random()
    if attackChance < 0.3 then
        lightning_attack()
        fists_attack()
    elseif ultiTimer >= ultiCooldown then
        ultimate_attack()
    else
        if distance <= main_boss.meleeAttackRange then
            lightning_attack()
        else
            fists_attack()
        end
    end

    main_boss.isAttacking = false
    attackTimer = 0.0

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
    meleeAttackTimer = 0.0
    lightningTimer = 0.0

    main_boss.currentState = main_boss.state.Move

end

function fists_attack()

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
        if main_boss.fistRbs[i] and main_boss.fistTransforms[i] then
            -- Set initial position
            main_boss.fistRbs[i]:set_position(fistPositions[i])
            
            -- Reset scale
            main_boss.fistTransforms[i].scale = Vector3.new(1, 1, 1)
            
            -- Add to scaling list with reference to the specific fist transform
            table.insert(main_boss.scalingAttacks, {
                transform = main_boss.fistTransforms[i],
                elapsed = 0,
                duration = rangeAttackDuration,
                startScale = Vector3.new(1, 1, 1),
                targetScale = Vector3.new(10, 10, 10)
            })
        end
    end

    main_boss.fistsThrown = true
    rangeAttackTimer = 0.0

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
        duration = ultiAttackDuration,
        startScale = Vector3.new(1, 1, 1),
        targetScale = Vector3.new(20, 20, 20) 
    })

    main_boss.ultimateThrown = true
    ultiTimer = 0.0
    ultiAttackTimer = 0.0

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

function on_exit()

end