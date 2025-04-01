using = false
-- Time
local current_time = 0  
shotgun_fire_rate = 1.3 
local next_fire_time = 0 

-- ammo
maxAmmo = 12  -- maxammo
ammo = maxAmmo  -- curreamoo
reload_time = 2.8  -- reloadtime
local is_reloading = false  -- inReloading?
local reload_end_time = 0  -- record_reload_time

--PlayerTransform
local playerTransf = nil
local playerScript = nil

-- Multipliers
local attackSpeedMultiplier = 1.0
local reloadSpeedMultiplier = 1.0

-- Define the bullet speed
local bullet_speed = 10.0
local sphereSpeed = 100
-- BulletList
local bullets = {}
local bulletCount = 8  -- Bullet Num
local spreadAngle = 5  -- Bullet angle

local shootParticlesComponent
local bulletDamageParticleComponent
damage = 15
local knockbackForce = 3000  -- force


--granadas

local granadeCooldown= 12
timerGranade = 0
local granadeEntity = nil
local granadeInitialSpeed = 12

local explosionRadius = 6.0
local explosionForce = 13.0
local explosionUpward = 2.0
local granadeParticlesExplosion = nil

local lbapretado = false
dropGranade = false
granadasSpeed = false

--Workbench
local upgradeManager = nil


local baseGranadePosition = nil       
local targetGranadePosition = nil    
local granadeMoveSpeed = 0.1   
local GRENADE_GRAVITY = 12.0  
local GRENADE_LAUNCH_ANGLE = math.rad(30)  
local GRENADE_SPEED_MULTIPLIER = 1.2      
local ISOMETRIC_CORRECTION_FACTOR = 0.707  
local DISTANCE_CALIBRATION = 1.22   

function on_ready()
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    
    for i = 1, bulletCount do
        local bulletName = "Sphere" .. i  
        local bullet = {}
        
        bullet.entity = current_scene:get_entity_by_name(bulletName)
        bullet.transform = bullet.entity:get_component("TransformComponent")
        bullet.rigidBodyComponent = bullet.entity:get_component("RigidbodyComponent")
        bullet.rigidBody = bullet.rigidBodyComponent.rb
        bullet.rigidBody:set_trigger(true)
        
        table.insert(bullets, bullet)  -- save to table

        bullet.rigidBodyComponent:on_collision_enter(function(entityA, entityB)
            handle_bullet_collision(entityA, entityB)
        end)
    end

    --shootParticlesComponent = current_scene:get_entity_by_name("ParticulasDisparo"):get_component("ParticlesSystemComponent")
    --bulletDamageParticleComponent = current_scene:get_entity_by_name("ParticlePlayerBullet"):get_component("ParticlesSystemComponent")

    --Granada
   
    granadeEntity = current_scene:get_entity_by_name("Granade")
    transformGranade = granadeEntity:get_component("TransformComponent")
    --granadeParticlesExplosion = granadeEntity:get_component("ParticlesSystemComponent")

    local rb = granadeEntity:get_component("RigidbodyComponent").rb
    rb:set_use_gravity(true)
    rb:set_mass(1.0) 
    rb:set_trigger(false)

    local rbComponent = granadeEntity:get_component("RigidbodyComponent")
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "FloorCollider" or nameB == "FloorCollider" then
            explodeGranade()
        end
    end)

    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

end


function on_update(dt)
    -- Applying multipliers
    local currentShootCoolDownRifle = shotgun_fire_rate * (1 / attackSpeedMultiplier)
    local currentMaxReloadTime = reload_time * (1 / reloadSpeedMultiplier)
    if using == true then
        -- updateTime
        current_time = current_time + dt  
        -- if in reload, check is fishing
        if is_reloading then
            if current_time >= reload_end_time then
                ammo = maxAmmo  -- reload bullet
                is_reloading = false
            else
                --print("in reload")
                return  -- in reload cant shoot
            end
        end
        local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)
        -- shoot
        if rightTrigger ~= 0 then
            if ammo > 0 and current_time >= next_fire_time then
                ammo = ammo - 1  -- use bulle 
                shoot(dt)
                next_fire_time = current_time + currentShootCoolDownRifle  -- next shoot time
            elseif ammo == 0 then
                --print("no bullet")
            else
                --print("fire colddown")
            end
        end

        -- reload
        if ammo==0 and not is_reloading then
            --print("Start reload")
            is_reloading = true
            reload_end_time = current_time + currentMaxReloadTime  -- setting reload time
        end


        --granade 
        if Input.is_button_pressed(Input.controllercode.LeftShoulder) and timerGranade <= 0 then
            lbapretado = true
            granadasSpeed = true
            update_joystick_position()
        else
            if lbapretado then
                dropGranade = true
            end
            lbapretado = false
            granadasSpeed = false
        end

        if upgradeManager.has_weapon_special() then
            handleGranade(dt)
        end
    end
