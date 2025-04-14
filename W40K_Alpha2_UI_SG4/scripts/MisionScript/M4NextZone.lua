local mission4RigidBodyComponent = nil
local mission4RigidBody = nil

m4_Clear = false
function on_ready()
     --Mission
     mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")

    mission4RigidBodyComponent = self:get_component("RigidbodyComponent")
    mission4RigidBody = mission4RigidBodyComponent.rb
    mission4RigidBody:set_trigger(true)
    mission4RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
        m4_Clear =true

        mission_Component.m5_Upgrade = true
        mission_Component.m6_heal = true
        print("dddddd")
        --print("player in zone")
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
