-- Player
playerHealth = 100
playerTransf = nil
local playerRb = nil
local moveSpeed = 6
local lastValidRotation = 0
local currentSpeed = 0
local acceleration = 10      
local deceleration = 8
moveDirection = nil
local rotationDirection = nil
angleRotation = 0
local godMode = false
isMoving = false
local dashSpeed = 15
local impulseApplied = false
local dashTimeCounter = 0
local dashTime = 0.3
dashColdownCounter = 0
dashColdown = 3.5
dashAvailable = true
intangibleDash = false
local intangibleDashTimeCounter = 0
local intangibleDashTime = 0.15
local deathAnimationTime = 3
local deathTimeCounter = 0
local deathAnimationSetted = false

local animacionEntradaRealizada = false
local timerAnimacionEntrada = 0

damageReduction = 1
tookDamage = false
makeDamage = false 

local StimsCounter = 0

enemys_targeting = 0

-- Disparo

shotgunammo = 0
actualweapon = 0 -- 0 = rifle 1 = escopeta
currentAnim = -1
currentUpAnim = -1
currentLowAnim = -1
animator = nil

local bolterUpper = nil
local bolterLower = nil
local bolterScript = nil
--ShotGun
local shotgunUpper = nil
local shotgunLower = nil
local shotGunScript = nil
--SawSword
swordUpper = nil
swordLower = nil
local swordScript = nil
local swordAnimationTime = 1
local swordAnimationTimeCounter = 0
-- Audio
local explorationMusic = nil
local combatMusic = nil

local combatMusicVolume = 0
local explorationMusicVolume = 0.05

local prevBackgroundMusicToPlay = -1
backgroundMusicToPlay = 0 -- 0 exploration 1 combat

-- sangrado
local isBleeding = false
local bleedTimer = 0
local bleedDuration = 5
local bleedDamage = 2
local timeSinceLastBleed = 0
local bleedInterval = 1

-- Extras
local pressedButton = false
local pressedButtonChangeWeapon = false
local sceneChanged = false

--UpgradeManager
local UpgradeManager = nil

--Barricade
local barricadeScript = nil
isCovering = false

--granadeSpeed
local granadeVelocity = 0.65
-- Rifle & Shotgun Variables (Needs to be centralized & organized :v)

scrapCounter = 0
local scrapObjects = {}
--local tuplaScrap = { {}, {} }
---local tuplaP1 = {}
--local tuplaP2 = {}
local distanceToPlayerToDestroy = 2, 2, 2
local attractionActive = false 
local attractionSpeed = 2
local amountOfScrap = 0
local scrapDestroyed = 0
local partOfList = 0

zonePlayer = 0
level = 1

enemyDirection = Vector3.new(0,0,0)

local checkpointsPosition = { Vector3.new(83, 0, 35), Vector3.new(192, 0, -52)}

--animation indexs
local idle = 4
attack = 0
local dash = 1
local die = 2
local drop = 3
local mainMenu = 5
local melee = 6
local run = 7
local runB = 8
local runL = 9
local runR = 10
local run_Shotgun = 11

