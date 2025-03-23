


local ammoTextComponent
local lifeTextComponent
local playerScript
local bolterScript = nil
local shotGunScript = nil

function on_ready()
    -- Add initialization code here
    ammoTextComponent = current_scene:get_entity_by_name("actual_ammo"):get_component("UITextComponent")
    lifeTextComponent = current_scene:get_entity_by_name("vida"):get_component("UITextComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    bolterScript = current_scene:get_entity_by_name("Bolter"):get_component("ScriptComponent")
    shotGunScript = current_scene:get_entity_by_name("Shotgun_low"):get_component("ScriptComponent")
end

function on_update(dt)
    -- Add update code here
    if bolterScript.using == true then
        ammoTextComponent:set_text(tostring(bolterScript.maxAmmo - bolterScript.ammo))
    elseif shotGunScript.using == true then
        ammoTextComponent:set_text(tostring(shotGunScript.ammo))
    end
    

    local playerHealth = playerScript.playerHealth

    if playerHealth >= 0 then
        lifeTextComponent:set_text(tostring(playerHealth))
    else
        lifeTextComponent:set_text(tostring(0))
    end

    
end

function on_exit()
    -- Add cleanup code here
end
