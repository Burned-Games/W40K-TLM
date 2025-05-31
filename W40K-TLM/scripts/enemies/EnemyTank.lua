local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")

tank = enemy:new()

local stats = nil

local audioPrefab = "prefabs/Audio/EnemyTankAudio.prefab"
local tackleIndicatorPrefab = "prefabs/Enemies/attacks/TankTackleIndicator.prefab"
local auraPrefab = "prefabs/particles/AuraTank.prefab"
local runPrefab = "prefabs/particles/Lvl1_run.prefab"

function on_ready()

    
    tank.entityName = self:get_component("TagComponent").tag
    -- Scene
    tank.sceneName = SceneManager:get_scene_name()

    -- Enemy
    tank.enemyTransf = self:get_component("TransformComponent")
    tank.enemyTag = self:get_component("TagComponent").tag
    tank.animator = self:get_component("AnimatorComponent")
    tank.enemyRbComponent = self:get_component("RigidbodyComponent")
    tank.enemyRb = tank.enemyRbComponent.rb
    tank.enemyRb:set_rotation(Vector3.new(tank.enemyTransf.rotation.x, tank.enemyTransf.rotation.y, tank.enemyTransf.rotation.z))
    tank.enemyNavmesh = self:get_component("NavigationAgentComponent")
    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "cuerpo_low" then
            tank.enemyMat = child:get_component("MaterialComponent")
            tank.originalMaterial = tank.enemyMat.material
            break
        end
    end

    --Mision
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")

    -- Player
    tank.player = current_scene:get_entity_by_name("Player")
    tank.playerTransf = tank.player:get_component("TransformComponent")
    tank.playerScript = tank.player:get_component("ScriptComponent")
    for i = 1, 11 do
        tank.playerObjects[i] = current_scene:get_entity_by_name(tank.playerObjectsTagList[i]):get_component("TransformComponent")
    end

    -- Camera
    tank.cameraScript = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent")

    -- Audio
    tank.audio = instantiate_prefab(audioPrefab)
    tank.audio:set_parent(self)
    local audioChildren = tank.audio:get_children()
    for _, child in ipairs(audioChildren) do
        if child:get_component("TagComponent").tag == "TankDeadSFX" then
            tank.dyingSFX = current_scene:get_entity_by_name("TankDeadSFX"):get_component("AudioSourceComponent")
        elseif child:get_component("TagComponent").tag == "TankDetectPlayerSFX" then
            tank.detectionSFX = current_scene:get_entity_by_name("TankDetectPlayerSFX"):get_component("AudioSourceComponent")
        elseif child:get_component("TagComponent").tag == "TankBerserkerSFX" then
            tank.berserkerSFX = current_scene:get_entity_by_name("TankBerserkerSFX"):get_component("AudioSourceComponent")
        elseif child:get_component("TagComponent").tag == "TankImpactPlayerSFX" then
            tank.impactPlayerSFX = current_scene:get_entity_by_name("TankImpactPlayerSFX"):get_component("AudioSourceComponent")
        elseif child:get_component("TagComponent").tag == "TankStepsSFX" then
            tank.stepsSFX = current_scene:get_entity_by_name("TankStepsSFX"):get_component("AudioSourceComponent")
        elseif child:get_component("TagComponent").tag == "TankHurtSFX" then
            tank.hurtSFX = current_scene:get_entity_by_name("TankHurtSFX"):get_component("AudioSourceComponent")
        elseif child:get_component("TagComponent").tag == "SupportShieldExplosionSFX" then
            tank.shieldExplosionSFX = current_scene:get_entity_by_name("SupportShieldExplosionSFX"):get_component("AudioSourceComponent")
        end
    end

    -- Particles
    tank.sparkParticle = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    tank.sparkParticleTransf = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")
    tank.run = instantiate_prefab(runPrefab)
    tank.runParticle = tank.run:get_component("ParticlesSystemComponent")
    tank.run:set_parent(self)
    if not tank.tackleIndicator then
        tank.tackleIndicator = instantiate_prefab(tackleIndicatorPrefab)
        tank.tackleIndicatorSprite = tank.tackleIndicator:get_component("SpriteComponent")
        tank.tackleIndicatorTransf = tank.tackleIndicator:get_component("TransformComponent")
        tank.tackleIndicator:set_parent(self)
        tank.tackleIndicatorSprite.tint_color = Vector4.new(1, 0, 0, 0)
    end

    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "MeleeArea" then
            tank.meleeArea = child
            tank.meleeAreaRbComponent = child:get_component("RigidbodyComponent")
            tank.meleeAreaRb = tank.meleeAreaRbComponent.rb
            tank.meleeAreaRb:set_trigger(true)
            tank.meleeAreaRbComponent:on_collision_enter(function(entityA, entityB)
                local nameA = entityA:get_component("TagComponent").tag
                local nameB = entityB:get_component("TagComponent").tag
            
                if (nameA == "Player" or nameB == "Player") then
                    tank:make_damage(tank.meleeDamage)
                    tank.meleeAreaRb:set_position(Vector3.new(0, -50, 0))
                end
            end)
            break
        end
    end

    

    -- Level
    tank.enemyType = "tank"
    tank:set_level()

    if self:get_component("TagComponent").tag == "EnemyTank1" then
        tank.level = 3
        tank.auraTank = instantiate_prefab(auraPrefab)
        tank.auraTank:set_parent(self)
        tank.zoneNumber = 4
    end

    tank:set_stats(tank.level, tank.zoneNumber)

    

    -- States
    tank.state = {Dead = 1, Idle = 2, Detect = 3, Move = 4, Attack = 5, Tackle = 6, Stun = 7}

    -- Internal Timers
    tank.pathUpdateTimer = 0.0
    tank.pathUpdateInterval = 0.1
    tank.attackTimer = 0.0
    tank.tackleTimer = 0.0
    tank.berserkaTimer = 0.0
    tank.idleTimer = 0.0
    tank.animDuration = 0.0
    tank.animTimer = 0.0
    tank.moveAudioDuration = 1.0

    -- Animations
    tank.attackAnim = 1
    tank.berserkaAnim = 3
    tank.dieAnim = 5
    tank.detectAnim = 6
    --tank.hitAnim = 5 
    tank.idleAnim = 9
    tank.stunAnim = 1
    tank.tackleAnim = 12
    tank.moveAnim = 13

    -- Animation timers
    tank.attackDuration = 2.0 
    tank.berserkaDuration = 2.0
    tank.dieDuration = 0.5
    tank.detectDuration = 1.5
    tank.stunDuration = 2.5
    tank.tackleDuration = 0.83

    -- Lists
    tank.nearbyEnemies = {}

    -- Ints
    tank.shieldScale = 4

    -- Floats
    tank.alertDistance = 3.5

    -- Bools
    tank.isBerserkaActive = false 
    tank.isPlayingBerserkaAnim = false
    tank.collisionWithPlayer = false
    tank.isCharging = false
    tank.canTackle = false
    tank.isAlerted = false
    tank.hasFoundNearbyEnemies = false
    tank.isFirstAttack = true

    -- Positions
    tank.targetDirection = Vector3.new(0, 0, 0)
    tank.enemyInitialPos = Vector3.new(tank.enemyTransf.position.x, tank.enemyTransf.position.y, tank.enemyTransf.position.z)
    tank.playerDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position) + 100
    tank.lastTargetPos = tank.playerTransf.position



    -- On Collision functions
    tank.enemyRbComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if (nameA == "Player" or nameB == "Player") then
            tank.collisionWithPlayer = true
            if tank.currentState == tank.state.Tackle or tank.currentState == tank.state.Move then
                tank.tackleIndicatorSprite.tint_color = Vector4.new(1, 0, 0, 0)
                tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))
                tank.isCharging = false
                tank.canTackle = false
                tank.tackleTimer = 0.0

                if tank.currentState == tank.state.Tackle then
                    tank.impactPlayerSFX:play()
                    tank:make_damage(tank.tackleDamage)
                    tank.playerScript.applyStunn()
                    
                    if not tank.isBerserkaActive then
                        tank:berserka_rage()
                    end
                end
                tank.currentState = tank.state.Attack
            end
        else
            local isNonBlockingCollision = 
                nameA:match("^Sphere") or nameA == "Granade" or 
                nameA == "DisruptorBullet" or nameA == "ChargeZone" or
                nameA == "EnemyRange" or nameA == "EnemyKamikaze" or nameA == "EnemySupport" or
                nameA == "SupportBullet1" or nameA == "SupportBullet2" or nameA == "SupportBullet3" or
                nameB:match("^Sphere") or nameB == "Granade" or
                nameB == "DisruptorBullet" or nameB == "ChargeZone" or
                nameB == "EnemyRange" or nameB == "EnemyKamikaze" or nameB == "EnemySupport" or
                nameB == "SupportBullet1" or nameB == "SupportBullet2" or nameB == "SupportBullet3"

            if not isNonBlockingCollision and tank.currentState == tank.state.Tackle then
                tank.tackleIndicatorSprite.tint_color = Vector4.new(1, 0, 0, 0)
                tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))
                tank.isCharging = false
                tank.canTackle = false
                tank.tackleTimer = 0.0
                tank.currentState = tank.state.Move
            end
        end
    end)

    tank.enemyRbComponent:on_collision_exit(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
    
        if (nameA == "Player" or nameB == "Player") then
            tank.collisionWithPlayer = false
            tank.isFirstAttack = true
        end
    end)