end

-- multiplyer of the armor ability
function set_attack_speed_multiplier(multiplier)
    attackSpeedMultiplier = multiplier
end

-- multiplyer of the armor ability
function set_reload_speed_multiplier(multiplier)
    reloadSpeedMultiplier = multiplier
end


function on_exit()
    -- Add cleanup code here
end

function shoot(dt)
    local playerPosition = playerTransf.position
    local baseAngle = playerScript.angleRotation  
    --print("Player Rotation (Y):", playerTransf.rotation.y)

    for i, bullet in ipairs(bullets) do
        local angleOffset = (i - (bulletCount / 2)) * spreadAngle  -- angle
        local shootAngle = baseAngle + math.rad(angleOffset) 
        
        local forwardVector = Vector3.new(math.sin(shootAngle), 0, math.cos(shootAngle))
        local newPosition = Vector3.new(
            playerPosition.x + forwardVector.x,
            playerPosition.y,
            playerPosition.z + forwardVector.z
        )
        
        bullet.transform.position = newPosition
        bullet.transform.rotation = Vector3.new(0, math.deg(shootAngle), 0)
        bullet.rigidBody:set_position(playerPosition)
        bullet.rigidBody:set_rotation(Vector3.new(0, math.deg(shootAngle), 0))
        
        local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
        bullet.rigidBody:set_velocity(velocity)
    end
end

