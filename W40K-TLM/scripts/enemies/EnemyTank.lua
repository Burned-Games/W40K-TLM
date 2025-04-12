local enemy = require("scripts/utils/enemy")
local stats_data = require("scripts/utils/enemy_stats")

tank = enemy:new()

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.5
local attackTimer = 0.0
local attackCooldown = 3.0
local tackleTimer = 0.0
local tackleCooldown = 10.0
local idleDuration = 1.0
local idleTimer = 0.0

function on_ready()

    tank.LevelGeneratorByPosition = current_scene:get_entity_by_name("LevelGeneratorByPosition"):get_component("TransformComponent")

    tank.player = current_scene:get_entity_by_name("Player")
    tank.playerTransf = tank.player:get_component("TransformComponent")
    tank.playerScript = tank.player:get_component("ScriptComponent")

    tank.enemyTransf = self:get_component("TransformComponent")
    tank.animator = self:get_component("AnimatorComponent")
    tank.enemyRbComponent = self:get_component("RigidbodyComponent")
    tank.enemyRb = tank.enemyRbComponent.rb
    tank.enemyNavmesh = self:get_component("NavigationAgentComponent")



    local enemy_type = "tank"
    tank:set_level()

    local stats = stats_data[enemy_type] and stats_data[enemy_type][tank.level]
    -- Debug in case is not working
    if not stats then
        log("No stats for type: " .. enemy_type .. " level: " .. tank.level)
        return
    end



    -- Stats of the Tank
    tank.health = stats.health
    tank.speed = stats.speed
    tank.tackleSpeed = stats.tackleSpeed
    tank.meleeDamage = stats.meleeDamage
    tank.tackleDamage = stats.tackleDamage
    tank.detectionRange = stats.detectionRange
    tank.meleeAttackRange = stats.meleeAttackRange
    tank.priority = stats.priority


    tank.level2 = false -- Toggle levels for testing
    tank.isBerserkaActive = false 

    tank.state.Tackle = 4

    tank.idleAnim = 3
    tank.moveAnim = 4
    tank.attackAnim = 0
    tank.tackleAnim = 1
    tank.dieAnim = 2

    tank.collisionWithPlayer = false
    tank.isCharging = false
    tank.canTackle = false

    tank.playerDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position) + 100        -- **ESTO HAY QUE ARREGLARLO**
    tank.targetDirection = Vector3.new(0, 0, 0)

    tank.enemyRbComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if (nameA == "Player" or nameB == "Player") then
            tank.collisionWithPlayer = true
            if tank.currentState == tank.state.Tackle or tank.currentState == tank.state.Move then
                tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))
                tank.isCharging = false
                tank.canTackle = false
                tackleTimer = 0

                if tank.currentState == tank.state.Tackle and tank.level2 and not tank.isBerserkaActive then
                    tank:berserka_rage()
                end
                tank.currentState = tank.state.Attack
            end
        else
            if tank.currentState == tank.state.Tackle then
                tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))
                tank.isCharging = false
                tank.canTackle = false
                tackleTimer = 0
                if tank.level2 and not tank.isBerserkaActive then
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

    if Input.is_key_pressed(Input.keycode.L) then
       tank.level2 = true
       print("Nivel 2 activado")
    elseif Input.is_key_pressed(Input.keycode.O) then
       tank.level2 = false
       print("Nivel 2 desactivado")
    end

    if tank.isDead then return end

    change_state()

    if tank.health <= 0 then
        tank:die_state()
    end

    if tank.haveShield and tank.health <= 0 then
        tank.haveShield = false
        tank.shield_destroyed = true
    end

    pathUpdateTimer = pathUpdateTimer + dt

    local currentTargetPos = tank.playerTransf.position
    if pathUpdateTimer >= pathUpdateInterval or tank:get_distance(tank.lastTargetPos, currentTargetPos) > 1.0 then
        tank.lastTargetPos = currentTargetPos
        tank:update_path(tank.playerTransf)
        pathUpdateTimer = 0
    end

    -- Update tackle cooldown timer
    if not tank.canTackle then
        tackleTimer = tackleTimer + dt
        if tackleTimer >= tackleCooldown then
            tank.canTackle = true
            tackleTimer = 0
        end
    end

    if tank.update_berserka then
        tank:update_berserka(dt)
    end

    if tank.playerDetected then
        tank:rotate_enemy(tank.playerTransf.position)
    end

    if tank.currentState == tank.state.Idle then
        tank:idle_state(dt)
        return

    elseif tank.currentState == tank.state.Move then 
        tank:move_state()

    elseif tank.currentState == tank.state.Attack then
        tank:attack_state(dt)

    elseif tank.currentState == tank.state.Tackle then
        tank:tackle_state()
    end

end

function tank:is_other_tank_in_tackle()
    if not tank.level2 then
        return false
    end

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

    idleTimer = idleTimer + dt

    if tank.currentAnim ~= tank.idleAnim then
        tank.currentAnim = tank.idleAnim
        tank.animator:set_current_animation(tank.currentAnim)
    end

    tank.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    -- Periodic scan for player
    if idleTimer >= idleDuration then
        idleTimer = 0

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
    
    attackTimer = attackTimer + dt

    if attackTimer >= attackCooldown then

        local attackDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position)
        if attackDistance <= tank.meleeAttackRange then
            tank:make_damage(tank.meleeDamage)
        end

        attackTimer = 0

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

    if tank.collisionWithPlayer then
        tank:make_damage(tank.tackleDamage)
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

    tank.berserkaTimer = 0
    tank.berserkaDuration = 180 

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