local mission8RigidBodyComponent = nil
local mission8RigidBody = nil

m8_Clear = false
m10_missionOpen = false
function on_ready()
    mission8RigidBodyComponent = self:get_component("RigidbodyComponent")
    mission8RigidBody = mission8RigidBodyComponent.rb
    mission8RigidBody:set_trigger(true)
    mission8RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
      
    if nameA == "Player" or nameB == "Player" then
        m8_Clear = true
        m10_missionOpen = true
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
