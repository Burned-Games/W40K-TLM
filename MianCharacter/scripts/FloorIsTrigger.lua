
local rigidBodyComponent

function on_ready()
    -- Add initialization code here
    rigidBodyComponent = self:get_component("RigidbodyComponent")
    rigidBodyComponent.rb:set_trigger(true)
end

function on_update(dt)
    -- Add update code here
end

function on_exit()
    -- Add cleanup code here
end
