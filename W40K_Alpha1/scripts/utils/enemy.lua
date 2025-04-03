local enemy = {}

-- Reference to the components of the entity
enemy.enemyTransf = nil
enemy.animator = nil
enemy.enemyNavmesh = nil

enemy.player = nil
enemy.playerTransf = nil

enemy.entity = nil

-- Generic stats of the enemy
enemy.health = 95
enemy.speed = 3
enemy.damage = 5
enemy.detectionRange = 25


enemy.state = { Idle = 1, Move = 2, Shoot = 3, Chase = 4, Stab = 5}
enemy.currentState = enemy.state.Idle


-- Variable for the functions of the enemy
enemy.currentAnim = 0
enemy.raycastAngle = 15
enemy.currentPathIndex = 1

function enemy:new(obj)

    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    return obj

end

function enemy.idle_state()

    if enemy.currentAnim ~= 0 then
        enemy.currentAnim = 0
        enemy.animator:set_current_animation(enemy.currentAnim)
    end

end

function enemy.move_state()

    if enemy.currentAnim ~= 1 then
        enemy.currentAnim = 1
        enemy.animator:set_current_animation(enemy.currentAnim)
    end

end

function enemy.chase_state()

    if enemy.currentAnim ~= 1 then
        enemy.currentAnim = 1
        enemy.animator:set_current_animation(enemy.currentAnim)
    end

end

function enemy.attack_state()

    -- Function implementation here
    log("Attack State")

end

function enemy.die_state()

    if enemy.currentAnim ~= 2 then
        enemy.currentAnim = 2
        enemy.animator:set_current_animation(enemy.currentAnim)
    end

end

function enemy.detect_area()

    local direction = Vector3.new(
        math.sin(math.rad(enemy.enemyTransf.rotation.y)), 
        0, 
        math.cos(math.rad(enemy.enemyTransf.rotation.y))
    )

    -- Normalize direction
    local distance = math.sqrt(direction.x^2 + direction.z^2)
    if distance > 0 then
        direction.x = direction.x / distance
        direction.z = direction.z / distance
    end

    -- Separation angle in radians (~30 degrees)
    local angleOffset = math.rad(enemy.raycastAngle)  

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

    local origin = enemy.enemyTransf.position
    local maxDistance = enemy.detectionRange

    -- Raycast
    local centerHit = Physics.Raycast(origin, direction, maxDistance)
    local leftHit = Physics.Raycast(origin, leftDirection, maxDistance)
    local rightHit = Physics.Raycast(origin, rightDirection, maxDistance)



    -- Raycast hitting the player
    if enemy.detect(centerHit, enemy.player) then
        log("Player detected in center ray")
    elseif enemy.detect(leftHit, enemy.player) then
        log("Player detected in left ray")
    elseif enemy.detect(rightHit, enemy.player) then
        log("Player detected in right ray")
    end

    -- Raycast hitting another entity
    if enemy.detect(centerHit, enemy.entity) then
        log("Entity detected in center ray")
    elseif enemy.detect(leftHit, enemy.entity) then
        log("Entity detected in left ray")
    elseif enemy.detect(rightHit, enemy.entity) then
        log("Entity detected in right ray")
    end



    -- Debug draw of the rays
    Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
    Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))

end

function enemy.detect(rayHit, entity)

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity == entity

end

function enemy.update_path(entity)

    if entity == nil or enemy.enemyNavmesh == nil then 
        return 
    end

    enemy.enemyNavmesh.path = enemy.enemyNavmesh:find_path(enemy.enemyTransf.position, entity.position)
    --enemy.currentPathIndex = 1

end

function enemy.get_distance(pos1, pos2)

    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)

end

return enemy
