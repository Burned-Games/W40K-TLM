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
enemyHealth = 95
shieldHealth = 0
haveShield = false
shield_destroyed = false

local detectDistance = 25
local shootDistance = 15
local chaseDistance = 8
local stabDistance = 2

local currentAnim = 0
local animator = nil

local state = { Idle = 1, Move = 2, Shoot = 3, Chase = 4, Stab = 5}
currentState = state.Idle
local playerDetected = false
local isChasing = false

local pathUpdateTimer = 0
local pathUpdateInterval = 0.5
local lastTargetPos = nil

local delayedPlayerPos = nil
local updateTargetTimer = 0
local updateTargetInterval = 1

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

local stabTimer = 1
local timeSinceLastStab = 0
local stabCooldown = 2 
local stabCooldownTimer = 0 

local invulnerability = 0.1
local timeSinceLastHit = 0

local currentPathIndex = 1

isDead = false

local audioDanoPlayerMusic = nil

local playerDistance = nil

local visionAngle = 0 -- Ángulo actual del rayo
local visionSpeed = 60 -- Velocidad de oscilación (grados por segundo)
local visionRange = 30 -- Máximo desplazamiento (grados)

pushed = false
local pushedTime = 0.5
local pushedTimeCounter = 0

zoneNumber = 0
local zone_set = false

--Mision
mission_Component = nil


function on_ready() 

    --audioDanoPlayerMusic = current_scene:get_entity_by_name("AudioDanoPlayer"):get_component("AudioSourceComponent")
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
    
    bulletComponent:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            make_damage()
        end
    end)

    mission6Component = current_scene:get_entity_by_name("Mission6Collider"):get_component("ScriptComponent")
    mission8Component = current_scene:get_entity_by_name("Mission8Collider"):get_component("ScriptComponent")

    if player ~= nil then
        playerDistance = get_distance(enemyTransf.position, playerTransf.position)
        lastTargetPos = playerTransf.position
        delayedPlayerPos = playerTransf.position
        update_path()
    end

    --Mission
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")

end



-- FSM del Orko Basico.
function on_update(dt)

    if zone_set ~= true then
        check_zone()
        zone_set = true
    end

    if player == nil or isDead == true then 
        return 
    end

    if enemyHealth <= 0 then
        die()
    end

    if haveShield and shieldHealth <= 0 then
        haveShield = false
        shield_destroyed=true
    end

    change_state(dt)

    pathUpdateTimer = pathUpdateTimer + dt
    timeSinceLastHit = timeSinceLastHit + dt
    updateTargetTimer = updateTargetTimer + dt

    -- Verificar si el jugador se movio lo suficiente o si paso el tiempo del intervalo
    local currentTargetPos = playerTransf.position
    if pathUpdateTimer >= pathUpdateInterval or get_distance(lastTargetPos, currentTargetPos) > 1.0 then
        update_path()
        lastTargetPos = currentTargetPos
        pathUpdateTimer = 0
    end

    if updateTargetTimer >= updateTargetInterval then
        delayedPlayerPos = Vector3.new(playerTransf.position.x, playerTransf.position.y, playerTransf.position.z)
        updateTargetTimer = 0
    end

    if playerDetected then
        rotate_enemy(playerTransf.position)
    end


    if pushed == false then
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
    else
        pushedTimeCounter = pushedTimeCounter + dt
        if pushedTimeCounter >= pushedTime then
            pushedTimeCounter = 0
            pushed = false
            
        end
    end

end



-- Deteccion del Player y cambio de estados en funcion de la distancia.
function change_state(dt)

    if playerDetected == false then
        detect_area()
    else
        single_raycast()
    end
                
    -- Si esta en Chasing no vuelve a Shoot ni a Move.
    if isChasing then
        if playerDistance <= stabDistance then
            if currentState ~= state.Stab then
                currentState = state.Stab
            end
                
        elseif playerDistance > stabDistance and currentState == state.Stab then
            currentState = state.Chase
        end
                
        return      -- Evita que vuelva a Move o Shoot.
    end
                
    -- **ORDEN IMPORTANTE** Chase y Stab tienen que evaluarse primero, sino no funcionara bien!!!
    if playerDistance <= stabDistance then
        if currentState ~= state.Stab then
            currentState = state.Stab
            isChasing = true
        end
                
    elseif playerDistance <= chaseDistance then
        if currentState ~= state.Chase then
            currentState = state.Chase
            isChasing = true
        end
                
    elseif playerDistance <= shootDistance then
        if currentState ~= state.Shoot then
            currentState = state.Shoot
        end
                
    elseif playerDistance > shootDistance and currentState == state.Shoot then
        if currentState ~= state.Move then
            currentState = state.Move
        end
    end

