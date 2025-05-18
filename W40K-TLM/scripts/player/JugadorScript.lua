local effect = require("scripts/utils/status_effects")


-- Player
maxHealth = 250
health = maxHealth
playerTransf = nil
playerRb = nil
local lastValidRotation = 0
--speed
local normalSpeed = 5
moveSpeed = 5
local speedDebuf = 1
local godModeSpeed = 12
local currentSpeed = 0
local acceleration = 10      
local deceleration = 8
moveDirection = nil
moveDirectionY = 0
moveDirectionX = 0
local rotationDirection = nil
angleRotation = 0
godMode = false
isMoving = false
local dashSpeed = 15
impulseApplied = false
meleeImpulseApplied = false
local dashTimeCounter = 0
local dashTime = 0.3
dashColdownCounter = 0
local dashMeleeColdownCounter = 0
dashColdown = 3.5
local dashMeleeColdown = 0.8
dashAvailable = true
dashMeleeAvailable = true
intangibleDash = false
local intangibleDashTimeCounter = 0
local intangibleDashTime = 0.15
local deathAnimationTime = 2.5
local deathTimeCounter = 0
local deathAnimationSetted = false

local workbenchUIManagerScript = nil
local pauseScript = nil

animacionEntradaRealizada = false
local timerAnimacionEntrada = 0

--Healing sistem
StimsCounter = 3
isHealing = false
local timesHealed = 0

local intervalcheker = 0
local intervalchekerUp = 0
local intervalChekerDown = 0

damageReduction = 1
tookDamage = false
makeDamage = false 


combatTimer = 0

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
local playerListener = nil

local exploreMusic = nil
local fightingMusic = nil

local fightingMusicVolume = 0
local exploreMusicVolume = 0.05

local prevBackgroundMusicToPlay = -1
backgroundMusicToPlay = 0 -- 0 exploration 1 fight

local footstepSFXTimer = 0
local footstepSFXDelay = 0.5

local playerDeathSFX = nil
local playerBurningSFX = nil
local playerDashSFX = nil
local playerInyectorSFX = nil
local playerOverloadsSFX = nil
local playerStepsSFX = nil
local playerSwapWeaponsSFX = nil
local playerCDSFX = nil

bleedingSFX = nil

-- effects
isBleeding = false
isNeuralInhibitioning = false
neuralFirstTime = true


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
--local tuplaP1 = {}
--local tuplaP2 = {}
local distanceToPlayerToDestroy = 2, 2, 2
local attractionActive = false 
local attractionSpeed = 2
local amountOfScrap = 0
local scrapDestroyed = 0
local partOfList = 0

zonePlayer = 0
level = 1

enemyDirection = nil

local checkpointsPositionLvl1 = { Vector3.new(-14, 0, -32), Vector3.new(105, 0, -115), Vector3.new(194, 0, -216)}
local checkpointsPositionLvl2 = { Vector3.new(0, 0, 0), Vector3.new(63, 0, -60)}

--animation indexs
idle = 17 --17
attack = 3
local dash = 5
local die = 7
local drop = 8
local mainMenu = 18
local melee = 19
local run = 24
local runB = 25
local runL = 26
local runR = 27
local walk = 30
shotgun_Pump = 28
local run_Shotgun = 12
h1_Bolter = 11
h1_Shotgun_Aim = 12
h1_Shotgun_Throw = 13
h1_Shotgun_Enter = 14
local heal = 15
local hit = 16
reload_Bolter = 20
reload_Shotgun = 22
local stun = 29
local aim = 0

local rotationAngle = 0
local transf = nil

local entities

-- particles
local particle_lvl1_run = nil
local particle_fire = nil
local particle_smoke = nil
local neuralInParticle = nil


local dtColective = 0

local fadeToBlackScript = nil

local changeing = false
local changed = false
local changeScene = false

local pauseMenu = nil
isHitted = false

local hitAnimationTime = 0.5
local hitAnimationCounter = 0

local healAnimationBool = false
local healAnimationSecondBool = false
local healAnimCounter = 0
local healAnimationTime = 1


local enemyOrkScript = nil

movingBackLookingUp = false
notMovingLookingUp = false
notMovingnotLooking = false

isStunned = false

local lastTriggerTime = 0
local interval = 2
local sceneName = nil

activateAutoAim = false

local aimAnimation = false

playerScript = nil

local playerMatsComponents = {}
local playerMatsOriginals = {}
local playerMatsDamages = {}