function on_ready()
    -- Add initialization code here

    --explorationMusic = current_scene:get_entity_by_name("MusicExploration"):get_component("AudioSourceComponent")
    --combatMusic = current_scene:get_entity_by_name("MusicCombat"):get_component("AudioSourceComponent")
    


    --UpgradeManager START
    --UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    if UpgradeManager ~= nil then
        UpgradeManager:apply_to_player(self)
    end
    --UpgradeManager END

    playerTransf = self:get_component("TransformComponent")
    
    playerRb = self:get_component("RigidbodyComponent").rb

    bolterUpper = current_scene:get_entity_by_name("Bolter_upper")
    bolterLower = current_scene:get_entity_by_name("Bolter_Lower")

    shotgunUpper = current_scene:get_entity_by_name("Shotgun_upper")
    shotgunLower = current_scene:get_entity_by_name("Shotgun_lower")
    swordUpper = current_scene:get_entity_by_name("ChainSword_Upper")
    swordUpper:set_active(false)
    swordLower = current_scene:get_entity_by_name("ChainSword_Lower")

    if current_scene:get_entity_by_name("SawSwordManager"):has_component("ScriptComponent") then

        swordScript = current_scene:get_entity_by_name("SawSwordManager"):get_component("ScriptComponent")
    end

    if current_scene:get_entity_by_name("BolterManager"):has_component("ScriptComponent") then

        bolterScript = current_scene:get_entity_by_name("BolterManager"):get_component("ScriptComponent")
    end

    if current_scene:get_entity_by_name("ShotgunManager"):has_component("ScriptComponent") then

        shotGunScript = current_scene:get_entity_by_name("ShotgunManager"):get_component("ScriptComponent")
    end

    if current_scene:get_entity_by_name("Barricade"):has_component("ScriptComponent") then

        barricadeScript = current_scene:get_entity_by_name("Barricade"):get_component("ScriptComponent")
    end

    if self:has_component("AnimatorComponent") then

        animator = self:get_component("AnimatorComponent")
    end
    
  
    --combatMusic:play() // A DESCOMENTAR
    --explorationMusic:play() // A DESCOMENTAR

    
    self:get_component("RigidbodyComponent"):on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
        local newIndex = zonePlayer + 1

        if nameA == "Checkpoint" .. tostring(newIndex) or nameB == "Checkpoint" .. tostring(newIndex) then           
            save_progress("zonePlayer", newIndex)
            zonePlayer = newIndex
            save_progress("scrap", scrapCounter)
            save_progress("health", playerHealth)
        end
        if nameA == "Stims" .. tostring(newIndex) or nameB == "Stims" .. tostring(newIndex) then           
            StimsCounter = StimsCounter + 1
        end
    end)

    --[[level = load_progress("level", 1)

    if level == 1 then
        if current_scene:get_entity_by_name("Checkpoint1"):has_component("RigidbodyComponent") then
            current_scene:get_entity_by_name("Checkpoint1"):get_component("RigidbodyComponent").rb:set_trigger(true)
            current_scene:get_entity_by_name("Checkpoint2"):get_component("RigidbodyComponent").rb:set_trigger(true)
        end
    end

    zonePlayer = load_progress("zonePlayer", 0)
    if level == 1 and zonePlayer >= 1 then
        playerRb:set_position(checkpointsPosition[zonePlayer])
        animacionEntradaRealizada = true

        scrapCounter = load_progress("scrap", 0)

        local newHealth = load_progress("health", 100)
        if newHealth > 80 then
            playerHealth = newHealth
        else
            playerHealth = 80
        end
    end

    if level > 1 then
        scrapCounter = load_progress("scrap", 0)
    end]] --// A DESCOMENTAR


end

function on_update(dt)

    if Input.is_key_pressed(Input.keycode.P) and attractionActive == false then
        attractionActive = not attractionActive 
        find_scrap()

    end

    if attractionActive == true then 
        attract_scrap(dt)
    
    end

    if enemys_targeting == 0 then
        
        attractionActive = not attractionActive 
        find_scrap()
    end


    if Input.is_key_pressed(Input.keycode.L)  then
        
        print("", enemys_targeting)

    end

    checkPlayerDeath(dt)
    handleWeaponSwitch(dt)
    --updateEntranceAnimation(dt)
    if deathAnimationSetted or swordScript.slashed--[[ or animacionEntradaRealizada == false]] then
        return
    end
    updateMusic(dt)
    updateDash(dt)
    updateGodMode()
    
    
    handleBleed(dt)

    autoaimUpdate()
    playerMovement(dt)

    handleCover()
    
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
            --explorationMusic:set_volume(explorationMusicVolume) // A DESCOMENTAR
            --combatMusic:set_volume(combatMusicVolume) // A DESCOMENTAR
            prevBackgroundMusicToPlay = 0
        else 
            explorationMusicVolume = explorationMusicVolume + dt * 0.05
            combatMusicVolume = combatMusicVolume - dt  * 0.05
            --explorationMusic:set_volume(explorationMusicVolume) // A DESCOMENTAR
            --combatMusic:set_volume(combatMusicVolume) // A DESCOMENTAR
        end
    elseif backgroundMusicToPlay == 1 and prevBackgroundMusicToPlay ~= backgroundMusicToPlay then
        if combatMusicVolume >= 0.05 then
            combatMusicVolume = 0.05
            explorationMusicVolume = 0
            --combatMusic:set_volume(combatMusicVolume) // A DESCOMENTAR
            --explorationMusic:set_volume(explorationMusicVolume) // A DESCOMENTAR
            prevBackgroundMusicToPlay = 1
        else 
            explorationMusicVolume = explorationMusicVolume - dt * 0.05
            combatMusicVolume = combatMusicVolume + dt * 0.05
            --explorationMusic:set_volume(explorationMusicVolume) // A DESCOMENTAR
            --combatMusic:set_volume(combatMusicVolume) // A DESCOMENTAR
        end
    end
