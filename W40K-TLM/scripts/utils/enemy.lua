local effect = require("scripts/utils/status_effects")
local zones_data = require("scripts/utils/zones_data")
local enemy = {}

enemy.state = { Dead = 1, Idle = 2, Detect = 3, Move = 4, Attack = 5}
enemy.godMode = true

local prefabScrap= "prefabs/Misc/Scrap.prefab"

function enemy:new(obj)

    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self


    -- Reference to the components of the entity
    obj.sceneName = nil

    obj.enemyTransf = nil
    obj.animator = nil
    obj.enemyRbComponent = nil
    obj.enemyRb = nil
    obj.enemyNavmesh = nil

    obj.player = nil
    obj.playerTransf = nil
    obj.playerScript = nil

    obj.explosive = nil
    obj.explosiveTransf = nil

    obj.scrap = nil
    obj.scrapTransf = nil

    obj.misionManager = nil

    obj.zone1 = nil
    obj.zone2 = nil
    obj.zone3 = nil
    obj.zone1RbComponent = nil
    obj.zone2RbComponent = nil
    obj.zone3RbComponent = nil
    obj.zone1Rb = nil
    obj.zone2Rb = nil
    obj.zone3Rb = nil


    -- Tags
    obj.enemyType = "Nil"
    obj.playerObjectsTagList = {"Sphere1", "Sphere2", "Sphere3", "Sphere4", "Sphere5", "Sphere6", "Sphere7", "Sphere8", "DisruptorBullet", "Granade", "ChargeZone"} 
    obj.playerObjects = {}

    -- Generic stats of the enemy
    obj.health = 95
    obj.defaultHealth = 95
    obj.speed = 3
    obj.defaultSpeed = 3
    obj.damage = 5
    obj.shieldHealth = 0
    obj.enemyShield = 35
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
    obj.hitAnim = -1
    obj.detectAnim = 4


    -- **Variable for the functions of the enemy**
    -- Ints
    obj.level = 1
    obj.key = 0
    obj.playerDistance = 0
    obj.proximityDetectionRadius = 3
    obj.raycastAngle = 15
    obj.currentPathIndex = 1
    obj.currentRotationY = 0
    obj.raycastRotationY = 0
    obj.oscillationAngle = 0
    obj.oscillationSpeed = 2
    obj.zoneNumber = 0

    -- Bools
    obj.haveShield = false
    obj.shieldDestroyed = false
    obj.isDead = false
    obj.playerDetected = false
    obj.invulnerable = false
    obj.isReturning = false
    obj.isPushed = false
    obj.isGranadePushed = false
    obj.zoneSet = false
    obj.isArenaEnemy = false
    obj.playingDieAnim = false
    obj.isPlayingAnimation = false
    obj.playerMissing = false

    -- Vector3
    obj.enemyInitialPos = Vector3.new(0, 0, 0)
    obj.lastTargetPos = Vector3.new(0, 0, 0)

    -- Timers
    obj.animDuration = 0.0
    obj.animTimer = 0.0
    obj.pushedTime = 0.3
    obj.pushedTimeCounter = 0.0
    obj.dieTimer = 0.0
    obj.dieDuration = 0.0
    obj.detectAnimTimer = 0.0
    obj.detectAnimDuration = 0.0

    -- Audios
    obj.hurtSFX = nil
    obj.dyingSFX = nil
    obj.stepSFX = nil

    -- Effects
    obj.isNeuralInhibitioning = false
    obj.neuralFirstTime = true

    -- Particles
    obj.particle_spark = nil
    obj.particle_spark_transform = nil

    -- Mision
    obj.enemyDie = false

    -- Alert system
    obj.isAlerted = false
    obj.hasAlerted = false

    return obj

end



function enemy:check_effects(dt)
    
    if self.isNeuralInhibitioning then
        if self.neuralFirstTime then
            local speedVecs = effect:ApplyNeuralChanges(self.speed, 0)
            self.speed = speedVecs.x       
            self.neuralFirstTime = false
        end
        self.isNeuralInhibitioning = effect:neural(dt)
        
    else
        
        if not self.neuralFirstTime then
            self.speed = self.defaultSpeed
        end
        self.neuralFirstTime = true
    end

