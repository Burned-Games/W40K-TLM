local state = { Idle = 1, Move = 2, Attack = 3}
local currentState = state.Idle

function on_ready() end

-- FSM General
function on_update(dt)

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

end

-- Funciones para los distintos estados.
function idle_state(dt) end

function move_state(dt) end

function attack_state(dt) end

function on_exit() end
