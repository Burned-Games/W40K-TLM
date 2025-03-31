-- Player
playerHealth = 100
local playerTransf
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

local animacionEntradaRealizada = false
local timerAnimacionEntrada = 0

damageReduction = 1
tookDamage = false
makeDamage = false 

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


--granadeSpeed
local granadeVelocity = 0.65
-- Rifle & Shotgun Variables (Needs to be centralized & organized :v)

scrap = 0

local deathAnimationSetted = false


function on_ready()
    -- Add initialization code here

    explorationMusic = current_scene:get_entity_by_name("MusicExploration"):get_component("AudioSourceComponent")
    combatMusic = current_scene:get_entity_by_name("MusicCombat"):get_component("AudioSourceComponent")
    


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

    swordScript = current_scene:get_entity_by_name("SawSwordManager"):get_component("ScriptComponent")

    bolterScript = current_scene:get_entity_by_name("BolterManager"):get_component("ScriptComponent")

    shotGunScript = current_scene:get_entity_by_name("ShotgunManager"):get_component("ScriptComponent")


    animator = self:get_component("AnimatorComponent")
  
    combatMusic:play()
    explorationMusic:play()


end

function on_update(dt)

    checkPlayerDeath(dt)
    handleWeaponSwitch(dt)
    if deathAnimationSetted or swordScript.slashed then
        return
    end
    updateMusic(dt)
    updateDash(dt)
    updateGodMode()
    updateEntranceAnimation(dt)
    
    handleBleed(dt)

    if not animacionEntradaRealizada then
        return
    end


    playerMovement(dt)

    

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
    if Input.get_button(Input.action.Dash) == Input.state.Down and dashAvailable == true then

        if(currentAnim ~= 3) then
            currentAnim = 3
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
        moveSpeed = 6*granadeVelocity
        else
        moveSpeed = 6
        end
        playerRb:set_trigger(false)
    end
end

function updateEntranceAnimation(dt)
    if animacionEntradaRealizada == false then
        if(currentAnim ~= 5) then
            currentAnim = 5
            animator:set_current_animation(currentAnim)
        end
        timerAnimacionEntrada = timerAnimacionEntrada + dt

        if(timerAnimacionEntrada > 6.2 )then
            playerTransf.rotation.y = 0
            animacionEntradaRealizada = true
            currentAnim = 6
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
        
        if swordAnimationTimeCounter == 0 then
            
        
            if currentAnim ~= 8 then
                currentAnim = 8
                animator:set_current_animation(currentAnim)
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

    local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)


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
            if currentAnim ~= 9 then
                currentAnim = 9
                animator:set_lower_animation(currentAnim)
            end
        else
            if currentAnim ~= 9 then
                currentAnim = 9
                animator:set_lower_animation(currentAnim)
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
    
        if rightTrigger == 0 then
            -- Animation idle
            if currentAnim ~= 6 then
                currentAnim = 6
                animator:set_current_animation(currentAnim)
            end


            
        end
    end
    end

    --[[if rightTrigger ~= 0 then
        
        animator:set_upper_animation(0)
        
    else
        animator:set_upper_animation(-1)
    end]]

    --Aiming Rotation
    --[[if (rotationDirectionX ~= 0 or rotationDirectionY ~= 0) then
        local lookLength = rotationDirectionX*rotationDirectionX + rotationDirectionY*rotationDirectionY
        if(lookLength > 0) then
            angleRotation = math.atan(rotationDirectionX, rotationDirectionY)
            playerTransf.rotation.y = angleRotation * 57.2958
        end
    end]]

    if moveDirection.x ~= 0 or moveDirection.z ~= 0 then
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
    end


    --[[if rotationDirectionX ~= 0 or rotationDirectionY ~= 0 then
        lastValidRotation = math.atan(rotationDirectionX, rotationDirectionY)
        playerTransf.rotation.y = math.deg(lastValidRotation)  
        isAiming = true
    elseif moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        lastValidRotation = math.atan(moveDirection.x, moveDirection.z)
        playerTransf.rotation.y = math.deg(lastValidRotation)
    else
        playerTransf.rotation.y = math.deg(lastValidRotation)
        isAiming = false
    end]]
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
function clampRotation(angle, minAngle, maxAngle)
    angle = normalizeAngle(angle)
    minAngle = normalizeAngle(minAngle)
    maxAngle = normalizeAngle(maxAngle)

    -- Si el minAngle es mayor que el maxAngle, significa que cruza el umbral de -180°/180°
    if minAngle > maxAngle then
        if angle > minAngle or angle < maxAngle then
            return angle
        end
        -- Elegir el límite más cercano
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
        if currentAnim ~= 4 and deathAnimationSetted == false then
            currentAnim = 4
            animator:set_current_animation(currentAnim)
            deathAnimationSetted = true
        end
        playerHealth = 0
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

