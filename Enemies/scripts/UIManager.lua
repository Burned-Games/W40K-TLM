


local ammoTextComponent
local lifeTextComponent
local playerScript


function on_ready()
    -- Add initialization code here
    ammoTextComponent = current_scene:get_entity_by_name("actual_ammo"):get_component("UITextComponent")
    lifeTextComponent = current_scene:get_entity_by_name("vida"):get_component("UITextComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
end

function on_update(dt)
    -- Add update code here
    ammoTextComponent:set_text(tostring(playerScript.maxAmmo - playerScript.ammo))

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
