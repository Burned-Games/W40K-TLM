enemyHealth = 10
local enemyDamage = 10
local moveSpeed = 6
local enemyTransf = nil
local enemyNavmesh = nil
local enemyRbComponent = nil
local enemyRb = nil
local hasExploded = false
local isDead = false

local detectDistance = 25
local bombDistance = 2

local animator = nil
local currentAnim = 0

local bomb = nil
local bombRb = nil

local player = nil
local playerTransf = nil
local playerScript = nil
local playerDetected = false

local state = { Idle = 1, Move = 2, Attack = 3}
local currentState = state.Idle

local pathUpdateTimer = 0                                               -- Los timers se tendran que cambiar con los que hay en el LuaBackend
local pathUpdateInterval = 0.5
local lastTargetPos = nil

local invulnerability = 0.1                                             -- La invulnerabilidad es para la funcion de make_damage, para que no este aplicando el damage constantemente
local timeSinceLastHit = 0                                              -- Este timer tambien hay que quitarlo en un futuro

local currentPathIndex = 1

function on_ready() 
    enemyTransf = self:get_component("TransformComponent")
    enemyNavmesh = self:get_component("NavigationAgentComponent")
    enemyRbComponent = self:get_component("RigidbodyComponent")
    enemyRb = enemyRbComponent.rb

    animator = self:get_component("AnimatorComponent")

    bomb = current_scene:get_entity_by_name("Bomb")
    bombRb = bomb:get_component("RigidbodyComponent").rb

    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")
    
    enemyRbComponent:on_collision_enter(function(entityA, entityB)         -- Funcion para comprobar colisiones, ahora esta el enemyRb, pero cambiadlo por el que necesiteis
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            if currentState ~= state.Attack then
                print("Player en contacto con el Kamikaze! Cambiando a Attack.")
                currentState = state.Attack
            end
        end
    end)

    if player ~= nil then
        lastTargetPos = playerTransf.position
        update_path()
    end

end



-- FSM Kamikaze
function on_update(dt)

    if player == nil or isDead == true then                             -- Comprueba si el player existe o si el enemigo esta muerto para evitar entrar en el update 
        return                                                          -- (poned las variables, ahora no tienen referencia)
    end

    if not hasExploded and enemyHealth <= 0 then
        drop_bomb()
        die()
    elseif hasExploded and enemyHealth <= 0 then
        die()
    end

    player_distance()                                                   -- Para detectar al player (hay que cambiarlo por el raycast)



    -- Actualiza el path hacia el player con el navmesh
    pathUpdateTimer = pathUpdateTimer + dt
    local currentTargetPos = playerTransf.position

    if pathUpdateTimer >= pathUpdateInterval or get_distance(lastTargetPos, currentTargetPos) > 1.0 then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end



    -- Para que mire al player
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



-- Deteccion del Player y cambio de estados en funcion de la distancia.
function player_distance()

    local playerDistance = get_distance(enemyTransf.position, playerTransf.position)

    if not playerDetected and playerDistance <= detectDistance then
        print("Player detectado! Pasando de Idle a Move.")
        currentState = state.Move
        playerDetected = true
    end

end



-- Funciones para los distintos estados.
function idle_state(dt)

    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
    end

end

function move_state(dt)

    if currentAnim ~= 3 then
        animator:set_current_animation(3)
        currentAnim = 3
    end

	-- Movimiento
    follow_path(dt)

end

function attack_state(dt)

    -- Logica de la explosion
    local explosionPos = bombRb:get_position()

        local entities = current_scene:get_all_entities()

        for _, entity in ipairs(entities) do 
            if entity ~= granadeEntity and entity:has_component("RigidbodyComponent") then 
                local entityRb = entity:get_component("RigidbodyComponent").rb
                local entityPos = entityRb:get_position()

                local direction = Vector3.new(
                    entityPos.x - explosionPos.x,
                    entityPos.y - explosionPos.y,
                    entityPos.z - explosionPos.z
                )

                local distance = math.sqrt(
                    direction.x * direction.x +
                    direction.y * direction.y +
                    direction.z * direction.z
                )

                if distance > 0 then
                    direction.x = direction.x / distance
                    direction.y = direction.y / distance
                    direction.z = direction.z / distance
                end

                if distance < explosionRadius then
                    local forceFactor = (explosionRadius - distance) / explosionRadius
                    direction.y = direction.y + explosionUpward
                    local finalForce = Vector3.new(
                        direction.x * explosionForce * forceFactor,
                        direction.y * explosionForce * forceFactor,
                        direction.z * explosionForce * forceFactor
                    )
                    entityRb:apply_impulse(finalForce)

                    local rotationFactor = explosionForce * forceFactor 
                    local randomRotation = Vector3.new(
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor
                    )

                    entityRb:set_angular_velocity(randomRotation)
                end
            end
        end
        
        rb:set_velocity(Vector3.new(0, 0, 0))
        rb:set_angular_velocity(Vector3.new(0, 0, 0))
        throwingGranade = false
    --make_damage()                       -- Provisional (hasta que sepa como quieren la logica de la explosion)
    die()

    health = 0
    hasExploded = true

end

function drop_bomb()

    if bomb == nil then
        return
    end

    bombRb:set_position(enemyTransf.position)

end



-- Funciones para calcular cosas.    :)
function make_damage()

    if player ~= nil then
        if playerScript ~= nil then

            playerScript.playerHealth = playerScript.playerHealth - enemyDamage
            print("PlayerHealth: " .. playerScript.playerHealth)

            return
        end
    end

end

function update_path()

    if player == nil or enemyNavmesh == nil then 
        return 
    end

    enemyNavmesh.path = enemyNavmesh:find_path(enemyTransf.position, playerTransf.position)
    currentPathIndex = 1

end

function follow_path(dt)

    if enemyNavmesh == nil or #enemyNavmesh.path == 0 then 
        return 
    end

    local nextPoint = enemyNavmesh.path[currentPathIndex]
    local direction = Vector3.new(
        nextPoint.x - enemyTransf.position.x,
        nextPoint.y - enemyTransf.position.y,
        nextPoint.z - enemyTransf.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.y^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            direction.y / distance,
            direction.z / distance
        )

        local velocity = Vector3.new(normalizedDirection.x * moveSpeed, 0, normalizedDirection.z * moveSpeed)
        enemyRb:set_velocity(velocity)

        rotate_enemy(nextPoint)
    else
        if currentPathIndex < #enemyNavmesh.path then
            currentPathIndex = currentPathIndex + 1
        end
    end

end

function rotate_enemy(targetPosition)

	local dx = targetPosition.x - enemyTransf.position.x
	local dz = targetPosition.z - enemyTransf.position.z

	local angleRotation = math.atan(dx, dz)

    enemyTransf.rotation.y = math.deg(angleRotation)

end

function get_distance(pos1, pos2)

    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)

end

function die()                                      -- !! IMPORTANTE !! Se tendra que cambiar para destruir el enemigo al morir, ahora solo se mueve lejos y se le pone en Idle :)
    currentState = state.Idle
    enemyRb:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end