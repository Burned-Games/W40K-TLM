local state = { Idle = 1, Chase = 2, Tackle = 3, TailWhip = 4 } 
local currentState = state.Idle

local player = nil
local playerTransf = nil
local playerScript = nil

-- Squighog stats 
local squighogHealth = 100
local squighogSpeed = 3
local isDead = false

local squighogNavmesh = nil 
local squighogRb = nil
local squighogTransf = nil

local detectDistance = 30 

-- Squighog habilities
local tackleSpeed = 10 
local tackleRangeAttack = 10 
local tackleCooldown = 5
local tackleDmg = 5
local tackleTimer = 0
local canTackle = true
local tackleHasDamaged = false 
local isCharging = false

local tailwhipRangeAttack = 5 
local tailwhipCooldown = 10
local tailwhipDmg = 10
local tailwhipTimer = 0 
local canTailwhip = true
local tailwhipHasDamaged = false 
local isTailwhiping = false

local pathUpdateTimer = 0
local pathUpdateInterval = 0.5
local lastTargetPos = nil

local isPlayerBehind = false 
local tailCollider = nil 

function on_ready() 
    player = current_scene:get_entity_by_name("Player")
    if player then
        playerTransf = player:get_component("TransformComponent")
        playerScript = player:get_component("ScriptComponent")
    end

    squighogNavmesh = self:get_component("NavigationAgentComponent")
    squighogRb = self:get_component("RigidbodyComponent").rb
    squighogTransf = self:get_component("TransformComponent")

    local tail = current_scene:get_entity_by_name("tail")
    if tail then
        tailCollider = tail:get_component("ColliderComponent")
    end
end 

function on_update(dt)
    if not player or isDead then return end
    if squighogHealth <= 0 then die() end

    pathUpdateTimer = pathUpdateTimer + dt

    if not canTackle then
        tackleTimer = tackleTimer + dt
        if tackleTimer >= tackleCooldown then
            canTackle = true
            tackleTimer = 0
        end
    end

    if not canTailwhip then
        tailwhipTimer = tailwhipTimer + dt
        if tailwhipTimer >= tailwhipCooldown then
            canTailwhip = true
            tailwhipTimer = 0
        end
    end

    if player and playerTransf then
        change_state()
    else 
        player = current_scene:get_entity_by_name("Player")
        if player then
            playerTransf = player:get_component("TransformComponent")
            playerScript = player:get_component("ScriptComponent")
        else
            currentState = state.Idle
        end
    end

    local currentTargetPos = playerTransf and playerTransf.position or nil
    if currentTargetPos and (pathUpdateTimer >= pathUpdateInterval or 
        (lastTargetPos and get_distance(lastTargetPos, currentTargetPos) > 1.0)) then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end

    if currentState == state.Idle then
        idle_state(dt)
    elseif currentState == state.Chase then 
        chase_state(dt)
    elseif currentState == state.TailWhip then
        tailwhip_state(dt)
    elseif currentState == state.Tackle then
        tackle_state(dt)
    end
end

function update_path()
    if squighogNavmesh == nil or player == nil or playerTransf == nil then 
        return 
    end

    squighogNavmesh.path = squighogNavmesh:find_path(squighogTransf.position, playerTransf.position)
    currentPathIndex = 1
end

function follow_path(dt)
    if squighogNavmesh == nil or #squighogNavmesh.path == 0 then 
        squighogRb:set_velocity(Vector3.new(0, 0, 0))
        return 
    end
    
    if currentPathIndex > #squighogNavmesh.path then
        currentPathIndex = 1
        if #squighogNavmesh.path == 0 then
            squighogRb:set_velocity(Vector3.new(0, 0, 0))
            return
        end
    end

    local nextPoint = squighogNavmesh.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - squighogTransf.position.x,
        0,
        nextPoint.z - squighogTransf.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            0,
            direction.z / distance
        )

        local velocity = Vector3.new(
            normalizedDirection.x * squighogSpeed, 
            0, 
            normalizedDirection.z * squighogSpeed
        )
        
        squighogRb:set_velocity(velocity)

        rotate_squighog(nextPoint)
    else
        if currentPathIndex < #squighogNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        else
            squighogRb:set_velocity(Vector3.new(0, 0, 0))
        end
    end
end

