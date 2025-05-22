local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

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
    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "uña1_low" then
            kamikaze.enemyMat = child:get_component("MaterialComponent")
            kamikaze.originalMaterial = kamikaze.enemyMat.material
            break
        end
    end

    -- Player
    kamikaze.player = current_scene:get_entity_by_name("Player")
    kamikaze.playerTransf = kamikaze.player:get_component("TransformComponent")
    kamikaze.playerScript = kamikaze.player:get_component("ScriptComponent")
    for i = 1, 11 do
        kamikaze.playerObjects[i] = current_scene:get_entity_by_name(kamikaze.playerObjectsTagList[i]):get_component("TransformComponent")
    end

    -- Camera
    kamikaze.cameraScript = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent")

    -- Explosive
    kamikaze.explosiveBarrelRb = current_scene:get_entity_by_name("Explosive"):get_component("RigidbodyComponent").rb

    -- Particle
    kamikaze.explosionParticle = current_scene:get_entity_by_name("particle_kamikaze"):get_component("ParticlesSystemComponent")
    kamikaze.explosionParticleTransf = current_scene:get_entity_by_name("particle_kamikaze"):get_component("TransformComponent")
    kamikaze.sparkParticle = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    kamikaze.sparkParticleTransf = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")
    kamikaze.bloodParticle = current_scene:get_entity_by_name("KamikazeBloodParticle"):get_component("ParticlesSystemComponent")
    kamikaze.bloodParticleTransf = current_scene:get_entity_by_name("KamikazeBloodParticle"):get_component("TransformComponent")

    -- Audio
    kamikaze.detectionSFX = current_scene:get_entity_by_name("KamikazeDetectionSFX"):get_component("AudioSourceComponent")
    kamikaze.dyingSFX = current_scene:get_entity_by_name("KamikazeDieSFX"):get_component("AudioSourceComponent")
    kamikaze.kamikazeExplosionSFX = current_scene:get_entity_by_name("KamikazeExplosionSFX"):get_component("AudioSourceComponent")
    kamikaze.kamikazeScreamBoomSFX = current_scene:get_entity_by_name("KamikazeScreamBoomSFX"):get_component("AudioSourceComponent")
    kamikaze.shieldExplosionSFX = current_scene:get_entity_by_name("SupportShieldExplosionSFX"):get_component("AudioSourceComponent")

    -- Level
    kamikaze.enemyType = "kamikaze"
    kamikaze:set_level()

    local stats = stats_data[kamikaze.enemyType] and stats_data[kamikaze.enemyType][kamikaze.level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. kamikaze.enemyType .. " level: " .. kamikaze.level) return end



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
    kamikaze.alertRadius = stats.alertRadius

    -- Timers
    kamikaze.pathUpdateTimer = 0.0
    kamikaze.pathUpdateInterval = 0.1
    kamikaze.attackTimer = 0.0
    kamikaze.attackDelay = 0.75
    kamikaze.animDuration = 0.0
    kamikaze.animTimer = 0.0
    kamikaze.detectDuration = 0.83
    kamikaze.attackDuration = 1.0


    -- Animations
    kamikaze.idleAnim = 4
    kamikaze.moveAnim = 7
    kamikaze.attackAnim = 9
    kamikaze.detectAnim = 1
    kamikaze.stunAnim = 8
    kamikaze.dieAnim = 0

    -- Lists
    kamikaze.nearbyEnemies = {}

    -- Floats
    kamikaze.alertDistance = 1.8

    -- Bools
    kamikaze.isExploding = false
    kamikaze.hasExploded = false
    kamikaze.hasDealtDamage = false
    kamikaze.hasStartedExplosionAnim = false
    kamikaze.isAlerted = false
    kamikaze.hasAlerted = false
    kamikaze.hasFoundNearbyEnemies = false

    -- Positions
    kamikaze.lastTargetPos = kamikaze.playerTransf.position
    kamikaze.enemyInitialPos = Vector3.new(kamikaze.enemyTransf.position.x, kamikaze.enemyTransf.position.y, kamikaze.enemyTransf.position.z)
    kamikaze.playerDistance = kamikaze:get_distance(kamikaze.enemyTransf.position, kamikaze.playerTransf.position) + 100
    kamikaze.lastTargetPos = kamikaze.playerTransf.position

end

