local enemyTransf = nil
local enemyWorldTransf = nil
local enemyNavmesh = nil
local enemyRb = nil
local player = nil
local playerTransf = nil
local playerScript = nil
local bullet = nil
local bulletTransform = nil
local bulletRb = nil

local moveSpeed = 3
enemyHealth = 50
shieldHealth = 0
shield_state = false
shield_destroyed = false

local detectDistance = 25
local shootDistance = 15
local chaseDistance = 8
local stabDistance = 2

local currentAnim = 0
local animator = nil

local state = { Idle = 1, Move = 2, Shoot = 3, Chase = 4, Stab = 5}
local currentState = state.Idle
local playerDetected = false
local isChasing = false

local pathUpdateTimer = 0
local pathUpdateInterval = 0.5
local lastTargetPos = nil

local burstCount = 0
local maxBurstShots = 4
local burstCooldown = 0.3
local timeSinceLastShot = 0
local timeBetweenBursts = 1
local burstCooldownTimer = 0
local isShootingBurst = false

local bulletSpeed = 5
local bulletDirection = Vector3.new(0, 0, 0)
local bulletDamageRadius = 1.5

local stabTimer = 2
local timeSinceLastStab = 0

local invulnerability = 0.1
local timeSinceLastHit = 0

local currentPathIndex = 1

local isDead = false

local audioDanoPlayerMusic = nil