end

function on_update(dt)

    if tank.isDead then return end

    if tank.zoneSet ~= true then
        tank:check_spawn()
        tank.zoneSet = true
    end

    if Input.is_key_pressed(Input.keycode.L) then
       tank.level = 1
       tank:set_stats(tank.level)
       print("Tank Level 1 active")
    elseif Input.is_key_pressed(Input.keycode.O) then
       tank.level = 2
       tank:set_stats(tank.level)
       print("Tank Level 2 active")
    end

    if not tank.isBerserkaActive then
        tank:check_effects(dt)
    end

    if not tank.hasFoundNearbyEnemies then
        tank:find_nearby_enemies()
        tank.hasFoundNearbyEnemies = true
    end

    change_state(dt)

    if tank.health <= 0 then
        if tank.key ~= 0 then
            tank.playerScript.enemys_targeting = tank.playerScript.enemys_targeting - 1
            tank.key = 0
        end
        tank.currentState = tank.state.Dead
    end

    if tank.haveShield and tank.enemyShield <= 0 then
        tank.haveShield = false
        tank.shield_destroyed = true
        tank.currentState = tank.state.Stun
    end

    tank.moveAudioTimer = tank.moveAudioTimer + dt
    tank.pathUpdateTimer = tank.pathUpdateTimer + dt
    if tank.enemyHit then
        tank.hitTimer = tank.hitTimer + dt 
    end
    tank.hitAudioTimer = tank.hitAudioTimer + dt

    tank:reset_material()

    local currentTargetPos = tank.playerTransf.position
    if tank.pathUpdateTimer >= tank.pathUpdateInterval or tank:get_distance(tank.lastTargetPos, currentTargetPos) > 1.0 then
        tank.lastTargetPos = currentTargetPos

        tank:check_initial_distance()
        if not tank.isReturning then
            tank:update_path(tank.playerTransf)
        else
            tank:update_path_position(tank.enemyInitialPos)
        end
        
        tank.pathUpdateTimer = 0
    end

    -- Update tackle cooldown timer
    if not tank.canTackle then
        tank.tackleTimer = tank.tackleTimer + dt
        if tank.tackleTimer >= tank.tackleCooldown then
            tank.canTackle = true
            tank.tackleTimer = 0.0
        end
    end

    if isAlerted then
        tank.alertTimer = tank.alertTimer + dt
        if tank.alertTimer >= tank.alertCooldown then
            tank.isAlerted = false
            tank.alertTimer = 0.0
        end
    end

    if tank.update_berserka then
        tank:update_berserka(dt)
    end

    if tank.isPlayingAnimation then
        tank.animTimer = tank.animTimer + dt
        tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))

        if tank.animTimer >= tank.animDuration then
            tank.isPlayingAnimation = false
        else
            return
        end
    end

    if tank.playerDetected and tank.currentState ~= tank.state.Tackle and tank.currentState ~= tank.state.Detect then
        if tank.key == 0 then
             
            tank.playerScript.enemys_targeting = tank.playerScript.enemys_targeting + 1
            tank.key = tank.key + 1
        end
        if not tank.playingDieAnim then
            tank:rotate_enemy(tank.playerTransf.position)
        end
    end
    
    if tank.currentState == tank.state.Dead then
        if self:get_component("TagComponent").tag == "EnemyTank1" then
            mission_Component.m9_EnemyCount = true
        end

        tank:die_state(dt)
        return

    elseif tank.currentState == tank.state.Idle then
        tank:idle_state(dt)
        
    elseif tank.currentState == tank.state.Detect then
        tank.meleeAreaRb:set_position(Vector3.new(0, -50, 0))
        tank:detect_state(dt)

    elseif tank.currentState == tank.state.Move then 
        tank:move_state()

    elseif tank.currentState == tank.state.Attack then
        tank:attack_state(dt)

    elseif tank.currentState == tank.state.Tackle then
        tank:tackle_state()

    elseif tank.currentState == tank.state.Stun then
        tank:stun_state()
    end

