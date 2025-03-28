local mission4RigidBodyComponent = nil
local mission4RigidBody = nil

mission4Clear = false
function on_ready()
    mission4RigidBodyComponent = self:get_component("RigidbodyComponent")
    mission4RigidBody = mission4RigidBodyComponent.rb
    mission4RigidBody:set_trigger(true)
    mission4RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
        mission4Clear =true
        print("player in zone")
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
