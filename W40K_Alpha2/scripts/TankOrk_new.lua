local enemy = require("scripts/utils/enemy")

tank = enemy:new()

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.5

function on_ready()

    tank.player = current_scene:get_entity_by_name("Player")
    tank.playerTransf = tank.player:get_component("TransformComponent")
    tank.playerScript = tank.player:get_component("ScriptComponent")

    tank.enemyTransf = self:get_component("TransformComponent")
    tank.animator = self:get_component("AnimatorComponent")
    tank.enemyRbComponent = self:get_component("RigidbodyComponent")
    tank.enemyRb = tank.enemyRbComponent.rb
    tank.enemyNavmesh = self:get_component("NavigationAgentComponent")



    -- Stats of the Range
    tank.health = 250
    tank.speed = 2
    tank.detectionRange = 20



    tank.idleAnim = 3
    tank.moveAnim = 4
    tank.attackAnim = 0
    tank.dieAnim = 2

    tank.playerDistance = tank:get_distance(tank.enemyTransf.position, tank.playerTransf.position) + 100        -- **ESTO HAY QUE ARREGLARLO**
    tank.lastTargetPos = tank.playerTransf.position
    tank.delayedPlayerPos = tank.playerTransf.position

end

function on_update(dt)

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

    if tank.playerDetected then
        tank:rotate_enemy(tank.playerTransf.position)
    end

    if tank.currentState == tank.state.Idle then
        tank:idle_state()
        return

    elseif tank.currentState == tank.state.Chase then 
        tank:chase_state()

    elseif tank.currentState == tank.state.Attack then
        tank:attack_state()

    elseif tan.currentState == tank.state.Tackle then
        tank:tackle_state()
    end

end

function change_state()
    
    tank:enemy_raycast()

    if playerDetected and playerTransf then
        playerDistance = get_distance(tankTransform.position, playerTransf.position)
    else
        playerDistance = math.huge
    end

    if player and playerTransf then 
        if playerDetected and playerDistance <= meleeDistance then
            -- Close enough to attack
            if currentState ~= state.Attack then
                currentState = state.Attack
                attackTimer = 0 -- Reset attack timer
            end
        elseif playerDistance <= tackleDistance and canTackle then
            -- Within tackle range but not attack range AND tackle is not on cooldown
            if currentState ~= state.Tackle and currentState ~= state.Attack then
                currentState = state.Tackle
                IsCharging = true
            end
        elseif playerDetected then
            -- Player detected but not close enough for attack or tackle
            if currentState ~= state.Chase and currentState ~= state.Attack and currentState ~= state.Tackle then
                currentState = state.Chase
                targetPosition = playerTransf.position -- Guardar la posición actual del jugador
            end
        else
            -- Out of range, go idle
            if currentState ~= state.Idle then
                currentState = state.Idle
            end
        end
    else
        -- No player detected, go idle
        if currentState ~= state.Idle then
            currentState = state.Idle
        end
    end

end

function on_exit() end