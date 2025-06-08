using = false
-- Time
local current_time = 0  
shotgun_fire_rate = 0.5
next_fire_time = 0 

-- ammo
maxAmmo = 12 -- maxammo
ammo = maxAmmo  -- curreamoo
reload_time = 2.8  -- reloadtime
is_reloading = false  -- inReloading?
local reload_end_time = 0  -- record_reload_time

--PlayerTransform
local playerTransf = nil
local playerScript = nil

-- Multipliers
local attackSpeedMultiplier = 1.0
local reloadSpeedMultiplier = 1.0

-- Define the bullet speed
local sphereSpeed = 50
-- BulletList
local bullets = {}
local bulletCount = 6  -- Bullet Num
local spreadAngle = 7.5  -- Bullet angle

damage = 10
local knockbackForce = 3000  -- force
local yPositionBullet = 1.5


--granadas
local granadeDamage = 100
granadeCooldown= 6
timerGranade = granadeCooldown
local granadeEntity = nil

local explosionRadius = 6.0

local lbapretado = false
dropGranade = false
granadasSpeed = false
local granadeNewPos = nil
local granadeMaxDistance = 9.0
granadeImpulse = false

-- Animation states
shootAnimation = false
granadeAnimation = false
local granadeAnimationTimer = 0
local granadeAnimationDuration = 0.4

--Workbench
local upgradeManager = nil
local workbenchUIManager = nil

     
local targetGranadePosition = nil    
local granadeMoveSpeed = 0.2   
--local GRENADE_GRAVITY = 25.0  
--local GRENADE_LAUNCH_ANGLE = math.rad(30)  
--local GRENADE_SPEED_MULTIPLIER = 50    
--local ISOMETRIC_CORRECTION_FACTOR = 0.707  
--local DISTANCE_CALIBRATION = 1.22   

local launched = false

local granadeOrigin = nil
local granadeDirection = nil
local granadeSpeed = 0.4
local granadeDistance = 0 
local initialize = true
local rb = nil
local throwing = false
local finalTargetPos = nil

-- Audio
local shotgunBulletImpactsSFX = nil
local shotgunGrenadeShotSFX = nil
local shotgunGrenadeSmokeSFX = nil
local shotgunReloadSFX = nil
local shotgunShotSFX = nil
local playerNoAmmoSFX = nil

local firstTimeAudio = false


local pauseMenu = nil

local hudManager = nil

local vibrationNormalSettings = Vector3.new(1, 1, 140)
local vibrationGranadeExplosionSettings = Vector3.new(1, 1, 500)

local manualReload = false

local astartesFervorManager = nil

local bolterScript = nil

local granadePreview = nil

local granadePreviewTransf = nil

local bulletTimers = nil

local swordScript = nil

local playerCDSFX = nil

local explosionVFX = nil
local explosionVFXTimer = 0

local playVFXAnimCounter = 0
local playVFXAnimCounterTime = 0.233