function change_state()
    if player and playerTransf then
        local playerDistance = get_distance(squighogTransf.position, playerTransf.position)
    
        if playerDistance <= tackleRangeAttack and canTackle then
            if currentState ~= state.Tackle then
                currentState = state.Tackle
                isCharging = true
            end
        elseif playerDistance <=  tailwhipRangeAttack and canTailwhip and isPlayerBehind then
            if currentState ~= state.TailWhip then
                currentState = state.TailWhip
                isTailwhiping = true
            end
        elseif playerDistance <= detectDistance then
            if currentState ~= state.Chase and currentState ~= state.Tackle then
                currentState = state.Chase
            end
        else
            if currentState ~= state.Idle then
                currentState = state.Idle
            end
        end
    else
        if currentState ~= state.Idle then
            currentState = state.Idle
        end
    end
end

local idleTimer = 0
local idleDuration = 1.0 

function idle_state(dt) 
    idleTimer = idleTimer + dt

    squighogRb:set_velocity(Vector3.new(0, 0, 0))

    if idleTimer >= idleDuration then
        idleTimer = 0
        
        if not player then
            player = current_scene:get_entity_by_name("Player")
            if player then
                playerTransf = player:get_component("TransformComponent")
                playerScript = player:get_component("ScriptComponent")
            end
        end
    end
end

function chase_state(dt)
    follow_path(dt)
end

function tackle_state(dt)
    if isCharging == true then
        chargeTime = 0
        isCharging = false
        tackleHasDamaged = false
        squighogSpeed = tackleSpeed
    end

    chargeTime = chargeTime + dt

    if chargeTime < 1.5 then 
        follow_path(dt)

        if player and playerTransf and playerScript and not tackleHasDamaged then 
            local playerDistance = get_distance(squighogTransf.position, playerTransf.position)
            
            if playerDistance <= tackleRangeAttack then
                print("Squighog Tackle Damage: " .. tackleDmg)
                playerScript.playerHealth = playerScript.playerHealth - tackleDmg
                print("Player Health after Tackle: " .. playerScript.playerHealth)
                tackleHasDamaged = true
            end
        end
    else
        squighogRb:set_velocity(Vector3.new(0, 0, 0))
        isCharging = true  
        canTackle = false  
        tackleTimer = 0    
        
        if player and playerTransf then
            local playerDistance = get_distance(squighogTransf.position, playerTransf.position)
            
            if playerDistance <= tailwhipRangeAttack and isPlayerBehind then
                currentState = state.TailWhip
                tailwhipTimer = 0
            elseif playerDistance <= detectDistance then
                currentState = state.Chase
            else
                currentState = state.Idle
            end
        else
            currentState = state.Idle
        end
    end    
end

function tailwhip_state(dt)
    if not tailwhipHasDamaged then
        -- Aplicar daño y empuje solo una vez
        if player and playerTransf and playerScript then
            local distance = get_distance(squighogTransf.position, playerTransf.position)
            
            if distance <= tailwhipRangeAttack then
                print("Squighog Tailwhip Damage: " .. tailwhipDmg)
                playerScript.playerHealth = playerScript.playerHealth - tailwhipDmg
                print("Player Health after Tailwhip: " .. playerScript.playerHealth)
                
                local direction = Vector3.new(
                    playerTransf.position.x - squighogTransf.position.x,
                    0,
                    playerTransf.position.z - squighogTransf.position.z
                ):normalize()

                local knockbackForce = 10 
                playerTransf.position = Vector3.new(
                    playerTransf.position.x + direction.x * knockbackForce,
                    playerTransf.position.y,
                    playerTransf.position.z + direction.z * knockbackForce
                )

                tailwhipHasDamaged = true 
                canTailwhip = false
            end
        end
    end

    tailwhipTimer = tailwhipTimer + dt
    if tailwhipTimer >= tailwhipCooldown then
        tailwhipTimer = 0
        tailwhipHasDamaged = false 
        canTailwhip = true
        isTailwhiping = false
        currentState = state.Chase 
    end
end

function rotate_squighog(targetPosition)
    local dx = targetPosition.x - squighogTransf.position.x
    local dz = targetPosition.z - squighogTransf.position.z

    local angleRotation = math.atan(dx, dz)
    squighogTransf.rotation.y = math.deg(angleRotation)
end

function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz) 
end

function on_trigger_enter(other)
    if other.name == "Player" and tailCollider then
        isPlayerBehind = true
        print("Player entered tail trigger. isPlayerBehind: " .. tostring(isPlayerBehind))
    end
end

function on_trigger_exit(other)
    if other.name == "Player" and tailCollider then
        isPlayerBehind = false
        print("Player exited tail trigger. isPlayerBehind: " .. tostring(isPlayerBehind))
    end
end

function die()
    if not isDead then
        print("Squighog has died! Health: " .. squighogHealth)
        currentState = state.Idle
        squighogRb:set_position(Vector3.new(-500, 0, 0))
        squighogHealth = 0
        isDead = true
    end
end

function on_exit() end
