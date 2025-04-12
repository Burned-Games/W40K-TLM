local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")
local effect = require("scripts/utils/status_effects")

range = enemy:new()

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.5
local updateTargetTimer = 0.0
local updateTargetInterval = 1.0
local timeSinceLastHit = 0.0
local timeSinceLastShot = 0.0
local timeBetweenBursts = 1.0
local burstCooldownTimer = 0.0
local burstCooldown = 0.3
local stabTimer = 1.0
local timeSinceLastStab = 0.0
local stabCooldown = 2.0
local stabCooldownTimer = 0.0
local invulnerableTime = 5.0

local bulletPool = {}
local currentBulletIndex = 1
local BULLET_LIFETIME = 5.0
local bulletTimers = {}

function on_ready() 

    range.LevelGeneratorByPosition = current_scene:get_entity_by_name("LevelGeneratorByPosition"):get_component("TransformComponent")

    range.player = current_scene:get_entity_by_name("Player")
    range.playerTransf = range.player:get_component("TransformComponent")
    range.playerScript = range.player:get_component("ScriptComponent")

    range.explosive = current_scene:get_entity_by_name("Explosive")
    range.explosiveTransf = range.explosive:get_component("TransformComponent")

    range.enemyTransf = self:get_component("TransformComponent")
    range.animator = self:get_component("AnimatorComponent")
    range.enemyRbComponent = self:get_component("RigidbodyComponent")
    range.enemyRb = range.enemyRbComponent.rb
    range.enemyNavmesh = self:get_component("NavigationAgentComponent")

    range.scrap = current_scene:get_entity_by_name("Scrap")
    range.scrapTransf = range.scrap:get_component("TransformComponent")

    -- Initialize bullet pool
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
        bullet.rb:set_position(Vector3.new(0, 0, 0))
        bulletPool[i] = bullet
        bulletTimers[i] = 0
    end

    local enemy_type = "range"
    range:set_level()

    local stats = stats_data[enemy_type] and stats_data[enemy_type][range.level]
    -- Debug in case is not working
    if not stats then
        log("No stats for type: " .. enemy_type .. " level: " .. range.level)
        return
    end


    
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
    range.level2 = false
    range.level3 = false
    range.enemyInDanger = false

    range.idleAnim = 3
    range.moveAnim = 4
    range.meleeAttackAnim = 0
    range.rangeAttackAnim = 1
    range.dieAnim = 2

    range.state.Shoot = 4
    range.state.Chase = 5
    range.state.Stab = 6

    range.isShootingBurst = false
    range.isChasing = false
    range.hasDealtDamage = false
    range.isfirstChase = true
    range.hasDealtDamage = false

    range.burstCount = 0

    range.enemyInitialPos = Vector3.new(range.enemyTransf.position.x, 0, range.enemyTransf.position.z)
    range.playerDistance = range:get_distance(range.enemyTransf.position, range.playerTransf.position) + 100        -- **ESTO HAY QUE ARREGLARLO**
    range.lastTargetPos = range.playerTransf.position
    range.delayedPlayerPos = range.playerTransf.position

end

function update_bullets(dt)
    for i, bullet in ipairs(bulletPool) do
        if bullet.active then
            bulletTimers[i] = bulletTimers[i] + dt
            if bulletTimers[i] >= BULLET_LIFETIME then
                deactivate_bullet(i)
            end
        end
    end
end

function deactivate_bullet(index)
    local bullet = bulletPool[index]
    bullet.active = false
    bullet.rb:set_position(Vector3.new(0, 0, 0))
    bullet.rb:set_velocity(Vector3.new(0, 0, 0))
    bulletTimers[index] = 0
    --log("Bullet " .. index .. " deactivated")
    --log("Bullet " .. index .. " position: " .. bullet.rb:get_position().x .. ", " .. bullet.rb:get_position().y .. ", " .. bullet.rb:get_position().z)
end