end

function tank:is_other_tank_in_tackle()

    local entities = current_scene:get_all_entities()
    for _, entity in ipairs(entities) do
        local tagComponent = entity:get_component("TagComponent")
        if tagComponent and tagComponent.tag == "EnemyTank" and entity ~= self then
            local otherTankScript = entity:get_component("ScriptComponent")
            if otherTankScript then                
                local tankInstance = otherTankScript.tank
                if tankInstance then
                    if tankInstance.currentState == self.state.Tackle then
                        return true
                    end
                end
            end
        end
    end
    
    return false  

end

function change_state(dt)

    if tank.isPlayingAnimation then return end

    tank:enemy_raycast(dt)
    tank:check_player_distance()

    if tank.playerDetected and not tank.isAlerted then
        tank.currentState = tank.state.Detect
        tank:avoid_alert_enemies()
        return
    end

    if tank.isPlayingBerserkaAnim then 
        if tank.animTimer >= tank.berserkaDuration then
            tank.isPlayingBerserkaAnim = false
        end
        return 
    end

    if tank.collisionWithPlayer then
        if tank.currentState == tank.state.Tackle or tank.currentState == tank.state.Move then
            tank.currentState = tank.state.Attack
        elseif tank.currentState == tank.state.Attack and tank.playerDistance > tank.meleeAttackRange then
            tank.currentState = tank.state.Move
        end
        return
    end

    if tank.playerDetected and tank.canTackle then
        local distanceToPlayer = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position)
        if not tank:is_other_tank_in_tackle() and distanceToPlayer > tank.minTackleDistance then
            if tank.currentState ~= tank.state.Tackle then
                tank.currentState = tank.state.Tackle
                tank.isCharging = true
                local direction = Vector3.new(
                    tank.playerTransf.position.x - tank.enemyTransf.position.x,
                    0,
                    tank.playerTransf.position.z - tank.enemyTransf.position.z
                )
                local distance = math.sqrt(direction.x^2 + direction.z^2)
                if distance > 0 then
                    direction.x = direction.x / distance
                    direction.z = direction.z / distance
                end
                tank.targetDirection = direction 
            end
        end
        return
    end

    if tank.playerDetected then
        if tank.currentState ~= tank.state.Move then
            tank.currentState = tank.state.Move
        end
        return
    end

    if tank.currentState ~= tank.state.Idle and not tank.isReturning then
        tank.currentState = tank.state.Idle
    end

