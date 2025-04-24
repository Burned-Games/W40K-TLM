using = false
-- Time
local current_time = 0  
shotgun_fire_rate = 1.3 
next_fire_time = 0 

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

granadeCooldown= 12
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
local granadeNewPos = nil
local granadeMaxDistance = 9.0

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

local launched = false

local granadeOrigin = nil
local granadeDirection = nil
local granadeSpeed = 0.1  
local granadeDistance = 0 
local initialize = true
local rb = nil
local throwing = false
local finalTargetPos = nil
shootAnimation = false

-- Audio
local shotgunBulletImpactsSFX
local shotgunGrenadeShotSFX
local shotgunGrenadeSmokeSFX
local shotgunReloadSFX
local shotgunShotSFX

--Particles
local particle_previewG_interior = nil
local particle_previewG_exterior = nil
local particle_previewG_interior_transform = nil
local particle_previewG_exterior_transform = nil

function on_ready()
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    cameraScript = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent")
    
    -- Audio
    shotgunBulletImpactsSFX = current_scene:get_entity_by_name("ShotgunBulletImpactsSFX"):get_component("AudioSourceComponent")
    shotgunGrenadeShotSFX = current_scene:get_entity_by_name("ShotgunGrenadeShotSFX"):get_component("AudioSourceComponent")
    shotgunGrenadeSmokeSFX = current_scene:get_entity_by_name("ShotgunGrenadeSmokeSFX"):get_component("AudioSourceComponent")
    shotgunReloadSFX = current_scene:get_entity_by_name("ShotgunReloadSFX"):get_component("AudioSourceComponent")
    shotgunShotSFX = current_scene:get_entity_by_name("ShotgunShotSFX"):get_component("AudioSourceComponent")
    
    --Particles
    particle_previewG_interior = current_scene:get_entity_by_name("particle_previewG_interior"):get_component("ParticlesSystemComponent")
    particle_previewG_exterior = current_scene:get_entity_by_name("particle_previewG_exterior"):get_component("ParticlesSystemComponent")
    particle_previewG_exterior_transform = current_scene:get_entity_by_name("particle_previewG_exterior"):get_component("TransformComponent")
    particle_previewG_interior_transform = current_scene:get_entity_by_name("particle_previewG_interior"):get_component("TransformComponent")
    
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

    rb = granadeEntity:get_component("RigidbodyComponent").rb
    rb:set_mass(1.0)
    rb:set_trigger(true)

    local rbComponent = granadeEntity:get_component("RigidbodyComponent")
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if (nameA == "FloorCollider" or nameB == "FloorCollider") and throwing then
            explodeGranade()
            throwing = false
        end
    end)

    --upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent") // A DESCOMENTAR

end

function normalizeVector(v)
    -- Calcular la magnitud del vector
    local magnitude = math.sqrt(v.x^2 + v.y^2 + v.z^2)

    -- Evitar la división por cero si la magnitud es 0
    if magnitude == 0 then
        return Vector3.new(0, 0, 0)  -- Retorna un vector nulo si el vector tiene magnitud 0
    end

    -- Dividir cada componente del vector por la magnitud para normalizar
    return Vector3.new(v.x / magnitude, v.y / magnitude, v.z / magnitude)
end

function on_update(dt)
    
    if playerScript.health <= 0 then
        return
    end
    if initialize then
        granadeOrigin = playerScript.playerTransf.position
        initialize = false
    end
    
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
                return  -- in reload cant shoot
            end
        end
        local rightTrigger = Input.get_button(Input.action.Shoot)

        -- shoot
        if rightTrigger == Input.state.Repeat then
            if playerScript.currentUpAnim ~= playerScript.attack and shootAnimation == false then
                playerScript.currentUpAnim = playerScript.attack
                playerScript.animator:set_upper_animation(playerScript.currentUpAnim)
                shootAnimation = true
            end
            if ammo > 0 and current_time >= next_fire_time then
                ammo = ammo - 1  -- use bullet 
                shoot(dt)
                next_fire_time = current_time + currentShootCoolDownRifle  -- next shoot time
                shootAnimation = false
            end

        else
            shootAnimation = false
        end

        -- reload
        if ammo == 0 and not is_reloading then
            is_reloading = true
            reload_end_time = current_time + currentMaxReloadTime  -- setting reload time
            shotgunReloadSFX:play()
        end

        local leftShoulder = Input.get_button(Input.action.Skill2)

        if leftShoulder == Input.state.Up and launched then
            --mover la particula a la posicion final de la granada

            --particle_previewG_exterior_transform.position = finalTargetPos --fix, posicion correcta --PETA 
            --particle_previewG_interior_transform.position = finalTargetPos --PETA 

            --particle_previewG_interior:emit(1) --PETA 
            --particle_previewG_exterior:emit(1) --PETA 

            granadeDistance = 0
            launched = false
            rb:set_use_gravity(true)
            throwing = true
            throwGranade(finalTargetPos)

        end

        --granade 
        if (leftShoulder == Input.state.Repeat or Input.is_key_pressed(Input.keycode.L)) and timerGranade <= 0 then
            lbapretado = true
            granadasSpeed = true
            throwing = false
            handleGranade(0)
            --update_joystick_position()
        else
            if lbapretado then
                shotgunGrenadeShotSFX:play()
                dropGranade = true
            end
            lbapretado = false
            granadasSpeed = false
        end

        

        if self--[[upgradeManager.has_weapon_special()]] then

            
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
    shotgunShotSFX:play()
