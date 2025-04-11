local enemy = {}

enemy.state = { Idle = 1, Move = 2, Attack = 3}
enemy.godMode = true





function enemy:new(obj)

    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    -- Reference to the components of the entity
    obj.level = nil
    obj.player = nil
    obj.playerTransf = nil
    obj.playerScript = nil
    obj.enemyTransf = nil
    obj.animator = nil
    obj.enemyRbComponent = nil
    obj.enemyRb = nil
    obj.enemyNavmesh = nil
    obj.explosive = nil
    obj.explosiveTransf = nil
    obj.scrap = nil
    obj.scrapTransf = nil

    -- Generic stats of the enemy
    obj.health = 95
    obj.shieldHealth = 0
    obj.enemyShield = 35
    obj.speed = 3
    obj.damage = 5
    obj.detectionRange = 25
    obj.priority = 0

    -- Variables for the states
    obj.state = self.state
    obj.currentState = obj.state.Idle

    -- Variables for the animations
    obj.currentAnim = 0
    obj.idleAnim = 0
    obj.moveAnim = 1
    obj.dieAnim = 2
    obj.attackAnim = 3

    -- Variable for the functions of the enemy
    obj.haveShield = false
    obj.shieldDestroyed = false
    obj.key = 0
    obj.isDead = false
    obj.playerDistance = 0
    obj.playerDetected = false
    obj.enemyInitialPos = nil
    obj.lastTargetPos = Vector3.new(0, 0, 0)
    obj.raycastAngle = 15
    obj.currentPathIndex = 1
    obj.currentRotationY = 0
    obj.invulnerable = false
    obj.isReturning = false

    return obj

end





-- State functions
function enemy:idle_state()

    if self.currentAnim ~= self.idleAnim then
        self.currentAnim = self.idleAnim
        self.animator:set_current_animation(self.currentAnim)
    end

end

function enemy:move_state()

    if self.currentAnim ~= self.moveAnim then
        self.currentAnim = self.moveAnim
        self.animator:set_current_animation(self.currentAnim)
    end

    self:follow_path()

end

function enemy:attack_state()

    -- Function implementation here
    log("Attack State")

end

function enemy:die_state()

    if self.currentAnim ~= self.dieAnim then
        self.currentAnim = self.dieAnim
        self.animator:set_current_animation(self.currentAnim)
    end

    self.playerScript.enemys_targeting = self.playerScript.enemys_targeting - 1 

    self.currentState = self.state.Idle
    self.enemyRb:set_position(Vector3.new(-500, 0, 0))
    self.isDead = true

    self:generate_scrap()

end





-- Function of the raycast
function enemy:enemy_raycast()

    local direction = Vector3.new(0, 0, 0)

    if not self.playerDetected then
        direction = Vector3.new(
            math.sin(math.rad(self.enemyTransf.rotation.y)), 
            0, 
            math.cos(math.rad(self.enemyTransf.rotation.y))
        )
    else
        direction = Vector3.new(
            self.playerTransf.position.x - self.enemyTransf.position.x,
            self.playerTransf.position.y - self.enemyTransf.position.y,
            self.playerTransf.position.z - self.enemyTransf.position.z
        )
    end

    -- Normalize direction
    local distance = math.sqrt(direction.x^2 + direction.z^2)
    if distance > 0 then
        direction.x = direction.x / distance
        direction.z = direction.z / distance
    end

    -- Separation angle in radians (~30 degrees)
    local angleOffset = math.rad(self.raycastAngle)  

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

    local origin = self.enemyTransf.position
    local maxDistance = self.detectionRange

    -- Raycast
    local centerHit = Physics.Raycast(origin, direction, maxDistance)
    local leftHit = Physics.Raycast(origin, leftDirection, maxDistance)
    local rightHit = Physics.Raycast(origin, rightDirection, maxDistance)



    -- Raycast hitting the player
    if self:detect(centerHit, self.player) then

        self.playerDetected = true
        self.playerDistance = self:get_distance(origin, centerHit.hitPoint)

    elseif self:detect(leftHit, self.player) then

        self.playerDetected = true
        self.playerDistance = self:get_distance(origin, leftHit.hitPoint)

    elseif self:detect(rightHit, self.player) then

        self.playerDetected = true
        self.playerDistance = self:get_distance(origin, rightHit.hitPoint)

    end

    -- Raycast hitting the explosive
    if self:detect(centerHit, self.explosive) then

        self.explosiveDetected = true

    elseif self:detect(leftHit, self.explosive) then

        self.explosiveDetected = true

    elseif self:detect(rightHit, self.explosive) then   

        self.explosiveDetected = true
    end

    -- Raycast hitting another entity
    if self:detect(centerHit, self.entity) then

        log("Entity detected in center ray")

    elseif self:detect(leftHit, self.entity) then

        log("Entity detected in left ray")

    elseif self:detect(rightHit, self.entity) then

        log("Entity detected in right ray")

    end



    -- Debug draw of the rays
    if enemy.godMode then
        Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
        Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
        Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    end