end

function detect_player(rayHit)

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity == player

end

function detect_area()

    local direction = Vector3.new(
        math.sin(math.rad(enemyTransf.rotation.y)), 
        0, 
        math.cos(math.rad(enemyTransf.rotation.y))
    )

    -- Normalizar dirección para evitar distancias erróneas
    local distance = math.sqrt(direction.x^2 + direction.z^2)
    if distance > 0 then
        direction.x = direction.x / distance
        direction.z = direction.z / distance
    end

    -- Ángulo de separación en radianes (~30 grados)
    local angleOffset = math.rad(15)  
    local intermediateAngleOffset = math.rad(7.5)

    -- Rotar la dirección hacia la izquierda y derecha
    local leftDirection = Vector3.new(
        direction.x * math.cos(angleOffset) - direction.z * math.sin(angleOffset),
        0,
        direction.x * math.sin(angleOffset) + direction.z * math.cos(angleOffset)
    )

    local rightDirection = Vector3.new(
        direction.x * math.cos(-angleOffset) - direction.z * math.sin(-angleOffset),
        0,
        direction.x * math.sin(-angleOffset) + direction.z * math.cos(-angleOffset)
    )

    local intermediateLeftDirection = Vector3.new(
        direction.x * math.cos(intermediateAngleOffset) - direction.z * math.sin(intermediateAngleOffset),
        0,
        direction.x * math.sin(intermediateAngleOffset) + direction.z * math.cos(intermediateAngleOffset)
    )

    local intermediateRightDirection = Vector3.new(
        direction.x * math.cos(-intermediateAngleOffset) - direction.z * math.sin(-intermediateAngleOffset),
        0,
        direction.x * math.sin(-intermediateAngleOffset) + direction.z * math.cos(-intermediateAngleOffset)
    )

    local origin = enemyTransf.position
    local maxDistance = 25.0

    -- Dibujar los tres rayos para depuración
    Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
    Physics.DebugDrawRaycast(origin, intermediateLeftDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1)) 
    Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    Physics.DebugDrawRaycast(origin, intermediateRightDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1))
    Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))

    -- Lanzar los rayos
    local centerHit = Physics.Raycast(origin, direction, maxDistance)
    local intermediateLeftHit = Physics.Raycast(origin, intermediateLeftDirection, maxDistance)
    local leftHit = Physics.Raycast(origin, leftDirection, maxDistance)
    local intermediateRightHit = Physics.Raycast(origin, intermediateRightDirection, maxDistance)
    local rightHit = Physics.Raycast(origin, rightDirection, maxDistance)
    

    if detect_player(centerHit) then

        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, centerHit.hitPoint)

    elseif detect_player(intermediateLeftHit) then
        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, intermediateLeftHit.hitPoint)

    elseif detect_player(leftHit) then

        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, leftHit.hitPoint)

    elseif detect_player(intermediateRightHit) then
        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, intermediateRightHit.hitPoint)

    elseif detect_player(rightHit) then

        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, rightHit.hitPoint)
        
    end

end

function single_raycast()
    
    local direction = Vector3.new(
        playerTransf.position.x - enemyTransf.position.x,
        playerTransf.position.y - enemyTransf.position.y,
        playerTransf.position.z - enemyTransf.position.z
    )

    local origin = enemyTransf.position
    local maxDistance = 25.0

    Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))

    local rayHit = Physics.Raycast(origin, direction, maxDistance)

    if detect_player(rayHit) then
        currentState = state.Move
        playerDetected = true
        playerDistance = get_distance(origin, rayHit.hitPoint)
    end
end

-- Funciones para los distintos estados.
function idle_state(dt)

    if currentAnim ~= 3 then
        currentAnim = 3
        animator:set_current_animation(currentAnim)
    end

end

function move_state(dt)

    if currentAnim ~= 4 then
        currentAnim = 4
        animator:set_current_animation(currentAnim)
    end

	-- Movimiento
    follow_path(dt)

end

function shoot_state(dt)

    enemyRb:set_velocity(Vector3.new(0, 0, 0))

    -- Logica de disparo
    if isShootingBurst then
        if currentAnim ~= 1 then
            currentAnim = 1
            animator:set_current_animation(currentAnim)
        end
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
        if currentAnim ~= 3 then
            currentAnim = 3
            animator:set_current_animation(currentAnim)
        end
        burstCooldownTimer = burstCooldownTimer + dt

        if burstCooldownTimer >= timeBetweenBursts then
            isShootingBurst = true
            burstCount = 0
            timeSinceLastShot = 0
        end
    end