end

function updateDash(dt)
    -- Check for dash activation
    if Input.get_button(Input.action.Dash) == Input.state.Down and dashAvailable == true then

        if(currentAnim ~= dash) then
            currentAnim = dash
            animator:set_current_animation(currentAnim)
        end
        
        local dashDirection = Vector3.new(math.sin(angleRotation), 0, math.cos(angleRotation))
        local impulse = Vector3.new(dashDirection.x * dashSpeed, dashDirection.y * dashSpeed, dashDirection.z * dashSpeed)
        playerRb:set_trigger(true)
        
        playerRb:apply_impulse(Vector3.new(impulse.x, impulse.y, impulse.z))
        impulseApplied = true
        dashAvailable = false
        intangibleDash = true
            
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
        playerTransf.rotation.y = math.deg(angleRotation)
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
        if shotGunScript.granadasSpeed then
            moveSpeed = 6 * granadeVelocity
        end
        playerRb:set_trigger(false)
    end
end

function updateEntranceAnimation(dt)
    if animacionEntradaRealizada == false then
        if(currentAnim ~= drop) then
            currentAnim = drop
            animator:set_current_animation(currentAnim)
        end
        timerAnimacionEntrada = timerAnimacionEntrada + dt

        if(timerAnimacionEntrada > 6.2 )then
            playerTransf.rotation.y = 0
            animacionEntradaRealizada = true
            currentAnim = idle
            animator:set_current_animation(currentAnim)
        end
        return
    end
end

function handleWeaponSwitch(dt)
    if Input.get_button(Input.action.Skill1) == Input.state.Down then
        if pressedButtonChangeWeapon == false then
            if actualweapon == 0 then
                actualweapon = 1
                shotgunUpper:set_active(true)
                shotgunLower:set_active(false)
                bolterUpper:set_active(false)
                bolterLower:set_active(true)
            else
                shotgunUpper:set_active(false)
                shotgunLower:set_active(true)
                bolterUpper:set_active(true)
                bolterLower:set_active(false)
                
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

    if swordScript.slashed == true then
        playerTransf.rotation.y = math.deg(angleRotation)
        if swordAnimationTimeCounter == 0 then
            
        
            if currentAnim ~= melee then
                currentAnim = melee
                animator:set_upper_animation(currentAnim)
                
            end
            swordUpper:set_active(true)
            shotgunUpper:set_active(false)
            bolterUpper:set_active(false)

        end

        if swordAnimationTimeCounter <= swordAnimationTime then
            swordAnimationTimeCounter = swordAnimationTimeCounter + dt
        else
            swordAnimationTimeCounter = 0
            swordUpper:set_active(false)
            shotgunUpper:set_active(true)
            bolterUpper:set_active(true)
            swordScript.slashed = false
        end
        
        
    end

    

    
end