function on_update(dt) 

    if Input.is_key_pressed(Input.keycode.L) then
        range.level2 = true
        print("Nivel 2 activado")
    elseif Input.is_key_pressed(Input.keycode.O) then
        tank.level2 = false
        print("Nivel 2 desactivado")
    end
    if Input.is_key_pressed(Input.keycode.P) then
        range.level3 = true
        print("Nivel 3 activado")
    elseif Input.is_key_pressed(Input.keycode.I) then
        range.level3 = false
        print("Nivel 3 desactivado")
    end
    if range.isDead then return end

    --check_effects()

    update_bullets(dt)
    change_state()

    if range.currentState == range.state.Idle then return end

    if range.health <= 0 then
        range:die_state()
    end

    if range.haveShield and range.enemyShield <= 0 then
        range.haveShield = false
        range.shieldDestroyed=true
    end

    pathUpdateTimer = pathUpdateTimer + dt
    updateTargetTimer = updateTargetTimer + dt
    timeSinceLastHit = timeSinceLastHit + dt

    if range.invulnerable then
        invulnerableTime = invulnerableTime - dt
        if invulnerableTime <= 0 then
            range.invulnerable = false
            invulnerableTime = 5.0
        end
    end

    local currentTargetPos = range.playerTransf.position
    if pathUpdateTimer >= pathUpdateInterval or range:get_distance(range.lastTargetPos, currentTargetPos) > 1.0 then
        range.lastTargetPos = currentTargetPos
        range:check_initial_distance()
        if range.playerDetected then
            range:update_path(range.playerTransf)
        else
            range:update_path_position(range.enemyInitialPos)
        end
        pathUpdateTimer = 0
    end

    if updateTargetTimer >= updateTargetInterval then
        range.delayedPlayerPos = Vector3.new(range.playerTransf.position.x, range.playerTransf.position.y, range.playerTransf.position.z)
        updateTargetTimer = 0
    end

    if range.playerDetected then
        if range.key == 0 then
             
            range.playerScript.enemys_targeting = range.playerScript.enemys_targeting + 1
            range.key = range.key + 1
        end
        range:rotate_enemy(range.playerTransf.position)
    end

    if range.currentState == range.state.Idle then
        range:idle_state()
        return

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

function change_state()

    range:enemy_raycast()
    range:check_player_distance()

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
                
    elseif range.playerDetected and range.playerDistance <= range.rangeAttackRange and not range.enemyInDanger then
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

        timeSinceLastShot = timeSinceLastShot + dt

        if timeSinceLastShot >= burstCooldown and range.burstCount < range.maxBurstShots then
            shoot_projectile(shouldTargetExplosive)
            range.burstCount = range.burstCount + 1
            timeSinceLastShot = 0

            if range.burstCount >= range.maxBurstShots then
                range.isShootingBurst = false
                burstCooldownTimer = 0
            end
        end
    else
        if range.currentAnim ~= range.idleAnim then
            range.currentAnim = range.idleAnim
            range.animator:set_current_animation(range.currentAnim)
        end

        burstCooldownTimer = burstCooldownTimer + dt

        if burstCooldownTimer >= timeBetweenBursts then
            range.isShootingBurst = true
            range.burstCount = 0
            timeSinceLastShot = 0
        end
    end
end

function range:chase_state()

    if range.level3 then
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
    
    if stabCooldownTimer > 0 then
        stabCooldownTimer = stabCooldownTimer - dt
        if range.currentAnim ~= range.idleAnim then
            range.currentAnim = range.idleAnim
            range.animator:set_current_animation(range.currentAnim)
        end
        return 
    end

        timeSinceLastStab = timeSinceLastStab + dt

    if timeSinceLastStab < stabTimer then
        if range.currentAnim ~= range.meleeAttackAnim then
            range.currentAnim = range.meleeAttackAnim
            range.animator:set_current_animation(range.currentAnim)
        end

        if not range.hasDealtDamage then
            range:make_damage(range.meleeDamage)
            if range.level2 then
                effect:apply_bleed(range.playerScript)
            end
            range.hasDealtDamage = true
        end

    elseif timeSinceLastStab >= stabTimer then
        timeSinceLastStab = 0
        stabCooldownTimer = stabCooldown 
        range.hasDealtDamage = false
    end

end

function shoot_projectile(targetExplosive)
    local bullet = bulletPool[currentBulletIndex]
    
    local startPos = Vector3.new(
        range.enemyTransf.position.x,
        range.enemyTransf.position.y + 0.65,
        range.enemyTransf.position.z
    )
    bullet.rb:set_position(startPos)
    
    -- Target position
    local targetPos = range.delayedPlayerPos -- Default to player
    if targetExplosive and range.explosiveDetected and range.leve3 then -- Switch to explosive if detected
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
    bulletTimers[currentBulletIndex] = 0

    -- collision handling for current bullet
    bullet.rbComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            range:make_damage(range.rangeDamage)
        end
        deactivate_bullet(currentBulletIndex)
    end)

    -- Update bullet index
    currentBulletIndex = currentBulletIndex + 1
    if currentBulletIndex > 5 then
        currentBulletIndex = 1
    end
end

function on_exit() end