local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")

kamikaze = enemy:new()



function on_ready() 

    -- Scene
    kamikaze.sceneName = SceneManager:get_scene_name()

    -- Enemy
    kamikaze.enemyTransf = self:get_component("TransformComponent")
    kamikaze.animator = self:get_component("AnimatorComponent")
    kamikaze.enemyRbComponent = self:get_component("RigidbodyComponent")
    kamikaze.enemyRb = kamikaze.enemyRbComponent.rb
    kamikaze.enemyNavmesh = self:get_component("NavigationAgentComponent")

    -- Player
    kamikaze.player = current_scene:get_entity_by_name("Player")
    kamikaze.playerTransf = kamikaze.player:get_component("TransformComponent")
    kamikaze.playerScript = kamikaze.player:get_component("ScriptComponent")
    for i = 1, 11 do
        kamikaze.playerObjects[i] = current_scene:get_entity_by_name(kamikaze.playerObjectsTagList[i]):get_component("TransformComponent")
    end

    -- Explosive
    kamikaze.explosiveBarrelRb = current_scene:get_entity_by_name("Explosive"):get_component("RigidbodyComponent").rb

    -- Particle
    kamikaze.particleKamikaze = current_scene:get_entity_by_name("particle_kamikaze"):get_component("ParticlesSystemComponent")
    kamikaze.particleKamikazeTransf = current_scene:get_entity_by_name("particle_kamikaze"):get_component("TransformComponent")
    kamikaze.particleSpark = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    kamikaze.particleSparkTransf = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")

    -- Audio
    kamikaze.kamikazeDetectionSFX = current_scene:get_entity_by_name("KamikazeDetectionSFX"):get_component("AudioSourceComponent")
    kamikaze.kamikazeDieSFX = current_scene:get_entity_by_name("KamikazeDieSFX"):get_component("AudioSourceComponent")
    kamikaze.kamikazeExplosionSFX = current_scene:get_entity_by_name("KamikazeExplosionSFX"):get_component("AudioSourceComponent")
    kamikaze.kamikazeExplosionSFX = current_scene:get_entity_by_name("KamikazeScreamBoomSFX"):get_component("AudioSourceComponent")



    -- Level
    kamikaze.enemyType = "kamikaze"
    kamikaze:set_level()

    local stats = stats_data[kamikaze.enemy_type] and stats_data[kamikaze.enemy_type][kamikaze.level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. kamikaze.enemy_type .. " level: " .. kamikaze.level) return end



    -- Stats of the Kamikaze
    kamikaze.health = stats.health
    kamikaze.defaultHealth = kamikaze.health
    kamikaze.speed = stats.speed
    kamikaze.defaultSpeed = kamikaze.speed
    kamikaze.damage = stats.damage
    kamikaze.detectionRange = stats.detectionRange
    kamikaze.attackRange = stats.attackRange
    kamikaze.explosionRange = stats.explosionRange
    kamikaze.priority = stats.priority

    -- Timers
    kamikaze.pathUpdateTimer = 0.0
    kamikaze.pathUpdateInterval = 0.1
    kamikaze.attackTimer = 0.0
    kamikaze.attackDelay = 0.75

    -- Animations
    kamikaze.idleAnim = 3
    kamikaze.moveAnim = 5
    kamikaze.attackAnim = 7
    kamikaze.dieAnim = 0

    -- Bools
    kamikaze.isExploding = false
    kamikaze.hasExploded = false
    kamikaze.hasDealtDamage = false
    kamikaze.hasStartedExplosionAnim = false

    -- Positions
    kamikaze.lastTargetPos = kamikaze.playerTransf.position

    kamikaze.playerDistance = kamikaze:get_distance(kamikaze.enemyTransf.position, kamikaze.playerTransf.position) + 100

end