function playerMovement(dt)

    local axisX_l = Input.get_axis_position(Input.axiscode.LeftX)
    local axisY_l = Input.get_axis_position(Input.axiscode.LeftY)

    local axisX_r = Input.get_axis_position(Input.axiscode.RightX)
    local axisY_r = Input.get_axis_position(Input.axiscode.RightY)

    local rightTrigger = Input.get_button(Input.action.Shoot)


    -- Camera angle in radians (45 degrees)
    local cameraAngle = math.rad(45)

    -- Rotate the entry axes to align the with the camera
    local moveDirectionX = axisX_l * math.cos(cameraAngle) - axisY_l * math.sin(cameraAngle)
    local moveDirectionY = axisX_l * math.sin(cameraAngle) + axisY_l * math.cos(cameraAngle)

    local rotationDirectionX = axisX_r * math.cos(cameraAngle) - axisY_r * math.sin(cameraAngle)
    local rotationDirectionY = axisX_r * math.sin(cameraAngle) + axisY_r * math.cos(cameraAngle)

    local keyboardleft = false
    local keyboardRight = false

   
    if Input.is_key_pressed(Input.keycode.W) or Input.is_key_pressed(Input.keycode.A) or Input.is_key_pressed(Input.keycode.S) or Input.is_key_pressed(Input.keycode.D) then
        if Input.is_key_pressed(Input.keycode.W) then
            moveDirectionY = -1  
            
        elseif Input.is_key_pressed(Input.keycode.S) then
            moveDirectionY = 1  
        else
            moveDirectionY = 0
        end
        
        if Input.is_key_pressed(Input.keycode.A) then
            moveDirectionX = -1  
        elseif Input.is_key_pressed(Input.keycode.D) then
            moveDirectionX = 1 
        else
            moveDirectionX = 0
        end

        keyboardleft = true
        
    end

    if keyboardleft then
        moveDirection = Vector3.new(
        moveDirectionX * math.cos(cameraAngle) - moveDirectionY * math.sin(cameraAngle),
        0,
        moveDirectionX * math.sin(cameraAngle) + moveDirectionY * math.cos(cameraAngle)
        )
    else
        moveDirection = Vector3.new(moveDirectionX, 0, moveDirectionY)
    end

    if Input.is_key_pressed(Input.keycode.Up) or Input.is_key_pressed(Input.keycode.Left) or Input.is_key_pressed(Input.keycode.Down) or Input.is_key_pressed(Input.keycode.Right) then
        if Input.is_key_pressed(Input.keycode.Up) then
            rotationDirectionY = -1  
            
        elseif Input.is_key_pressed(Input.keycode.Down) then
            rotationDirectionY = 1  
        else
            rotationDirectionY = 0
        end
        
        if Input.is_key_pressed(Input.keycode.Left) then
            rotationDirectionX = -1  
        elseif Input.is_key_pressed(Input.keycode.Right) then
            rotationDirectionX = 1 
        else
            rotationDirectionX = 0
        end

        keyboardRight = true
        
    end

    if keyboardRight then
        rotationDirection = Vector3.new(
        rotationDirectionX * math.cos(cameraAngle) - rotationDirectionY * math.sin(cameraAngle),
        0,
        rotationDirectionX * math.sin(cameraAngle) + rotationDirectionY * math.cos(cameraAngle)
        )
    else
        rotationDirection = Vector3.new(rotationDirectionX, 0, rotationDirectionY)
    end

    

    if impulseApplied == false then
    if moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        isMoving = true
        -- Animacion walk

        if actualweapon == 0 then
            if currentAnim ~= run and bolterScript.shootAnimation == false then
                currentAnim = run
                animator:set_upper_animation(currentAnim)
                animator:set_lower_animation(currentAnim)
            end
        else
            if currentAnim ~= run  then

                currentAnim = run
                print("siiiiiiii")
                animator:set_lower_animation(currentAnim)
                if currentUpAnim ~= run_Shotgun then
                    
                    currentUpAnim = run_Shotgun
                    animator:set_upper_animation(currentUpAnim)
                end
                
                
            end
            if currentUpAnim ~= run_Shotgun and shotGunScript.shootAnimation == false then
                    
                currentUpAnim = run_Shotgun
                animator:set_upper_animation(currentUpAnim)
            end

            
        end
        
    
        -- Progressive acceleration until reaching moveSpeed
        currentSpeed = math.min(currentSpeed + acceleration * dt, moveSpeed)
    
        local velocity = Vector3.new(moveDirection.x * currentSpeed, 0, moveDirection.z * currentSpeed)
    
        playerRb:set_velocity(velocity)
    
        -- Rotate the player with the movement if not aiming
        if axisX_r == 0 and axisY_r == 0 then
            angleRotation = math.atan(moveDirection.x, moveDirection.z)
            lastValidRotation = angleRotation
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
    
        
            -- Animation idle
            if currentAnim ~= idle and bolterScript.shootAnimation == false and shotGunScript.shootAnimation == false then
                currentAnim = idle
                animator:set_current_animation(currentAnim)
            end


            
        
    end
    end

    --[[if rightTrigger == Input.state.Down then
        print("shooooot")
        if currentAnim ~= attack then
            
            currentAnim = attack
            animator:set_upper_animation(currentAnim)
        end
    end]]

    --Aiming Rotation
    --[[if (rotationDirectionX ~= 0 or rotationDirectionY ~= 0) then
        local lookLength = rotationDirectionX*rotationDirectionX + rotationDirectionY*rotationDirectionY
        if(lookLength > 0) then
            angleRotation = math.atan(rotationDirectionX, rotationDirectionY)
            playerTransf.rotation.y = angleRotation * 57.2958
        end
    end]]

   --[[ if moveDirection.x ~= 0 or moveDirection.z ~= 0 then
        if rotationDirectionX ~= 0 or rotationDirectionY ~= 0 then
            -- If Is moving and aiming
            local desiredRotation = math.deg(math.atan(rotationDirectionX, rotationDirectionY))

            local moveAngle = math.deg(math.atan(moveDirection.x, moveDirection.z))
            local minAngle = moveAngle - 90
            local maxAngle = moveAngle + 90

            -- Limit the rotation
            local clampedRotation = clampRotation(desiredRotation, minAngle, maxAngle)

            angleRotation = math.rad(clampedRotation)
            playerTransf.rotation.y = clampedRotation
        end
    else
        -- If the player doesn't move 360 rotation
        if rotationDirectionX ~= 0 or rotationDirectionY ~= 0 then
            lastValidRotation = math.atan(rotationDirectionX, rotationDirectionY)
            angleRotation = lastValidRotation
            playerTransf.rotation.y = math.deg(lastValidRotation)
            isAiming = true
        else
            playerTransf.rotation.y = math.deg(lastValidRotation)
            isAiming = false
        end
    end]]


    if rotationDirectionX ~= 0 or rotationDirectionY ~= 0 then
        lastValidRotation = math.atan(rotationDirectionX, rotationDirectionY)
        angleRotation = lastValidRotation
        playerTransf.rotation.y = math.deg(lastValidRotation)  
        isAiming = true
    elseif moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        lastValidRotation = math.atan(moveDirection.x, moveDirection.z)
        angleRotation = lastValidRotation
        playerTransf.rotation.y = math.deg(lastValidRotation)
    else
        playerTransf.rotation.y = math.deg(lastValidRotation)
        angleRotation = lastValidRotation
        isAiming = false
    end
