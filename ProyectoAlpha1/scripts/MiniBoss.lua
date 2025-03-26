local state = { Idle = 1, Move = 2, Attack = 3}
local currentState = state.Idle

local miniHealth = 50
local miniSpeed = 5
local chargeSpeed = 10 -- "Embestida" hability speed
local attackRange = 5 
local barridoRange = 2 -- distancia para hacer el barrido
local isCharging = false 
local isDead = false

local player = nil
local playerTransf = nil
local playerScript = nil
local playerDetected = false

local miniNavmesh = nil
local miniTransf = nil
local miniRb = nil
local animator = nil
local currentAnim = 0

local pathUpdateTimer = 0
local pathUpdateInterval = 0.5
local lastTargetPos = nil

local hachaTimer = 0
local isGiratoria = false

function on_ready()
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    miniNavmesh = self:get_component("NavigationAgentComponent")
    miniRb = self:get_component("RigidbodyComponent").rb
    miniTransf = self:get_component("TransformComponent")

    animator = self:get_component("AnimatorComponent")

    if player ~= nil then
        lastTargetPos = playerTransf.position
        update_path()
    end
    currentState = state.Idle
end

-- FSM General
function on_update(dt)
    if player == nil or isDead == true then                             -- Comprueba si el player existe o si el enemigo esta muerto para evitar entrar en el update 
        return                                                          -- (poned las variables, ahora no tienen referencia)
    end

    if miniHealth <= 0 then
        die()
    end

    --player_distance()
    change_state() -- Funcion para cambiar de estados

    pathUpdateTimer = pathUpdateTimer + dt
    local currentTargetPos = playerTransf.position
    --update hachaTimer
    if hachaTimer > 0 then
        hachaTimer = hachaTimer - dt
    else
        isGiratoria = false
    end

    if pathUpdateTimer >= pathUpdateInterval or get_distance(lastTargetPos, currentTargetPos) > 1.0 then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end

    if playerDetected then
        rotate_enemy(playerTransf.position)
    end


    -- FSM { Idle -> Move -> Attack}
    if currentState == state.Idle then
        idle_state(dt)

    elseif currentState == state.Move then
        move_state(dt)

    elseif currentState == state.Attack then
        attack_state(dt)
    end

end

--function change_state()

    -- Aqui la logica que necesiteis para cambiar de estado (distancia del player o alguna condicion especial)
   -- if playerDetected then
    --    if player_distance() < attackRange then
     --       currentState = state.Attack
      --  else
       --     currentState = state.Move
       -- end
   -- else
     --   currentState = state.Idle
   -- end
--end

-- Funciones para los distintos estados.
function idle_state(dt) end

function move_state(dt) end

function attack_state(dt)
    playerDist = player_distance()

    if playerDist <= attackRange then
        if not isGiratoria and hachaTimer == 0 then
            perform_hacha_giratoria()
        end
    elseif playerDist <= barridoRange  then
        perform_barrido()
    end
end
function perform_hacha_giratoria()
    --tirar hacha y que vuelva:
    isGiratoria = true
    hachaTimer = 10;
end
function perform_barrido()
    --hacer barrido dependiendo de la posicion del player (izquierda o derecha) 
    if playerTransf.position.x > miniTransf.position.x then
        --barrido a la derecha
    else
        --barrido a la izquierda
    end
end

function player_distance()
    local pDist = get_distance(miniTransf.position, playerTransf.position)
    return pDist
end

function change_state()

    local playerDistance = player_distance()

    -- Primera deteccion (Idle -> Move).
    if not playerDetected then
        print("Player detectado! Pasando de Idle a Move.")
        currentState = state.Move
        playerDetected = true
    end

    if playerDistance <= attackRange then
        if currentState ~= state.Attack then
            print("Player en rango de disparo! Cambiando a Attack.")
            currentState = state.Attack
        end

    --elseif playerDistance > shootDistance and currentState == state.Shoot then
    --    if currentState ~= state.Move then
    --        print("Player fuera de rango! Volviendo a Move.")
    --        currentState = state.Move
    --    end
    --end

end

function on_exit() end
