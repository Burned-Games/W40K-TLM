local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

main_boss = enemy:new()

local stats = nil

local shieldPrefab = "prefabs/Enemies/shields/BossShield.prefab"
local wrathPrefab = "prefabs/Enemies/attacks/WrathBoss.prefab"

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
    main_boss.shield = instantiate_prefab(shieldPrefab)
    main_boss.shieldTransf = main_boss.shield:get_component("TransformComponent")
    main_boss.shieldTransf.position = Vector3.new(-500, 0, -200)

    -- Wrath
    main_boss.wrath = instantiate_prefab(wrathPrefab)
    main_boss.wrathTransf = main_boss.wrath:get_component("TransformComponent")
    main_boss.wrathRbComponent = main_boss.wrath:get_component("RigidbodyComponent")
    main_boss.wrathRb = main_boss.wrathRbComponent.rb
    main_boss.wrathRb:set_position(Vector3.new(-500, 0, -500))
    main_boss.wrathRb:set_trigger(true)

    -- Fists
    main_boss.fistScript = current_scene:get_entity_by_name("FistManager"):get_component("ScriptComponent")

    -- Lightning
    main_boss.lightning = current_scene:get_entity_by_name("Lightning")
    main_boss.lightningScript = main_boss.lightning:get_component("ScriptComponent")

    -- Ultimate
    main_boss.ultimateScript = current_scene:get_entity_by_name("Ultimate"):get_component("ScriptComponent")

    -- Arena
    main_boss.arena = current_scene:get_entity_by_name("ArenaCenter")
    main_boss.arenaTrasnf = main_boss.arena:get_component("TransformComponent")

    -- Audio
    main_boss.bossFaseTwoChangeSFX = current_scene:get_entity_by_name("BossFaseTwoChangeSFX"):get_component("AudioSourceComponent")
    main_boss.hurtSFX = current_scene:get_entity_by_name("BossHurtSFX"):get_component("AudioSourceComponent")
    main_boss.shieldExplosionSFX = current_scene:get_entity_by_name("BossShieldExplosionSFX"):get_component("AudioSourceComponent")
    main_boss.bossShieldZapSFX = current_scene:get_entity_by_name("BossShieldZapSFX"):get_component("AudioSourceComponent")
    main_boss.bossStepsSFX = current_scene:get_entity_by_name("BossStepsSFX"):get_component("AudioSourceComponent")

    -- Particle
    main_boss.sparkParticle = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    main_boss.sparkParticleTransf = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")
    main_boss.bloodParticle = current_scene:get_entity_by_name("BossBloodParticle"):get_component("ParticlesSystemComponent")
    main_boss.bloodParticleTransf = current_scene:get_entity_by_name("BossBloodParticle"):get_component("TransformComponent")

    -- Fade To Black
    main_boss.fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")

    -- Arena
    main_boss.triggerBossBattle = current_scene:get_entity_by_name("TriggerBossBattle"):get_component("RigidbodyComponent")
    


    -- Attack lists
    main_boss.scalingAttacks = {}
    main_boss.attacksToTeleport = {}



    -- Level
    main_boss.enemy_type = "main_boss"
    stats = stats_data[main_boss.enemy_type] and stats_data[main_boss.enemy_type][main_boss.level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. main_boss.enemy_type .. " level: " .. main_boss.level) return end
    set_stats()



    -- States
    main_boss.state = {Dead = 1, Idle = 2, Move = 3, Attack = 4, Shield = 5, Rage = 6}

    -- Internal Timers
    main_boss.pathUpdateTimer = 0.0
    main_boss.pathUpdateInterval = 0.1
    main_boss.attackTimer = 0.0
    main_boss.meleeAttackTimer = 0.0
    main_boss.shieldTimer = 0.0
    main_boss.totemTimer = 0.0
    main_boss.colliderUpdateInterval = 0.1
    main_boss.animDuration = 0.0
    main_boss.animTimer = 0.0
    main_boss.contador = 0.0
    main_boss.timeToTransition = 5.0

    main_boss.fistsDuration = 1.67
    main_boss.thunderDuration = 2.67
    main_boss.shieldDuration = 1.33
    main_boss.rageDuration = 2.33
    main_boss.ultiDuration = 2.5
    main_boss.dieDuration = 1.83
    main_boss.idleDuration = 2.5

    -- Animations
    main_boss.idleAnim = 3
    main_boss.moveAnim = 8
    main_boss.meleeAnim = 5
    main_boss.rangeAnim = 4
    main_boss.shieldAnim = 0
    main_boss.totemAnim = 6
    main_boss.ultiAnim = 7
    main_boss.dieAnim = 1
    main_boss.rageAnim = 2

    -- Bools
    main_boss.battleStart = false
    main_boss.isRaging = false
    main_boss.isAttacking = false
    main_boss.shieldActive = false
    main_boss.hasMovedToCenter = false
    main_boss.isReturning = false
    main_boss.isPlayingAnimation = false
    main_boss.changeing = false
    main_boss.fadeToBlack = false

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

    main_boss.triggerBossBattle:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            main_boss.battleStart = true
        end
    end)