end

function normalizeAngle(angle)
    while angle > 180 do
        angle = angle - 360
    end
    while angle < -180 do
        angle = angle + 360
    end
    return angle
end

function detect_enemy(rayHit)

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange"

end

function autoaimUpdate()
    local direction = Vector3.new(
        math.sin(angleRotation), 
        0, 
        math.cos(angleRotation)
    )

    --print(angleRotation)

    -- Normalizar dirección para evitar distancias erróneas
    local distance = math.sqrt(direction.x^2 + direction.z^2)
    if distance > 0 then
        direction.x = direction.x / distance
        direction.z = direction.z / distance
    end

    -- Ángulo de separación en radianes (~30 grados)
    local angleOffset = math.rad(7.5)  
    local intermediateAngleOffset = math.rad(3.75)

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

    local origin = playerTransf.position
    local maxDistance = 12.0

    Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
    Physics.DebugDrawRaycast(origin, intermediateLeftDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1)) 
    Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    Physics.DebugDrawRaycast(origin, intermediateRightDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1))
    Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))

    local centerHit = Physics.Raycast(origin, direction, maxDistance)
    local intermediateLeftHit = Physics.Raycast(origin, intermediateLeftDirection, maxDistance)
    local leftHit = Physics.Raycast(origin, leftDirection, maxDistance)
    local intermediateRightHit = Physics.Raycast(origin, intermediateRightDirection, maxDistance)
    local rightHit = Physics.Raycast(origin, rightDirection, maxDistance)

    if detect_enemy(centerHit) then
        local enemyPos = centerHit.hitEntity:get_component("TransformComponent").position
        enemyDirection = normalizeVector(Vector3.new(enemyPos.x - origin.x,enemyPos.y - origin.y ,enemyPos.z - origin.z))
    elseif detect_enemy(intermediateLeftHit) then
        local enemyPos = intermediateLeftHit.hitEntity:get_component("TransformComponent").position
        enemyDirection = normalizeVector(Vector3.new(enemyPos.x - origin.x,enemyPos.y - origin.y ,enemyPos.z - origin.z ))

    elseif detect_enemy(leftHit) then
        local enemyPos = leftHit.hitEntity:get_component("TransformComponent").position
        enemyDirection = normalizeVector(Vector3.new(enemyPos.x - origin.x,enemyPos.y - origin.y ,enemyPos.z - origin.z))

    elseif detect_enemy(intermediateRightHit) then
        local enemyPos = intermediateRightHit.hitEntity:get_component("TransformComponent").position
        enemyDirection = normalizeVector(Vector3.new(enemyPos.x - origin.x,enemyPos.y - origin.y ,enemyPos.z - origin.z))

    elseif detect_enemy(rightHit) then
        local enemyPos = rightHit.hitEntity:get_component("TransformComponent").position
        enemyDirection = normalizeVector(Vector3.new(enemyPos.x - origin.x,enemyPos.y - origin.y ,enemyPos.z - origin.z))

    else
        enemyDirection = nil
    end

    if enemyDirection then
        
    end
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