function on_ready()
    sceneName = SceneManager:get_scene_name()

    -- Add initialization code here

    -- Audio

    playerListener = current_scene:get_entity_by_name("Listener"):get_component("TransformComponent")

    exploreMusic = current_scene:get_entity_by_name("ExploreMusic"):get_component("AudioSourceComponent")
    fightingMusic = current_scene:get_entity_by_name("FightingMusic"):get_component("AudioSourceComponent")

    playerDeathSFX = current_scene:get_entity_by_name("PlayerDeathSFX"):get_component("AudioSourceComponent")
    bleedingSFX = current_scene:get_entity_by_name("PlayerBleedingSFX"):get_component("AudioSourceComponent")
    playerBurningSFX = current_scene:get_entity_by_name("PlayerBurningSFX"):get_component("AudioSourceComponent")
    playerDashSFX = current_scene:get_entity_by_name("PlayerDashSFX"):get_component("AudioSourceComponent")
    playerInyectorSFX = current_scene:get_entity_by_name("PlayerInyectorSFX"):get_component("AudioSourceComponent")
    playerOverloadsSFX = current_scene:get_entity_by_name("PlayerOverloadsSFX"):get_component("AudioSourceComponent")
    playerStepsSFX = current_scene:get_entity_by_name("PlayerStepsSFX"):get_component("AudioSourceComponent")
    playerSwapWeaponsSFX = current_scene:get_entity_by_name("PlayerSwapWeaponsSFX"):get_component("AudioSourceComponent")
    playerCDSFX = current_scene:get_entity_by_name("PlayerCDSFX"):get_component("AudioSourceComponent")

    local musicVolume = load_progress("musicVolumeGeneral", 50.0) / 100
    exploreMusic:set_volume(musicVolume)
    exploreMusic:play()
    fightingMusic:set_volume(0)
    fightingMusic:play() 

   entities = current_scene:get_all_entities()

    -- Particles 
    -- en la posicion de caida de la granada-> 
    -- 
    particle_lvl1_run = current_scene:get_entity_by_name("particle_lvl1_run"):get_component("ParticlesSystemComponent")
    particle_fire = current_scene:get_entity_by_name("particle_fire"):get_component("ParticlesSystemComponent")
    particle_smoke = current_scene:get_entity_by_name("particle_smoke"):get_component("ParticlesSystemComponent")
    
    
    --UpgradeManager START
    UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    if UpgradeManager ~= nil then
        UpgradeManager:apply_to_player(self)
    end
    --UpgradeManager END

    playerTransf = self:get_component("TransformComponent")

    transf = self:get_component("TransformComponent")

    playerScript = self:get_component("ScriptComponent")

    rotationAngle = { value = self:get_component("TransformComponent").position.y }
    
    playerRb = self:get_component("RigidbodyComponent").rb

    pauseScript = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")
    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")

    enemyOrkScript = current_scene:get_entity_by_name("EnemyRange"):get_component("ScriptComponent")
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

    barricadeScript = current_scene:get_entity_by_name("Barricade"):get_component("ScriptComponent")

    if self:has_component("AnimatorComponent") then
        animator = self:get_component("AnimatorComponent")
    end
    
    self:get_component("RigidbodyComponent"):on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
        local nameATran = entityA:get_component("TransformComponent")
        local nameBTran = entityB:get_component("TransformComponent")
        
        local newIndex = zonePlayer + 1

        --[[ if nameA == "Inyectores" or nameB == "Inyectores" then   
                   
            StimsCounter = StimsCounter + 1
            if nameA == "Inyectores" then
                
                
                local rigid = entityA:get_component("RigidbodyComponent").rb
                local newPos = Vector3.new(2000000, 0, 0)
                rigid:set_position(newPos)
            end
            if nameB == "Inyectores" then
                
                
                local rigid = entityB:get_component("RigidbodyComponent").rb
                local newPos = Vector3.new(2000000, 0, 0)
                rigid:set_position(newPos)
                
            end
        end ]]
    end)

    --Mision
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")

    level = load_progress("level", 1)

    zonePlayer = load_progress("zonePlayer", 0)
    if level == 1 and zonePlayer >= 1 then
        --animacionEntradaRealizada = true
    end

    if level == 3 or SceneManager:get_scene_name() == "level3.TeaScene" then
        neuralInParticle = current_scene:get_entity_by_name("NeuralInhibitionPartycle"):get_component("TransformComponent")
    end

    UpgradeManager:load_upgrades()
    StimsCounter = load_progress("stims", StimsCounter)
    scrapCounter = load_progress("scrap", 0)

    if zonePlayer >= 1 then
        health = load_progress("health", maxHealth)
        if SceneManager:get_scene_name() == "level1.TeaScene" then
            playerRb:set_position(checkpointsPositionLvl1[zonePlayer])
        elseif SceneManager:get_scene_name() == "level2.TeaScene" then
            if zonePlayer > 2 then
                zonePlayer = 0
            end
            playerRb:set_position(checkpointsPositionLvl2[zonePlayer])
        end
    else
        health = maxHealth
        local newPos = Vector3.new(playerTransf.position.x,0,playerTransf.position.z)
        playerRb:set_position(newPos)
    end

    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")

    --current_scene:get_entity_by_name("Camera"):get_component("TransformComponent").position = playerTransf.Position

    local children = self:get_children()
    for _, child in ipairs(children) do
        local tag = child:get_component("TagComponent").tag
        if tag == "Ultramarine_low" or tag == "Jetpack_lv1" or tag == "Jetpack_lv2" or tag == "Casco_lv1" or tag == "Casco_lvl_2" or tag == "Shotgun_upper" 
        or tag == "Shotgun_lower" or tag == "ChainSword_Upper" or tag == "ChainSword_Lower" or tag == "Bolter_upper" or tag == "Bolter_Lower" then
            local component = child:get_component("MaterialComponent")
            table.insert(playerMatsComponents,component)
            table.insert(playerMatsOriginals,component.material)
            local damageMat = PBRMaterial.new()
            damageMat.albedo_texture = component.material.albedo_texture
            damageMat.color = Vector4.new(255/255, 0/255, 0/255, 255/255)
            table.insert(playerMatsDamages,damageMat)
            
        end
    end
