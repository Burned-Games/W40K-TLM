local Player = nil
local UpgradeManager = nil

local combatTimer = 0
local protectionTimer = 0
local protectionActive = false

function on_ready()
    Player = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
end

function on_update(dt)
    update_combat_state(dt)
    update_protection(dt)
end

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