function get_angle_to_target(origin, targetPosition)
    local dir = Vector3.new(targetPosition.x - origin.x, targetPosition.y - origin.y, targetPosition.z - origin.z )
    return math.atan(dir.x, dir.z) 
end

function clampRotation(angle, minAngle, maxAngle)
    angle = normalizeAngle(angle)
    minAngle = normalizeAngle(minAngle)
    maxAngle = normalizeAngle(maxAngle)

    if minAngle > maxAngle then
        if angle > minAngle or angle < maxAngle then
            return angle
        end
        if math.abs(angle - minAngle) < math.abs(angle - maxAngle) then
            return minAngle
        else
            return maxAngle
        end
    else
        return math.max(minAngle, math.min(angle, maxAngle))
    end
end

function checkPlayerDeath(dt)
    if playerHealth <= 0 then
        if currentAnim ~= die and deathAnimationSetted == false then
            currentAnim = die
            animator:set_current_animation(currentAnim)
            deathAnimationSetted = true
            playerRb:set_velocity(Vector3.new(0, 0, 0))
        end
        playerHealth = 0
        playerTransf.rotation.y = math.deg(angleRotation)
        deathTimeCounter = deathTimeCounter + dt
        if deathTimeCounter >= deathAnimationTime and sceneChanged == false then
            sceneChanged = true
            SceneManager.change_scene("levelLose.TeaScene")
        end
    end
    if playerHealth >= 100 then
        playerHealth = 100
    end
end



function take_damage(amount)
    if godMode or intangibleDash then 
        return 
    end

    local finalDamage = amount * damageReduction
    playerHealth = playerHealth - finalDamage
    tookDamage = true    
end