end

function on_update(dt)

    updateMusic(dt)
    if combatTimer <= 0 then   
        backgroundMusicToPlay = 0
    else
        backgroundMusicToPlay = 1
    end
    
    footstepSFXTimer = footstepSFXTimer + dt
    
    if pauseScript.isPaused or workbenchUIManagerScript.isWorkBenchOpen then
        playerRb:set_velocity(Vector3.new(0, 0, 0))
        if currentAnim ~= idle  then
            currentAnim = idle
            animator:set_lower_animation(currentAnim)
            if currentAnim then
                currentUpAnim = idle
                animator:set_upper_animation(currentUpAnim)
            end
        end
        return
    end 
    dtColective = dtColective + dt
    update_combat_state(dt)

    

    if dtColective - lastTriggerTime >= interval then
        updateScrapList()
        
        lastTriggerTime = dtColective
    end

    if StimsCounter > 0 and isHealing == false and (Input.is_button_pressed(Input.controllercode.DpadRight) or Input.is_key_pressed(Input.keycode.H)) then
        StimsCounter = StimsCounter - 1
        intervalcheker = dtColective
        intervalChekerDown = intervalcheker - 0.5
        intervalchekerUp = intervalcheker + 0.5
        isHealing = true
        damageReduction = 0.8
        if mission_Component.getCurrerTaskIndex(true) == 6 then
            mission_Component.m6_heal = true
        end

        if currentUpAnim ~= heal then
            healAnimationSecondBool = true
            healAnimationBool = true
                currentUpAnim = heal
                
                animator:set_upper_animation(currentUpAnim)
        end
    end
    updateEntranceAnimation(dt)

    if animacionEntradaRealizada == false and sceneName == "level1.TeaScene" and zonePlayer == 0 then
        return
    end
    if healAnimationSecondBool then
        healAnimCounter = healAnimCounter + dt
        if healAnimCounter >= healAnimationTime then
            healAnimationBool = false
            healAnimationSecondBool = false
            currentAnim = -1
        end
    end
    
    if isHealing == true and intervalchekerUp > dtColective and intervalChekerDown < dtColective  then
        
        intervalchekerUp = intervalchekerUp + 1.5
        intervalChekerDown = intervalChekerDown + 1.5
        HealPlayer()
    end   

    check_effects(dt)
    checkPlayerDeath(dt)
    handleBleed(dt)

    if Input.is_key_pressed(Input.keycode.M) then
        applyStunn()
    end


    if isStunned == true then
        playerTransf.rotation.y = math.deg(angleRotation)
        return
    end
    handleWeaponSwitch(dt)
    updateAnims(dt)
    
    if(changeing)then
        if fadeToBlackScript.fadeToBlackDoned then
            changeScene = true
        end
    end


    if changeScene == true and not changed then
        SceneManager.change_scene("scenes/lose.TeaScene")
        changed = true
    end

    if deathAnimationSetted then
        return
    end

    
    
    if workbenchUIManagerScript.isWorkBenchOpen == false then
        updateDash(dt)
        updateDashMelee(dt)
    end

    updateGodMode(dt)
    
    if godMode or activateAutoAim then
        autoaimUpdate()
    end
    if pauseScript.isPaused == false and workbenchUIManagerScript.isWorkBenchOpen == false then
        playerMovement(dt)
    end 
        
        


    handleCover()
    
    

    -- Listener Position
    playerListener.position = playerTransf.position
end

function on_exit()
    fightingMusic:pause()
    exploreMusic:pause()
    -- Add cleanup code here
end