end

function tank:idle_state(dt) 

    if tank.currentAnim ~= tank.idleAnim then
        tank:play_blocking_animation(tank.idleAnim, tank.idleDuration)
    end

    -- Periodic scan for player
    if tank.idleTimer >= tank.idleDuration then
        tank.idleTimer = 0.0

        if tank.collisionWithPlayer then
            tank.currentState = tank.state.Attack
        end
    end

end

function tank:attack_state(dt)
    
    if tank.isFirstAttack then
        tank.attackTimer = tank.attackCooldown 
        tank.isFirstAttack = false
    else
        tank.attackTimer = tank.attackTimer + dt
    end
    
    tank.enemyRb:set_velocity(Vector3.new(0, 0, 0)) 
    tank:rotate_enemy(tank.playerTransf.position) 

    if tank.attackTimer >= tank.attackCooldown then
        if tank.currentAnim ~= tank.attackAnim then
            tank:play_blocking_animation(tank.attackAnim, tank.attackDuration)
        end

        if tank.animTimer >= tank.attackDuration then
            local attackDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position)
            if attackDistance <= tank.meleeAttackRange then
                tank.impactPlayerSFX:play()
                tank.meleeAreaRb:set_position(tank.enemyTransf.position)
            else
                tank.currentState = tank.state.Move
                tank.meleeAreaRb:set_position(Vector3.new(0, -50, 0))
            end
            tank.attackTimer = 0.0
        end

    end

