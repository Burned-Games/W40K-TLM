local Player = nil
local UpgradeManager = nil

local combatTimer = 0
local protectionTimer = 0
local protectionActive = false

fervorAstartesCooldown = 0
local fervorAstartesDuration = 10
local fervorAstartesTimer = 0
local fervorAstartesActive = false
local fervorAstartesStandardPlaced = false
local fervorAstartesStandardEntity = nil
local fervorAstartesRadius = 6.0

local attackSpeedBonus = 1.2 
local reloadSpeedBonus = 1.15

function on_ready()
    Player = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    fervorAstartesStandardEntity = current_scene:get_entity_by_name("FervorAstartesStandard")
end

function on_update(dt)

    update_combat_state(dt)
    update_protection(dt)
    handle_fervor_astartes(dt)
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

    if not fervorAstartesActive and fervorAstartesCooldown > 0 then
        fervorAstartesCooldown = fervorAstartesCooldown - dt
    end

    if Input.get_button(Input.action.Skill3) == Input.state.Down and fervorAstartesCooldown <= 0 and not fervorAstartesStandardPlaced then
        --print("Colocando estandarte")
        place_fervor_astartes_standard(playerPosition, standardTransform)

    end
    -- If the Fervor Astartes ability is active
    if fervorAstartesActive then
        fervorAstartesTimer = fervorAstartesTimer + dt

        if fervorAstartesTimer >= fervorAstartesDuration then
            --print("[Fervor Astartes] Tiempo agotado - Finalizando efecto")
            end_fervor_astartes(standardTransform)
        else

            local playerPos = playerPosition.position
            local standardPos = standardTransform.position

            local distance = math.sqrt(
                (playerPos.x - standardPos.x) ^ 2 +
                (playerPos.y - standardPos.y) ^ 2 +
                (playerPos.z - standardPos.z) ^ 2
            )
            -- If the player is inside the radius of the Fervor Astartes standard
            if distance <= fervorAstartesRadius and fervorAstartesActive then
                if Player.bolterScript then
                    Player.bolterScript:set_attack_speed_multiplier(attackSpeedBonus)
                    Player.bolterScript:set_reload_speed_multiplier(reloadSpeedBonus)
                end

                if Player.shotgunScript then
                    Player.shotgunScript:set_attack_speed_multiplier(attackSpeedBonus)
                    Player.shotgunScript:set_reload_speed_multiplier(reloadSpeedBonus)
                end
            -- If the player is outside the radius of the Fervor Astartes standard
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

        local posicion = Vector3.new(playerPosition.position.x, playerPosition.position.y, playerPosition.position.z)
        standardTransform.position = posicion

        fervorAstartesStandardPlaced = true
        fervorAstartesActive = true
        fervorAstartesTimer = 0
    end
end 

-- Function to end the Fervor Astartes ability
function end_fervor_astartes(standardTransform)
    fervorAstartesActive = false
    fervorAstartesStandardPlaced = false
    fervorAstartesCooldown = 25  
    fervorAstartesTimer = 0

    local endingPosition = Vector3.new(0, -100, 0)
    standardTransform.position = endingPosition
end
