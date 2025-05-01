local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

range = enemy:new()



function on_ready() 

    range.LevelGeneratorByPosition = current_scene:get_entity_by_name("LevelGeneratorByPosition"):get_component("TransformComponent")

    -- Enemy
    range.enemyTransf = self:get_component("TransformComponent")
    range.animator = self:get_component("AnimatorComponent")
    range.enemyRbComponent = self:get_component("RigidbodyComponent")
    range.enemyRb = range.enemyRbComponent.rb
    range.enemyNavmesh = self:get_component("NavigationAgentComponent")

    -- Player
    range.player = current_scene:get_entity_by_name("Player")
    range.playerTransf = range.player:get_component("TransformComponent")
    range.playerScript = range.player:get_component("ScriptComponent")
    for i = 1, 11 do
        range.playerObjects[i] = current_scene:get_entity_by_name(range.playerObjectsTagList[i]):get_component("TransformComponent")
    end

    -- Explosive
    range.explosive = current_scene:get_entity_by_name("Explosive")
    range.explosiveTransf = range.explosive:get_component("TransformComponent")

    -- Mision
    range.misionManager = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    range.enemyDie = false

    -- Particles
    range.particleSpark = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    range.particleSparkTransf = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")

    -- Audio
    range.dyingSFX = current_scene:get_entity_by_name("RangeDyingSFX"):get_component("AudioSourceComponent")
    range.hurtSFX = current_scene:get_entity_by_name("RangeHurtSFX"):get_component("AudioSourceComponent")
    --range.bulletImpactSFX = current_scene:get_entity_by_name("RangeBulletImpactSFX"):get_component("AudioSourceComponent")
    range.meleeImpactSFX = current_scene:get_entity_by_name("RangeCaCImpactSFX"):get_component("AudioSourceComponent")
    range.rangeShotSFX = current_scene:get_entity_by_name("RangeShotSFX"):get_component("AudioSourceComponent")
    
    -- Bullet pool
    range.bulletPool = {}
    range.bulletTimers = {}
    for i = 1, 5 do
        local bulletEntity = current_scene:get_entity_by_name("EnemyBullet" .. i)

        local bullet = {
            entity = bulletEntity,
            transform = bulletEntity:get_component("TransformComponent"),
            rbComponent = bulletEntity:get_component("RigidbodyComponent"),
            active = false
        }

        bullet.rb = bullet.rbComponent.rb
        bullet.rb:set_trigger(true)
        bullet.rb:set_position(Vector3.new(0, -5, 0))

        range.bulletPool[i] = bullet
        range.bulletTimers[i] = 0
    end



    -- Level
    range.enemyType = "range"
    range:set_level()

    local stats = stats_data[range.enemyType] and stats_data[range.enemyType][range.level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. range.enemyType .. " level: " .. range.level) return end



    -- States
    range.state = {Dead = 1, Idle = 2, Move = 3, Attack = 4, Shoot = 5, Chase = 6, Stab = 7}

    -- Stats of the Range
    range.health = stats.health
    range.speed = stats.speed
    range.bulletSpeed = stats.bulletSpeed
    range.meleeDamage = stats.meleeDamage
    range.rangeDamage = stats.rangeDamage
    range.detectionRange = stats.detectionRange
    range.meleeAttackRange = stats.meleeAttackRange
    range.rangeAttackRange = stats.rangeAttackRange
    range.chaseRange = stats.chaseRange
    range.maxBurstShots = stats.maxBurstShots
    range.priority = stats.priority

    -- External Timers
    range.updateTargetInterval = stats.updateTargetInterval
    range.timeBetweenBursts = stats.timeBetweenBursts
    range.burstCooldown = stats.burstCooldown
    range.stabCooldown = stats.stabCooldown
    range.invulnerableTime = stats.invulnerableTime
    range.alertRadius = stats.alertRadius

    -- Internal Timers
    range.pathUpdateTimer = 0.0
    range.pathUpdateInterval = 0.1
    range.updateTargetTimer = 0.0
    range.timeSinceLastShot = 0.0
    range.burstCooldownTimer = 0.0
    range.timeSinceLastStab = 0.0
    range.stabCooldownTimer = 0.0
    range.stabTimer = 1.0
    range.bulletLifetime = 5.0
    range.findRangesTimer = 0.0
    range.findRangesInterval = 1.5

    -- Animations
    range.idleAnim = 3
    range.moveAnim = 4
    range.meleeAttackAnim = 0
    range.rangeAttackAnim = 1
    range.dieAnim = 2

    -- Bools
    range.isShootingBurst = false
    range.isChasing = false
    range.hasDealtDamage = false
    range.isfirstChase = true
    range.hasDealtDamage = false
    range.isAlerted = false

    -- Ints
    range.burstCount = 0
    range.currentBulletIndex = 1

    -- Timers
    range.dieTimer = 0
    range.dieAnimDuration = 61

    -- Lists
    range.nearbyRanges = {}

    -- Positions
    range.enemyInitialPos = Vector3.new(range.enemyTransf.position.x, range.enemyTransf.position.y, range.enemyTransf.position.z)
    range.lastTargetPos = range.playerTransf.position
    range.delayedPlayerPos = range.playerTransf.position

    range.playerDistance = range:get_distance(range.enemyTransf.position, range.playerTransf.position) + 100