function handle_bullet_collision(entityA, entityB)
   
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag
    
    local function damage_enemy(enemyEntity, bulletEntity)
        if enemyEntity then
            local enemyScript = enemyEntity:get_component("ScriptComponent")
            local enemyRigidBody = enemyEntity:get_component("RigidbodyComponent").rb
            local bulletTransform = bulletEntity:get_component("TransformComponent")
             
           
            if enemyScript then
                --bulletDamageParticleComponent:emit(20)
                if enemyScript.shieldHealth and enemyScript.shieldHealth > 0 then
                    enemyScript.shieldHealth = enemyScript.shieldHealth - damage
                    playerScript.makeDamage = true
                else
                    enemyScript.enemyHealth = enemyScript.enemyHealth - damage
                    playerScript.makeDamage = true
                end
            end

            local enemyPosition = enemyEntity:get_component("TransformComponent").position
            local bulletPosition = bulletTransform.position
            local knockbackDirection = Vector3.normalize(Vector3.new(
                enemyPosition.x - bulletPosition.x,
                0,
                enemyPosition.z - bulletPosition.z
            ))
            
            --print("Knockback Direction: ", knockbackDirection.x, knockbackDirection.z)
            
            local knockbackVelocity = Vector3.new(
                knockbackDirection.x * knockbackForce,
                0,
                knockbackDirection.z * knockbackForce
            )

            enemyRigidBody:apply_force(knockbackVelocity)
        end
    end
    
    if nameA == "EnemyOrk" or nameB == "EnemyOrk" then
        local enemy = (nameA == "EnemyOrk" and entityA) or (nameB == "EnemyOrk" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end


    if nameA == "EnemySupp" or nameB == "EnemySupp" then
        local enemy = (nameA == "EnemySupp" and entityA) or (nameB == "EnemySupp" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end

    if nameA == "EnemyKamikaze" or nameB == "EnemyKamikaze" then
        local enemy = (nameA == "EnemyOrk" and entityA) or (nameB == "EnemyOrk" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end

    if nameA == "EnemyTank" or nameB == "EnemyTank" then
        local enemy = (nameA == "EnemyOrk" and entityA) or (nameB == "EnemyOrk" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end

    if nameA == "MainBoss" or nameB == "MainBoss" then
        local enemy = (nameA == "MainBoss" and entityA) or (nameB == "MainBoss" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end
    
end


function update_joystick_position()
    local playerPos = playerTransf.position
    
    if targetGranadePosition == nil then
        targetGranadePosition = Vector3.new(playerPos.x, playerPos.y + 1.5, playerPos.z)
    end

    local inputX = Input.get_axis_position(Input.axiscode.RightX)
    local inputY = Input.get_axis_position(Input.axiscode.RightY)

    local isometricAngle = math.rad(-45)
    
    local rightVector = {
        x = math.cos(isometricAngle),
        y = 0,
        z = -math.sin(isometricAngle)
    }
    
    local forwardVector = {
        x = math.sin(isometricAngle) * math.cos(isometricAngle),
        y = -math.sin(isometricAngle),
        z = math.cos(isometricAngle) * math.cos(isometricAngle)
    }

    local moveX = (rightVector.x * inputX) + (forwardVector.x * inputY)
    local moveZ = (rightVector.z * inputX) + (forwardVector.z * inputY)
    
    local moveDirection = Vector3.new(moveX, 0, moveZ)
    
    local dirLength = math.sqrt(moveX^2 + moveZ^2)
    if dirLength > 0 then
        moveDirection = Vector3.new(
            moveX / dirLength,
            0,
            moveZ / dirLength
        )
    else
        moveDirection = Vector3.new(0, 0, 0)
    end

    local offset = Vector3.new(
        moveDirection.x * granadeMoveSpeed,
        0,
        moveDirection.z * granadeMoveSpeed
    )

    targetGranadePosition = Vector3.new(
        targetGranadePosition.x + offset.x,
        playerPos.y + 1.5,
        targetGranadePosition.z + offset.z
    )


    granadeEntity:get_component("TransformComponent").position = targetGranadePosition

    --print("Move Offset:", offset.x, offset.z)
end

function handleGranade(dt)
    if timerGranade > 0 then
        timerGranade = timerGranade - dt
    end

    if  dropGranade and timerGranade <= 0 then
        throwGranade()
        dropGranade = false
        --escopetaAudioManagerScript:playLaunchGranade()
        timerGranade = granadeCooldown
    end
end

function throwGranade()
    if not granadeEntity or not targetGranadePosition then return end


    local rb = granadeEntity:get_component("RigidbodyComponent").rb
    local playerPos = playerTransf.position
    local startPos = Vector3.new(
        playerPos.x, 
        playerPos.y + 1.5, 
        playerPos.z
    )
    

    local ISOMETRIC_CORRECTION = 0.7071  
    local DISTANCE_CALIBRATION = 1.22    


    local rawDeltaX = targetGranadePosition.x - startPos.x
    local rawDeltaZ = targetGranadePosition.z - startPos.z


    local actualDeltaX = rawDeltaX / (math.cos(math.rad(-45)) * DISTANCE_CALIBRATION)
    local actualDeltaZ = rawDeltaZ / (math.cos(math.rad(-45)) * DISTANCE_CALIBRATION)
    

    local horizontalDistance = math.sqrt(actualDeltaX^2 + actualDeltaZ^2) * ISOMETRIC_CORRECTION


    local MIN_DISTANCE = 1.5
    if horizontalDistance < MIN_DISTANCE then
        horizontalDistance = MIN_DISTANCE
        actualDeltaX = actualDeltaX * (MIN_DISTANCE / horizontalDistance)
        actualDeltaZ = actualDeltaZ * (MIN_DISTANCE / horizontalDistance)
    end


    local LAUNCH_ANGLE = math.rad(35)   
    local GRAVITY = 14.0               
    local SPEED_BOOST = 1.15           


    local verticalSpeed = math.sqrt(GRAVITY * horizontalDistance * math.tan(LAUNCH_ANGLE))
    local flightTime = (2 * verticalSpeed) / GRAVITY
    local horizontalSpeed = (horizontalDistance / (flightTime * math.cos(LAUNCH_ANGLE))) * SPEED_BOOST

    local dirX = rawDeltaX / (math.abs(rawDeltaX) + math.abs(rawDeltaZ) + 0.0001)  
    local dirZ = rawDeltaZ / (math.abs(rawDeltaX) + math.abs(rawDeltaZ) + 0.0001)


    local finalVelocity = Vector3.new(
        dirX * horizontalSpeed,
        verticalSpeed,
        dirZ * horizontalSpeed
    )


    rb:set_position(startPos)
    rb:set_velocity(finalVelocity)
    throwingGranade = true


    targetGranadePosition = nil
end



function explodeGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        local explosionPos = rb:get_position()

        local entities = current_scene:get_all_entities()

        for _, entity in ipairs(entities) do 
            if entity ~= granadeEntity and entity ~= current_scene:get_entity_by_name("Player") and entity:has_component("RigidbodyComponent") then 
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
        --escopetaAudioManagerScript:playExplodeGranade()
        --granadeParticlesExplosion:emit(10)
        throwingGranade = false
    end
end

