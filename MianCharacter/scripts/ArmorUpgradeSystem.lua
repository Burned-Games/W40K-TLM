local Player = nil
local UpgradeManager = nil

local combatTimer = 0
local protectionTimer = 0
local protectionActive = false

function on_ready()
    Player = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    UpgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

    print("ArmorUpgradeSystem initialized")
end

function on_update(dt)
    update_combat_state(dt)
    update_protection(dt)
end

function update_combat_state(dt)
    if Player.tookDamage then
        combatTimer = 5.0
        Player.tookDamage = false
        protectionActive = false
        protectionTimer = 0
        print("Entrando en combate - Timer reset a 5.0")
    else
        if combatTimer > 0 then
            combatTimer = combatTimer - dt
            if combatTimer <= 0 then
                print("Saliendo de combate - Han pasado 5s sin daño")
            end
        end
    end
end

function update_protection(dt)
    if not UpgradeManager.upgrades.armor.protection then
        return
    end
    
    if combatTimer <= 0 and protectionActive==false then
        protectionActive = true
        Player.damageReduction = 0.9
        print("Protección activada - Reducción de daño: 10%")
    end
    if protectionActive==true and combatTimer > 0 then
        protectionTimer = protectionTimer + dt
        
        if protectionTimer >= 3.0 then
            protectionActive = false
            Player.damageReduction = 1.0 
            protectionTimer = 0
            print("Protección desactivada - Han pasado 3s en combate")
        end
    end
end