end



function on_update(dt) 

    -- If the enemy is dead doesn't enter the on_update function
    if range.isDead then return end

    if range.playingDieAnim then
        range.enemyRb:set_trigger(true)
        range.enemyRb:set_velocity(Vector3.new(0, 0, 0))
        range.dieTimer = range.dieTimer + 1
    end



    -- Setting the zone to know if the enemy can spawn
    if range.zoneSet ~= true then
        range:check_spawn()
        range.zoneSet = true
    end

    if Input.is_key_pressed(Input.keycode.L) then
        range.level = 1
        print("Range Level 1 active")
    elseif Input.is_key_pressed(Input.keycode.O) then
        range.level = 2
        print("Range Level 2 active")
    elseif Input.is_key_pressed(Input.keycode.P) then
        range.level = 3
        print("Range Level 3 active")
    end

    range:check_effects(dt)
    range:check_pushed(dt)

    if range.isPushed then return end
        
    update_bullets(dt)
    change_state(dt)

    if range.currentState == range.state.Idle then return end
    
    if range.health <= 0 then
        if range.key ~= 0 then
            
            range.playerScript.enemys_targeting = range.playerScript.enemys_targeting - 1
            range.key = 0
        end
        range.currentState = range.state.Dead
    end

    if range.haveShield and range.enemyShield <= 0 then
        range.haveShield = false
        range.shieldDestroyed=true
    end

    range.pathUpdateTimer = range.pathUpdateTimer + dt
    range.updateTargetTimer = range.updateTargetTimer + dt

    if range.invulnerable then
        range.invulnerableTime = range.invulnerableTime - dt
        if range.invulnerableTime <= 0 then
            range.invulnerable = false
            range.invulnerableTime = 5.0
        end
    end

    if isAlerted then
        range.alertTimer = range.alertTimer + dt
        if range.alertTimer >= range.alertCooldown then
            range.isAlerted = false
            range.alertTimer = 0.0
        end
    end
    
    local currentTargetPos = range.playerTransf.position
    if range.pathUpdateTimer >= range.pathUpdateInterval or range:get_distance(range.lastTargetPos, currentTargetPos) > 1.0 then
        range.lastTargetPos = currentTargetPos
        range:check_initial_distance()
        if range.playerDetected then
            range:update_path(range.playerTransf)
        else
            range:update_path_position(range.enemyInitialPos)
        end
        range.pathUpdateTimer = 0
    end

    if range.updateTargetTimer >= range.updateTargetInterval then
        range.delayedPlayerPos = Vector3.new(range.playerTransf.position.x, range.playerTransf.position.y, range.playerTransf.position.z)
        range.updateTargetTimer = 0
    end

    if range.playerDetected then
        if range.key == 0 then
             
            range.playerScript.enemys_targeting = range.playerScript.enemys_targeting + 1
            range.key = range.key + 1
        end
        range:rotate_enemy(range.playerTransf.position)
    end

    if range.currentState == range.state.Dead then
        range:die_state(dt)
        return
    elseif range.currentState == range.state.Idle then
        range:idle_state()

    elseif range.currentState == range.state.Move then
        range:move_state()

    elseif range.currentState == range.state.Shoot then
        range:shoot_state(dt)

    elseif range.currentState == range.state.Chase then
        range:chase_state()

    elseif range.currentState == range.state.Stab then
        range:stab_state(dt)
    end

