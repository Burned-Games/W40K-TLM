local colliderComponent = nil
local collider = nil
local changeScene = false

local fadeToBlackScript = nil
local changeing = false
local changed = false

function on_ready()


    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")

    colliderComponent = self:get_component("RigidbodyComponent")
    collider = colliderComponent.rb
    collider:set_trigger(true)

    colliderComponent:on_collision_enter(function(entityA, entityB)                
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
       
        if (nameA == "Player" or nameB == "Player") and not changeing then
            save_progress("level", 3)
            fadeToBlackScript:DoFade()
            changeing = true
            mission_Component.mr2_Check = true
        end
    end)
    
end

function on_update(dt)
    -- Add update code here

    if(changeing)then
        if fadeToBlackScript.fadeToBlackDoned then
            changeScene = true
        end
    end


    if changeScene == true and not changed then
        SceneManager.change_scene("scenes/level3.TeaScene")
        changed = true
    end
end

function on_exit()
    -- Add cleanup code here
end
