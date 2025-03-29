local mission6RigidBodyComponent = nil
local mission6RigidBody = nil

m6_Clear = false
m7_missionOpen = false
function on_ready()
    mission6RigidBodyComponent = self:get_component("RigidbodyComponent")
    mission6RigidBody = mission6RigidBodyComponent.rb
    mission6RigidBody:set_trigger(true)
    mission6RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
        m6_Clear =true
        m7_missionOpen = true
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