end

function change_state(dt)

    range:enemy_raycast()
    range:check_player_distance()

    range.findRangesTimer = range.findRangesTimer + dt

    -- Check for nearby ranges periodically
    if range.findRangesTimer >= range.findRangesInterval then
        if range.playerDetected then
            range:find_nearby_ranges()
            range:alert_nearby_ranges(dt)
        end
        range.findRangesTimer = 0
    end

    -- If is Chasing don't return to Shoot or Move
    if range.isChasing then
        if range.playerDistance <= range.meleeAttackRange then
            if range.currentState ~= range.state.Stab then
                range.currentState = range.state.Stab
            end
                
        elseif range.playerDistance > range.meleeAttackRange and range.currentState == range.state.Stab then
            range.currentState = range.state.Chase
        end
                
        return
    end

    -- **IMPORTANT ORDER** Chase and Stab have to evaluate each other first, otherwise it won't work well !!!
    if range.playerDistance <= range.meleeAttackRange then
        if range.currentState ~= range.state.Stab then
            range.currentState = range.state.Stab
            range.isChasing = true
        end
                
    elseif range.playerDistance <= range.chaseRange then
        if range.currentState ~= range.state.Chase then
            range.currentState = range.state.Chase
            range.isChasing = true
        end
                
    elseif range.playerDetected and range.playerDistance <= range.rangeAttackRange then
        if range.currentState ~= range.state.Shoot then
            range.currentState = range.state.Shoot
        end
                
    elseif range.playerDetected and range.playerDistance > range.rangeAttackRange then
        if range.currentState ~= range.state.Move then
            range.currentState = range.state.Move
        end
    end

end



function range:shoot_state(dt)

    range.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    --Checks if explosive is detected and within range of the player
    local shouldTargetExplosive = false
    if range.explosiveDetected then
        local playerToExplosive = range:get_distance(range.playerTransf.position, range.explosiveTransf.position)
        if playerToExplosive <= 5.0 then
            shouldTargetExplosive = true
        end
    end

    if range.isShootingBurst then
        if range.currentAnim ~= range.rangeAttackAnim then
            range.currentAnim = range.rangeAttackAnim
            range.animator:set_current_animation(range.currentAnim)
        end 

        range.timeSinceLastShot = range.timeSinceLastShot + dt

        if range.timeSinceLastShot >= range.burstCooldown and range.burstCount < range.maxBurstShots then
            shoot_projectile(shouldTargetExplosive)
            range.burstCount = range.burstCount + 1
            range.timeSinceLastShot = 0
            range.rangeShotSFX:play()

            if range.burstCount >= range.maxBurstShots then
                range.isShootingBurst = false
                range.burstCooldownTimer = 0
            end
        end
    else
        if range.currentAnim ~= range.idleAnim then
            range.currentAnim = range.idleAnim
            range.animator:set_current_animation(range.currentAnim)
        end

        range.burstCooldownTimer = range.burstCooldownTimer + dt

        if range.burstCooldownTimer >= range.timeBetweenBursts then
            range.isShootingBurst = true
            range.burstCount = 0
            range.timeSinceLastShot = 0
        end
    end

end

function range:chase_state()

    if range.level == 3 then
        if range.isfirstChase then
            range.invulnerable = true
            range.isfirstChase = false
        end
    end
    
    if range.currentAnim ~= range.moveAnim then
        range.currentAnim = range.moveAnim
        range.animator:set_current_animation(range.currentAnim)
    end

    range:follow_path()

end

