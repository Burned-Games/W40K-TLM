local dialogoScriptComponent = nil
local RigidBodyComponent = nil
local RigidBody = nil

local detect = false
local first = true

-- Initialization
function on_ready()
    dialogoScriptComponent = current_scene:get_entity_by_name("Dialogo_Level3System"):get_component("ScriptComponent")

    --Here is collider, if u want u can change name (popup Example RigidBody Component to u want)
    RigidBodyComponent = self:get_component("RigidbodyComponent")
    RigidBody = RigidBodyComponent.rb
    RigidBody:set_trigger(true)
    RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
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
        dialogoScriptComponent.dialogChange = true
        first = false
    end
end

function on_exit()
    -- Add cleanup code here
end

