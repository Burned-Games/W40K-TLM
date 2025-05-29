local popupScriptComponent = nil
local popupRigidBodyComponent = nil
local popupRigidBody = nil
local mission_Component = nil

local detect = false
local first = true

local current_scene_name = nil
local current_scene_tag = nil


--Special 
local isPersistentActive = false
local closUpdate = true
local SpecialText_1 = "(x/1)"
local SpecialText_2 = "(x/2)"
local SpecialText_3 = "(x/1)"



-- Initialization
function on_ready()
    --Get PopupManager(not modify)
    popupScriptComponent = current_scene:get_entity_by_name("PopUpManager"):get_component("ScriptComponent")
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    --Here is collider, if u want u can change name (popup Example RigidBody Component to u want)
    popupRigidBodyComponent = self:get_component("RigidbodyComponent")
    popupRigidBody = popupRigidBodyComponent.rb
    popupRigidBody:set_trigger(true)
    popupRigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
        detect = true
    else
        detect =false
    end
    end)

    current_scene_name = SceneManager:get_scene_name()
    current_scene_tag = self:get_component("TagComponent").tag
    first = true
    detect = false
    
end

-- Call this to show the popup

function on_update(dt)
    -- Add update code here

    if current_scene_name == "level1.TeaScene" then
        if detect and first and current_scene_tag == "PopUp_1" then
            print("Level 1")
            popupScriptComponent.show_popup(false,"[Y] to change weapon")
            first = false
        end

        if detect and first and current_scene_tag == "PopUp_2" then
            print("Level 1")
            popupScriptComponent.show_popup(false,"[RT] to break some objects")
            first = false
        end

        if detect and first and current_scene_tag == "PopUp_3" then
            popupScriptComponent.show_popup(false,"[A] to interact")
            first = false
        end

        if detect and first and current_scene_tag == "PopUp_4" then
            popupScriptComponent.show_popup(false,"[B] to dash")
            first = false
        end

        if detect and first and current_scene_tag == "PopUp_5" then
            popupScriptComponent.show_popup(false,"[RB] to use chainsword")
            first = false
        end

        if detect and first and current_scene_tag == "PopUp_6" then
            popupScriptComponent.show_popup(false,"[DPAD_RIGHT] to heal yourself")
            first = false
        end

        if detect and first and current_scene_tag == "PopUp_7" then
            popupScriptComponent.show_popup(false,"New enemy incoming")
            first = false
        end



        if current_scene_tag == "PopUp_SP_1" then
            local description = string.gsub(SpecialText_1, "x", tostring(mission_Component.m3_EnemyCount))
            if detect and first then
                popupScriptComponent.show_popup(false, description, true)
                first = false
                isPersistentActive = true
            end
            
            if isPersistentActive and closUpdate then
                popupScriptComponent.update_persistent_popup_text(description)
                if mission_Component.m3_EnemyCount >= 2 then
                    closUpdate = false
                end
            end
        end


        --Special 
        if current_scene_tag == "PopUp_SP_2" then
            local description = string.gsub(SpecialText_2, "x", tostring(mission_Component.m8_lever))
           if detect and first then
                popupScriptComponent.show_popup(false, description, true)
                first = false
                isPersistentActive = true
            end

            if isPersistentActive and closUpdate then
                popupScriptComponent.update_persistent_popup_text(description)
                if mission_Component.m8_lever >= 2 then
                    closUpdate = false
                end
            end
        end

        if current_scene_tag == "PopUp_SP_3" then
            -- local description = string.gsub(SpecialText_3, "x", tostring(mission_Component.m9_EnemyCount))
            -- if detect and first then
            --     popupScriptComponent.show_popup(false, description, true)
            --     first = false
            --     isPersistentActive = true
            -- end

            -- if isPersistentActive and closUpdate then
            --     popupScriptComponent.update_persistent_popup_text(description)
            --     --if mission_Component.m9_EnemyCount >= 2 then
            --         --closUpdate = false
            --     --end
            -- end
        end



    elseif current_scene_name == "level2.TeaScene" then
        --print("Level 2")
       
    elseif current_scene_name == "level3.TeaScene" then
        --print("Level 3")
    end

        


    
end

function on_exit()
    -- Add cleanup code here
end

