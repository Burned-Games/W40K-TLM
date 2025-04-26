local Player = nil
local UpgradeManager = nil

local combatTimer = 0
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

function on_ready()
    Player = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    fervorAstartesStandardEntity = current_scene:get_entity_by_name("FervorAstartesStandard")
    pauseMenu = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")
    fervorAniamtor = fervorAstartesStandardEntity:get_component("AnimatorComponent")

end

function on_update(dt)
    if not pauseMenu.isPaused then
        update_combat_state(dt)
        update_protection(dt)
        handle_fervor_astartes(dt)
    end
end

-- Function to update the combat state of the player
function update_combat_state(dt)
    if Player.tookDamage or Player.makeDamage then
        combatTimer = 5.0
        Player.tookDamage = false
        Player.makeDamage = false
    else
        if combatTimer > 0 then
            combatTimer = combatTimer - dt
            if combatTimer <= 0 then
                protectionTimer = 0
            end
        end
    end
end

-- Function to update the protection state of the player
function update_protection(dt)
    if not UpgradeManager.upgrades.armor.protection then
        return
    end

    if combatTimer <= 0 then
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
end

-- Function to handle the Fervor Astartes ability
function handle_fervor_astartes(dt)
    if not UpgradeManager.upgrades.armor.specialAbility then
        return
    end

    local playerPosition = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    local standardTransform = current_scene:get_entity_by_name("FervorAstartesStandard"):get_component("TransformComponent")

    -- Reducir el cooldown siempre que sea mayor que 0, independientemente del estado de la habilidad
    if fervorAstartesCooldown > 0 then
        fervorAstartesCooldown = fervorAstartesCooldown - dt
        fervorAstartesAvailable = false
    end
    
    if fervorAstartesCooldown <= 0 and not fervorAstartesAvailable then
        fervorAstartesAvailable = true
    end

    if Input.get_button(Input.action.Skill3) == Input.state.Down and fervorAstartesAvailable and not fervorAstartesStandardPlaced then
        place_fervor_astartes_standard(playerPosition, standardTransform)
    end
    
    -- El resto del código permanece igual
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
            
            if distance <= fervorAstartesRadius and fervorAstartesActive then
                if Player.bolterScript then
                    Player.bolterScript:set_attack_speed_multiplier(attackSpeedBonus)
                    Player.bolterScript:set_reload_speed_multiplier(reloadSpeedBonus)
                end

                if Player.shotgunScript then
                    Player.shotgunScript:set_attack_speed_multiplier(attackSpeedBonus)
                    Player.shotgunScript:set_reload_speed_multiplier(reloadSpeedBonus)
                end
            else
                if Player.bolterScript then
                    Player.bolterScript:set_attack_speed_multiplier(1.0)
                    Player.bolterScript:set_reload_speed_multiplier(1.0)
                end

                if Player.shotgunScript then
                    Player.shotgunScript:set_attack_speed_multiplier(1.0)
                    Player.shotgunScript:set_reload_speed_multiplier(1.0)
                end
            end
        end
    end
end

-- Function to place the Fervor Astartes standard
function place_fervor_astartes_standard(playerPosition, standardTransform)
    if fervorAstartesStandardEntity then
        fervorAniamtor:set_current_animation(0)

        local posicion = Vector3.new(playerPosition.position.x, playerPosition.position.y, playerPosition.position.z)
        standardTransform.position = posicion


        fervorAstartesStandardPlaced = true
        fervorAstartesActive = true
        fervorAstartesTimer = 0
        
        fervorAstartesCooldown = 25
        fervorAstartesAvailable = false
    end
end 

-- Function to end the Fervor Astartes ability
function end_fervor_astartes(standardTransform)
    fervorAstartesActive = false
    fervorAstartesStandardPlaced = false
    fervorAstartesTimer = 0

    local endingPosition = Vector3.new(0, -100, 0)
    standardTransform.position = endingPosition

    fervorAniamtor:set_current_animation(1)
end