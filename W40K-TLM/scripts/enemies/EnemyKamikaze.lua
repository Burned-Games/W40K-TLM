local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")

kamikaze = enemy:new()

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.1
local attackTimer = 0.0
local attackDelay = 0.75

-- Audio 
local kamikazeDetectionSFX
local kamikazeDieSFX
local kamikazeExplosionSFX
local kamikazeScreamBoomSFX

-- Particle 
local particle_kamikaze = nil
local particle_kamikaze_transform = nil
local particle_spark = nil
local particle_spark_transform = nil

function on_ready() 

    kamikaze.LevelGeneratorByPosition = current_scene:get_entity_by_name("LevelGeneratorByPosition"):get_component("TransformComponent")

    kamikaze.player = current_scene:get_entity_by_name("Player")
    kamikaze.playerTransf = kamikaze.player:get_component("TransformComponent")
    kamikaze.playerScript = kamikaze.player:get_component("ScriptComponent")

    kamikaze.enemyTransf = self:get_component("TransformComponent")
    kamikaze.animator = self:get_component("AnimatorComponent")
    kamikaze.enemyRbComponent = self:get_component("RigidbodyComponent")
    kamikaze.enemyRb = kamikaze.enemyRbComponent.rb
    kamikaze.enemyNavmesh = self:get_component("NavigationAgentComponent")

    kamikaze.explosiveBarrel = current_scene:get_entity_by_name("Explosive")
    kamikaze.explosiveBarrelRb = kamikaze.explosiveBarrel:get_component("RigidbodyComponent").rb

    kamikaze.scrap = current_scene:get_entity_by_name("Scrap")
    kamikaze.scrapTransf = kamikaze.scrap:get_component("TransformComponent")

    -- Audio
    kamikazeDetectionSFX = current_scene:get_entity_by_name("KamikazeDetectionSFX"):get_component("AudioSourceComponent")
    kamikazeDieSFX = current_scene:get_entity_by_name("KamikazeDieSFX"):get_component("AudioSourceComponent")
    kamikazeExplosionSFX = current_scene:get_entity_by_name("KamikazeExplosionSFX"):get_component("AudioSourceComponent")
    kamikazeScreamBoomSFX = current_scene:get_entity_by_name("KamikazeScreamBoomSFX"):get_component("AudioSourceComponent")

    -- Particle
    particle_kamikaze = current_scene:get_entity_by_name("particle_kamikaze"):get_component("ParticlesSystemComponent")
    particle_kamikaze_transform = current_scene:get_entity_by_name("particle_kamikaze"):get_component("TransformComponent")
    particle_spark = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    particle_spark_transform = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")

    local enemy_type = "kamikaze"
    kamikaze:set_level()

    local stats = stats_data[enemy_type] and stats_data[enemy_type][kamikaze.level]
    -- Debug in case is not working
    if not stats then
        log("No stats for type: " .. enemy_type .. " level: " .. kamikaze.level)
        return
    end



    -- Stats of the Kamikaze
    kamikaze.health = stats.health
    kamikaze.speed = stats.speed
    kamikaze.damage = stats.damage
    kamikaze.detectionRange = stats.detectionRange
    kamikaze.attackRange = stats.attackRange
    kamikaze.explosionRange = stats.explosionRange
    kamikaze.priority = stats.priority



    kamikaze.idleAnim = 3
    kamikaze.moveAnim = 5
    kamikaze.attackAnim = 7
    kamikaze.dieAnim = 0

    kamikaze.isExploding = false
    kamikaze.hasExploded = false
    kamikaze.hasDealtDamage = false

    kamikaze.playerDistance = kamikaze:get_distance(kamikaze.enemyTransf.position, kamikaze.playerTransf.position) + 100        -- **ESTO HAY QUE ARREGLARLO**
    kamikaze.lastTargetPos = kamikaze.playerTransf.position

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
        end
        kamikaze:die_state()
        kamikazeDieSFX:play()
    elseif kamikaze.hasExploded and kamikaze.health <= 0 then
        if kamikaze.key ~= 0 then
            kamikaze.playerScript.enemys_targeting = kamikaze.playerScript.enemys_targeting - 1
        end
        
        kamikaze:die_state()
        kamikazeExplosionSFX:play()
    end

    if kamikaze.haveShield and kamikaze.enemyShield <= 0 then
        kamikaze.haveShield = false
        kamikaze.shieldDestroyed = true
    end

    if kamikaze.isExploding then
        attackTimer = attackTimer + dt
        kamikaze:attack_state()
        return
    end

    pathUpdateTimer = pathUpdateTimer + dt

    local currentTargetPos = kamikaze.playerTransf.position
    if pathUpdateTimer >= pathUpdateInterval or kamikaze:get_distance(kamikaze.lastTargetPos, currentTargetPos) > 1.0 then
        kamikaze.lastTargetPos = currentTargetPos
        kamikaze:update_path(kamikaze.playerTransf)
        pathUpdateTimer = 0
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

    if attackTimer >= attackDelay and not kamikaze.hasDealtDamage then

        local explosionPos = kamikaze.enemyRb:get_position()
        local playerPos = kamikaze.playerTransf.position

        local distance = kamikaze:get_distance(explosionPos, playerPos)
        particle_kamikaze_transform.position = kamikaze.enemyTransf.position
        
        if distance < kamikaze.explosionRange then
            particle_kamikaze_transform.position = explosionPos
            particle_kamikaze:emit(2)
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

    if kamikaze.explosiveBarrel == nil then return end

    kamikaze.explosiveBarrelRb:set_position(Vector3.new(kamikaze.enemyTransf.position.x, 0.4, kamikaze.enemyTransf.position.z))

end

function on_exit() end