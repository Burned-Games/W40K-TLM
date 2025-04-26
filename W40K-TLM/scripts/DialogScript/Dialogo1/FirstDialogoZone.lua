dialogLines = {
    { name = "Radio", text = "Soldier? Are you alive? If so, you're on a very important mission." },
    { name = "Radio", text = "Do you see those orkz? They colonized this planet, go finish this two." }
}


local mission4RigidBodyComponent = nil
local mission4RigidBody = nil
dialogScriptComponent = nil

m4_Clear = false
function on_ready()
     --Mission
   dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
   popupScriptComponent = current_scene:get_entity_by_name("PopUpManager"):get_component("ScriptComponent")

    mission4RigidBodyComponent = self:get_component("RigidbodyComponent")
    mission4RigidBody = mission4RigidBodyComponent.rb
    mission4RigidBody:set_trigger(true)
    mission4RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
        m4_Clear =true

        dialogScriptComponent.start_dialog(dialogLines)
        popupScriptComponent.show_popup(false, "QUEST STARTING")

    end
    end)
    -- Add initialization code here
end

function on_update(dt)
    -- Add update code here
end

function on_exit()
    -- Add cleanup code here
end
