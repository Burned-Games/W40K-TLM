local popupScriptComponent = nil
local popupExampleRigidBodyComponent = nil
local popupExampleRigidBody = nil

local detect = false
local first = true

-- Initialization
function on_ready()
    --Get PopupManager(not modify)
    popupScriptComponent = current_scene:get_entity_by_name("PopUpManager"):get_component("ScriptComponent")

    --Here is collider, if u want u can change name (popup Example RigidBody Component to u want)
    popupExampleRigidBodyComponent = self:get_component("RigidbodyComponent")
    popupExampleRigidBody = popupExampleRigidBodyComponent.rb
    popupExampleRigidBody:set_trigger(true)
    popupExampleRigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
        --call popup
        --show_popup if u wanna show new zone use "False"
        --show_popup if u wanna show Boss use "True"
        --And text u wanna show
       
        detect = true
    else
        detect =false
    end
    end)

end

-- Call this to show the popup

function on_update(dt)
    -- Add update code here

    if detect and first then
        popupScriptComponent.show_popup(false,"[Y] to change weapon")
        first = false
    end
end

function on_exit()
    -- Add cleanup code here
end

