local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")

tank = enemy:new()



function on_ready()

    tank.LevelGeneratorByPosition = current_scene:get_entity_by_name("LevelGeneratorByPosition"):get_component("TransformComponent")

    -- Enemy
    tank.enemyTransf = self:get_component("TransformComponent")
    tank.animator = self:get_component("AnimatorComponent")
    tank.enemyRbComponent = self:get_component("RigidbodyComponent")
    tank.enemyRb = tank.enemyRbComponent.rb
    tank.enemyNavmesh = self:get_component("NavigationAgentComponent")

    -- Player
    tank.player = current_scene:get_entity_by_name("Player")
    tank.playerTransf = tank.player:get_component("TransformComponent")
    tank.playerScript = tank.player:get_component("ScriptComponent")
    for i = 1, 11 do
        tank.playerObjects[i] = current_scene:get_entity_by_name(tank.playerObjectsTagList[i]):get_component("TransformComponent")
    end

    -- Audio 
    tank.berserkerSFX = current_scene:get_entity_by_name("TankBerserkerSFX"):get_component("AudioSourceComponent")
    tank.detectPlayerSFX = current_scene:get_entity_by_name("TankDetectPlayerSFX"):get_component("AudioSourceComponent")
    tank.impactPlayerSFX = current_scene:get_entity_by_name("TankImpactPlayerSFX"):get_component("AudioSourceComponent")
    tank.stepsSFX = current_scene:get_entity_by_name("TankStepsSFX"):get_component("AudioSourceComponent")

    -- Particles
    tank.particleSpark = current_scene:get_entity_by_name("particle_spark"):get_component("ParticlesSystemComponent")
    tank.particleSparkTransf = current_scene:get_entity_by_name("particle_spark"):get_component("TransformComponent")



    -- Level
    tank.enemy_type = "tank"
    tank:set_level()

    local stats = stats_data[tank.enemy_type] and stats_data[tank.enemy_type][tank.level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. tank.enemy_type .. " level: " .. tank.level) return end



    -- States
    tank.state = {Dead = 1, Idle = 2, Move = 3, Attack = 4, Tackle = 5}

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

    -- External Timers
    tank.attackCooldown = stats.attackCooldown
    tank.tackleCooldown = stats.tackleCooldown
    tank.idleDuration = stats.idleDuration
    tank.berserkaDuration = stats.berserkaDuration

    -- Internal Timers
    tank.pathUpdateTimer = 0.0
    tank.pathUpdateInterval = 0.1
    tank.attackTimer = 0.0
    tank.tackleTimer = 0.0
    tank.idleTimer = 0.0
    tank.berserkaTimer = 0.0

    -- Animations
    tank.idleAnim = 3
    tank.moveAnim = 4
    tank.attackAnim = 0
    tank.tackleAnim = 1
    tank.dieAnim = 2

    -- Bools
    tank.isBerserkaActive = false 
    tank.collisionWithPlayer = false
    tank.isCharging = false
    tank.canTackle = false

    -- Positions
    tank.targetDirection = Vector3.new(0, 0, 0)
    tank.playerDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position) + 100



    -- On Collision functions
    tank.enemyRbComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if (nameA == "Player" or nameB == "Player") then
            tank.collisionWithPlayer = true
            if tank.currentState == tank.state.Tackle or tank.currentState == tank.state.Move then
                tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))
                tank.isCharging = false
                tank.canTackle = false
                tank.tackleTimer = 0.0

                if tank.currentState == tank.state.Tackle then
                    tank.particleSparkTransf.position = tank.playerTransf.position
                    tank.particleSpark:emit(5)
                    tank:make_damage(tank.tackleDamage)
                    
                    if tank.level == 2 and not tank.isBerserkaActive then
                        tank:berserka_rage()
                    end
                end
                tank.currentState = tank.state.Attack
            end
        else
            if tank.currentState == tank.state.Tackle then
                tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))
                tank.isCharging = false
                tank.canTackle = false
                tank.tackleTimer = 0.0
                if tank.level == 2 and not tank.isBerserkaActive then
                    tank:berserka_rage()
                end
                tank.currentState = tank.state.Move
            end
        end
    end)

    tank.enemyRbComponent:on_collision_exit(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
    
        if (nameA == "Player" or nameB == "Player") then
            tank.collisionWithPlayer = false
        end
    end)

end

