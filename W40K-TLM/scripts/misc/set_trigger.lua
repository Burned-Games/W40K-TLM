function on_ready()
    -- Add initialization code here
    local rigidBody = self:get_component("RigidbodyComponent").rb

    rigidBody:set_trigger(true)

end

function on_update(dt) end

function on_exit() end