function updateMusic(dt)
    if backgroundMusicToPlay == 0 and prevBackgroundMusicToPlay ~= backgroundMusicToPlay then
        if exploreMusicVolume >= 0.05 then
            exploreMusicVolume = 0.05
            fightingMusicVolume = 0
            exploreMusic:set_volume(exploreMusicVolume) 
            fightingMusic:set_volume(fightingMusicVolume)
            prevBackgroundMusicToPlay = 0
        else 
            exploreMusicVolume = exploreMusicVolume + dt * 0.05
            fightingMusicVolume = fightingMusicVolume - dt  * 0.05
            exploreMusic:set_volume(exploreMusicVolume) 
            fightingMusic:set_volume(fightingMusicVolume) 
        end
    elseif backgroundMusicToPlay == 1 and prevBackgroundMusicToPlay ~= backgroundMusicToPlay then
        if fightingMusicVolume >= 0.05 then
            fightingMusicVolume = 0.05
            exploreMusicVolume = 0
            fightingMusic:set_volume(fightingMusicVolume)
            exploreMusic:set_volume(exploreMusicVolume)
            prevBackgroundMusicToPlay = 1
        else 
            exploreMusicVolume = exploreMusicVolume - dt * 0.05
            fightingMusicVolume = fightingMusicVolume + dt * 0.05
            exploreMusic:set_volume(exploreMusicVolume)
            fightingMusic:set_volume(fightingMusicVolume)
        end
    end
end

function updateDash(dt)
    -- Check for dash activation
    if Input.get_button(Input.action.Dash) == Input.state.Down and not dashAvailable then
        playerCDSFX:play()
    end
    
    if Input.get_button(Input.action.Dash) == Input.state.Down and dashAvailable == true and swordScript.slasheeed == false then
        if(currentAnim ~= dash) and swordScript.slasheeed == false then
            currentAnim = dash
            currentUpAnim = dash
            animator:set_current_animation(currentAnim)
        end
        local dashDirection = nil
        if isMoving == false then
            dashDirection = Vector3.new(math.sin(angleRotation), 0, math.cos(angleRotation))
        else
            dashDirection = Vector3.new(moveDirectionX, 0, moveDirectionY)
        end
        
        local impulse = Vector3.new(dashDirection.x * dashSpeed, dashDirection.y * dashSpeed, dashDirection.z * dashSpeed)
        --playerRb:set_trigger(true)
        
        playerRb:apply_impulse(Vector3.new(impulse.x, impulse.y, impulse.z))
        impulseApplied = true
        dashAvailable = false
        intangibleDash = true
        
        playerDashSFX:play()

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

function updateDashMelee(dt)
    -- Check for dash activation
    



end

function updateGodMode(dt)

    if Input.is_key_pressed(Input.keycode.F1) then
        if godMode == false then
            moveSpeed = normalSpeed * speedDebuf
            playerRb:set_trigger(false)
            local newPos = Vector3.new(playerTransf.position.x,0,playerTransf.position.z)
            playerRb:set_position(newPos)
        end
        if pressedButton == false then
            godMode = not godMode
            current_scene.debug_flags.debug_draw = godMode
        end
        pressedButton = true
    else
        pressedButton = false
    end

    if godMode then
        if Input.is_key_pressed(Input.keycode.F2) then
            SceneManager.change_scene("scenes/level1.TeaScene")
            log ("cambio 1")
        end
        if Input.is_key_pressed(Input.keycode.F3) then
            SceneManager.change_scene("scenes/level2.TeaScene")
            log ("cambio 2")
        end
        if Input.is_key_pressed(Input.keycode.F4) then
            log ("cambio 3")
            SceneManager.change_scene("scenes/level3.TeaScene")
        end
        if Input.is_key_pressed(Input.keycode.F5) then
            log ("cambio 4")
            SceneManager.change_scene("Default.TeaScene")
        end
        if Input.is_key_pressed(Input.keycode.F6) then
            scrapCounter = scrapCounter + 1000
        end
        health = maxHealth
        bolterScript.ammo = 0
        shotgunammo = 0
        moveSpeed = godModeSpeed
        playerRb:set_trigger(true)
        dashColdownCounter = dashTime
        shotGunScript.timerGranade = 0
        bolterScript.cooldownDisruptorBulletTimeCounter = bolterScript.cooldownDisruptorBulletTime
        swordScript.coolDownCounter = swordScript.coolDown
  
        if Input.is_button_pressed(Input.controllercode.DpadUp) or Input.is_key_pressed(Input.keycode.J) then

            local newPos = Vector3.new(playerTransf.position.x,playerTransf.position.y + dt * moveSpeed,playerTransf.position.z)
            playerRb:set_position(newPos)

        elseif Input.is_button_pressed(Input.controllercode.DpadDown) or Input.is_key_pressed(Input.keycode.K) then

            local newPos = Vector3.new(playerTransf.position.x,playerTransf.position.y - dt * moveSpeed,playerTransf.position.z)
            playerRb:set_position(newPos)
        end
    elseif isCovering == false then
        
    end
