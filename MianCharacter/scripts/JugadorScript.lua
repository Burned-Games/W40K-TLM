-- Player
playerHealth = 100
local playerTransf
local playerRb = nil
local moveSpeed = 6
local lastValidRotation = 0
local currentSpeed = 0         
local acceleration = 10      
local deceleration = 8
local forwardVector
moveDirection = nil
local rotationDirection = nil
angleRotation = 0
local godMode = false
isMoving = false
local dashSpeed = 15
local impulseApplied = false
local dashTimeCounter = 0
local dashTime = 0.3
local dashColdownCounter = 0
local dashColdown = 3.5
local dashAvailable = true
intangibleDash = false
local intangibleDashTimeCounter = 0
local intangibleDashTime = 0.15
local deathAnimationTime = 3
local deathTimeCounter = 0

local animacionEntradaRealizada = false
local timerAnimacionEntrada = 0

-- Disparo

shotgunammo = 0
local actualweapon = 0 -- 0 = rifle 1 = escopeta
local currentAnim = -1
local animator

local bolter = nil
local bolterScript = nil
--ShotGun
local shotGunScript = nil

--granadas

local granadeCooldown= 12
local timerGranade = 0
local granadeEntity = nil
local granadeInitialSpeed = 12

local explosionRadius = 7.0
local explosionForce = 13.0
local explosionUpward = 2.0
local granadeParticlesExplosion = nil

-- Audio
local explorationMusic = nil
local combatMusic = nil

local combatMusicVolume = 0
local explorationMusicVolume = 0.05

local prevBackgroundMusicToPlay = -1
backgroundMusicToPlay = 0 -- 0 exploration 1 combat

local rifleAudioManagerScript 
local escopetaAudioManagerScript 

-- Extras
local pressedButton = false
local pressedButtonChangeWeapon = false
local sceneChanged = false

--UpgradeManager
local UpgradeManager = nil

-- Rifle & Shotgun Variables (Needs to be centralized & organized :v)


local reloadTimeShotgun = 0
local shootCoolDownShotgun = 1.3
local damageShotgun = 120


function on_ready()
    -- Add initialization code here

    explorationMusic = current_scene:get_entity_by_name("MusicExploration"):get_component("AudioSourceComponent")
    combatMusic = current_scene:get_entity_by_name("MusicCombat"):get_component("AudioSourceComponent")
    


    --UpgradeManager START
    UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    if UpgradeManager ~= nil then
        UpgradeManager:apply_to_player(self)
    end
    --UpgradeManager END


    playerTransf = self:get_component("TransformComponent")
    
    playerWorldTransf = playerTransf:get_world_transform()
    
    playerRb = self:get_component("RigidbodyComponent").rb

    forwardVector = Vector3.new(1,0,0)
    disparado = false

    bolter = current_scene:get_entity_by_name("Bolter")
    bolterScript = bolter:get_component("ScriptComponent")

    shotGunScript = current_scene:get_entity_by_name("Shotgun_low"):get_component("ScriptComponent")





    animator = self:get_component("AnimatorComponent")


    granadeEntity = current_scene:get_entity_by_name("Granade")
    transformGranade = granadeEntity:get_component("TransformComponent")
    granadeParticlesExplosion = granadeEntity:get_component("ParticlesSystemComponent")
    floorEntity = current_scene:get_entity_by_name("FloorCollider")

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

    combatMusic:play()
    explorationMusic:play()


end

function on_update(dt)

    updateMusic(dt)
    updateDash(dt)
    updateGodMode()
    updateEntranceAnimation(dt)
    handleWeaponSwitch()

    if not animacionEntradaRealizada then
        return
    end


    playerMovement(dt)
    handleGranade(dt)
    checkPlayerDeath(dt)

    backgroundMusicToPlay = 0
end

function on_exit()
    -- Add cleanup code here
end



function updateMusic(dt)
    if backgroundMusicToPlay == 0 and prevBackgroundMusicToPlay ~= backgroundMusicToPlay then
        if explorationMusicVolume >= 0.05 then
            explorationMusicVolume = 0.05
            combatMusicVolume = 0
            explorationMusic:set_volume(explorationMusicVolume)
            combatMusic:set_volume(combatMusicVolume)
            prevBackgroundMusicToPlay = 0
        else 
            explorationMusicVolume = explorationMusicVolume + dt * 0.05
            combatMusicVolume = combatMusicVolume - dt  * 0.05
            explorationMusic:set_volume(explorationMusicVolume)
            combatMusic:set_volume(combatMusicVolume)
        end
    elseif backgroundMusicToPlay == 1 and prevBackgroundMusicToPlay ~= backgroundMusicToPlay then
        if combatMusicVolume >= 0.05 then
            combatMusicVolume = 0.05
            explorationMusicVolume = 0
            combatMusic:set_volume(combatMusicVolume)
            explorationMusic:set_volume(explorationMusicVolume)
            prevBackgroundMusicToPlay = 1
        else 
            explorationMusicVolume = explorationMusicVolume - dt * 0.05
            combatMusicVolume = combatMusicVolume + dt * 0.05
            explorationMusic:set_volume(explorationMusicVolume)
            combatMusic:set_volume(combatMusicVolume)
        end
    end