function on_update(dt) 

    if kamikaze.isDead then return end

    kamikaze:check_effects(dt)
    kamikaze:check_pushed(dt)

    if kamikaze.isPushed == true then
        return
    end

    if kamikaze.isGranadePushed then return end

    if not kamikaze.hasFoundNearbyEnemies then
        kamikaze:find_nearby_enemies()
        kamikaze.hasFoundNearbyEnemies = true
    end

    if kamikaze.isExploding then
        kamikaze.attackTimer = kamikaze.attackTimer + dt
        kamikaze:attack_state()
        return
    end

    change_state(dt)

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

    if isAlerted then
        kamikaze.alertTimer = kamikaze.alertTimer + dt
        if kamikaze.alertTimer >= kamikaze.alertCooldown then
            kamikaze.isAlerted = false
            kamikaze.alertTimer = 0.0
        end
    end

    kamikaze.moveAudioTimer = kamikaze.moveAudioTimer + dt
    kamikaze.pathUpdateTimer = kamikaze.pathUpdateTimer + dt
    if kamikaze.enemyHit then
        kamikaze.hitTimer = kamikaze.hitTimer + dt 
    end
    kamikaze.hitAudioTimer = kamikaze.hitAudioTimer + dt

    kamikaze:reset_material()

    local currentTargetPos = kamikaze.playerTransf.position
    if kamikaze.pathUpdateTimer >= kamikaze.pathUpdateInterval or kamikaze:get_distance(kamikaze.lastTargetPos, currentTargetPos) > 1.0 then
        kamikaze.lastTargetPos = currentTargetPos
        kamikaze:check_initial_distance()
        if not kamikaze.isReturning then
            kamikaze:update_path(kamikaze.playerTransf)
        else
            kamikaze:update_path_position(kamikaze.enemyInitialPos)
        end
        kamikaze.pathUpdateTimer = 0
    end

    if kamikaze.isPlayingAnimation then
        kamikaze.animTimer = kamikaze.animTimer + dt
        kamikaze.enemyRb:set_velocity(Vector3.new(0, 0, 0))

        if kamikaze.animTimer >= kamikaze.animDuration then
            kamikaze.isPlayingAnimation = false
        else
            return
        end
    end

    if kamikaze.playerDetected then
        --kamikazeDetectionSFX:play()
        if kamikaze.key == 0 then
             
            kamikaze.playerScript.enemys_targeting = kamikaze.playerScript.enemys_targeting + 1
            kamikaze.key = kamikaze.key + 1
        end

        if not kamikaze.playingDieAnim then
            kamikaze:rotate_enemy(kamikaze.playerTransf.position)
        end
    end

    if kamikaze.currentState == kamikaze.state.Dead then
        kamikaze:die_state(dt)
        return

    elseif kamikaze.currentState == kamikaze.state.Idle then
        kamikaze:idle_state()

    elseif kamikaze.currentState == kamikaze.state.Detect then
        kamikaze:detect_state(dt)

    elseif kamikaze.currentState == kamikaze.state.Move then
        kamikaze:move_state()
    
    elseif kamikaze.currentState == kamikaze.state.Attack then
        kamikaze:attack_state()
    end

end

function change_state(dt)

    if kamikaze.isPlayingAnimation then return end

    kamikaze:enemy_raycast(dt)
    kamikaze:check_player_distance()

    if kamikaze.playerDetected and kamikaze.currentState ~= kamikaze.state.Detect and not kamikaze.isAlerted and not kamikaze.hasAlerted then
        kamikaze.currentState = kamikaze.state.Detect
        kamikaze:avoid_alert_enemies()
        return
    end

    if kamikaze.playerDetected and kamikaze.playerDistance <= kamikaze.detectionRange then
        kamikaze.currentState = kamikaze.state.Move
    end

    if kamikaze.playerDetected and kamikaze.playerDistance <= kamikaze.attackRange then
        kamikaze.currentState = kamikaze.state.Attack
        kamikaze.isExploding = true
    end

end

function kamikaze:attack_state()

    if kamikaze.currentAnim ~= kamikaze.attackAnim then
        kamikaze.kamikazeScreamBoomSFX:play()
        kamikaze:play_blocking_animation(kamikaze.attackAnim, kamikaze.attackDuration)
    end

    kamikaze.enemyRb:set_velocity(Vector3.new(0, 0, 0))


    if kamikaze.attackTimer >= kamikaze.attackDelay and not kamikaze.hasDealtDamage then

        local explosionPos = kamikaze.enemyRb:get_position()
        local playerPos = kamikaze.playerTransf.position
        local distance = kamikaze:get_distance(explosionPos, playerPos)

        if kamikaze.explosionParticle then
            kamikaze.explosionParticleTransf.position = Vector3.new(kamikaze.enemyTransf.position.x, kamikaze.enemyTransf.position.y + 0.5, kamikaze.enemyTransf.position.z)
            kamikaze.explosionParticle:emit(2)
        end
        
        if distance < kamikaze.explosionRange then
            kamikaze:make_damage(kamikaze.damage)
            effect:apply_bleed(kamikaze.playerScript)
        end

        kamikaze.hasDealtDamage = true
        kamikaze.health = 0
        kamikaze.hasExploded = true
        kamikaze.kamikazeExplosionSFX:play()
        kamikaze.playerScript.enemys_targeting = kamikaze.playerScript.enemys_targeting - 1
        kamikaze:die_state()
    end

end

function drop_explosive()

    kamikaze.explosiveBarrelRb:set_position(Vector3.new(kamikaze.enemyTransf.position.x, 0.4, kamikaze.enemyTransf.position.z))

end

function kamikaze:find_nearby_enemies()
    kamikaze.nearbyEnemies = {}

    local count = 0
    for _, entity in ipairs(kamikaze.cameraScript.enemies) do
        local tag = entity:get_component("TagComponent")
        local name = entity:get_component("TagComponent").tag
        
        if (name == "EnemyRange" or name == "EnemyTank" or name == "EnemyKamikaze") and entity ~= self then
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")
            
            if entityTransform and script then
                local distance = kamikaze:get_distance(kamikaze.enemyTransf.position, entityTransform.position)
                
                if distance <= kamikaze.alertRadius then
                    count = count + 1
                    local enemyData = {
                        entity = entity,
                        transform = entityTransform,
                        script = script[name:lower():sub(6)],
                        distance = distance,
                        alerted = false
                    }
                    table.insert(kamikaze.nearbyEnemies, enemyData)
                end
            end
        end
    end
end

function on_exit() end