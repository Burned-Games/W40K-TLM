local state = { Idle = 1, Move = 2, Chase = 3, Attack = 4, Tackle = 5 }
local currentState = state.Idle

local player = nil
local playerTransf = nil
local playerScript = nil

-- Squighog stats 
local squighogHealth = 100
local squighogSpeed = 5
local isDead = false

local squighogNavmesh = nil 
local squighogRb = nil
local squighogTransf = nil

local detectRange = 30

-- Squighog habilities
local attackType = nil

local chargeSpeed = 10 
local chargeRangeAttack = 3 
local chargeCooldown = 5
local chargeDmg = 5
local isCharging = false 
local ChargeTime = 0

local tailwhipRangeAttack = 1
local tailwhipCooldown = 10
local tailwhipDmg = 10
local TailWhipTime = 0

--local animator = nil

local pathUpdateTimer = 0
local pathUpdateInterval = 0.5
local lastTargetPos = nil
local currentPathIndex = 1

function on_ready() 
    player = current_scene:get_entity_by_name("Player")
    if player then
        playerTransf = player:get_component("TransformComponent")
        playerScript = player:get_component("ScriptComponent")
    end

    squighogTransf = self:get_component("TransformComponent")
    squighogRb = self:get_component("RigidbodyComponent").rb
    squighogNavmesh = self:get_component("NavigationAgentComponent")
    
    --animator = self:get_component("AnimatorComponent")
end 

function on_collision(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then 
        if attackType and canDealDamage then
            make_damage(attackType)  
            attackType = nil 
            canDealDamage = false
            chargeTimer = 1
        end
    end 
end

function on_update(dt)
    if not player or isDead then return end
    if squighogHealth <= 0 then die() end

    pathUpdateTimer = pathUpdateTimer + dt
    
    
    if pathUpdateTimer >= pathUpdateInterval then
        update_path()
        pathUpdateTimer = 0
    end

    if playerDetected then
        rotate_enemy(playerTransf.position)
    end

    change_state()

    if currentState == state.Idle then
        idle_state(dt)
    elseif currentState == state.Advise then
        advise_state(dt)
    elseif currentState == state.Charge then
        charge_state(dt)
    elseif currentState == state.Positioning then
        positioning_state(dt)
    elseif currentState == state.TailWhip then
        tailwhip_state(dt)
    end

    if chargeTimer > 0 then
        chargeTimer = chargeTimer - dt
        if chargeTimer <= 0 then
            canDealDamage = true
        end
    end

    if tailwhipTimer > 0 then
        tailwhipTimer = tailwhipTimer - dt
        if tailwhipTimer <= 0 then
            currentState = state.Positioning
        end
    end
end

function change_state()
    if not squighogTransf or not playerTransf then
        return
    end

    local distance = get_distance(squighogTransf.position, playerTransf.position)
    
    if distance < chargeRangeAttack and not isCharging then
        currentState = state.Charge
    elseif distance < tailwhipRangeAttack then
        currentState = state.TailWhip
    elseif distance > chargeRangeAttack then
        currentState = state.Positioning
    else
        currentState = state.Advise
    end
end

function advise_state(dt)
    playerDetected = true
    currentState = state.Positioning
end

function charge_state(dt)
    if chargeCooldownTime <= 0 and not isCharging then
        isCharging = true
        attackType = "charge"
        lastTargetPos = playerTransf.position
        move_towards(lastTargetPos, chargeSpeed)
        chargeTimer = 1.5 
    end
    if chargeTimer <= 0 and isCharging then
        isCharging = false
        currentState = state.Positioning
    end
end

function positioning_state(dt)
    local distanceToPlayer = get_distance(squighogTransf.position, playerTransf.position)

    if distanceToPlayer > 1 then
        move_towards(playerTransf.position, squighogSpeed) 
    elseif distanceToPlayer <= tailwhipRangeAttack then
        currentState = state.TailWhip  
    end
end

function tailwhip_state(dt)
    if tailWhipCooldownTime <= 0 then
        attackType = "tailwhip"
        tailwhipTimer = 1 
        tailWhipCooldownTime = tailwhipCooldown
    end
end

function make_damage(attackType)
    if playerScript then
        if attackType == "charge" then
            playerScript.playerHealth = playerScript.playerHealth - chargeDmg
            --audioDanoPlayerMusic:pause()
            --audioDanoPlayerMusic:play()
            print("PlayerHealth: " .. playerScript.playerHealth)
        elseif attackType == "tailwhip" then
            knockback_player(player, 5)
            playerScript.playerHealth = playerScript.playerHealth - tailwhipDmg
            --audioDanoPlayerMusic:pause()
            --audioDanoPlayerMusic:play()
            print("PlayerHealth: " .. playerScript.playerHealth)
        end
    end
end

function move_towards(targetPosition, speed)
    local direction = Vector3.new(targetPosition.x - squighogTransf.position.x, 0, targetPosition.z - squighogTransf.position.z)
    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(direction.x / distance, 0, direction.z / distance)
        local velocity = Vector3.new(normalizedDirection.x * speed, 0, normalizedDirection.z * speed)
        squighogRb:set_velocity(velocity)
    else
        squighogRb:set_velocity(Vector3.new(0, 0, 0)) 
    end
end

function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz) 
end

function knockback_player(player, force)
    local direction = (playerTransf.position - squighogTransf.position):normalize()
    playerTransf.position = playerTransf.position + direction * force
end

function update_path()
    if player and squighogNavmesh then 
        squighogNavmesh.path = squighogNavmesh:find_path(squighogTransf.position, playerTransf.position)
        currentPathIndex = 1
    end
end

function rotate_enemy(targetPosition)
    local dx = targetPosition.x - squighogTransf.position.x
    local dz = targetPosition.z - squighogTransf.position.z
    squighogTransf.rotation.y = math.deg(math.atan(dx, dz))
end 

function die()
    currentState = state.Idle
    squighogRb:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end 