end

function tank:tackle_state()
    if tank.currentAnim ~= tank.tackleAnim then
        tank.currentAnim = tank.tackleAnim
        tank.animator:set_current_animation(tank.currentAnim)
    end

    if tank.isCharging and tank.targetDirection then
        tank.tackleIndicatorSprite.tint_color = Vector4.new(1, 0, 0, 1)

        local velocity = Vector3.new(
            tank.targetDirection.x * tank.tackleSpeed,
            0,
            tank.targetDirection.z * tank.tackleSpeed
        )

        tank.enemyRb:set_velocity(velocity)
            tank:rotate_enemy(Vector3.new(
            tank.enemyTransf.position.x + tank.targetDirection.x,
            tank.enemyTransf.position.y,
            tank.enemyTransf.position.z + tank.targetDirection.z
        ))
    else
        tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    end

end

function tank:berserka_rage()
    tank.isBerserkaActive = true
    tank.isPlayingBerserkaAnim = true

    if tank.currentAnim ~= tank.berserkaAnim then
        tank.berserkerSFX:play()
        tank:play_blocking_animation(tank.berserkaAnim, tank.berserkaDuration)
    end

    tank.originalStats = {
        speed = tank.speed,
        tackleSpeed = tank.tackleSpeed,
    } 

    -- Increase stats 50%
    tank.health = tank.health * stats.statsIncrement
    tank.speed = tank.speed * stats.statsIncrement
    tank.tackleSpeed = tank.tackleSpeed * stats.statsIncrement
    tank.meleeDamage = tank.meleeDamage * stats.statsIncrement
    tank.tackleDamage = tank.tackleDamage * stats.statsIncrement

    function tank:update_berserka(dt)
        self.berserkaTimer = self.berserkaTimer + dt

        if self.berserkaTimer >= self.berserkaDuration then
            -- Reduce stats 33%
            self.health = self.health * stats.statsDecrement
            self.meleeDamage = self.meleeDamage * stats.statsDecrement
            self.tackleDamage = self.tackleDamage * stats.statsDecrement

            self.speed = self.originalStats.speed
            self.tackleSpeed = self.originalStats.tackleSpeed

            self.isBerserkaActive = false
            self.update_berserka = nil
            self.originalStats = nil
        end
    end
end

function tank:find_nearby_enemies()
    tank.nearbyEnemies = {}

    local count = 0
    for _, entity in ipairs(tank.cameraScript.enemies) do
        local tag = entity:get_component("TagComponent")
        local name = entity:get_component("TagComponent").tag
        
        if (name == "EnemyRange" or name == "EnemyTank" or name == "EnemyKamikaze" or name == "EnemySupport") and entity ~= self then
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")
            
            if entityTransform and script then
                local distance = tank:get_distance(tank.enemyTransf.position, entityTransform.position)
                
                if distance <= tank.alertRadius then
                    count = count + 1
                    local enemyData = {
                        entity = entity,
                        transform = entityTransform,
                        script = script[name:lower():sub(6)],
                        distance = distance,
                        alerted = false
                    }
                    table.insert(tank.nearbyEnemies, enemyData)
                end
            end
        end
    end
end

function tank:set_stats(level)
    stats = stats_data[tank.enemyType] and stats_data[tank.enemyType][tank.level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. tank.enemyType .. " level: " .. tank.level) return end

    -- Stats of the Tank
    tank.health = stats.health
    tank.defaultHealth = tank.health
    tank.speed = stats.speed
    tank.defaultSpeed = tank.speed
    tank.tackleSpeed = stats.tackleSpeed
    tank.meleeDamage = stats.meleeDamage
    tank.tackleDamage = stats.tackleDamage
    tank.detectionRange = stats.detectionRange
    tank.meleeAttackRange = stats.meleeAttackRange
    tank.priority = stats.priority
    tank.alertRadius = stats.alertRadius
    tank.minTackleDistance = stats.meleeAttackRange + 3

    -- External Timers
    tank.attackCooldown = stats.attackCooldown
    tank.tackleCooldown = stats.tackleCooldown
    tank.idleDuration = stats.idleDuration
    tank.berserkaDuration = stats.berserkaDuration

end

function on_exit() end