end

function chase_state(dt)

    if currentAnim ~= 4 then
        currentAnim = 4
        animator:set_current_animation(currentAnim)
    end

    follow_path(dt)

end

function stab_state(dt)

    enemyRb:set_velocity(Vector3.new(0, 0, 0))

    if stabCooldownTimer > 0 then
        stabCooldownTimer = stabCooldownTimer - dt
        if currentAnim ~= 3 then
            currentAnim = 3
            animator:set_current_animation(currentAnim)
        end
        return 
    end

        timeSinceLastStab = timeSinceLastStab + dt

    if timeSinceLastStab < stabTimer then
        if currentAnim ~= 0 then
            currentAnim = 0
            animator:set_current_animation(currentAnim)
        end
        make_damage()
        bleed_damage()
    elseif timeSinceLastStab >= stabTimer then
        timeSinceLastStab = 0
        stabCooldownTimer = stabCooldown 
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
                print("PlayerHealth " .. playerScript.playerHealth)
            end

            --audioDanoPlayerMusic:pause()
            --audioDanoPlayerMusic:play()
            timeSinceLastHit = 0
        end
    end

end

function shoot_projectile(dt)

    bulletRb:set_position(Vector3.new(enemyTransf.position.x, enemyTransf.position.y + 0.65, enemyTransf.position.z))

    local direction = Vector3.new(delayedPlayerPos.x - enemyTransf.position.x, 0, delayedPlayerPos.z - enemyTransf.position.z)
    local velocity = Vector3.new(direction.x * bulletSpeed, 0, direction.z * bulletSpeed)
    bulletRb:set_velocity(velocity)

end

function bleed_damage()

    if playerScript ~= nil then
        playerScript:applyBleed()
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

local currentRotationY = 0

function rotate_enemy(targetPosition)

	local dx = targetPosition.x - enemyTransf.position.x
	local dz = targetPosition.z - enemyTransf.position.z

    local targetAngle = math.deg(math.atan(dx / dz))
    if dz < 0 then
        targetAngle = targetAngle + 180
    end

    targetAngle = (targetAngle + 180) % 360 - 180
    local currentAngle = (currentRotationY + 180) % 360 - 180
    local deltaAngle = (targetAngle - currentAngle + 180) % 360 - 180

    currentRotationY = currentAngle + deltaAngle * 0.1
    enemyTransf.rotation.y = currentRotationY

end

function get_distance(pos1, pos2)

    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)

end

function check_zone()
    if zoneNumber == 0 then
        local zone1 = current_scene:get_entity_by_name("Zone1")
        local zone2 = current_scene:get_entity_by_name("Zone2")
        local zone3 = current_scene:get_entity_by_name("Zone3")
        local zone1RbComponent = zone1:get_component("RigidbodyComponent")
        local zone2RbComponent = zone2:get_component("RigidbodyComponent")
        local zone3RbComponent = zone3:get_component("RigidbodyComponent")

        local zone1Rb = zone1RbComponent.rb
        local zone2Rb = zone2RbComponent.rb
        local zone3Rb = zone3RbComponent.rb
        zone1Rb:set_trigger(true)
        zone2Rb:set_trigger(true)
        zone3Rb:set_trigger(true)

        zone1RbComponent:on_collision_enter(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Zone1" or nameB == "Zone1" then
                zoneNumber = 1
            end
        end)
        zone2RbComponent:on_collision_enter(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Zone2" or nameB == "Zone2" then
                zoneNumber = 2
            end
        end)
        zone3RbComponent:on_collision_enter(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if nameA == "Zone3" or nameB == "Zone3" then
                zoneNumber = 3
            end
        end)
    end

    if zoneNumber < playerScript.zonePlayer then
        enemyRb:set_position(Vector3.new(-500, 0, 0))
        self:set_active(false)
    end
end

function die()
    currentState = state.Idle
    enemyRb:set_position(Vector3.new(-500, 0, 0))
    isDead = true

    mission_Component.enemyDieCount = mission_Component.enemyDieCount + 1

    if mission6Component.m7_missionOpen == true then
        mission_Component.enemyDie_M7 = mission_Component.enemyDie_M7-1
    end

    if mission8Component.m10_missionOpen == true then
        mission_Component.enemyDie_M10 = mission_Component.enemyDie_M10-1
    end

end

function on_exit() end