end

function updateDash(dt)
    -- Check for dash activation
    if (Input.is_button_pressed(Input.controllercode.East) or Input.is_key_pressed(Input.keycode.M)) and dashAvailable == true then
        if moveDirection ~= nil then
            local impulse = Vector3.new(moveDirection.x * dashSpeed, moveDirection.y * dashSpeed, moveDirection.z * dashSpeed)
            playerRb:set_trigger(true)
            playerRb:apply_impulse(Vector3.new(moveDirection.x * dashSpeed, moveDirection.y * dashSpeed, moveDirection.z * dashSpeed))
            impulseApplied = true
            dashAvailable = false
            intangibleDash = true
        end       
    end
    
    -- Update dash cooldown
    if dashAvailable == false then
        dashColdownCounter = dashColdownCounter + dt
        if dashColdownCounter >= dashColdown then
            dashAvailable = true
            dashColdownCounter = 0
        end
    end

    -- Update dash duration
    if impulseApplied == true then
        dashTimeCounter = dashTimeCounter + dt
        if dashTimeCounter >= dashTime then
            impulseApplied = false
            dashTimeCounter = 0
            playerRb:set_trigger(false)
        end
    end

    -- Update intangibility during dash
    if intangibleDash then
        intangibleDashTimeCounter = intangibleDashTimeCounter + dt
        if intangibleDashTimeCounter >= intangibleDashTime then
            intangibleDash = false
            intangibleDashTimeCounter = 0
        end
    end
end

function updateGodMode()
    if Input.is_key_pressed(Input.keycode.F1) then
        if pressedButton == false then
            godMode = not godMode
        end
        pressedButton = true
    else
        pressedButton = false
    end

    if godMode then
        playerHealth = 100
        bolterScript.ammo = 0
        shotgunammo = 0
        moveSpeed = 12
        playerRb:set_trigger(true)
    else
        moveSpeed = 6
        playerRb:set_trigger(false)
    end
end

function updateEntranceAnimation(dt)
    if animacionEntradaRealizada == false then
        if(currentAnim ~= 3) then
            currentAnim = 3
            animator:set_current_animation(currentAnim)
        end
        timerAnimacionEntrada = timerAnimacionEntrada + dt

        if(timerAnimacionEntrada > 6.2 )then
            playerTransf.rotation.y = 0
            animacionEntradaRealizada = true
            currentAnim = 4
            animator:set_current_animation(currentAnim)
        end
        return
    end
end

function handleWeaponSwitch()
    if Input.is_button_pressed(Input.controllercode.North) == true then
        if pressedButtonChangeWeapon == false then
            if actualweapon == 0 then
                actualweapon = 1
            else
                actualweapon = 0
            end
            pressedButtonChangeWeapon = true
        end
    else
        pressedButtonChangeWeapon = false
    end

    if actualweapon == 0 then
        bolterScript.using = true
        shotGunScript.using = false
    else
        bolterScript.using = false
        shotGunScript.using = true
    end
end