function on_ready()
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    cameraScript = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent")
    granadePreview = current_scene:get_entity_by_name("GranadePreview")
    granadePreviewTransf = granadePreview:get_component("TransformComponent")
    if current_scene:get_entity_by_name("BolterManager"):has_component("ScriptComponent") then

        bolterScript = current_scene:get_entity_by_name("BolterManager"):get_component("ScriptComponent")
    end
    -- Audio
    shotgunBulletImpactsSFX = current_scene:get_entity_by_name("ShotgunBulletImpactsSFX"):get_component("AudioSourceComponent")
    shotgunGrenadeShotSFX = current_scene:get_entity_by_name("ShotgunGrenadeShotSFX"):get_component("AudioSourceComponent")
    shotgunGrenadeSmokeSFX = current_scene:get_entity_by_name("ShotgunGrenadeSmokeSFX"):get_component("AudioSourceComponent")
    shotgunReloadSFX = current_scene:get_entity_by_name("ShotgunReloadSFX"):get_component("AudioSourceComponent")
    shotgunShotSFX = current_scene:get_entity_by_name("ShotgunShotSFX"):get_component("AudioSourceComponent")
    playerNoAmmoSFX = current_scene:get_entity_by_name("PlayerNoAmmoSFX"):get_component("AudioSourceComponent")
    
    playerCDSFX = current_scene:get_entity_by_name("PlayerCDSFX"):get_component("AudioSourceComponent")

    astartesFervorManager = current_scene:get_entity_by_name("ArmorUpgradeSystem"):get_component("ScriptComponent")
    bulletTimers = {}
    for i = 1, bulletCount do
        local bulletName = "Sphere" .. i  
        local bullet = {}
        
        bullet.entity = current_scene:get_entity_by_name(bulletName)
        bullet.transform = bullet.entity:get_component("TransformComponent")
        bullet.rigidBodyComponent = bullet.entity:get_component("RigidbodyComponent")
        bullet.rigidBody = bullet.rigidBodyComponent.rb
        bullet.rigidBody:set_trigger(true)
        
        table.insert(bullets, bullet)  -- save to table
        bulletTimers[i] = 0
        bullet.rigidBodyComponent:on_collision_enter(function(entityA, entityB)
            handle_bullet_collision(entityA, entityB)
        end)
    end

    --Granada
   
    granadeEntity = current_scene:get_entity_by_name("Granade")
    transformGranade = granadeEntity:get_component("TransformComponent")

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

    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    local workbenchUIManagerEntity = current_scene:get_entity_by_name("WorkBenchUIManager")
    if workbenchUIManagerEntity:is_valid() then
        workbenchUIManager = workbenchUIManagerEntity:get_component("ScriptComponent")
    end

    pauseMenu = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")    
    hudManager = current_scene:get_entity_by_name("HUD"):get_component("ScriptComponent")

    if current_scene:get_entity_by_name("SawSwordManager"):has_component("ScriptComponent") then

        swordScript = current_scene:get_entity_by_name("SawSwordManager"):get_component("ScriptComponent")
    end

    explosionVFX = current_scene:get_entity_by_name("GranadeExplosion")
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

    if timerGranade < granadeCooldown then
            timerGranade = timerGranade + dt
        end

    for i = 1, bulletCount do
        if bulletTimers[i] ~= 0 then
            bulletTimers[i] = bulletTimers[i] + dt

            if bulletTimers[i] > 0.4 then
                bullets[i].rigidBody:set_position(Vector3.new(0,-150,0))
                bulletTimers[i] = 0
            end
        end
    end

    if astartesFervorManager.isPlayerInRadius then
        set_attack_speed_multiplier(2.0)
        set_reload_speed_multiplier(1.5)
    else
        set_attack_speed_multiplier(1.0)
        set_reload_speed_multiplier(1.0)
    end

    if playerScript.health <= 0 or (workbenchUIManager and workbenchUIManager.isWorkBenchOpen) then
        return
    end

    if not pauseMenu.isPaused then
        
        resetGranadeAnimation(dt)

        if initialize then
            granadeOrigin = playerScript.playerTransf.position
            initialize = false
        end

        -- Applying multipliers
        local currentShootCoolDownRifle = shotgun_fire_rate * (1 * 1.5 / (attackSpeedMultiplier ))
        local currentMaxReloadTime = reload_time * (1 / reloadSpeedMultiplier)
        if using == true then
            -- updateTime
            current_time = current_time + dt  

            local rightTrigger = Input.get_button(Input.action.Shoot)
            if ammo <= 0 and rightTrigger == Input.state.Down then
                playerNoAmmoSFX:play()
                hudManager.arma2Texture:set_color(Vector4.new(1, 0, 0, 1))
                hudManager.ammoTextComponent:set_color(Vector4.new(1, 0, 0, 1))            
            else
                hudManager.arma2Texture:set_color(Vector4.new(1, 1, 1, 1))
                hudManager.ammoTextComponent:set_color(Vector4.new(1, 1, 1, 1))    
            end

            -- if in reload, check is fishing 
            if is_reloading or manualReload then
                if current_time >= reload_end_time then
                    ammo = maxAmmo  -- reload bullet
                    is_reloading = false
                    manualReload = false
                    playerScript.currentAnim = -1
                    firstTimeAudio = false
                else
                    if playerScript.currentUpAnim ~= playerScript.reload_Shotgun then
                        if firstTimeAudio == false then
                            shotgunReloadSFX:play()
                            firstTimeAudio = true
                        end
                        playerScript.currentUpAnim = playerScript.reload_Shotgun
                        playerScript.animator:set_upper_animation(playerScript.currentUpAnim)
                    end
                    
                end
            end
            local rightTrigger = Input.get_button(Input.action.Shoot)

            -- shoot
            if rightTrigger == Input.state.Repeat and is_reloading == false and swordScript.slasheeed == false then
                if playerScript.currentUpAnim ~= playerScript.shotgun_Pump and shootAnimation == false  then
                    playerScript.currentUpAnim = playerScript.shotgun_Pump
                    playerScript.animator:set_upper_animation(playerScript.currentUpAnim)
                    shootAnimation = true
                end
                

                if ammo > 0 and current_time >= next_fire_time then
                    ammo = ammo - 1  -- use bullet 
                    --bolterScript.vfxShootTransf.position.y = vfxShootPosY
                    shoot(dt)
                    next_fire_time = current_time + currentShootCoolDownRifle  -- next shoot time
                    if bolterScript.currentVFXAnim ~= 1 then
                        bolterScript.animatorVFXShoot:set_current_animation(1)
                        bolterScript.currentVFXAnim = 1
                        playVFXAnimCounter = 0
                    end
                else
                    playVFXAnimCounter = playVFXAnimCounter + dt

                    if playVFXAnimCounter >= playVFXAnimCounterTime then
                        if bolterScript.currentVFXAnim ~= 0 then
                            bolterScript.animatorVFXShoot:set_current_animation(0)
                            bolterScript.currentVFXAnim = 0
                        end
                    end
                    
                end
                playerScript.shootingIndicator = true

            else
                if playerScript.currentAnim ~= -1 and shootAnimation == true then
                    playerScript.currentAnim = -1
                end
                --bolterScript.vfxShootTransf.position.y = 830
                
                shootAnimation = false
                
                playerScript.shootingIndicator = false
                if bolterScript.currentVFXAnim ~= 0 then
                    bolterScript.animatorVFXShoot:set_current_animation(0)
                    bolterScript.currentVFXAnim = 0
                end
            end

           

            -- reload
            if (ammo == 0 or (Input.is_button_pressed(Input.controllercode.West) and ammo < maxAmmo)) and not is_reloading then
                
                is_reloading = true
                reload_end_time = current_time + currentMaxReloadTime  -- setting reload time
                
            end

            local leftShoulder = Input.get_button(Input.action.Skill2)

            if leftShoulder == Input.state.Up and launched then
                --mover la particula a la posicion final de la granada

                granadePreviewTransf.position = Vector3.new(0, -230, 0)
                granadeDistance = 0
                launched = false
                rb:set_use_gravity(true)
                throwing = true
                throwGranade(finalTargetPos)
                timerGranade = 0
            end

            if leftShoulder == Input.state.Down and upgradeManager.has_weapon_special() and timerGranade < granadeCooldown then
                playerCDSFX:play()
            end
            --granade 
            if ((leftShoulder == Input.state.Repeat or Input.is_key_pressed(Input.keycode.L))) and upgradeManager.has_weapon_special() and timerGranade >= granadeCooldown then
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

            
            
        end

        
    end
    if explosionVFX:is_active() then
        explosionVFXTimer = explosionVFXTimer + dt

        if explosionVFXTimer >= 0.5 then
            local explosionTransf = explosionVFX:get_component("TransformComponent")
            explosionTransf.position = Vector3.new(-1200, 700, 800)
            explosionVFX:set_active(false)
            explosionVFXTimer = 0
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
            yPositionBullet,
            playerPosition.z + forwardVector.z
        )
        
        bullet.rigidBody:set_position(newPosition)
        bullet.rigidBody:set_rotation(Vector3.new(0, math.deg(shootAngle), 0))
        
        local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
        bullet.rigidBody:set_velocity(velocity)
        bulletTimers[i] = 0.1
    end
    shotgunShotSFX:play()
    Input.send_rumble(vibrationNormalSettings.x, vibrationNormalSettings.y, vibrationNormalSettings.z)
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
                    if enemyTag == "EnemyRange" or enemyTag == "EnemyTutorial" then
                        enemyInstance = enemyScript.range
                    elseif enemyTag == "EnemySupport" then
                        enemyInstance = enemyScript.support
                    elseif enemyTag == "EnemyTank" or enemyTag == "EnemyTank1" then
                        enemyInstance = enemyScript.tank
                    elseif enemyTag == "EnemyKamikaze" then
                        enemyInstance = enemyScript.kamikaze
                    elseif enemyTag == "EnemyBoss" then
                        enemyInstance = enemyScript.main_boss
                    end
        
                    enemyInstance:take_damage(damage)
                    playerScript.makeDamage = true

                    shotgunBulletImpactsSFX:pause()
                    shotgunBulletImpactsSFX:play()
                end
            end

            --  knockback -> not working well :(

            local enemyPosition = enemyEntity:get_component("TransformComponent").position
            local bulletPosition = bulletTransform.position
            
            local knockbackDirection = Vector3.new(
                enemyPosition.x - bulletPosition.x,
                0,
                enemyPosition.z - bulletPosition.z
            )
            
            local magnitude = math.sqrt(knockbackDirection.x^2 + knockbackDirection.z^2)
            if magnitude > 0 then
                knockbackDirection.x = knockbackDirection.x / magnitude
                knockbackDirection.z = knockbackDirection.z / magnitude
            end
            
            local knockbackVelocity = Vector3.new(
                knockbackDirection.x * knockbackForce,
                0,
                knockbackDirection.z * knockbackForce
            )
            

        end
    end
    
    if nameA:match("^Enemy") then 
        damage_enemy(entityA, entityB)
    elseif  nameB:match("^Enemy") then
        damage_enemy(entityB, entityA)
    end
    
    local bulletEntityA = nil
    local bulletEntityB = nil
    
    for _, bullet in ipairs(bullets) do
        if bullet.entity == entityA then
            bulletEntityA = bullet
            break
        end

        if bullet.entity == entityB then
            bulletEntityB = bullet
            break
        end
    end

    if bulletEntityA and (nameB ~= "Player" and nameB ~= "FloorCollider" and not nameB:match("^Sphere") ) then
        bulletEntityA.rigidBody:set_position(Vector3.new(0, -250, 0))
        bulletEntityA.rigidBody:set_velocity(Vector3.new(0, 0, 0))
    end

    if bulletEntityB and (nameA ~= "Player" and nameA ~= "FloorCollider" and not nameA:match("^Sphere") ) then
        bulletEntityB.rigidBody:set_position(Vector3.new(0, -250, 0))
        bulletEntityB.rigidBody:set_velocity(Vector3.new(0, 0, 0))
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
        granadeDirection = normalizeVector(Vector3.new(math.sin(playerScript.angleRotation), 0.02, math.cos(playerScript.angleRotation)))
    if granadeDistance < granadeMaxDistance then
        granadeDistance = granadeDistance + granadeSpeed
    end

    granadeNewPos = Vector3.new(granadeOrigin.x + granadeDirection.x * granadeDistance, 0.02, granadeOrigin.z + granadeDirection.z * granadeDistance)
    finalTargetPos = granadeNewPos
    --rb:set_position(granadeNewPos)
    granadePreviewTransf.position = Vector3.new(granadeNewPos.x, granadeNewPos.y, granadeNewPos.z)

    launched = true
end

function throwGranade(targetPosition)
    if not granadeEntity or not targetPosition then return end

    if not granadeAnimation then
        playerScript.currentUpAnim = playerScript.h1_Shotgun_Throw
        playerScript.animator:set_upper_animation(playerScript.currentUpAnim)
        granadeAnimation = true
        granadeAnimationTimer = 0

    end

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
    local GRAVITY = 4              -- Gravedad
    local SPEED_BOOST = 3          -- Aceleración horizontal adicional

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
    rb:set_angular_velocity(Vector3.new(5,0,5))
end



function explodeGranade()
    if granadeEntity ~= nil then
        
        if playerScript.currentAnim ~= -1 then
            playerScript.currentAnim = -1
        end

        shotgunGrenadeSmokeSFX:play()
        
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        local explosionPos = rb:get_position()

        

        for _, entity in ipairs(cameraScript.enemies) do 
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
                    local enemyTag = nil
                    local enemyScript = nil
                    local enemyInstance = nil

                    if entity ~= nil then    
                        enemyTag = entity:get_component("TagComponent").tag           
                        enemyScript = entity:get_component("ScriptComponent")
                    end

                    if entity ~= nil then
                        if enemyScript ~= nil then
                            if enemyTag == "BarrilDestruible" or enemyTag == "CajaDestruible" or enemyTag == "CajaDestruibleV2" or enemyTag == "ScrapPile" then 
                                local script = entity:get_component("ScriptComponent")
                                script:give_phisycs()
                                script.hasDestroyed = true

                            else
                                local isPushed = false
                                
                                if enemyTag == "EnemyRange" or enemyTag == "EnemyTutorial" then
                                    enemyInstance = enemyScript.range
                                    isPushed = true
                                elseif enemyTag == "EnemySupport" then
                                    isPushed = true
                                    enemyInstance = enemyScript.support
                                elseif enemyTag == "EnemyTank" or enemyTag == "EnemyTank1" then
                                    enemyInstance = enemyScript.tank
                                elseif enemyTag == "EnemyKamikaze" then
                                    isPushed = true    
                                    enemyInstance = enemyScript.kamikaze
                                elseif enemyTag == "EnemyBoss" then
                                    enemyInstance = enemyScript.main_boss
                                end
                                
                                enemyInstance.isNeuralInhibitioning = true
                                
                                playerScript.makeDamage = true
                                enemyInstance:take_damage(granadeDamage)

                                if isPushed then
                                    enemyInstance.isGranadePushed = true
                                    local impulseForce = 7
                                    local impulseDirection = Vector3.new(
                                    entityPos.x - explosionPos.x,
                                    entityPos.y - explosionPos.y,
                                    entityPos.z - explosionPos.z)
                                    entityRb:apply_impulse(Vector3.new(impulseDirection.x * impulseForce, impulseDirection.y * impulseForce, impulseDirection.z * impulseForce))
                                end
                                
                            end
                        end


                    
                    end
                    
                end
            end
        end
        
        explosionVFX:set_active(true)
        local explosionTransf = explosionVFX:get_component("TransformComponent")
        explosionTransf.position = Vector3.new(explosionPos.x, explosionPos.y, explosionPos.z)

    
        
        rb:set_position(Vector3.new(0, -1000, 0))
        rb:set_velocity(Vector3.new(0, 0, 0))
        rb:set_angular_velocity(Vector3.new(0, 0, 0))
        rb:set_use_gravity(false)
        throwingGranade = false
        cameraScript.startShake(0.2,5)
        Input.send_rumble(vibrationGranadeExplosionSettings.x, vibrationGranadeExplosionSettings.y, vibrationGranadeExplosionSettings.z)
        
    end
end

function resetGranadeAnimation(dt)
    if granadeAnimation then
        granadeAnimationTimer = granadeAnimationTimer + dt
        if granadeAnimationTimer >= granadeAnimationDuration then
            granadeAnimation = false
            granadeAnimationTimer = 0
        end
    end
end

