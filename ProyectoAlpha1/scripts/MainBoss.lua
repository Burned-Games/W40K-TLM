local state = { Idle = 1, Move = 2, Attack = 3, Patrol =4}
local currentState = state.Idle

local mainboss = nil
local bossTransform = nil
local bossAnimator = nil
local bossRigidbody = nil
local bossNavmesh = nil

local player = nil
local playerTransform = nil
local playerScript = nil

local waypoint1
local waypoint2
local waypoint3
local currentWaypoint = 1
local waypointPositions = {}


local bossHealth = 150
local bossDamage = 25
local moveSpeed = 5
local bossAttackRange = 5
local bossAttackCooldown = 2
local bossAttackTimer = 0

function on_ready() 

    -- Get the main boss entity

    bossTransform = self:get_component("TransformComponent")
    bossAnimator = self:get_component("AnimatorComponent")
    bossRigidbody = self:get_component("RigidbodyComponent").rb
    bossNavmesh = self:get_component("NavigationAgentComponent")

    -- Get the player entity
    player = current_scene:get_entity_by_name("Player")
    playerTransform = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    waypoint1 = current_scene:get_entity_by_name("Waypoint1")
    waypoint2 = current_scene:get_entity_by_name("Waypoint2")
    waypoint3 = current_scene:get_entity_by_name("Waypoint3")
    
    if waypoint1 and waypoint2 and waypoint3 then
        local wp1Transform = waypoint1:get_component("TransformComponent")
        local wp2Transform = waypoint2:get_component("TransformComponent")
        local wp3Transform = waypoint3:get_component("TransformComponent")
        
        if wp1Transform and wp2Transform and wp3Transform then
            waypointPositions[1] = wp1Transform.position
            waypointPositions[2] = wp2Transform.position
            waypointPositions[3] = wp3Transform.position
        end


    elseif enemyRangeEntity ~= nil and enemyRangeTransf ~= nil then
        lastTargetPos = enemyRangeTransf.position
        update_path()
    end

    -- Set the initial state
    currentState = state.Patrol

end

-- FSM General
function on_update(dt)

    change_state() -- Funcion para cambiar de estados

    -- FSM { Idle -> Move -> Attack}
    if currentState == state.Idle then
        idle_state(dt)

    elseif currentState == state.Move then
        move_state(dt)

    elseif currentState == state.Patrol then
        patrol_state(dt)

    elseif currentState == state.Attack then
        attack_state(dt)
    end

end

function change_state()

    -- Aqui la logica que necesiteis para cambiar de estado (distancia del player o alguna condicion especial)

end

function patrol_state(dt)
    if animator then
        if currentAnim ~= 2 then
            animator:set_current_animation(2)
            currentAnim = 2
        end
    end

    -- Get current waypoint
    local currentTarget = waypointPositions[currentWaypoint]
    
    -- Update path to current waypoint if needed
    if lastTargetPos == nil or get_distance(lastTargetPos, currentTarget) > 1.0 then
        update_waypoint_path()
    end
    
    -- Follow the path
    follow_path(dt)
    
    -- Calculate distance to current waypoint
    local distance = get_distance(bossTransform.position, currentTarget)
    
    -- If we're close enough, change to next waypoint
    if distance <= 1.0 then
        currentWaypoint = currentWaypoint % #waypointPositions + 1
        update_waypoint_path()
    end
    
   
end
-- Funciones para los distintos estados.
function idle_state(dt) end

function move_state(dt) end

function attack_state(dt) end

function follow_path(dt)
    if bossNavmesh == nil or #bossNavmesh.path == 0 then 
        if bossRigidbody then
            bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
        end
        return 
    end
    
    -- Verificar que el índice es válido
    if currentPathIndex > #bossNavmesh.path then
        currentPathIndex = 1
        if #bossNavmesh.path == 0 then
            if bossRigidbody then
                bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
            end
            return
        end
    end

    local nextPoint = bossNavmesh.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - bossTransform.position.x,
        0, -- Ignoramos la Y para movimiento en plano
        nextPoint.z - bossTransform.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            0,
            direction.z / distance
        )

        -- Usar física para el movimiento
        if bossRigidbody then
            local velocity = Vector3.new(normalizedDirection.x * moveSpeed, 0, normalizedDirection.z * moveSpeed)
            bossRigidbody:set_velocity(velocity)
        end

        rotate_enemy(nextPoint)
    else
        if currentPathIndex < #bossNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        else
            -- Llegamos al final del camino, detener movimiento
            if bossRigidbody then
                bossRigidbody:set_velocity(Vector3.new(0, 0, 0))
            end
        end
    end
end

function update_waypoint_path()
    if bossNavmesh then
        local currentTarget = waypointPositions[currentWaypoint]
        bossNavmesh.path = bossNavmesh:find_path(bossTransform.position, currentTarget)
        lastTargetPos = currentTarget
        currentPathIndex = 1
    end
end

function rotate_enemy(targetPosition)
    local dx = targetPosition.x - bossTransform.position.x
    local dz = targetPosition.z - bossTransform.position.z

    local angleRotation = math.atan(dx, dz)
    bossTransform.rotation.y = math.deg(angleRotation)
end

function get_distance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = 0 -- Ignore height difference for pathfinding
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Die()
    currentState = state.Idle
    bossRigidbody:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end