function on_update(dt)

    if tank.isDead then return end

    if Input.is_key_pressed(Input.keycode.L) then
       tank.level = 1
       print("Tank Level 1 active")
    elseif Input.is_key_pressed(Input.keycode.O) then
       tank.level = 2
       print("Tank Level 2 active")
    end

    tank:check_effects(dt)
    tank:check_pushed(dt)

    if tank.isPushed == true then return end

    change_state()

    if tank.health <= 0 then
        if tank.key ~= 0 then
            tank.playerScript.enemys_targeting = tank.playerScript.enemys_targeting - 1
            tank.key = 0
        end
        tank:die_state()
    end

    if tank.haveShield and tank.health <= 0 then
        tank.haveShield = false
        tank.shield_destroyed = true
    end

    tank.pathUpdateTimer = tank.pathUpdateTimer + dt

    local currentTargetPos = tank.playerTransf.position
    if tank.pathUpdateTimer >= tank.pathUpdateInterval or tank:get_distance(tank.lastTargetPos, currentTargetPos) > 1.0 then
        tank.lastTargetPos = currentTargetPos
        tank:update_path(tank.playerTransf)
        tank.pathUpdateTimer = 0.0
    end

    -- Update tackle cooldown timer
    if not tank.canTackle then
        tank.tackleTimer = tank.tackleTimer + dt
        if tank.tackleTimer >= tank.tackleCooldown then
            tank.canTackle = true
            tank.tackleTimer = 0.0
        end
    end

    if tank.update_berserka then
        tank:update_berserka(dt)
    end

    if tank.playerDetected and tank.currentState ~= tank.state.Tackle then
        tank:rotate_enemy(tank.playerTransf.position)
    end

    if tank.currentState == tank.state.Idle then
        tank:idle_state(dt)
        return

    elseif tank.currentState == tank.state.Move then 
        if tank.key == 0 then
             
            tank.playerScript.enemys_targeting = tank.playerScript.enemys_targeting + 1
            tank.key = tank.key + 1
        end
        tank:move_state()

    elseif tank.currentState == tank.state.Attack then
        tank:attack_state(dt)

    elseif tank.currentState == tank.state.Tackle then
        tank:tackle_state()
    end

end

function tank:is_other_tank_in_tackle()

    if tank.level ~= 2 then return false end

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

function change_state()

    tank:enemy_raycast()
    tank:check_player_distance()

    if tank.collisionWithPlayer then
        if tank.currentState == tank.state.Tackle or tank.currentState == tank.state.Move then
            tank.currentState = tank.state.Attack
        elseif tank.currentState == tank.state.Attack and tank.playerDistance > tank.meleeAttackRange then
            tank.currentState = tank.state.Move
        end
        return
    end

    if tank.playerDetected and tank.canTackle then
        if not tank:is_other_tank_in_tackle() then
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

    if tank.currentState ~= tank.state.Idle then
        tank.currentState = tank.state.Idle
    end

end

function tank:idle_state(dt) 

    tank.idleTimer = tank.idleTimer + dt

    if tank.currentAnim ~= tank.idleAnim then
        tank.currentAnim = tank.idleAnim
        tank.animator:set_current_animation(tank.currentAnim)
    end

    tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    -- Periodic scan for player
    if tank.idleTimer >= tank.idleDuration then
        tank.idleTimer = 0.0

        if tank.collisionWithPlayer then
            tank.currentState = tank.state.Attack
        end
    end

end

function tank:attack_state(dt)

    if tank.currentAnim ~= tank.attackAnim then
        tank.currentAnim = tank.attackAnim
        tank.animator:set_current_animation(tank.currentAnim)
    end

    tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    tank:rotate_enemy(tank.playerTransf.position)
    
    tank.attackTimer = tank.attackTimer + dt

    if tank.attackTimer >= tank.attackCooldown then

        local attackDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position)
        if attackDistance <= tank.meleeAttackRange then
            tank.particleSparkTransf.position = tank.playerTransf.position
            tank.particleSpark:emit(5)
            tank:make_damage(tank.meleeDamage)
        end

        tank.attackTimer = 0.0

        local attackDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position)
        if tank.collisionWithPlayer then
            tank.currentState = tank.state.Idle
        elseif attackDistance > tank.meleeAttackRange then
            tank.currentState = tank.state.Move
        end

    end

end

function tank:tackle_state()
    if tank.currentAnim ~= tank.tackleAnim then
        tank.currentAnim = tank.tackleAnim
        tank.animator:set_current_animation(tank.currentAnim)
    end

    if tank.isCharging and tank.targetDirection then
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

function on_exit() end