end

function handle_bullet_collision(entityA, entityB)
   
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag
    
    local function damage_enemy(enemyEntity, bulletEntity)
        if enemyEntity then
            local enemyScript = enemyEntity:get_component("ScriptComponent")
            local enemyRigidBody = enemyEntity:get_component("RigidbodyComponent").rb
            local bulletTransform = bulletEntity:get_component("TransformComponent")
            local enemyTag = nil
            local enemyInstance = nil
            
            if enemyEntity ~= nil then    
                enemyTag = enemyEntity:get_component("TagComponent").tag           
            end

            if enemyEntity ~= nil then
                if enemyScript ~= nil then
                    if enemyTag == "EnemyRange" or enemyTag == "EnemyRange1" or enemyTag == "EnemyRange2" or enemyTag == "EnemyRange3" or enemyTag == "EnemyRange4" or enemyTag == "EnemyRange5" or enemyTag == "EnemyRange6" then
                        enemyInstance = enemyScript.range
                    elseif enemyTag == "EnemySupport" then
                        enemyInstance = enemyScript.support
                    elseif enemyTag == "EnemyTank" or enemyTag == "EnemyTank1" or enemyTag == "EnemyTank2" or enemyTag == "EnemyTank3" or enemyTag == "EnemyTank4" or enemyTag == "EnemyTank5" or enemyTag == "EnemyTank6" then
                        enemyInstance = enemyScript.tank
                    elseif enemyTag == "EnemyKamikaze" then
                        enemyInstance = enemyScript.kamikaze
                    end
        
                    enemyInstance:take_damage(damage)
                    playerScript.makeDamage = true
                       
                    if enemyTag == "MainBoss" then
                        enemyScript:take_damage(damage)
                        playerScript.makeDamage = true
                    end
                end
            end


            local enemyPosition = enemyEntity:get_component("TransformComponent").position
            local bulletPosition = bulletTransform.position
            local knockbackDirection = Vector3.normalize(Vector3.new(
                enemyPosition.x - bulletPosition.x,
                0,
                enemyPosition.z - bulletPosition.z
            ))
            
            
            local knockbackVelocity = Vector3.new(
                knockbackDirection.x * knockbackForce,
                0,
                knockbackDirection.z * knockbackForce
            )

            enemyRigidBody:apply_force(knockbackVelocity)
        end
    end
    
    if nameA == "EnemyRange" or nameA == "EnemyRange1" or nameA == "EnemyRange2" or nameA == "EnemyRange3"  or nameA == "EnemyRange4" or nameA == "EnemyRange5" or nameA == "EnemyRange6" or nameB == "EnemyRange" or nameB == "EnemyRange1" or nameB == "EnemyRange2" or nameB == "EnemyRange3"  or nameB == "EnemyRange4" or nameB == "EnemyRange5" or nameB == "EnemyRange6" then
        local enemy = ((nameA == "EnemyRange" or nameA == "EnemyRange1" or nameA == "EnemyRange2" or nameA == "EnemyRange3"  or nameA == "EnemyRange4" or nameA == "EnemyRange5" or nameA == "EnemyRange6") and entityA) or ((nameB == "EnemyRange" or nameB == "EnemyRange1" or nameB == "EnemyRange2" or nameB == "EnemyRange3"  or nameB == "EnemyRange4" or nameB == "EnemyRange5" or nameB == "EnemyRange6") and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end


    if nameA == "EnemySupport" or nameB == "EnemySupport" then
        local enemy = (nameA == "EnemySupport" and entityA) or (nameB == "EnemySupport" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end

    if nameA == "EnemyKamikaze" or nameB == "EnemyKamikaze" then
        local enemy = (nameA == "EnemyKamikaze" and entityA) or (nameB == "EnemyKamikaze" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end

    if nameA == "EnemyTank" or nameA== "EnemyTank1" or nameA == "EnemyTank2" or nameA == "EnemyTank3"  or nameA == "EnemyTank4" or nameA == "EnemyTank5" or nameA == "EnemyTank6" or nameA == "EnemyTank1" or nameA == "EnemyTank2" or nameA == "EnemyTank3"  or nameA == "EnemyTank4" or nameA == "EnemyTank5" or nameA == "EnemyTank6" or nameB == "EnemyTank" or nameB == "EnemyTank1" or nameB == "EnemyTank2" or nameB == "EnemyTank3"  or nameB == "EnemyTank4" or nameB == "EnemyTank5" or nameB == "EnemyTank6" or nameB == "EnemyTank1" or nameB == "EnemyTank2" or nameB == "EnemyTank3"  or nameB == "EnemyTank4" or nameB == "EnemyTank5" or nameB == "EnemyTank6" then
        local enemy = ((nameA == "EnemyTank" or nameA == "EnemyTank1" or nameA == "EnemyTank2" or nameA == "EnemyTank3"  or nameA == "EnemyTank4" or nameA == "EnemyTank5" or nameA == "EnemyTank6") and entityA) or ((nameB == "EnemyTank" or nameB == "EnemyTank1" or nameB == "EnemyTank2" or nameB == "EnemyTank3"  or nameB == "EnemyTank4" or nameB == "EnemyTank5" or nameB == "EnemyTank6") and entityB)
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

end

function handleGranade(dt)
    
    granadeDirection = normalizeVector(Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation)))
    if granadeDistance < granadeMaxDistance then
        granadeDistance = granadeDistance + granadeSpeed
    end

    granadeNewPos = Vector3.new(granadeOrigin.x + granadeDirection.x * granadeDistance, 0, granadeOrigin.z + granadeDirection.z * granadeDistance)
    finalTargetPos = granadeNewPos
    rb:set_position(granadeNewPos)
    launched = true
end

function throwGranade(targetPosition)
    if not granadeEntity or not targetPosition then return end

    local rb = granadeEntity:get_component("RigidbodyComponent").rb
    local playerPos = playerTransf.position
    local startPos = Vector3.new(
        playerPos.x, 
        playerPos.y + 1.5, 
        playerPos.z
    )

    local ISOMETRIC_CORRECTION = 0.7071  
    local DISTANCE_CALIBRATION = 1.22    

    local rawDeltaX = targetPosition.x - startPos.x
    local rawDeltaZ = targetPosition.z - startPos.z

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
    local GRAVITY = 10.0                -- Gravedad
    local SPEED_BOOST = 1.13            -- Aceleración horizontal adicional

    -- Aquí agregamos el factor para la velocidad de caída
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

                    local enemyTag = entity:get_component("TagComponent").tag

                    if enemyTag == "EnemyRange" or enemyTag == "EnemyRange1" or enemyTag == "EnemyRange2" or enemyTag == "EnemyRange3" or enemyTag == "EnemyRange4" or enemyTag == "EnemyRange5" or enemyTag == "EnemyRange6" or enemyTag == "EnemySupport" or enemyTag == "EnemyKamikaze" or enemyTag == "EnemyTank" or enemyTag == "EnemyTank1" or enemyTag == "EnemyTank2" or enemyTag == "EnemyTank3" or enemyTag == "EnemyTank4" or enemyTag == "EnemyTank5" or enemyTag == "EnemyTank6" or enemyTag == "MainBoss" then 
                        enemyOrkScript = entity:get_component("ScriptComponent")
                        if enemyOrkScript ~= nil then
                            enemyOrkScript.range.isNeuralInhibitioning = true
                            playerScript.makeDamage = true
                        end
                    else
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
        end
        
        rb:set_velocity(Vector3.new(0, 0, 0))
        rb:set_angular_velocity(Vector3.new(0, 0, 0))
        --escopetaAudioManagerScript:playExplodeGranade()
        --granadeParticlesExplosion:emit(10)
        throwingGranade = false
        cameraScript.startShake(0.2,5)
    end
end