function playerMovement(dt)

    local axisX_l = Input.get_axis_position(Input.axiscode.LeftX)
    local axisY_l = Input.get_axis_position(Input.axiscode.LeftY)

    local axisX_r = Input.get_axis_position(Input.axiscode.RightX)
    local axisY_r = Input.get_axis_position(Input.axiscode.RightY)

    local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)


    -- Camera angle in radians (45 degrees)
    local cameraAngle = math.rad(45)

    -- Rotate the entry axes to align the with the camera
    local moveDirectionX = axisX_l * math.cos(cameraAngle) - axisY_l * math.sin(cameraAngle)
    local moveDirectionY = axisX_l * math.sin(cameraAngle) + axisY_l * math.cos(cameraAngle)

    local rotationDirectionX = axisX_r * math.cos(cameraAngle) - axisY_r * math.sin(cameraAngle)
    local rotationDirectionY = axisX_r * math.sin(cameraAngle) + axisY_r * math.cos(cameraAngle)

    moveDirection = Vector3.new(moveDirectionX, 0, moveDirectionY)

    rotationDirection = Vector3.new(moveDirectionX, 0, moveDirectionY)

    if impulseApplied == false then
    if moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        isMoving = true
        -- Animacian walk

        if actualweapon == 0 then
            if currentAnim ~= 7 then
                currentAnim = 7
                animator:set_current_animation(currentAnim)
            end
        else
            if currentAnim ~= 8 then
                currentAnim = 8
                animator:set_current_animation(currentAnim)
            end
        end
        
    
        -- Progressive acceleration until reaching moveSpeed
        currentSpeed = math.min(currentSpeed + acceleration * dt, moveSpeed)
    
        local velocity = Vector3.new(moveDirection.x * currentSpeed, 0, moveDirection.z * currentSpeed)
    
        playerRb:set_velocity(velocity)
    
        -- Rotate the player with the movement if not aiming
        if axisX_r == 0 and axisY_r == 0 then
            angleRotation = math.atan(moveDirection.x, moveDirection.z)
            playerTransf.rotation.y = math.deg(angleRotation) 
        end
    
    else
        isMoving = false
        -- deaccelerate
        if currentSpeed > 0 then
            currentSpeed = math.max(currentSpeed - deceleration * dt, 0) -- Reducir velocidad gradualmente
            local velocity = Vector3.new(moveDirection.x * currentSpeed, 0, moveDirection.z * currentSpeed)
            playerRb:set_velocity(velocity)
        else
            -- Stop the player
            playerRb:set_velocity(Vector3.new(0, 0, 0))
        end
    
        if rightTrigger == 0 then
            -- Animation idle
            if actualweapon == 0 then
                if currentAnim ~= 4 then
                    currentAnim = 4
                    animator:set_current_animation(currentAnim)
                end
            else
                if currentAnim ~= 5 then
                    currentAnim = 5
                    animator:set_current_animation(currentAnim)
                end
            end

            
        end
    end
    end

    --Aiming Rotation
    if (rotationDirectionX ~= 0 or rotationDirectionY ~= 0) then
        local lookLength = rotationDirectionX*rotationDirectionX + rotationDirectionY*rotationDirectionY
        if(lookLength > 0) then
            angleRotation = math.atan(rotationDirectionX, rotationDirectionY)
            playerTransf.rotation.y = angleRotation * 57.2958
        end
    end


    if rotationDirectionX ~= 0 or rotationDirectionY ~= 0 then
        lastValidRotation = math.atan(rotationDirectionX, rotationDirectionY)
        playerTransf.rotation.y = math.deg(lastValidRotation)  
        isAiming = true
    elseif moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        lastValidRotation = math.atan(moveDirection.x, moveDirection.z)
        playerTransf.rotation.y = math.deg(lastValidRotation)
    else
        playerTransf.rotation.y = math.deg(lastValidRotation)
        isAiming = false
    end
end


function checkPlayerDeath(dt)
    if playerHealth <= 0 then
        playerHealth = 0
        deathTimeCounter = deathTimeCounter + dt
        if deathTimeCounter >= deathAnimationTime and sceneChanged == false then
            sceneChanged = true
            SceneManager.change_scene("levelLose.TeaScene")
        end
    end
end

function handleGranade(dt)
    if timerGranade > 0 then
        timerGranade = timerGranade - dt
    end

    if Input.is_button_pressed(Input.controllercode.LeftShoulder) and timerGranade <= 0 then
        throwGranade()
        escopetaAudioManagerScript:playLaunchGranade()
        timerGranade = granadeCooldown
    end
end

function throwGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        
        local direction = Vector3.new(math.sin(math.rad(playerTransf.rotation.y)), 0.5, math.cos(math.rad(playerTransf.rotation.y)))
        
        local vectorPosition = Vector3.new(playerTransf.position.x + math.sin(math.rad(playerTransf.rotation.y)), playerTransf.position.y+2, playerTransf.position.z + math.cos(math.rad(playerTransf.rotation.y)))
        rb:set_position(vectorPosition)

       
        
        
        local velocity = Vector3.new(direction.x * granadeInitialSpeed, direction.y * granadeInitialSpeed, direction.z * granadeInitialSpeed)
        rb:set_velocity(velocity)
        throwingGranade = true
    end
end

function explodeGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        local explosionPos = rb:get_position()

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
        escopetaAudioManagerScript:playExplodeGranade()
        granadeParticlesExplosion:emit(10)
        throwingGranade = false
    end
end

