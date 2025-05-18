local Player = nil
local UpgradeManager = nil

local protectionTimer = 0
local protectionActive = false

fervorAstartesCooldown = 0
fervorAstartesAvailable = true
local fervorAstartesDuration = 10
local fervorAstartesTimer = 0
local fervorAstartesActive = false
local fervorAstartesStandardPlaced = false
local fervorAstartesStandardEntity = nil
local fervorAstartesRadius = 6.0
local fervorAniamtor = nil

local attackSpeedBonus = 1.2 
local reloadSpeedBonus = 1.15

local pauseMenu = nil

local hudManager = nil
local workbenchUIManager = nil
isPlayerInRadius = false 

--Audio
local bannerFallSFX = nil
local bannerZoneSFX = nil
local bannerZoneTrans = nil

function on_ready()
    Player = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    fervorAstartesStandardEntity = current_scene:get_entity_by_name("FervorAstartesStandard")
    pauseMenu = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")
    fervorAniamtor = fervorAstartesStandardEntity:get_component("AnimatorComponent")
    hudManager = current_scene:get_entity_by_name("HUD"):get_component("ScriptComponent")
    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")

    --Audio
    bannerFallSFX = current_scene:get_entity_by_name("BannerFallSFX"):get_component("AudioSourceComponent")
    bannerZoneSFX = current_scene:get_entity_by_name("BannerZoneSFX"):get_component("AudioSourceComponent")
    bannerZoneTrans = current_scene:get_entity_by_name("BannerZoneSFX"):get_component("TransformComponent")

end

function on_update(dt)
    if not pauseMenu.isPaused and not workbenchUIManagerScript.isWorkBenchOpen then
        update_protection(dt)
        handle_fervor_astartes(dt)
    end
    
    if isPlayerInRadius then
        hudManager.recargaEntity:set_active(true)
        hudManager.velocidadAtaqueEntity:set_active(true)
    else
        hudManager.recargaEntity:set_active(false)
        hudManager.velocidadAtaqueEntity:set_active(false)
    end
end

-- Function to update the protection state of the player
function update_protection(dt)
    if not UpgradeManager.upgrades.armor.protection then
        hudManager.proteccionEntity:set_active(false)
        return
    else
        hudManager.proteccionEntity:set_active(true)

    end

    if Player.combatTimer <= 0 then
        if not protectionActive then
            protectionActive = true
            Player.damageReduction = 0.9
        end
    else
        protectionTimer = protectionTimer + dt
        
        if protectionTimer >= 3.0 then
            protectionActive = false
            Player.damageReduction = 1.0
        end
    end
    
    if Player.combatTimer <= 0 then
        protectionTimer = 0
    end
end

-- Function to handle the Fervor Astartes ability
function handle_fervor_astartes(dt)
    if not UpgradeManager.upgrades.armor.specialAbility then
        return
    end

    local playerPosition = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    local standardTransform = current_scene:get_entity_by_name("FervorAstartesStandard"):get_component("TransformComponent")

    if fervorAstartesCooldown > 0 then
        fervorAstartesCooldown = fervorAstartesCooldown - dt
        fervorAstartesAvailable = false
    end
    
    if fervorAstartesCooldown <= 0 and not fervorAstartesAvailable then
        fervorAstartesAvailable = true
    end

    if Input.get_button(Input.action.Skill3) == Input.state.Down and fervorAstartesAvailable and not fervorAstartesStandardPlaced or Input.is_key_pressed(Input.keycode.Y) and fervorAstartesAvailable and not fervorAstartesStandardPlaced then
        place_fervor_astartes_standard(playerPosition, standardTransform)
    end
    
    if fervorAstartesActive then
        fervorAstartesTimer = fervorAstartesTimer + dt

        if fervorAstartesTimer >= fervorAstartesDuration then
            end_fervor_astartes(standardTransform)
        else
            local playerPos = playerPosition.position
            local standardPos = standardTransform.position

            local distance = math.sqrt(
                (playerPos.x - standardPos.x) ^ 2 +
                (playerPos.y - standardPos.y) ^ 2 +
                (playerPos.z - standardPos.z) ^ 2
            )
            
            local wasInRadius = isPlayerInRadius
            isPlayerInRadius = distance <= fervorAstartesRadius
        end
    end
end

-- Function to place the Fervor Astartes standard
function place_fervor_astartes_standard(playerPosition, standardTransform)
    if fervorAstartesStandardEntity then
        fervorAniamtor:set_current_animation(0)  

        local posicion = Vector3.new(playerPosition.position.x, playerPosition.position.y, playerPosition.position.z)
        standardTransform.position = posicion
        
        bannerZoneTrans.position = posicion
        bannerFallSFX:play()
        bannerZoneSFX:play()

        fervorAstartesStandardPlaced = true
        fervorAstartesActive = true
        fervorAstartesTimer = 0
        
        fervorAstartesCooldown = 25
        fervorAstartesAvailable = false
        
        isPlayerInRadius = false
        
        hudManager.recargaEntity:set_active(false)
        hudManager.velocidadAtaqueEntity:set_active(false)
    end
end 

-- Function to end the Fervor Astartes ability
function end_fervor_astartes(standardTransform)
    fervorAstartesActive = false
    fervorAstartesStandardPlaced = false
    fervorAstartesTimer = 0

    bannerZoneSFX:pause()

    local endingPosition = Vector3.new(0, -100, 0)
    standardTransform.position = endingPosition

    fervorAniamtor:set_current_animation(1)
       
    isPlayerInRadius = false
    hudManager.recargaEntity:set_active(false)
    hudManager.velocidadAtaqueEntity:set_active(false)
end

function on_exit()
    bannerZoneSFX:pause()
end