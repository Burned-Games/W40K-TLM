local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

main_boss = enemy:new()

local stats = nil

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.5
local shieldTimer = 0
local shieldCooldown = 5
local attackTimer = 0
local attackCooldown = 10

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
    main_boss.attackAnim = 2
    main_boss.rageAnim = 3
    main_boss.ultiAnim = 4

    main_boss.isRaging = false
    main_boss.isAttacking = false
    main_boss.shieldActive = false

    main_boss.lastTargetPos = main_boss.playerTransf.position

    main_boss.wrathRbComponent:on_collision_stay(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            main_boss:make_damage()
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

    if distance <= main_boss.rangeAttackRange then
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

    if main_boss.currentAnim ~= 1 then
        main_boss.animator:set_current_animation(3)
        main_boss.currentAnim = 1
    end

    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    main_boss.shieldTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)
    main_boss.shieldTransf.scale = Vector3.new(2.5, 2.5, 2.5)

    main_boss.wrathTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z)
    main_boss.wrathTransf.scale = Vector3.new(10, 10, 10)

    main_boss.currentState = main_boss.state.Move

end

function main_boss:attack_state()

    if not main_boss.isAttacking then return end

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

end

function fists_attack()

    log("Fists Attack")

end

function on_exit()

end