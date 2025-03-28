local state = { Idle = 1, Move = 2, Chase = 3, Attack = 4, Tackle = 5 }
local currentState = state.Idle

local player
local playerTransf
local playerScript

local detectDistance = 30
local tackleDistance = 10
local IsCharging = false
local chargeTime = 0
local damagedistance = 5
local meleeDistance = 3

local tankTransform = nil
local forwardVector
local tankRigidbody = nil
local tankNavmesh = nil

local defaultVelocity = 2
local tackleVelocity = 13
local tankVelocity = defaultVelocity
tankHealth = 75
local isDead = false
local tankDamage = 10  -- This will now be the melee damage
local AttackCooldown = 3
local tankNavmesh = nil

local tackleCooldown = 8
local tackleTimer = 0       
local canTackle = true      

local currentAnim = 0
local animator
local attackTimer = 0

local pathUpdateTimer = 0                                        
local pathUpdateInterval = 1.0
local lastTargetPos = nil

haveShield = false
shieldHealth = 0
local tackleHasDamaged = false

function on_ready()
    player = current_scene:get_entity_by_name("Player")
    if player then
        playerTransf = player:get_component("TransformComponent")
        playerScript = player:get_component("ScriptComponent")
    end

    tankTransform = self:get_component("TransformComponent")
    tankRigidbody = self:get_component("RigidbodyComponent").rb
    tankScript = self:get_component("ScriptComponent")
    tankNavmesh = self:get_component("NavigationAgentComponent")

    animator = self:get_component("AnimatorComponent")
    
end

function on_update(dt)
    -- Update timer for path updates
    pathUpdateTimer = pathUpdateTimer + dt
    
    -- Update tackle cooldown timer
    if not canTackle then
        tackleTimer = tackleTimer + dt
        if tackleTimer >= 25 then  
            canTackle = true
            tackleTimer = 0
        end
    end

    if haveShield and shieldHealth <= 0 then
        haveShield = false
        shield_destroyed = true
    end

    -- Check player existence and update distances
    if player and playerTransf then
        change_state() -- Function to change states based on distances
    else
        -- Try to find player in case it was not found before
        player = current_scene:get_entity_by_name("Player")
        if player then
            playerTransf = player:get_component("TransformComponent")
            playerScript = player:get_component("ScriptComponent")
        else
            currentState = state.Idle
        end
    end

    -- Handle death condition
    if tankHealth <= 0 then
        Die()
        return
    end

    -- Update path if needed
    local currentTargetPos = playerTransf and playerTransf.position or nil
    if currentTargetPos and (pathUpdateTimer >= pathUpdateInterval or 
        (lastTargetPos and get_distance(lastTargetPos, currentTargetPos) > 1.0)) then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end

    -- FSM { Idle -> Move -> Chase -> Attack -> Tackle}
    if currentState == state.Idle then
        idle_state(dt)
    elseif currentState == state.Move or currentState == state.Chase then
        chase_state(dt)
    elseif currentState == state.Attack then
        attack_state(dt)
    elseif currentState == state.Tackle then
        tackle_state(dt)
    end
end

function update_path()
    if tankNavmesh == nil or player == nil or playerTransf == nil then 
        return 
    end

    tankNavmesh.path = tankNavmesh:find_path(tankTransform.position, playerTransf.position)
    currentPathIndex = 1
end

function follow_path(dt)
    if tankNavmesh == nil or #tankNavmesh.path == 0 then 
        tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
        return 
    end
    
    -- Verificar que el índice es válido
    if currentPathIndex > #tankNavmesh.path then
        currentPathIndex = 1
        if #tankNavmesh.path == 0 then
            tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
            return
        end
    end

    local nextPoint = tankNavmesh.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - tankTransform.position.x,
        0,
        nextPoint.z - tankTransform.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            0,
            direction.z / distance
        )

        local velocity = Vector3.new(
            normalizedDirection.x * tankVelocity, 
            0, 
            normalizedDirection.z * tankVelocity
        )
        
        tankRigidbody:set_velocity(velocity)

        rotate_tank(nextPoint)
    else
        if currentPathIndex < #tankNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        else
            -- Llegamos al final del camino
            tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
        end
    end
end


