local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

main_boss = enemy:new()

local stats = nil

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.5
local shieldTimer = 0.0
local shieldCooldown = 5.0
local attackTimer = 0.0
local attackCooldown = 10.0

local rangeAttackTimer = 0.0
local rangeAttackDuration = 2.0
local lightningTimer = 0.0
local lightningDuration = 0.5

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
    main_boss.isLightningDamaging = false
    main_boss.hasDealtLightningDamage = false
    main_boss.shieldActive = false

    main_boss.lastTargetPos = main_boss.playerTransf.position

    main_boss.wrathRbComponent:on_collision_stay(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            log("Wrath hit the player")
            main_boss:make_damage()
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

    if main_boss.lightningTrown then
        if not main_boss.isLightningDamaging then
            rangeAttackTimer = rangeAttackTimer + dt
            if rangeAttackTimer >= rangeAttackDuration then
                main_boss.isLightningDamaging = true
                lightningTimer = 0.0
            end
        else
            lightningTimer = lightningTimer + dt
            if lightningTimer >= lightningDuration then
                main_boss.isLightningDamaging = false
                main_boss.lightningTrown = false
                main_boss.hasDealtLightningDamage = false
                main_boss.lightningRb:set_position(Vector3.new(-500, 0, -500))
            end
        end
    end


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
    main_boss.wrathTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)

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
    else
        if distance <= main_boss.meleeAttackRange then
            lightning_attack()
        else
            fists_attack()
        end
    end

    main_boss.isAttacking = false
    attackTimer = 0

end

function move_shield()

    if main_boss.shieldActive then
        main_boss.shieldTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)
        main_boss.wrathTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)
    else
        main_boss.shieldTransf.position = Vector3.new(-500, 10, -200)
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
    elseif dx < 0 and dz > 0 then
        angle = angle + 360
    end
    main_boss.lightningTransf.rotation = Vector3.new(
        main_boss.lightningTransf.rotation.x,
        angle,
        main_boss.lightningTransf.rotation.z
    )

    main_boss.lightningTrown = true
    main_boss.isLightningDamaging = false
    rangeAttackTimer = 0.0
    lightningTimer = 0.0

    main_boss.currentState = main_boss.state.Move

end

function fists_attack()

    log("Fists Attack")

end

function on_exit()

end