end

function on_update(dt)

    if not main_boss.battleStart then return end

    main_boss:check_effects(dt)

    change_state()

    if main_boss.currentState == main_boss.state.Idle then return end

    if main_boss.health <= 0 then
        main_boss:die_state()
    end

    main_boss.attackTimer = main_boss.attackTimer + dt
    main_boss.shieldTimer = main_boss.shieldTimer + dt
    main_boss.pathUpdateTimer = main_boss.pathUpdateTimer + dt
    if main_boss.enemyHit then
        main_boss.hitTimer = main_boss.hitTimer + dt 
        main_boss.hitAudioTimer = main_boss.hitAudioTimer + dt
    end
    if main_boss.isDead then main_boss.contador = main_boss.contador + dt end

    if main_boss.isReturning and not main_boss.hasMovedToCenter then
        main_boss.currentState = main_boss.state.Move

        if main_boss:get_distance(main_boss.enemyTransf.position, main_boss.arenaTrasnf.position) <= 0.5 then
            main_boss.hasMovedToCenter = true
            main_boss.isReturning = false
            main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
            main_boss.enemyNavmesh.path = {}
            main_boss.playerDetected = true
            main_boss.isAttacking = false
            main_boss.currentState = main_boss.state.Attack
        end
    end

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

    if main_boss.ultimateScript.ultimateThrown and not main_boss.ultimateScript.ultimateCasting then
        if main_boss.currentAnim ~= main_boss.idleAnim then
            main_boss.currentAnim = main_boss.idleAnim
            main_boss.animator:set_current_animation(main_boss.currentAnim)
        end
        main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    end

    if main_boss.isPlayingAnimation then
        main_boss.animTimer = main_boss.animTimer + dt
        main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))

        if main_boss.animTimer >= main_boss.animDuration then
            main_boss.isPlayingAnimation = false
        else
            return
        end
    end

    if main_boss.playerDetected then
        if not main_boss.isDead or not main_boss.isPlayingAnimation or main_boss.ultimateScript.ultimateThrown or main_boss.ultimateScript.ultimateCasting and not main_boss.isReturning then
            main_boss:rotate_enemy(main_boss.playerTransf.position)
        elseif main_boss.isReturning then
            main_boss:rotate_enemy(main_boss.arenaCenter.position)
        end
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

    if main_boss.isReturning then return end

    local distance = main_boss:get_distance(main_boss.enemyTransf.position, main_boss.playerTransf.position)

    if not main_boss.isRaging and main_boss.health <= main_boss.rageHealth then
        main_boss.currentState = main_boss.state.Rage
        return
    end

    if main_boss.isPlayingAnimation then return end

    if not main_boss.isAttacking then
        if main_boss.isReturning then return end
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
    elseif distance <= main_boss.detectionRange and not main_boss.isRaging and not main_boss.hasMovedToCenter then
        main_boss.playerDetected = true
        main_boss.currentState = main_boss.state.Move
    end

end

function main_boss:rage_state()

    if not main_boss.hasMovedToCenter and not main_boss.isReturning then
        log("Boss entering Rage and moving to center of arena")
        if main_boss.currentAnim ~= main_boss.rageAnim then
            main_boss:play_blocking_animation(main_boss.rageAnim, main_boss.rageDuration)
        end

        main_boss:update_path(main_boss.arenaTrasnf)
        main_boss.currentState = main_boss.state.Move
        main_boss.isReturning = true
    end

    if not main_boss.isRaging then
        main_boss.level = 2

        stats = stats_data[main_boss.enemy_type] and stats_data[main_boss.enemy_type][main_boss.level]
        -- Debug in case is not working
        if not stats then log("No stats for type: " .. main_boss.enemy_type .. " level: " .. main_boss.level) return end
        set_stats()

        log("New stats setted")
        main_boss.isRaging = true

        main_boss.bossFaseTwoChangeSFX:play()

    end

end

function main_boss:shield_state()

    log("Shield Thrown")

    if main_boss.currentAnim ~= main_boss.shieldAnim then
        main_boss:play_blocking_animation(main_boss.shieldAnim, main_boss.shieldDuration)
        main_boss.bossShieldZapSFX:play()
    end

    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    main_boss.shieldTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y + 3, main_boss.enemyTransf.position.z)
    main_boss.wrathRb:set_position(Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z))