end

function updateEntranceAnimation(dt)
    if sceneName == "level1.TeaScene"and zonePlayer == 0 then 
            
        if animacionEntradaRealizada == false then
            if(currentAnim ~= drop) then
                currentAnim = drop
                animator:set_current_animation(currentAnim)
            end
            timerAnimacionEntrada = timerAnimacionEntrada + dt
            if(timerAnimacionEntrada > 3.6 )then
                playerTransf.rotation.y = 0
                animacionEntradaRealizada = true
                currentAnim = idle
                animator:set_current_animation(currentAnim)
            end
            return
        end

end
end

function handleWeaponSwitch(dt)
    if Input.get_button(Input.action.Skill1) == Input.state.Down or Input.is_key_pressed(Input.keycode.O) and swordScript.slasheeed == false then
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

            playerSwapWeaponsSFX:play()
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

    if swordScript.slasheeed == true then
        shotGunScript.is_reloading = false
        bolterScript.manualReload = false
        bolterScript.reloadAnimation = false
        playerTransf.rotation.y = math.deg(angleRotation)
        if swordAnimationTimeCounter == 0 then
            if currentAnim ~= melee then
                currentAnim = melee
                animator:set_current_animation(currentAnim)
            end
            swordUpper:set_active(true)
            shotgunUpper:set_active(false)
            bolterUpper:set_active(false)

        end

        if swordAnimationTimeCounter <= swordAnimationTime then
            swordAnimationTimeCounter = swordAnimationTimeCounter + dt
        else
            currentUpAnim = -1
            swordAnimationTimeCounter = 0
            swordUpper:set_active(false)
            shotgunUpper:set_active(true)
            bolterUpper:set_active(true)
            swordScript.slasheeed = false
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

    if axisY_l > 1.0 - 0.2 and axisY_l < 1.0 + 0.2 and axisY_r > -1.0 - 0.2 and axisY_r < -1.0 + 0.2 then
        movingBackLookingUp = true
    else
        movingBackLookingUp = false
    end
    -- Camera angle in radians (45 degrees)
    local cameraAngle = math.rad(45)

    -- Rotate the entry axes to align the with the camera
    moveDirectionX = axisX_l * math.cos(cameraAngle) - axisY_l * math.sin(cameraAngle)
    moveDirectionY = axisX_l * math.sin(cameraAngle) + axisY_l * math.cos(cameraAngle)

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

    

    if impulseApplied == false and meleeImpulseApplied == false then
    if moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        notMovingLookingUp = false
        if footstepSFXTimer > footstepSFXDelay then
            footstepSFXTimer = 0
            playerStepsSFX:play()
            particle_lvl1_run:emit(20)
        end
        isMoving = true
        
        -- Animacion walk
        
        if rotationDirection.x ~= 0 or rotationDirection.y ~= 0 then
            local moveMargin = 0.3
            local threshold = 0.3

            -- Calculando los rangos para X y Z
            local minX = moveDirection.x - moveMargin
            local maxX = moveDirection.x + moveMargin
            
            local minZ = moveDirection.z - moveMargin
            local maxZ = moveDirection.z + moveMargin

            
            local dotProduct = rotationDirection.x * moveDirection.x + rotationDirection.z * moveDirection.z
            local angleInDegrees = math.deg(math.atan(rotationDirection.z, rotationDirection.x)) 
            
            local angle2InDegrees = math.deg(math.atan(moveDirection.z, moveDirection.x)) 
            
            local diference = angleInDegrees - angle2InDegrees
            if rotationDirection.x > minX and rotationDirection.x < maxX and
            (rotationDirection.z > minZ and rotationDirection.z < maxZ) then        
                moveSpeed = normalSpeed * speedDebuf
                if actualweapon == 0 then
                    if currentAnim ~= run  and swordScript.slasheeed == false and isHitted == false and bolterScript.chaaarging == false  then
                        currentAnim = run
                        animator:set_lower_animation(currentAnim)
                        if currentUpAnim ~= run and bolterScript.shootAnimation == false and bolterScript.reloadAnimation == false and healAnimationBool == false and aimAnimation == false then
                            currentUpAnim = run
                            animator:set_upper_animation(currentUpAnim)
                        end
                    end
                else
                    if currentAnim ~= run and swordScript.slasheeed == false and isHitted == false and shotGunScript.granadeAnimation == false then
                        currentAnim = run
                        animator:set_lower_animation(currentAnim)
                        if currentUpAnim ~= run and shotGunScript.shootAnimation == false and shotGunScript.is_reloading == false and aimAnimation == false and healAnimationBool == false and swordScript.slasheeed == false then                     
                            currentUpAnim = run
                            animator:set_upper_animation(currentUpAnim)
                        end
                        
                        
                    end                 
                end
            elseif (rotationDirection.x > minZ and rotationDirection.x < maxZ and
                (rotationDirection.z > minX and rotationDirection.z < maxX))or ((rotationDirection.x < minZ or rotationDirection.x > maxZ) and
                (rotationDirection.z < minX or rotationDirection.z > maxX)) then
                    moveSpeed = 4 * speedDebuf
                    if actualweapon == 0 then
                        if currentAnim ~= runB  and swordScript.slasheeed == false and isHitted == false and bolterScript.chaaarging == false  then
                            currentAnim = runB
                            animator:set_lower_animation(currentAnim)
                            if currentUpAnim ~= runB and bolterScript.shootAnimation == false and bolterScript.reloadAnimation == false and healAnimationBool == false and aimAnimation == false then
                                currentUpAnim = runB
                                animator:set_upper_animation(currentUpAnim)
                            end
                        end
                    else
                        if currentAnim ~= runB and swordScript.slasheeed == false and isHitted == false and shotGunScript.granadeAnimation == false then
                            currentAnim = runB
                            animator:set_lower_animation(currentAnim)
                            if currentUpAnim ~= runB and shotGunScript.shootAnimation == false and shotGunScript.is_reloading == false and aimAnimation == false and healAnimationBool == false and swordScript.slasheeed == false then                     
                                currentUpAnim = runB
                                animator:set_upper_animation(currentUpAnim)
                            end
                            
                            
                        end                 
                    end
            
            elseif diference < diference + 10 and diference > diference - 10 then
                
                local cross = rotationDirection.x * moveDirection.z - rotationDirection.z * moveDirection.x

                if cross > 0 then
                    -- IZQUIERDA
                    moveSpeed = 4 * speedDebuf
                    if actualweapon == 0 then
                        if currentAnim ~= runR  and swordScript.slasheeed == false and isHitted == false and bolterScript.chaaarging == false  then
                            currentAnim = runR
                            animator:set_lower_animation(currentAnim)
                            if currentUpAnim ~= runR and bolterScript.shootAnimation == false and bolterScript.reloadAnimation == false and healAnimationBool == false and aimAnimation == false then
                                currentUpAnim = runR
                                animator:set_upper_animation(currentUpAnim)
                            end
                        end
                    else
                        if currentAnim ~= runR and swordScript.slasheeed == false and isHitted == false and shotGunScript.granadeAnimation == false then
                            currentAnim = runR
                            animator:set_lower_animation(currentAnim)
                            if currentUpAnim ~= runR and shotGunScript.shootAnimation == false and shotGunScript.is_reloading == false and aimAnimation == false and healAnimationBool == false and swordScript.slasheeed == false then                     
                                currentUpAnim = runR
                                animator:set_upper_animation(currentUpAnim)
                            end
                            
                            
                        end                 
                    end

                elseif cross < 0 then
                    -- DERECHA
                    moveSpeed = 4 * speedDebuf
                    if actualweapon == 0 then
                        if currentAnim ~= runL  and swordScript.slasheeed == false and isHitted == false and bolterScript.chaaarging == false  then
                            currentAnim = runL
                            animator:set_lower_animation(currentAnim)
                            if currentUpAnim ~= runL and bolterScript.shootAnimation == false and bolterScript.reloadAnimation == false and healAnimationBool == false and aimAnimation == false then
                                currentUpAnim = runL
                                animator:set_upper_animation(currentUpAnim)
                            end
                        end
                    else
                        if currentAnim ~= runL and swordScript.slasheeed == false and isHitted == false and shotGunScript.granadeAnimation == false then
                            currentAnim = runL
                            animator:set_lower_animation(currentAnim)
                            if currentUpAnim ~= runL and shotGunScript.shootAnimation == false and shotGunScript.is_reloading == false and aimAnimation == false and healAnimationBool == false and swordScript.slasheeed == false then                     
                                currentUpAnim = runL
                                animator:set_upper_animation(currentUpAnim)
                            end
                            
                            
                        end                 
                    end
                end

                
                
            end
        else
       

            if rotationDirection.x == 0 and rotationDirection.z == 0 then
                
                if actualweapon == 0 then
                    if currentAnim ~= run  and swordScript.slasheeed == false and isHitted == false and bolterScript.chaaarging == false  then
                        currentAnim = run
                        animator:set_lower_animation(currentAnim)
                        if currentUpAnim ~= run and bolterScript.shootAnimation == false and bolterScript.reloadAnimation == false and healAnimationBool == false and aimAnimation == false and swordScript.slasheeed == false then
                            currentUpAnim = run
                            moveSpeed = normalSpeed * speedDebuf
                            animator:set_upper_animation(currentUpAnim)
                        end
                    end
                else
                    if currentAnim ~= run and swordScript.slasheeed == false and isHitted == false and shotGunScript.granadeAnimation == false then
                        currentAnim = run
                        animator:set_lower_animation(currentAnim)
                        if currentUpAnim ~= run and shotGunScript.shootAnimation == false and shotGunScript.is_reloading == false and aimAnimation == false and healAnimationBool == false and swordScript.slasheeed == false then                     
                            currentUpAnim = run
                            moveSpeed = normalSpeed * speedDebuf
                            animator:set_upper_animation(currentUpAnim)
                        end
                        
                        
                    end                 
                end
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
        if axisY_r > -1.0 - 0.2 and axisY_r < -1.0 + 0.2 then
            notMovingLookingUp = true
        else
            notMovingLookingUp = false
        end
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
            if currentAnim ~= idle and bolterScript.chaaarging == false and swordScript.slasheeed == false or currentUpAnim ~= idle and shotGunScript.shootAnimation == false and aimAnimation == false and swordScript.slasheeed == false and isHitted == false and shotGunScript.is_reloading == false and bolterScript.chaaarging == false and bolterScript.reloadAnimation == false and healAnimationBool == false and shotGunScript.granadeAnimation == false and bolterScript.shootAnimation == false then
                currentAnim = idle
                animator:set_lower_animation(currentAnim)
                if shotGunScript.shootAnimation == false and aimAnimation == false and bolterScript.shootAnimation == false and aimAnimation == false and bolterScript.reloadAnimation == false and healAnimationBool == false and shotGunScript.granadeAnimation == false and swordScript.slasheeed == false then
                    currentUpAnim = idle
                    animator:set_upper_animation(currentUpAnim)
                end
            end
        



            
        
    end
    end

    --[[if rightTrigger == Input.state.Down then
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
        notMovingnotLooking = false
        if currentUpAnim ~= aim and bolterScript.shootAnimation == false and shotGunScript.shootAnimation == false and swordScript.slasheeed == false and isHitted == false and healAnimationBool == false and shotGunScript.is_reloading == false and bolterScript.reloadAnimation == false then
            currentUpAnim = aim
            animator:set_upper_animation(currentUpAnim)
            aimAnimation = true
        end
        lastValidRotation = math.atan(rotationDirectionX, rotationDirectionY)
        angleRotation = lastValidRotation
        playerTransf.rotation.y = math.deg(lastValidRotation)  
        isAiming = true
    elseif moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        notMovingnotLooking = false
        if currentAnim ~= -1 and aimAnimation == true then
            currentAnim = -1
        end
        aimAnimation = false
        lastValidRotation = math.atan(moveDirection.x, moveDirection.z)
        angleRotation = lastValidRotation
        playerTransf.rotation.y = math.deg(lastValidRotation)
    else
        notMovingnotLooking = true
        if currentAnim ~= -1 and aimAnimation == true then
            currentAnim = -1
        end
        aimAnimation = false
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

    return rayHit and rayHit.hasHit and rayHit.hitEntity and rayHit.hitEntity:is_valid() and (rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange1" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange2" 
    or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRang3" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange4" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange5" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange6" 
    or rayHit.hitEntity:get_component("TagComponent").tag == "EnemySupport" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyTank" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyTank1" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyTank2" 
    or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyRange5" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyTank3" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyTank4" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyTank5" 
    or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyTank6" or rayHit.hitEntity:get_component("TagComponent").tag == "EnemyKamikaze" or rayHit.hitEntity:get_component("TagComponent").tag == "MainBoss")

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

    local pos = playerTransf.position
    local origin = Vector3.new(pos.x, pos.y, pos.z)

    origin.y = 0.5
    local maxDistance = 12.0

    if godMode then
        Physics.DebugDrawRaycast(origin, direction, maxDistance, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
        Physics.DebugDrawRaycast(origin, intermediateLeftDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1)) 
        Physics.DebugDrawRaycast(origin, leftDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
        Physics.DebugDrawRaycast(origin, intermediateRightDirection, maxDistance, Vector4.new(0, 1, 0, 1), Vector4.new(1, 1, 0, 1))
        Physics.DebugDrawRaycast(origin, rightDirection, maxDistance, Vector4.new(1, 1, 0, 1), Vector4.new(0, 1, 1, 1))
    end

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
    if health <= 0 then
        if currentAnim ~= die and deathAnimationSetted == false then
            currentAnim = die
            animator:set_current_animation(currentAnim)
            deathAnimationSetted = true
            playerRb:set_velocity(Vector3.new(0, 0, 0))
            playerDeathSFX:play()
            changeing = true
            fadeToBlackScript:DoFade()
        end
        health = 0
        playerTransf.rotation.y = math.deg(angleRotation)
        deathTimeCounter = deathTimeCounter + dt
        if deathTimeCounter >= deathAnimationTime and sceneChanged == false then
            sceneChanged = true
            
            
        end
    end
end

function handleBleed(dt)

    if isBleeding then
        health = effect:bleed(playerScript, health, dt)
    end

end
--[[
function find_scrap()
    --local entities = current_scene:get_all_entities()
    --tuplaScrap = { {}, {} }
    --local entities = current_scene:get_all_entities()


    amountOfScrap = 0


    scrapObjects = {}
    local amount = 0
    for _, entity in ipairs(entities) do
        local entitiname = entity:get_component("TagComponent").tag
        
        if entitiname == "Scrap" then
            amount = amount + 1
            playerPos = playerTransf.position

            local transform = entity:get_component("TransformComponent")
            local cercania = Vector3.new(
            math.abs(playerPos.x - transform.position.x),
            math.abs(playerPos.y - transform.position.y),
            math.abs(playerPos.z - transform.position.z)
            )
            
            if cercania.x < 200 and cercania.y < 200 and cercania.z < 200 then
                


            

            table.insert(scrapObjects, entity:get_component("TransformComponent"))

            
            amountOfScrap = amountOfScrap + 1
            end
        end
        
        
        
    end
    if amountOfScrap == 0 then
        attractionActive = false

    end
    

    
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
            scrapCounter = scrapCounter + 37
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
        
    
    end 
end
]]
function handleCover()
    if sceneName ~= "level3.TeaScene" then
        if barricadeScript.isPlayerInRange == false then
            isCovering = false
            moveSpeed = normalSpeed * speedDebuf
            return
        end
        if Input.get_button(Input.action.Cover) == Input.state.Down then
            isCovering = not isCovering
            --print("isCovering", isCovering)
        end

        if isCovering then
            moveSpeed = 4 * speedDebuf
        else
            moveSpeed = normalSpeed * speedDebuf
        end
    end
end

function HealPlayer()

    if timesHealed <= 0 then playerInyectorSFX:play() end

    timesHealed = timesHealed + 1
    local healAmount = (maxHealth * 0.35) / 5
    health = health + healAmount
    

    if health > maxHealth then
        health = maxHealth
    end

    if timesHealed >= 5 then
        
      isHealing = false
      timesHealed = 0
      damageReduction = 1
    end
end

function saveProgress()
    saveUpgrades()

    health = maxHealth
    zonePlayer = zonePlayer + 1
    save_progress("zonePlayer", zonePlayer)
    save_progress("scrap", scrapCounter)
    save_progress("health", health)
    save_progress("stims", StimsCounter)
end

function saveUpgrades()
    UpgradeManager:save_upgrades()
end

function takeHit()
    currentAnim = hit
    isHitted = true

end

function updateAnims(dt)
    if isHitted then
        for i, component in ipairs(playerMatsComponents) do 
            component.material = playerMatsDamages[i]
        end
        
        hitAnimationCounter = hitAnimationCounter + dt
        if hitAnimationCounter < hitAnimationTime then
            if currentUpAnim ~= hit and swordScript.slasheeed == false and bolterScript.shootAnimation == false and shotGunScript.shootAnimation == false then
                currentUpAnim = hit
                animator:set_upper_animation(currentUpAnim)
                
            end
            
            
        else
            isHitted = false
        end
    else
        hitAnimationCounter = 0
        for i, component in ipairs(playerMatsComponents) do 
            component.material = playerMatsOriginals[i]
        end
    end


end

function check_effects(dt)
    
    if isNeuralInhibitioning then
        if neuralFirstTime then
            local speedVecs = effect:ApplyNeuralChanges(speedDebuf, 0)
            speedDebuf = speedVecs.x       
            neuralFirstTime = false
        end
        neuralInParticle.position = Vector3.new(playerTransf.position.x, 2.5, playerTransf.position.z)
        isNeuralInhibitioning = effect:neural(dt)
        
    else
        
        if not neuralFirstTime then
            neuralInParticle.position = Vector3.new(-34, 3, -3)
            speedDebuf = 1
        end
        neuralFirstTime = true
    end

    if isStunned then
        isStunned = effect:ManageStun(dt)
    end

end

function update_combat_state(dt)
    if isHitted or makeDamage then
        combatTimer = 5.0
        --isHitted = false
        makeDamage = false
    else
        if combatTimer > 0 then
            combatTimer = combatTimer - dt
        end
    end

    if combatTimer <= 0 then
        normalSpeed = 7.5
    else
        normalSpeed = 5
    end
end

function applyStunn()
    effect:ApplyStun()
    playerRb:set_velocity(Vector3.new(0, 0, 0))
    isStunned = true

    if currentAnim ~= stun then
        currentAnim = stun
        currentUpAnim = stun
        animator:set_current_animation(currentAnim)
    end

end
function updateScrapList()
    
    entities = current_scene:get_all_entities()

end