end

function enemy:check_pushed(dt)

    if self.isPushed or self.isGranadePushed then
        self:update_pushed(dt)
    end

end

function enemy:update_pushed(dt)

    self.pushedTimeCounter = self.pushedTimeCounter + dt
    if self.pushedTimeCounter >= self.pushedTime then
        self.pushedTimeCounter = 0
        self.isPushed = false
        self.isGranadePushed = false
    end

end

-- State functions
function enemy:idle_state()

    if self.currentAnim ~= self.idleAnim then
        self:play_blocking_animation(self.idleAnim, self.idleDuration)
    end

end

function enemy:move_state()

    if self.currentAnim ~= self.moveAnim then
        self.currentAnim = self.moveAnim
        self.animator:set_current_animation(self.currentAnim)
    end
    print("Move")
    self:follow_path()

end

function enemy:attack_state()

    -- Function implementation here
    log("Attack State")

end

function enemy:detect_state(dt)

    if self.currentAnim ~= self.detectAnim then
        self:play_blocking_animation(self.detectAnim, self.detectDuration)
        print("Detect animation")
    end

    if self.animTimer >= self.detectDuration and not self.isAlerted then
        self:alert_nearby_enemies(dt)
    end
end

function enemy:die_state(dt)
    
    if self.currentAnim ~= self.dieAnim then
        self:play_blocking_animation(self.dieAnim, self.dieDuration)
        --if self.hurtSFX ~= nil then self.hurtSFX:stop() end
        if self.dyingSFX ~= nil then self.dyingSFX:play() end
    end

    if self.animTimer >= self.dieDuration then

        self.playerScript.enemys_targeting = self.playerScript.enemys_targeting - 1 
        self.currentState = self.state.Idle
        self.enemyRb:set_position(Vector3.new(-500, 0, 0))
        self.isDead = true

        self:generate_scrap()

        if self.misionManager and self.enemyDie == false  then
            if self.misionManager.getCurrerTaskIndex(true) <= 3 then
                self.misionManager.m3_EnemyCount = self.misionManager.m3_EnemyCount + 1
            end
            
            if self.misionManager.getCurrerTaskIndex(true) == 4 then
                self.misionManager.m4_EnemyCount = self.misionManager.m4_EnemyCount + 1
            end
            
            self.enemyDie = true
        end
    end
end

function enemy:stun_state()
    if self.currentAnim ~= self.stunAnim then
        self:play_blocking_animation(self.stunAnim, self.stunDuration)
    end
    self.enemyRb:set_velocity(Vector3.new(0, 0, 0))
end