end

-- Function to detect entities with the raycast
function enemy:detect(rayHit, entity)

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity == entity

end

-- Function to calculate the path of an entity
function enemy:update_path(transform)

    if transform == nil or self.enemyNavmesh == nil then 
        return 
    end

    self.enemyNavmesh.path = self.enemyNavmesh:find_path(self.enemyTransf.position, transform.position)
    self.currentPathIndex = 1

end

function enemy:update_path_position(position)

    if position == nil or self.enemyNavmesh == nil then 
        return 
    end

    self.enemyNavmesh.path = self.enemyNavmesh:find_path(self.enemyTransf.position, position)
    self.currentPathIndex = 1

end

-- Function to follow the next point of the path
function enemy:follow_path()

    if self.enemyNavmesh == nil or #self.enemyNavmesh.path == 0 then
        return
    end

    local nextPoint = self.enemyNavmesh.path[self.currentPathIndex]

    local direction = Vector3.new(
        nextPoint.x - self.enemyTransf.position.x,
        nextPoint.y - self.enemyTransf.position.y,
        nextPoint.z - self.enemyTransf.position.z
    )

    local distance = math.sqrt(direction.x^2 + direction.y^2 + direction.z^2)

    if distance > 0.1 then
        local normalizedDirection = Vector3.new(
            direction.x / distance,
            direction.y / distance,
            direction.z / distance
        )

        local velocity = Vector3.new(normalizedDirection.x * self.speed, 0, normalizedDirection.z * self.speed)
        self.enemyRb:set_velocity(velocity)

        self:rotate_enemy(nextPoint)
    else
        if self.currentPathIndex < #self.enemyNavmesh.path then
            self.currentPathIndex = self.currentPathIndex + 1
        end
    end

end





-- Functions to calculate things
function enemy:generate_scrap()
    self.scrapTransf.position = self.enemyTransf.position
end

function enemy:check_initial_distance()

    local distance = self:get_distance(self.enemyInitialPos, self.enemyTransf.position)
    if distance > 40 then
        self.playerDetected = false
        self.currentState = self.state.Move
        self.isReturning = true
    elseif self.isReturning and distance < 0.5 then
        self.enemyRb:set_velocity(Vector3.new(0, 0, 0))
        self.currentState = self.state.Idle
        self.isReturning = false
    end

end

function enemy:set_level()

    

end

function enemy:make_damage(damage)

    if self.playerScript.playerHealth > 0 then
        self.playerScript.playerHealth = self.playerScript.playerHealth - damage
        print(self.playerScript.playerHealth)
    end

end

function enemy:take_damage(damage, shieldMultiplier)
    if shieldMultiplier == nil then
        shieldMultiplier = 1
    end

    if self.invulnerable then
        log("Enemy is invulnerable")
        return
    end
    if self.shieldHealth > 0 then
        self.shieldHealth = self.shieldHealth - (damage * shieldMultiplier)
        print(self.shieldHealth)
    else
        self.health = self.health - damage
        print(self.health)
    end

    if self.health <= 0 then
        self:die_state()
    end

end

function enemy:rotate_enemy(targetPosition)

	local dx = targetPosition.x - self.enemyTransf.position.x
	local dz = targetPosition.z - self.enemyTransf.position.z

    local targetAngle = math.deg(math.atan(dx / dz))
    if dz < 0 then
        targetAngle = targetAngle + 180
    end

    targetAngle = (targetAngle + 180) % 360 - 180
    local currentAngle = (self.currentRotationY + 180) % 360 - 180
    local deltaAngle = (targetAngle - currentAngle + 180) % 360 - 180

    self.currentRotationY = currentAngle + deltaAngle * 0.1
    self.enemyTransf.rotation.y = self.currentRotationY

end

function enemy:get_distance(pos1, pos2)

    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)

end

return enemy