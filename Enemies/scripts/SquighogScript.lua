--NOTAS
-- Faltan funciones por crear

local state = { Idle = 1, Move = 2, Attack = 3}
local currentState = state.Idle

local squighogHealth = 50
local squighogSpeed = 5
local chargeSpeed = 10 -- "Embestida" hability speed
local attackRange = 5 
local isCharging = false 
local isDead = false

local player = nil
local playerTransf = nil
local playerScript = nil
local playerDetected = false

local squighogNavmesh = nil
local squighogRb = nil
local animator = nil
local currentAnim = 0

local pathUpdateTimer = 0
local pathUpdateInterval = 0.5
local lastTargetPos = nil

function on_ready() 
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    squighogNavmesh = self:get_component("NavigationAgentComponent")
    squighogRb = self:get_component("RigidbodyComponent").rb

    animator = self:get_component("AnimatorComponent")

    squighogRb:on_collision_enter(funcion(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then 
            make_damage()
        end 
    end)

    if player ~= nil then
        lastTargetPos = playerTransf.position
        update_path()
    end

end 

-- FSM General
function on_update(dt)

    if player == nil or isDead then return end
    if health <= 0 then die() end
    player_distance()

    pathUpdateTimer = pathUpdateTimer + dt
    local currentTargetPos = playerTransf.position

    if pathUpdateTimer >= pathUpdateInterval or get_distance(lastTargetPos, currentTargetPos) > 1.0 then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end

    if playerDetected then
        rotate_enemy(playerTransf.position)
    end

    change_state() -- Funcion para cambiar de estados

    -- FSM { Idle -> Move -> Attack}
    if currentState == state.Idle then
        idle_state(dt)

    elseif currentState == state.Move then
        move_state(dt)

    elseif currentState == state.Attack then
        attack_state(dt)
    end

end

function change_state()

    -- Aqui la logica que necesiteis para cambiar de estado (distancia del player o alguna condicion especial)
    if playerDetected then
        if distanceToPlayer() < attackRange then
            currentState = state.Attack
        else
            currentState = state.Move
        end
    else
        currentState = state.Idle
    end
end

function playerDistance()
    local playerDistance = get_distance(self.position, playerTransf.position)
    if not playerDetected and playerDistance <= 10 then
        playerDetected = true
        currentState = state.Move
    elseif playerDistance <= attackRange then
        currentState = state.Attack
    elseif playerDistance > attackRange and currentState == state.Attack then
        currentState = state.Move
    end
end

-- Funciones para los distintos estados.
function idle_state(dt) 
   -- if currentAnim ~= 1 then
      --  animator:set_current_animation(1)
      --  currentAnim = 1
   -- end
end

function move_state(dt) 
   -- if currentAnim ~= 3 then
      --  animator:set_current_animation(3)
      --  currentAnim = 3
   -- end
    followPath(dt)
end

function attack_state(dt) 
    if distanceToPlayer() < attackRange then
        performCharge()
    elseif playerIsBehind() then
        performTailWhip()
    end
end

function performCharge()
    if not isCharging then
        isCharging = true
        move_towards(player.position, chargeSpeed)
        delay(1.5, function() isCharging = false end)
    end
end

function performTailWhip()
    deal_damage(player, 20) 
    knockback_player(player, 5)
end

function updatePath()
    if player == nil or navmesh == nil then return end
    navmesh.path = navmesh:find_path(self.position, playerTransf.position)
end

function followPath(dt)
    if navmesh == nil or #navmesh.path == 0 then return end
    local nextPoint = navmesh.path[1]
    move_towards(nextPoint, speed * dt)
    rotateEnemy(nextPoint)
end

function rotateEnemy(targetPosition)
    local dx = targetPosition.x - self.position.x
    local dz = targetPosition.z - self.position.z
    local angleRotation = math.atan(dx, dz)
    self.rotation.y = math.deg(angleRotation)
end

function die()
    currentState = state.Idle
    rb:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end 