function range:stab_state(dt)

    range.enemyRb:set_velocity(Vector3.new(0, 0, 0))
    
    if range.stabCooldownTimer > 0 then
        range.stabCooldownTimer = range.stabCooldownTimer - dt
        if range.currentAnim ~= range.idleAnim then
            range.currentAnim = range.idleAnim
            range.animator:set_current_animation(range.currentAnim)
        end
        return 
    end

        range.timeSinceLastStab = range.timeSinceLastStab + dt

    if range.timeSinceLastStab < range.stabTimer then
        if range.currentAnim ~= range.meleeAttackAnim then
            range.currentAnim = range.meleeAttackAnim
            range.animator:set_current_animation(range.currentAnim)
        end

        if not range.hasDealtDamage then
            range.particleSparkTransf.position = range.playerTransf.position
            range.particleSpark:emit(5)

            range.meleeImpactSFX:play()
            range:make_damage(range.meleeDamage)
            if range.level > 1 then
                effect:apply_bleed(range.playerScript)
            end

            range.hasDealtDamage = true
        end

    elseif range.timeSinceLastStab >= range.stabTimer then
        range.timeSinceLastStab = 0
        range.stabCooldownTimer = range.stabCooldown 
        range.hasDealtDamage = false
    end

end



function update_bullets(dt)

    for i, bullet in ipairs(range.bulletPool) do
        if bullet.active then
            range.bulletTimers[i] = range.bulletTimers[i] + dt
            if range.bulletTimers[i] >= range.bulletLifetime then
                deactivate_bullet(i)
            end
        end
    end

end

function deactivate_bullet(index)

    local bullet = range.bulletPool[index]
    bullet.active = false

    bullet.rb:set_position(Vector3.new(0, 0, 0))
    bullet.rb:set_velocity(Vector3.new(0, 0, 0))

    range.bulletTimers[index] = 0

end

function shoot_projectile(targetExplosive)

    local bullet = range.bulletPool[range.currentBulletIndex]
    
    local startPos = Vector3.new(
        range.enemyTransf.position.x - 1,
        range.enemyTransf.position.y + 0.982,
        range.enemyTransf.position.z - 0.1
    )
    bullet.rb:set_position(startPos)
    
    -- Target position
    local targetPos = range.delayedPlayerPos -- Default to player
    if targetExplosive and range.explosiveDetected and range.level == 3 then -- Switch to explosive if detected
        targetPos = range.explosiveTransf.position 
    end

    -- Calculate normalized direction
    local dx = targetPos.x - startPos.x
    local dz = targetPos.z - startPos.z
    
    -- Set velocity and activate bullet
    bullet.rb:set_velocity(Vector3.new(
        dx * range.bulletSpeed,
        0,
        dz * range.bulletSpeed
    ))
    bullet.active = true
    range.bulletTimers[range.currentBulletIndex] = 0

    -- Collision handling for current bullet
    bullet.rbComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            range.particleSparkTransf.position = range.playerTransf.position
            range.particleSpark:emit(5) 
            range:make_damage(range.rangeDamage) 
        end
        
        deactivate_bullet(range.currentBulletIndex)
    end)

    -- Update bullet index
    range.currentBulletIndex = range.currentBulletIndex + 1
    if range.currentBulletIndex > 5 then
        range.currentBulletIndex = 1
    end

end
function range:find_nearby_ranges()
    range.nearbyRanges = {}
    
    local all_entities = current_scene:get_all_entities()    
    
    local count = 0
    for _, entity in ipairs(all_entities) do
        local tag = entity:get_component("TagComponent")
        local name = entity:get_component("TagComponent").tag
        
        if name == "EnemyRange" and entity ~= self then
            local script = entity:get_component("ScriptComponent")
            local entityTransform = entity:get_component("TransformComponent")
            
            if entityTransform and script then
                local distance = range:get_distance(range.enemyTransf.position, entityTransform.position)
                
                if distance <= range.alertRadius then
                    count = count + 1
                    local rangeData = {
                        entity = entity,
                        transform = entityTransform,
                        script = script.range,
                        distance = distance,
                        alerted = false
                    }
                    table.insert(range.nearbyRanges, rangeData)
                end
            end
        end
    end
end

function range:alert_nearby_ranges(dt)  
    if range.isAlerted then return end
    
    local alertedCount = 0
    for _, rangeData in ipairs(range.nearbyRanges) do
        if rangeData.script and not rangeData.alerted then
            rangeData.script.playerDetected = true
            rangeData.script.isAlerted = true
            rangeData.script.alertTimer = 0.0
            if range:get_distance(rangeData.transform.position, range.playerTransf.position) > range.rangeAttackRange then
                rangeData.script.currentState = range.state.Move
            end
            rangeData.alerted = true
            alertedCount = alertedCount + 1
        end
    end
    range.isAlerted = true
end

function on_exit() end