function handleBleed(dt)

    if isBleeding then
        bleedTimer = bleedTimer - dt
        timeSinceLastBleed = timeSinceLastBleed + dt

        if timeSinceLastBleed >= bleedInterval then
            if playerHealth > 0 then
                playerHealth = playerHealth - bleedDamage
            end
            timeSinceLastBleed = 0
        end

        if bleedTimer <= 0 then
            isBleeding = false
        end
    end

end

function applyBleed()
    isBleeding = true
    bleedTimer = bleedDuration
    timeSinceLastBleed = 0
end

function find_scrap()
    local entities = current_scene:get_all_entities()
    --tuplaScrap = { {}, {} }
    amountOfScrap = 0


    scrapObjects = {}

    for _, entity in ipairs(entities) do
        local entitiname = entity:get_component("TagComponent").tag
        if entitiname == "Scrap" then
            playerPos = playerTransf.position

            local transform = entity:get_component("TransformComponent")
            local cercania = Vector3.new(
            math.abs(playerPos.x - transform.position.x),
            math.abs(playerPos.y - transform.position.y),
            math.abs(playerPos.z - transform.position.z)
            )
            
            if cercania.x < 200 and cercania.y < 200 and cercania.z < 200 then
                


            

            table.insert(scrapObjects, entity:get_component("TransformComponent"))

            --tuplaScrap = tuplet_insert(tuplaScrap, entity, 1)
            
            --tuplaScrap = tuplet_insert(tuplaScrap, transform, 2)
            amountOfScrap = amountOfScrap + 1
            end
        end
        
        
    end
    if amountOfScrap == 0 then
        attractionActive = false

    end

    --tuplaP1 = tuplaScrap[1]
    --tuplaP2 = tuplaScrap[2]
end

function attract_scrap(dt)
    partOfList = partOfList + 1
    
    for _, scrap in ipairs(scrapObjects) do
        
        playerPos = playerTransf.position
        local cercania = Vector3.new(
            math.abs(playerPos.x - scrap.position.x),
            math.abs(playerPos.y - scrap.position.y),
            math.abs(playerPos.z - scrap.position.z)
        )
        
        local direction = Vector3.new(playerPos.x - scrap.position.x,
        playerPos.y - scrap.position.y, 
        playerPos.z - scrap.position.z)

        local l = attractionSpeed * dt
        local p = Vector3.new(direction.x * l ,
                              direction.y * l , 
                              direction.z * l )
        local scrapPos = Vector3.new(scrap.position.x + p.x,
                                     scrap.position.y + p.y, 
                                     scrap.position.z + p.z)
        scrap.position = scrapPos

        -- Calcular la distancia entre el player y la chatarra
        local cercania = Vector3.new(
            math.abs(playerPos.x - scrap.position.x),
            math.abs(playerPos.y - scrap.position.y),
            math.abs(playerPos.z - scrap.position.z)
        )
        ----print("algo", cercania.x, cercania.y, cercania.z)

        if cercania.x < 2 and cercania.y < 2 and cercania.z < 2 then
            --current_scene:destroy_entity(tuplaP1[partOfList])
            scrap.position.x = 5000000000
            scrap.position.y = 5000000000
            scrap.position.z = 5000000000
            scrapCounter = scrapCounter + 100
            scrapDestroyed = scrapDestroyed + 1




        end
        if amountOfScrap == scrapDestroyed then
            scrapDestroyed = 0
            attractionActive = false

        end

        --[[
        if partOfList >= amountOfScrap then
            partOfList = 0
        end
        ]]
    
    end 
end

function handleCover()
    if barricadeScript then
        if barricadeScript.isPlayerInRange == false then
            isCovering = false
            moveSpeed = 6
            return
        end
        if Input.get_button(Input.action.Cover) == Input.state.Down then
            isCovering = not isCovering
            print("isCovering", isCovering)
        end

        if isCovering then
            moveSpeed = 4
        else
            moveSpeed = 6
        end
    end
end

function HealPlayer()
    playerHealth = playerHealth + 40

    if playerHealth > 100 then
        playerHealth = 100
    end
end