end

function main_boss:attack_state()

    if not main_boss.isAttacking then return end

    if main_boss.ultimateScript.ultimateThrown or main_boss.ultimateScript.ultimateCasting then
        main_boss.isAttacking = false
        main_boss.attackTimer = 0.0
        return
    end

    if main_boss.currentAnim ~= main_boss.idleAnim then
        main_boss.currentAnim = main_boss.idleAnim
        main_boss.animator:set_current_animation(main_boss.currentAnim)
    end

    local distance = main_boss:get_distance(main_boss.enemyTransf.position, main_boss.playerTransf.position)
    local attackChance = math.random()

    if main_boss.isRaging and main_boss.ultimateScript.ultiTimer >= main_boss.ultiCooldown then
        ultimate_attack()
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

function main_boss:die_state(dt)
    
    if main_boss.currentAnim ~= main_boss.dieAnim then
        main_boss:play_blocking_animation(main_boss.dieAnim, main_boss.dieDuration)
        if main_boss.dyingSFX ~= nil then main_boss.dyingSFX:play() end
    end

    if not main_boss.isDead then main_boss.isDead = true end

    print(main_boss.changeing)
    print(main_boss.contador)
    print(main_boss.timeToTransition)
    if  not main_boss.changeing and (main_boss.contador >= main_boss.timeToTransition) then
        main_boss.changeing = true
        main_boss.fadeToBlackScript:DoFade()
    end

    if main_boss.changeing then
        if main_boss.fadeToBlackScript.fadeToBlackDoned then
            SceneManager.change_scene("scenes/credits.TeaScene")
        end
    end
end

function move_shield()

    if main_boss.shieldActive then
        main_boss.shieldTransf.position = Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y + 3, main_boss.enemyTransf.position.z)
        main_boss.wrathRb:set_position(Vector3.new(main_boss.enemyTransf.position.x, main_boss.enemyTransf.position.y, main_boss.enemyTransf.position.z))
    else
        main_boss.shieldTransf.position = Vector3.new(-500, 0, -200)
        main_boss.wrathRb:set_position(Vector3.new(-500, 0, -200))
    end

end

function lightning_attack()

    if main_boss.lightningScript.lightningThrown then return end

    if main_boss.currentAnim ~= main_boss.meleeAnim then
        main_boss:play_blocking_animation(main_boss.meleeAnim, main_boss.thunderDuration)
    end

    log("Lightning Attack")

    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    main_boss.lightningScript:lightning()

end

function fists_attack()

    if main_boss.fistScript.fistsThrown or main_boss.fistScript.fistsAttackPending then return end

    if main_boss.currentAnim ~= main_boss.rangeAnim then
        main_boss:play_blocking_animation(main_boss.rangeAnim, main_boss.fistsDuration)
    end

    log("Fists Indicator")

    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    main_boss.fistScript:fist()

end

function ultimate_attack()

    log("Ultimate Attack")

    main_boss.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    main_boss.ultimateScript:ultimate()

end

function set_stats()

    -- Stats of the Main Boss
    if main_boss.level == 1 then
        main_boss.health = stats.health
        main_boss.rageHealth = stats.rageHealth
    end
    main_boss.bossShieldHealth = stats.bossShieldHealth
    main_boss.totemHealth = stats.totemHealth
    main_boss.speed = stats.speed
    main_boss.defaultSpeed = main_boss.speed
    main_boss.lightningScript.meleeDamage = stats.meleeDamage
    main_boss.fistScript.rangeDamage = stats.rangeDamage
    main_boss.ultimateScript.ultimateDamage = stats.ultimateDamage
    main_boss.detectionRange = stats.detectionRange
    main_boss.meleeAttackRange = stats.meleeAttackRange
    main_boss.rangeAttackRange = stats.rangeAttackRange
    main_boss.totemRange = stats.totemRange

    -- External Timers
    main_boss.attackCooldown = stats.attackCooldown
    main_boss.lightningScript.meleeAttackDuration = stats.meleeAttackDuration
    main_boss.lightningScript.lightningDuration = stats.lightningDuration
    main_boss.fistScript.rangeAttackDuration = stats.rangeAttackDuration
    main_boss.fistScript.fistsDamageCooldown = stats.fistsDamageCooldown
    main_boss.shieldCooldown = stats.shieldCooldown
    main_boss.ultiCooldown = stats.ultiCooldown
    main_boss.ultimateScript.ultiAttackDuration = stats.ultiAttackDuration
    main_boss.ultimateScript.ultiHittingDuration = stats.ultiHittingDuration
    main_boss.totemCooldown = stats.totemCooldown

end



function on_exit()

end