function on_ready() 

    audioDanoPlayerMusic = current_scene:get_entity_by_name("AudioDanoPlayer"):get_component("AudioSourceComponent")
	enemyTransf = self:get_component("TransformComponent")
    enemyNavmesh = self:get_component("NavigationAgentComponent")
    enemyRb = self:get_component("RigidbodyComponent").rb
    enemyWorldTransf = enemyTransf:get_world_transform()

    animator = self:get_component("AnimatorComponent")

    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    bullet = current_scene:get_entity_by_name("EnemyBullet")
    bulletTransform = bullet:get_component("TransformComponent")
    bulletComponent = bullet:get_component("RigidbodyComponent")
    bulletRb = bulletComponent.rb
    bulletRb:set_trigger(true)
    
    bulletComponent:on_collision_enter(function(entityA, entityB)                -- El OnCollisionEnter no funciona, hay que mirar porque
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



-- FSM del Orko Basico.
function on_update(dt)

    if player == nil or isDead == true then 
        return 
    end

    if enemyHealth <= 0 then
        Die()
    end

    if shield_state and shieldHealth <= 0 then
        print("Shield desactivado" .. shieldHealth .. enemyHealth)
        shield_state = false
        shield_destroyed=true
    end

    player_distance()
    --check_bullet_collision()

    pathUpdateTimer = pathUpdateTimer + dt
    timeSinceLastHit = timeSinceLastHit + dt

    -- Verificar si el jugador se movio lo suficiente o si paso el tiempo del intervalo
    local currentTargetPos = playerTransf.position
    if pathUpdateTimer >= pathUpdateInterval or get_distance(lastTargetPos, currentTargetPos) > 1.0 then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end


    if playerDetected then
        rotate_enemy(playerTransf.position)
    end


    if currentState == state.Idle then
        idle_state(dt)

    elseif currentState == state.Move then
        move_state(dt)

    elseif currentState == state.Shoot then
        shoot_state(dt)
        playerScript.backgroundMusicToPlay = 1

    elseif currentState == state.Chase then
        chase_state(dt)                                 -- Voy a mantener el Chase y el Move como funciones separadas para cuando sean orkos de niveles mas altos.
        playerScript.backgroundMusicToPlay = 1

    elseif currentState == state.Stab then
        stab_state(dt)
        playerScript.backgroundMusicToPlay = 1
    end

end



-- Deteccion del Player y cambio de estados en funcion de la distancia.
function player_distance()

    local playerDistance = get_distance(enemyTransf.position, playerTransf.position)

    -- Primera deteccion (Idle -> Move).
    if not playerDetected and playerDistance <= detectDistance then
        print("Player detectado! Pasando de Idle a Move.")
        currentState = state.Move
        playerDetected = true
    end

    -- Si esta en Chasing no vuelve a Shoot ni a Move.
    if isChasing then
        if playerDistance <= stabDistance then
            if currentState ~= state.Stab then
                print("Player en rango de Stab! Cambiando a Stab.")
                currentState = state.Stab
            end

        elseif playerDistance > stabDistance and currentState == state.Stab then
            print("Player fuera de rango! Volviendo a Chase.")
            currentState = state.Chase
        end

        return      -- Evita que vuelva a Move o Shoot.
    end

    -- **ORDEN IMPORTANTE** Chase y Stab tienen que evaluarse primero, sino no funcionara bien!!!
    if playerDistance <= stabDistance then
        if currentState ~= state.Stab then
            print("Player en rango de cuerpo a cuerpo! Cambiando a Stab.")
            currentState = state.Stab
            isChasing = true
        end

    elseif playerDistance <= chaseDistance then
        if currentState ~= state.Chase then
            print("Player en rango de persecucion! Cambiando a Chase.")
            currentState = state.Chase
            isChasing = true
        end

    elseif playerDistance <= shootDistance then
        if currentState ~= state.Shoot then
            print("Player en rango de disparo! Cambiando a Shoot.")
            currentState = state.Shoot
        end

    elseif playerDistance > shootDistance and currentState == state.Shoot then
        if currentState ~= state.Move then
            print("Player fuera de rango! Volviendo a Move.")
            currentState = state.Move
        end
    end

end

function check_bullet_collision()

    local bulletPos = bulletTransform.position
    local playerPos = playerTransf.position

    if get_distance(bulletPos, playerPos) <= bulletDamageRadius then
        make_damage()
    end

end



-- Funciones para los distintos estados.
function idle_state(dt)

    if currentAnim ~= 0 then
        animator:set_current_animation(0)
        currentAnim = 0
    end

end

function move_state(dt)

    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
    end

	-- Movimiento
    follow_path(dt)

end

function shoot_state(dt)

    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
    end

    enemyRb:set_velocity(Vector3.new(0, 0, 0))

    -- Logica de disparo
    if isShootingBurst then
        timeSinceLastShot = timeSinceLastShot + dt

        if timeSinceLastShot >= burstCooldown and burstCount < maxBurstShots then
            shoot_projectile(dt)
            burstCount = burstCount + 1
            timeSinceLastShot = 0

            if burstCount >= maxBurstShots then
                isShootingBurst = false
                burstCooldownTimer = 0
            end
        end
    else
        burstCooldownTimer = burstCooldownTimer + dt

        if burstCooldownTimer >= timeBetweenBursts then
            isShootingBurst = true
            burstCount = 0
            timeSinceLastShot = 0
        end
    end

end

function chase_state(dt)

    if currentAnim ~= 1 then
        animator:set_current_animation(1)
        currentAnim = 1
    end

    follow_path(dt)

end

function stab_state(dt)

    if currentAnim ~= 0 then
        animator:set_current_animation(0)
        currentAnim = 0
    end

    enemyRb:set_velocity(Vector3.new(0, 0, 0))

    -- Logica de Stab
    timeSinceLastStab = timeSinceLastStab + dt

    if timeSinceLastStab >= stabTimer then
        make_damage()
        timeSinceLastStab = 0
    end

end



-- Funciones para calcular cosas.    :)
function make_damage()
    if timeSinceLastHit < invulnerability then
        return
    end

    if player ~= nil then
        if playerScript ~= nil then
            local damage = 10

            if playerScript.playerHealth > 0 then
                playerScript.playerHealth = playerScript.playerHealth - damage
            end
            


            audioDanoPlayerMusic:pause()
            audioDanoPlayerMusic:play()
            print("PlayerHealth: " .. playerScript.playerHealth)
            timeSinceLastHit = 0
        end
    end

end

function shoot_projectile(dt)

    bulletRb:set_position(enemyTransf.position)

    local direction = Vector3.new(playerTransf.position.x - enemyTransf.position.x, 0, playerTransf.position.z - enemyTransf.position.z)
    local velocity = Vector3.new(direction.x * bulletSpeed, 0, direction.z * bulletSpeed)
    bulletRb:set_velocity(velocity)

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

function Die()
    currentState = state.Idle
    enemyRb:set_position(Vector3.new(-500, 0, 0))
    isDead = true
end

function on_exit() end