function change_state()
    if player and playerTransf then
        local playerDistance = get_distance(tankTransform.position, playerTransf.position)
        
        -- Check distances in order of priority
        if playerDistance <= meleeDistance then
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
        elseif playerDistance <= detectDistance then
            -- Within detection range but not tackle range or tackle on cooldown
            if currentState ~= state.Chase and currentState ~= state.Attack and currentState ~= state.Tackle then
                currentState = state.Chase
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

-- Idle state - tank is static and looking for player
local idleTimer = 0
local idleDuration = 1.0

function idle_state(dt) 
    idleTimer = idleTimer + dt

    -- Animation
    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
    end

    -- Stop movement
    tankRigidbody:set_velocity(Vector3.new(0, 0, 0))

    -- Periodic scan for player
    if idleTimer >= idleDuration then
        idleTimer = 0
        
        -- Try to find player if not already found
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
    -- Animation for chase
    if currentAnim ~= 2 then
        animator:set_current_animation(2)
        currentAnim = 2
    end
    
    follow_path(dt)
end

function tackle_state(dt)
    -- Animation for tackle
    if currentAnim ~= 3 then
        animator:set_current_animation(3)
        currentAnim = 3
    end

    if IsCharging == true then
        local directPath = {}
        local startPos = tankTransform.position
        local targetPos = playerTransf.position
        

        table.insert(directPath, startPos)
        table.insert(directPath, targetPos)
        
        tankNavmesh.path = directPath
        currentPathIndex = 1
        
        chargeTime = 0
        IsCharging = false
        tackleHasDamaged = false
        tankVelocity = 13 
    end
    

    chargeTime = chargeTime + dt
    

    if chargeTime < 1.5 then
        follow_path(dt)
        

        if player and playerTransf and playerScript and not tackleHasDamaged then
            local playerDistance = get_distance(tankTransform.position, playerTransf.position)
            
            if playerDistance <= tackleDistance then
                local damage = 50
                playerScript.playerHealth = playerScript.playerHealth - damage
                tackleHasDamaged = true
            end
        end
    else

        tankRigidbody:set_velocity(Vector3.new(0, 0, 0))

        canTackle = false
        tackleTimer = 0
        

        tankVelocity = defaultVelocity

        currentState = state.Chase
    end
end

-- Attack state - tank performs a slow melee attack
function attack_state(dt)
    -- Animation for attack
    if currentAnim ~= 4 then
        animator:set_current_animation(4)
        currentAnim = 4
    end
    
    -- Static during attack
    tankRigidbody:set_velocity(Vector3.new(0, 0, 0))
    
    -- Face player during attack
    if player and playerTransf then
        rotate_tank(playerTransf.position)
    end
    
    -- Attack cooldown system
    attackTimer = attackTimer + dt
    
    if attackTimer >= AttackCooldown then
        -- Perform the attack after cooldown
        if player and playerTransf and playerScript then
            local attackDistance = get_distance(tankTransform.position, playerTransf.position)
            
            if attackDistance <= meleeDistance then
                -- Attempt to damage player directly with 10 damage
                local damage = 10
                
                -- Directly reduce player health
                playerScript.playerHealth = playerScript.playerHealth - damage
            end
        end
        
        -- Reset timer after attack
        attackTimer = 0
        
        -- Return to Chase state after attacking
        currentState = state.Chase
    end
end
-- Helper function to rotate the tank to face a target position
function rotate_tank(targetPosition)
    local dx = targetPosition.x - tankTransform.position.x
    local dz = targetPosition.z - tankTransform.position.z
    
    local angleRotation = math.atan(dx, dz)
    tankTransform.rotation.y = math.deg(angleRotation)
end

-- Helper function to calculate distance between two positions
function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Function to handle death
function Die()
    if not isDead then
        print("Tank has died! Health: " .. tankHealth)
        currentState = state.Idle
        tankRigidbody:set_position(Vector3.new(-500, 0, 0))
        tankHealth = 0
        isDead = true
    end
end

function take_damage(amount)
    -- Reduce tank health
    tankHealth = tankHealth - amount
    print("Tank took damage. Current Health: " .. tankHealth)
    
    -- Optional: Check for death
    if tankHealth <= 0 then
        Die()
    end
end

function on_exit() 
    -- Clean up code here
end