function on_update(dt) 

    if kamikaze.isDead then return end
    kamikaze:check_effects(dt)
    kamikaze:check_pushed(dt)
    if kamikaze.isPushed == true then
        return
    end
    change_state()

    if kamikaze.currentState == kamikaze.state.Idle then return end

    if not kamikaze.hasExploded and kamikaze.health <= 0 then
        drop_explosive()
        if kamikaze.key ~= 0 then
            kamikaze.playerScript.enemys_targeting = kamikaze.playerScript.enemys_targeting - 1
            kamikaze.key = 0
        end
        kamikaze:die_state()
        kamikaze.kamikazeDieSFX:play()
    elseif kamikaze.hasExploded and kamikaze.health <= 0 then
        if kamikaze.key ~= 0 then
            kamikaze.playerScript.enemys_targeting = kamikaze.playerScript.enemys_targeting - 1
            kamikaze.key = 0
        end
        
        kamikaze:die_state()
        kamikaze.kamikazeExplosionSFX:play()
    end

    if kamikaze.haveShield and kamikaze.enemyShield <= 0 then
        kamikaze.haveShield = false
        kamikaze.shieldDestroyed = true
    end

    if kamikaze.isExploding then
        kamikaze.attackTimer = kamikaze.attackTimer + dt
        kamikaze:attack_state()
        return
    end

    kamikaze.pathUpdateTimer = kamikaze.pathUpdateTimer + dt

    local currentTargetPos = kamikaze.playerTransf.position
    if kamikaze.pathUpdateTimer >= kamikaze.pathUpdateInterval or kamikaze:get_distance(kamikaze.lastTargetPos, currentTargetPos) > 1.0 then
        kamikaze.lastTargetPos = currentTargetPos
        kamikaze:update_path(kamikaze.playerTransf)
        kamikaze.pathUpdateTimer = 0
    end

    if kamikaze.playerDetected then
        --kamikazeDetectionSFX:play()
        if kamikaze.key == 0 then
             
            kamikaze.playerScript.enemys_targeting = kamikaze.playerScript.enemys_targeting + 1
            kamikaze.key = kamikaze.key + 1
        end
        kamikaze:rotate_enemy(kamikaze.playerTransf.position)
    end

    if kamikaze.currentState == kamikaze.state.Idle then
        kamikaze:idle_state()
        return

    elseif kamikaze.currentState == kamikaze.state.Move then
        kamikaze:move_state()
    
    elseif kamikaze.currentState == kamikaze.state.Attack then
        kamikaze:attack_state()
    end

end

function change_state()

    kamikaze:enemy_raycast()
    kamikaze:check_player_distance()

    if kamikaze.playerDetected and kamikaze.playerDistance <= kamikaze.detectionRange then
        kamikaze.currentState = kamikaze.state.Move
        kamikaze.playerDetected = true
    end

    if kamikaze.playerDetected and kamikaze.playerDistance <= kamikaze.attackRange then
        kamikaze.currentState = kamikaze.state.Attack
        kamikaze.isExploding = true
    end

end

function kamikaze:attack_state()

    kamikaze.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    if kamikaze.currentAnim ~= kamikaze.attackAnim then
        kamikaze.currentAnim = kamikaze.attackAnim
        kamikaze.animator:set_current_animation(kamikaze.currentAnim)
    end


    if kamikaze.attackTimer >= kamikaze.attackDelay and not kamikaze.hasDealtDamage then

        local explosionPos = kamikaze.enemyRb:get_position()
        local playerPos = kamikaze.playerTransf.position
        local distance = kamikaze:get_distance(explosionPos, playerPos)

        kamikaze.particleKamikazeTransf.position = kamikaze.enemyTransf.position
        
        if distance < kamikaze.explosionRange then
            kamikaze.particleKamikazeTransf.position = explosionPos
            kamikaze.particleKamikaze:emit(2)
            kamikaze:make_damage(kamikaze.damage)
        end

        kamikaze.hasDealtDamage = true
        kamikaze.health = 0
        kamikaze.hasExploded = true
        kamikaze.playerScript.enemys_targeting = kamikaze.playerScript.enemys_targeting - 1
        kamikaze:die_state()
    end

end

function drop_explosive()

    kamikaze.explosiveBarrelRb:set_position(Vector3.new(kamikaze.enemyTransf.position.x, 0.4, kamikaze.enemyTransf.position.z))

end

function on_exit() end