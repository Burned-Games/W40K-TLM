local mission9RigidBodyComponent = nil
local mission9RigidBody = nil


m9_Clear = false
m9_IndicateTable = false
function on_ready()
    mission9RigidBodyComponent = self:get_component("RigidbodyComponent")
    mission9RigidBody = mission9RigidBodyComponent.rb
    mission9RigidBody:set_trigger(true)
    mission9RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
       local nameA = entityA:get_component("TagComponent").tag
       local nameB = entityB:get_component("TagComponent").tag
      
    if nameA == "Player" or nameB == "Player" then
        m9_Clear = true
    end
    end)
    -- Add initialization code here
end

function on_update(dt)
    -- Add update code here
    if Input.is_key_pressed(Input.keycode.L) then
        m9_IndicateTable = true
    end
end

function on_exit()
    -- Add cleanup code here
end