-- Function of the raycast
function enemy:enemy_raycast(dt)

    local direction = Vector3.new(0, 0, 0)
    local origin = Vector3.new(self.enemyTransf.position.x, 0.5, self.enemyTransf.position.z)
    local maxDistance = self.detectionRange

    self.raycastRotationY = self.enemyTransf.rotation.y

    if not self.playerDetected then
        direction = Vector3.new(
            math.sin(math.rad(self.raycastRotationY)), 
            0, 
            math.cos(math.rad(self.raycastRotationY))
        )
    else
        direction = Vector3.new(
            self.playerTransf.position.x - origin.x,
            0,
            self.playerTransf.position.z - origin.z
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

    local centerDirection = Vector3.new(0, 0, 0)
    if not self.playerDetected then
        self.oscillationAngle = self.oscillationAngle + self.oscillationSpeed * dt
        local centralAngleOffset = math.sin(self.oscillationAngle) * angleOffset
        
        centerDirection = Vector3.new(
            direction.x * math.cos(centralAngleOffset) - direction.z * math.sin(centralAngleOffset),
            0,
            direction.x * math.sin(centralAngleOffset) + direction.z * math.cos(centralAngleOffset)
        )
    else
        centerDirection = direction
    end

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

    -- Raycast
    local centerHit = Physics.Raycast(origin, centerDirection, maxDistance)
    local leftHit = Physics.Raycast(origin, leftDirection, maxDistance)
    local rightHit = Physics.Raycast(origin, rightDirection, maxDistance)

    -- Raycast hitting the player
    if not self.isReturning then
        if self:detect(centerHit, self.player) then

            self.playerDetected = true
            self.playerMissing = false
            self.playerDistance = self:get_distance(origin, centerHit.hitPoint)
    
        elseif self:detect(leftHit, self.player) then
    
            self.playerDetected = true
            self.playerMissing = false
            self.playerDistance = self:get_distance(origin, leftHit.hitPoint)
    
        elseif self:detect(rightHit, self.player) then
    
            self.playerDetected = true
            self.playerMissing = false
            self.playerDistance = self:get_distance(origin, rightHit.hitPoint)
    
        end
    
        -- Raycast hitting the player objects
        for i = 1, 11 do
            if self:detect_by_tag(centerHit, self.playerObjectsTagList[i]) then
    
                self.playerDetected = true
                self.playerMissing = false
        
            elseif self:detect_by_tag(leftHit, self.playerObjectsTagList[i]) then
        
                self.playerDetected = true
                self.playerMissing = false
        
            elseif self:detect_by_tag(rightHit, self.playerObjectsTagList[i]) then
        
                self.playerDetected = true
                self.playerMissing = false
        
            end
        end

        if self.playerDetected and not (self:detect(centerHit, self.player) or self:detect(leftHit, self.player) or self:detect(rightHit, self.player)) then
            self.playerMissing = true
        end
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
    if self.playerScript.godMode then
        Physics.DebugDrawRaycast(origin, centerDirection, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
        Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
        Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    end

end

-- Function to detect entities with the raycast
function enemy:detect(rayHit, entity)

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity == entity

end

function enemy:detect_by_tag(rayHit, tag)

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity:get_component("TagComponent").tag == tag

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
        if self.isReturning then
            velocity = velocity * 2
        end

        self.enemyRb:set_velocity(velocity)

        self:rotate_enemy(nextPoint)
    else
        if self.currentPathIndex < #self.enemyNavmesh.path then
            self.currentPathIndex = self.currentPathIndex + 1
        end
    end

end

function enemy:check_spawn()

    local levelZones = zones_data["level" .. self.level]
    local pos = self.enemyTransf.position

    if levelZones then
        for _, zone in ipairs(levelZones) do
            if self:is_point_in_polygon(pos, zone.points) then
                self.zoneNumber = zone.id
                break
            end
        end
    else
        print("[ZONES] No zones for level:", self.level)
    end

    if self.zoneNumber < self.playerScript.zonePlayer + 1 then
        self.currentState = self.state.Idle
        self.enemyRb:set_position(Vector3.new(-500, 0, 0))
        self.isDead = true
    end

end

function enemy:is_point_in_polygon(point, polygon)
    local inside = false
    local j = #polygon
    for i = 1, #polygon do
        local xi, zi = polygon[i].x, polygon[i].z
        local xj, zj = polygon[j].x, polygon[j].z
        if ((zi > point.z) ~= (zj > point.z)) and
           (point.x < (xj - xi) * (point.z - zi) / (zj - zi + 0.0001) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

function enemy:alert_nearby_enemies(dt)  
    if self.isAlerted then return end
    print("Alert nearby Enemies")
    local alertedCount = 0
    for _, enemyData in ipairs(self.nearbyEnemies) do
        if enemyData.script and not enemyData.alerted then
            enemyData.script.playerDetected = true
            enemyData.script.isAlerted = true
            enemyData.script.alertTimer = 0.0
            enemyData.alerted = true
            alertedCount = alertedCount + 1
        end
    end
    self.isAlerted = true
    self.currentState = self.state.Move
end

function enemy:avoid_alert_enemies(dt)  
    if self.hasAlerted then return end
    for _, enemyData in ipairs(self.nearbyEnemies) do
        if enemyData.script then
            enemyData.script.hasAlerted = true
        end
    end
    self.hasAlerted = true
end


function enemy:generate_scrap()

    local scrapCount = math.random(1, 3)
    
    log("Generating " .. scrapCount .. " scraps")
    
    for i = 1, scrapCount do
        --offset para que no se spawneen uno encima de otro
        local offsetX = math.random(-100, 100) / 100  
        local offsetZ = math.random(-100, 100) / 100
        
        local spawnPosition = Vector3.new(
            self.enemyTransf.position.x + offsetX,
            self.enemyTransf.position.y,
            self.enemyTransf.position.z + offsetZ
        )
        
        local scrap = instantiate_prefab(prefabScrap)
        local scrapTransf = scrap:get_component("TransformComponent")
        scrapTransf.position = spawnPosition
        
        log("Spawned scrap " .. i .. " at position: " .. spawnPosition.x .. ", " .. spawnPosition.y .. ", " .. spawnPosition.z)
        
        if i == 1 then
            self.scrap = scrap
            self.scrapTransf = scrapTransf
        end
    end
end

function enemy:check_initial_distance()

    local distance = self:get_distance(self.enemyInitialPos, self.enemyTransf.position)
    if distance > 30 then
        self.playerDetected = false
        self.currentState = self.state.Move
        self.isReturning = true
        self.health = self.defaultHealth
    elseif self.isReturning and distance < 0.5 then
        self.enemyRb:set_velocity(Vector3.new(0, 0, 0))
        self.currentState = self.state.Idle
        self.isReturning = false
        self.health = self.defaultHealth
    end

end

function enemy:set_level()

    if self.sceneName == "level1.TeaScene" then
        self.level = 1
    elseif self.sceneName == "level2.TeaScene" then
        self.level = 2
    else
        self.level = 1
    end

end

function enemy:play_blocking_animation(animId, duration)

    self.currentAnim = animId
    self.animator:set_current_animation(animId)
    self.isPlayingAnimation = true
    self.animDuration = duration
    self.animTimer = 0.0

end

function enemy:make_damage(damage)
    
    if self.playerScript.godMode then return end
    if self.playerScript.intangibleDash then return end
    if self.playerScript.isCovering then return end

    if self.playerScript.health > 0 then
        local finalDamange = damage * self.playerScript.damageReduction
        self.playerScript.health = self.playerScript.health - finalDamange
        print(self.playerScript.health)
        self.playerScript.takeHit()
    end

end

function enemy:take_damage(damage, shieldMultiplier)
    
    -- if self.hitAnim ~= -1 then
    --     if self.currentAnim ~= self.hitAnim then
    --         self.currentAnim = self.hitAnim
    --         self.animator:set_current_animation(self.currentAnim)
    --     end
    -- end
    
    if shieldMultiplier == nil then
        shieldMultiplier = 1
    end

    if self.invulnerable then
        log("Enemy is invulnerable")
        return
    end
    if self.shieldHealth > 0 then
        self.shieldHealth = self.shieldHealth - (damage * shieldMultiplier)
        if self.hurtSFX then self.hurtSFX:play() end
        print(self.shieldHealth)
    else
        self.health = self.health - damage
        if self.hurtSFX then self.hurtSFX:play() end
        print(self.health)
    end

    if self.health <= 0 then
        self:die_state()
    end

end

function enemy:rotate_enemy(targetPosition)
    local dx = targetPosition.x - self.enemyTransf.position.x
    local dz = targetPosition.z - self.enemyTransf.position.z

    local targetAngle = math.deg(self:atan2(dx, dz))

    self.enemyRb:set_rotation(Vector3.new(0, targetAngle,0))
end

function enemy:check_player_distance()
    if self.isReturning then return end
    local distance = self:get_distance(self.enemyTransf.position, self.playerTransf.position)
    if distance <= self.proximityDetectionRadius then
        self.playerDetected = true
        self.playerDistance = distance
    end
    for i = 1, 11 do
        if self.playerObjects[i] ~= nil then
            local objectDistance = self:get_distance(self.enemyTransf.position, self.playerObjects[i].position)
            if objectDistance <= self.proximityDetectionRadius then
                self.playerDetected = true
            end
        end
    end
end

function enemy:get_distance(pos1, pos2)

    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    local dz = pos2.z - pos1.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)

end

function enemy:atan2(y, x)
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 then
        if y >= 0 then
            return math.atan(y / x) + math.pi
        else
            return math.atan(y / x) - math.pi
        end
    elseif x == 0 then
        if y > 0 then
            return math.pi / 2
        elseif y < 0 then
            return -math.pi / 2
        else
            return 0 -- indeterminado, pero retornamos 0 por defecto
        end
    end
end

return enemy